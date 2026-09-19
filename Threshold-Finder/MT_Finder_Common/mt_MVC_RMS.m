%% MEASURE MVC______________________________________________________________

%% SET UP VARIABLES_________________________________________________________
mvc.rms.max = nan(3,1);                                                     % mV, max MVC in each of three trials
mvc.rms.data = nan(3,100000);                                               % mV, rms value
mvc.raw.data = nan(3,1000000);                                              % mV, raw value (not sure to use rms or raw data in this case)
mvc.duration = 2;                                                           % s, MVC duration
trial.mvc.current = 1;                                                      % trial control *** change to zero - so only accepted trials are counted ***
trial.mvc.maxtrial = 3;                                                     % number of MVC trials *** move to start and use as variable for size of mvc variables ***


%% SHOW INSTRUCTIONS________________________________________________________
mt_present_instruction(win, wsize, ins)                                     % MVC instructions *** ins is not clear ***
WaitSecs(1); 
KbWait;


%% TRIAL CONTROL LOOP_______________________________________________________
while trial.mvc.current <= trial.mvc.maxtrial                               % test 3 times *** change to < ***
    
    % show ready instruction (whether participant is ready)
    mt_present_instruction(win, wsize, ready);                              % ready
    WaitSecs(1);
    KbWait;                                                                 % press button
    
    
    % fixation cross
    Screen('DrawLines', win, fix.line, 2, [255 255 255]);                   % fixition cross
    Screen('Flip', win);  
    WaitSecs(1);                                                            % one second 
    
    % instruction (squeeze)
    mt_present_instruction(win, wsize, start);                           

    % initialise data variables
    mvc.rms.record = [];                                                    % buffer for one trial
    mvc.rms.rawrecord = [];                                                 % buffer for one trial
    
    % get start time
    mvc.starttime=GetSecs;                                                  % start timer                                          


    %% TIME THE MVC DURATION________________________________________________
    while GetSecs - mvc.starttime <= mvc.duration                           % 2 seconds *** change to <
        
        drawnow;                                                            % PROCESS CALLBACKS

        [rms] = mt_measure_RMS(emg_asynch_chunk(:,emg.muscle)*ni_gain);     % MEASURE RMS
        
        mvc.rms.record = [mvc.rms.record; rms.value];                       % SAVE RMS
        mvc.rms.rawrecord = [mvc.rms.rawrecord; emg_asynch_chunk(:,emg.muscle).*ni_gain];

    end
    
    
    %% SAVE MVC DATA________________________________________________________
    mvc.raw.index = size(mvc.rms.rawrecord,1);
    mvc.raw.data(trial.mvc.current, 1:mvc.raw.index) = mvc.rms.rawrecord;
    mvc.rms.index = size(mvc.rms.record, 1);
    mvc.rms.data(trial.mvc.current, 1:mvc.rms.index) = mvc.rms.record;
    mvc.rms.max(trial.mvc.current, :) = max(mvc.rms.data(trial.mvc.current, 1:mvc.rms.index));% maximum


    %% PRESENT INSTRUCTIONS TO RELAX________________________________________
    mt_present_instruction(win, wsize, relax);                              % relax
    WaitSecs(1);


    %% SHOW MVC ON SCREEN___________________________________________________
    mvc.instruction.t1 = (['Max Contraction: ',num2str(mvc.rms.max(trial.mvc.current, :), 4)]);% build maximum contraction text
    mt_present_instruction(win, wsize, mvc.instruction);                    % display text
    WaitSecs(2);
    
    
    %% SHOW FEEDBACK (enourage, show we keep this?)_________________________
    mt_present_instruction(win, wsize, enc);                
    WaitSecs(1);


    %% ACCEPT CURRENT MVC VALUE?____________________________________________
    accepted = mt_askAccept();                                              % ask if we accepte  this trial
    if accepted 
        trial.mvc.current = trial.mvc.current + 1;                          % increment accepted trial counter
    end

end


%% CALCULATE AVERAGE________________________________________________________
mvc.value = mean(mvc.rms.max, 1);                                           % value of MVC


%% MVC DISPLAY SETTINGS_____________________________________________________ *** this should be somewhere else, not in the measure MVC script ***
switch version.mt           

    case 'Active'
        display.target.mode = 'Above';                                      % subject have to keep muscle activity above the target
        display.gain = 0.5;                                                 % target position (always in the middle)
        display.MVC = mvc.value .* str2double(settings.MVC) .* 0.01 .* 2;   % set display range to 2x target so target always shown in middle of display
									    % *** what is the 0.01 doing?
	
    case 'Rest' 
        display.target.mode = 'Below';                                      % subject maintain rest                                                          
        display.gain = emg.rms.max ./ mvc.value;                            % define the resting threshold as a proportion of MVC                   
        display.MVC = mvc.value;
	
end