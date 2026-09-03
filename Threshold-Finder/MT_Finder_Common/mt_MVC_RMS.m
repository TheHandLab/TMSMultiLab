%% measure MVC
mvc.rms.max = nan(3,1);                                                     % max MVC in each trial
mvc.rms.data = nan(3,100000);                                              % rms value
mvc.raw.data = nan(3,1000000);                                              % raw value (not sure to use rms or raw data in this case)
mvc.duration = 2;                                                           % MVC duration
trial.mvc.current = 1;                                                      % trial control
trial.mvc.maxtrial = 3;                                                     % number of MVC trials

%% show instrctions
mt_present_instruction(win, wsize, ins)                                   % MVC instructions
WaitSecs(1); 
KbWait;

%% trial control
while trial.mvc.current <= trial.mvc.maxtrial                               % test 3 times
    
    %% show instruction (whether participant is ready)
    mt_present_instruction(win, wsize, ready);                              % ready
    WaitSecs(1);
    KbWait;                                                                 % press button
    
    %% fixation cross
    Screen('DrawLines', win, fix.line, 2, [255 255 255]);                   % fixition cross
    Screen('Flip', win);  
    WaitSecs(1);                                                            % one second 
    
    %% instruction (squeeze)
    mt_present_instruction(win, wsize, start);                           

    %% preallocation 
    mvc.rms.record = [];                                                    % buffer for one trial
    mvc.rms.rawrecord = [];                                                 % buffer for one trial
    
     %% get time
    mvc.starttime=GetSecs;                                                  % start timer                                          

    %% squeeze duration
    while GetSecs - mvc.starttime <= mvc.duration                           % 2 seconds
        
        %% PROCESS CALLBACKS
        drawnow;

        %% acquire rms
        [rms] = mt_measure_RMS(emg_asynch_chunk(:,emg.muscle)*ni_gain);   % require rms
        
        % save rms
        mvc.rms.record = [mvc.rms.record; rms.value];
        mvc.rms.rawrecord = [mvc.rms.rawrecord; emg_asynch_chunk(:,emg.muscle)*ni_gain];

    end
    
    %% save mvc
    mvc.raw.index = size(mvc.rms.rawrecord,1);
    mvc.raw.data(trial.mvc.current,1:mvc.raw.index) = mvc.rms.rawrecord;
    mvc.rms.index = size(mvc.rms.record,1);
    mvc.rms.data(trial.mvc.current,1:mvc.rms.index) = mvc.rms.record;
    mvc.rms.max(trial.mvc.current,:) = max(mvc.rms.data(trial.mvc.current,1:mvc.rms.index));  % average

    %% instruction (relax)
    mt_present_instruction(win, wsize, relax);                            % relax
    WaitSecs(1);

    %% show MVC
    mvc.instruction.t1=(['MaxGrip: ',num2str(mvc.rms.max(trial.mvc.current,:),4)]);    % maxgrip value
    mt_present_instruction(win, wsize, mvc.instruction);                  % display maxgrip
    WaitSecs(2);
    
    %% instruction (enourage, show we keep this?)
    mt_present_instruction(win, wsize, enc);                
    WaitSecs(1);

    %% whether accepte current value
    accepted = mt_askAccept();                                            % ask if we accepte  this trial
    
    if accepted 
        trial.mvc.current = trial.mvc.current + 1;                          
    end

end

%% calculate scale
mvc.value = mean(mvc.rms.max,1);                                        % value of MVC

%% MVC settings

switch version.mt           
    case 'Active' 
        display.target.mode = 'Above';                                      % subject have to keep muscle activity above the target                                                
        display.gain = 0.5;                                                 % target position (always in the middle)
        display.MVC = mvc.value*str2double(settings.MVC).*0.01 * 2 ;        % Set the display range to twice the target force so that the target
                                                                            % is always shown in the middle of the display
    case 'Rest' 
        display.target.mode = 'Below';                                      % subject maintain rest                                                          
        display.gain = emg.rms.max ./ mvc.value;                            % define the resting threshold as a proportion of MVC                   
        display.MVC = mvc.value;
end







