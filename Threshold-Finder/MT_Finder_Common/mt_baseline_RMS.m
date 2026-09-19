%% MEASURE BASELINE EMG ACTIVITY WHEN PARTICIPANT IS RELAXED________________

%% INITIALISE TRIAL_________________________________________________________
trial.baseline = 1;							    % *** change to false ***
baseline.mean = [];
baseline.duration = 2;                                                      % seconds


%% TRIAL CONTROL LOOP_______________________________________________________
while trial.baseline <= 1                                                   % *** change to while false ***

    mt_present_instruction(win, wsize, relax);                              % show instructions: relax hand, record initialgrip
    
    baseline.starttime = GetSecs;					    % get timer start time
    
    
    %% RECORD BASELINE EMG FOR TWO SECONDS__________________________________
    while GetSecs - baseline.starttime <= baseline.duration
        
        drawnow;                                                            % PROCESS CALLBACKS

        [rms.baseline] = mt_measure_RMS(emg_asynch_chunk(:, emg.muscle).*ni_gain);% MEASURE RMS
										% *** change to measure EMG, and extract multiple parameters ***

        baseline.mean = [baseline.mean, rms.baseline.value];                % SAVE BASELINE DATA
	
    end
    
    
    %% STOP RECORDING AND WAIT______________________________________________
    Screen('DrawLines', win, fix.line, 2, [255, 255, 255]);    	            % DRAW FIXATION CROSS
    Screen('Flip', win);                                                    % PRESENT FIXATION CROSS
    WaitSecs(1);                                                            % WAIT 1 SECOND
    baseline.value = nanmean(baseline.mean);                                % CALCULATE MEAN ACROSS ALL SAMPLED EPOCHS
    
    
    %% DISPLAY BASELINE VALUES______________________________________________
    basline.t1 = (['Baseline: ',num2str(baseline.value)]);                  % BUILD TEXT VARIABLE FOR BASELINE
    mt_present_instruction(win, wsize, basline);                            % DISPLAY INSTRUCTIONS *** fix typo here ***
    
    % wait
    WaitSecs(2);							    % *** remove this? ***
    
    
    %% ACCEPT BASELINE VALUE?_______________________________________________
    accepted = mt_askAccept();
    
    if accepted 
    
        trial.baseline = trial.baseline + 1;				    % *** change to true ***
	
    end

end