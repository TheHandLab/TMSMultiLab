%% 4 target of MVC proportion (to find the amplitude of active muscle)

mvc.inwindow.tolerate = 5;                                                  % how long participant hold on the target
mvc.criterion.trials = 4;                                                   % target number
mvc.gain = [0.1,0.2,0.3,0.4];                                               % taget proportion
mvc.criterion.rms.data = [];                                                % buffer for each trial
mvc.raw.data = nan(mvc.criterion.trials,30*s_asynch.Rate);                  % give participant 30s, not sure what we should do if they can not hold it for 30 seconds
mvc.inwindow.start = nan(mvc.criterion.trials,1);                           % when did participant first above the target
mvc.index.finish = nan(mvc.criterion.trials,1);                             % when did participant finish the trial                         


%% instructions
mtfr_present_instruction(win, wsize, mvc.criterion.instrustion);            % instructions
WaitSecs(1);
KbWait;


%% CLEAN BUFFER AND REOPEN S_ASYNCH
stop(s_asynch);                                                             % STOP ASYNCH
emg_asynch_data = [];                                                       % CLEAN BUFFER
emg_asynch_time = [];                                                       % CLEAN BUFFER
s_asynch.startBackground();                                                 % START ASYNCH
mvc.record.time = GetSecs;                                                  % start time

%% 4 trials with different percentage of MVC
next_percentage = 1;

while next_percentage <= mvc.criterion.trials                              
   
    mvc.display.gain = mvc.gain(next_percentage);                           % MVC proportion
    current_gain = true;                                                    % loop control 
    mvc.startin = 0;                                                        % in target control            

    while current_gain
        
        %% connect to the callback
        drawnow;

        %% MEASURE RMS
        [RMS.mvc] = rmtf_measure_RMS(emg_asynch_chunk(:,emg.muscle) * ni_gain); % MEASURE RMS FOR EACH CHUNK OF DATA
        mvc.criterion.rms.data = [mvc.criterion.rms.data; RMS.mvc.value];
        
        %% DISPLAT REAL-TIME FEEDBACK
        if size(mvc.criterion.rms.data,1) > emg.filter.size
            [rms.filter,bar,target,mvc.display] = mtfr_display_bar(mvc.value, ...
                baseline.value,mvc.criterion.rms.data(end-emg.filter.size+1:end), ...
                win,wsize,mvc.display);
            
            %% filp window
            Screen('Flip',win);


            %% TIME DURATION WHEN FORCE IS IN THE TARGET RANGE
            clock = GetSecs;

            if target.inwindow.count
                %% start timer when rms is the first time in the target window
                if mvc.startin == 0                                             % if this is the first frame inside window
                    mvc.startin = clock;                                        % record start time
                end


                %% duration in the target window
                mvc.timeinwindow = clock - mvc.startin;                         % duration in the target window


                %% PARTICIPANT KEEP LONGER ENOUGH IN TARGET WINDOW
                if mvc.timeinwindow > mvc.inwindow.tolerate 
                    current_gain = false;                                    % MOVE TO NEXT PROPORTION
                    mvc.index.finish(next_percentage) = size(emg_asynch_data(:,emg.muscle),1); % FINISH INDEX
                    mvc.raw.data(next_percentage,1:mvc.index.finish(next_percentage)) = emg_asynch_data(:,emg.muscle); % EMG DATA
                    mvc.inwindow.start(next_percentage) = (mvc.startin - mvc.record.time) * 1000;  % in ms
                    next_percentage = next_percentage + 1;                  
                    mvc.criterion.data = [];
                end

            else 

                mvc.startin = 0;                                            % if force out of the target window, recount 

            end
        end

    end
    
    Screen('DrawLines', win, fix.line, 2, [255 255 255]);                   % fixition cross
    Screen('Flip', win);                                                    % flip window
    WaitSecs(3);

    %% CLEAN BUFFER AND REOPEN S_ASYNCH
    stop(s_asynch);                                                         % STOP ASYNCH
    emg_asynch_data = [];                                                   % CLEAN BUFFER
    emg_asynch_time = [];                                                   % CLEAN BUFFER
    s_asynch.startBackground();                                             % START ASYNCH
    mvc.record.time = GetSecs;                                              % TIME UPDATE

end