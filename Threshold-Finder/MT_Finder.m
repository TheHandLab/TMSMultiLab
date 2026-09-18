% SET UP LOCAL ENVIRONMENT__________________________________________________
mt_environment;


%% START THE SCRIPT_________________________________________________________
system.start = GetSecs;                                                      % save  time started to calculate the total time taken
run_time = datestr(now, 'yyyy_mm_dd_HH_MM');                                 % current time


%% START THE USER INTERFACE, CONFIGURE EXPERIMENT SETTINGS__________________
[settings, position, ax, input, updateIntensity] = mt_startUI ();


%% CONFIGURE VERSION OF Threshold-Finder____________________________________
%% MT choice - > RMT or AMT
version.mt = settings.MT;                                                    % *** do we need two different variables with the same info here? ***

%% auto or fast or amt
version.type = settings.version;   % auto  (in tms_configure)                % *** do we need two different variables with the same info here? ***
                                   % fast
                                   % amt


%% SET THE SUBJECT NUMBER AND FOLDERS______________________________________
subject = ['S' settings.subjectID];                                         % prompt user for filename here
subject_muscle = settings.muscle;                                           % *** do we need two different variables with the same info here? ***

% build the subject file name
if settings.algorithm                                                       % *** two different variables used in this if... else... end loop - could this be a switch (version.type) loop? ***
    fileName = [subject '_AMT_QUEST_' subject_muscle '_' run_time];         % *** `subject_muscle '_' run_time` is copied x4 here - this can all be done on one line at the end of this loop ***
    
elseif strcmp(version.type, 'auto')
    fileName = [subject '_RMT_Auto_' subject_muscle '_' run_time];          % file name
    
elseif strcmp(version.type, 'fast')
    fileName = [subject '_RMT_fast_' subject_muscle '_' run_time];          % file name
    
elseif strcmp(version.type, 'amt') && ~settings.algorithm
    fileName = [subject '_AMT_BR_' subject_muscle '_' run_time];            % file name
    
end

% fileName = [filename, subject_muscle, '_' run_time];                      % remove the above repetition


save_folder = fullfile(settings.outputFolder, subject);                     % folder path
if ~exist(save_folder, 'dir')
    mkdir(save_folder);                                                     % create subject folder
end


%% CONSTANTS_______________________________________________________________
mt_emg_configure;                                                           % CONFIGURE EMG & RMS

mt_tms_configure;                                                           % CONFIGURE MAGIC TMS COMMUNICATION

mt_ni_configure;                                                            % CONFIGURE National Instruments DEVICE

mt_Quest_parameters;                                                        % CONFIGURE QUEST *** change name to quest_configure; make conditional on quest being used here ***

mt_set_mt;                                                                  % INITIALIZE mt VECTOR
                                                                            % *** it's probably a bad idea to have one variable with the same name as the first two characters of all the scripts - change to something else? ***


%% IF USER CHOOSES TO DISPLAY CURRENT EMG SIGNAL ON SCREEN__________________
if settings.display

    mt_display_configure;                                                   % CONFIGURE THE DISPLAY

    mt_MVC_instructions;                                                    % CONFIGURE THE MVC INSTRUCTIONS

    mt_baseline_RMS;                                                        % MEASURE BASELINE RMS *** should be EMG - allow various options ***

    mt_MVC_RMS;                                                             % MEASURE MVC

    % SHOW INSTRUCTIONS
    if strcmp(version.mt, 'Active')
        mt_present_instruction(win, wsize, main.amt);                       % *** just one variable differs in this call, so this can be done inside the mt_present_instruction function ***
	
    elseif strcmp(version.mt, 'Rest')
        mt_present_instruction(win, wsize, main.rmt);                       % rest
	
    end
    WaitSecs(2);
    KbWait;
    
end


%% PROMPT USER TO START Threshold-Finder BY PRESSING A SAFETY PEDAL_________
% disp('System ready. Press the safety pedal to start.');
% tms.pedal.control = s_tms.inputSingleScan;
% while tms.pedal.control == 0                                              % *** should set the == 0 to be == pedalup (and set pedalup as a variable in the ni_config) ***
%     tms.pedal.control = s_tms.inputSingleScan;                            % check inputs
% end


%% WHILE LOOP CONTROL_______________________________________________________
run_next_intensity = true;                                                  % TRANSITION TO THE NEXT INTENSITY

while run_next_intensity                                                    % INTENSITY CONTROL - THE MAIN LOOP

    %% CHOOSE TMS INTENSITY FOR DIFFERENT ALGORITHMS________________________
    if quest.condition                                                      % QUEST
    
        i = round(tms.intensity.quest ./ tms.resolution).*tms.resolution;   % QUEST suggestion, rounded to nearest valid intensity
	
    else                                                                    % BINARY SEARCH
    
        i = round(mean([tms.intensity.min, tms.intensity.max]) ./ tms.resolution).*tms.resolution;% MIDPOINT BETWEEN MIN AND MAX POSSIBLE INTENSITIES
	
    end

    input.intensity.Text = sprintf('%d%%', i);                              % DISPLAY CURRENT INTENSITY

    idx.intensity = find(mt(:,1,3) == i);                                   % FIND INDEX OF THIS INTENSITY IN THRESHOLD VECTOR
  
  
    %% PROCESS TMS INTENSITY FOR DIFFERENT ALGORITHMS_______________________
    if quest.condition                                                      % if QUEST algorithm is used

        idx.same = nnz(~isnan(mt(idx.intensity, :, 1)));                    % How many times has this intensity already been tested?

        tms.intensity.same = idx.same + 1;                                  % The next repetition number
	                                                                    % *** idx.same is only used on these two lines? - delete one line ? ***

        has_value = false;                                                  % Set to false to run this intensity
	                                                                    % *** `has_value` is not an informative name - change to `run_this_intensity` ? ***
 
 
        %% FIND MT__________________________________________________________
        if size(tms.intensity.sequence, 2) >= quest.decision_trials - 1     % if sufficient QUEST trials have been run
                                                                            % *** change `>= a-1` to `> a` ***
									    
            % Final threshold estimated from QUEST posterior, to nearest possible intensity
            MT.value = round(QuestMean(quest.q) ./ tms.resolution) .* tms.resolution;
	    
            % Find corresponding intensity index
            MT.index = find(mt(:,1,3) == MT.value);
	    
            % STOP Threshold-Finder
            run_next_intensity = false;                                     % *** is this doing the same job as `has_value` ?
	    
        end

    else                                                                    % if Binary search algorithm is used
    
        tms.intensity.same = 1;                                             % *** in this else clause, this variable is always 1 - can be set when quest.condition is set, or not used ***

        %% Has this intensity already been tested?
        has_value = sum(isnan(mt(idx.intensity, tms.intensity.same, 1:2))) ~= 2;% if this intensity has been tested, then one of the two columns in `mt(hits, misses)` will have a non-NaN value, hence the sum will not be 2
        
        %% FIND MT__________________________________________________________
        if has_value                                                        % if the selected intensity has already been tested (i.e., there is no spare intensity between MIN and MAX)
	
	    % Find the first intensity which has already been tested and has at least the required number of hits
            MT.index = find(mt(:, tms.intensity.same, 1) >= tms.hit, 1, 'first');
	    
	    % set the MT to be this value
            MT.value = mt(MT.index, tms.intensity.same, 3);
	    
	    % STOP Threshold-Finder
            run_next_intensity = false;
        end
    end

    
    %% INITIALISE THE RMS BUFFER TO DISPLAY CURRENT EMG SIGNAL______________
    if settings.display                                                     % if EMG is displayed on screen
        rms.data = [];
        rms.time = [];
    end
    
    
    %% IF CURRENT INTENSITY NEEDS TO BE TESTED______________________________
    while ~has_value                                                        % IF CURRENT INTENSITY HAS NOT BEEN TESTED (Binary search) OR IF IT NEEDS TESTING AGAIN (QUEST)
        
        %% READ THE SAFETY PEDAL STATUS_____________________________________
        tms.pedal.control = s_tms.inputSingleScan;                          % *** this safety control is a long time before the TMS - move it to immediately before the TMS ***


        %% SET TMS, mt, T, AND CLOCK VARIABLES______________________________
        mt_set_initialization;                                              % INITIALIZATION
                                                                            % mt = empty array for results *** should mt not be set outside the intensity loop? ***
                                                                            % R = r trials included in average MEP
                                                                            % clock = time since start of last trial

        %% PROCESS CALLBACKS FROM NI BACKGROUND DATA STREAM_________________
        drawnow;                                                            % ALLOW THE BACKGROUD CALLBACK TO UPDATA THE EMG DATA

        
        %% IS THE TIME DIFFERENCE BETWEEN THE NEXT PULSE AND THE PREVIOUS PULSE GREATER THAN TMS INTERVAL
        if strcmp(version.type, 'auto')
	
            tms.interval = 7.5 + (rand - 0.5) * 5;                          % *** these numbers should be set as variables ***
								            % *** not clear why only the 'auto' tms.interval is defined here - is the interval defined somewhere else for different algorithms? not ideal ***
									    % probably a switch algorithm is required here - at least for clarity, or set the rand multiple to be 0 for fast_auto
        end
        
        [wait, tms.clock, tms.update.time] = mt_wait(tms.interval, tms.trigger.time);% CHECK TIME INTERVAL SINCE LAST PULSE
                                                                            % WAIT allows you to:
                                                                            % 1) keep collecting data after the previous TMS pulse
                                                                            % AND
                                                                            % 2) not present TMS until long enough has passed


        %% MEASURE RMS______________________________________________________
        [RMS] = mt_measure_RMS(emg_asynch_chunk(:, emg.muscle) .* ni_gain); % MEASURE RMS FOR EACH CHUNK OF DATA
	                                                                    % *** ALSO MEASURE MVC and P2P HERE
									    % change script to: mt_measure_EMG, and extract RMS, MVC, and P2P within the same window


	%% DISPLAY CURRENT MVC TO SUBJECT___________________________________
	if settings.display
	   % mt_EMG_display                                                 % change to mt_EMG_display - allow display of any of the above EMG variables
	end
	
	
        %% DECIDE WHETHER TO PRESENT TMS____________________________________
        if settings.display 
            mt_MVC_display;                                                  % DISPLAY REAL-TIME FEEDBACK
	                                                                     % *** does this run once per chunk of data?
									     % *** this script does *three different things*:
									     %		display data AND
									     %		decide whether to present TMS AND
									     %		present TMS
									     % *** seems that visual display uses MVC to determine TMS, while nonvisual uses RMS (and MEP is measured relative to P2P) - why different?
									     % *** EMG background criterion should be a variable: RMS or MVC or P2P, with suggested values for each
									     % *** then, algorithim can flexibly use whichever is needed to decide whether to present TMS

        else
	    if strcmp(version.mt, 'Rest')                                    % *** not clear why RMS is only assessed for the rest condition here - we can still use RMS to trigger during active MT without feedback ***
            
                %% ASSESS RMS_______________________________________________
                RMS.inrange = RMS.value >= emg.rms.min && RMS.value <= emg.rms.max; % ASSESS WHETHER RMS IS IN RANGE
            
                %% PRESENT TMS IF RMS IS IN RANGE AND IT HAS BEEN LONG ENOUGH SINCE THE LAST PULSE
                if RMS.inrange && ~wait  % && tms.pedal.control == 1
                    [tms] = mt_present_TMS(s_tms,tms);                       % PRESENT TMS IF ALL CRITERIONS MET
		                                                             % *** this line is in two different scripts - simplify - this loop is to *decide* whether to present TMS: Yes/No; then present it below ***
                end
	    end
        end


        %% READ THE SAFETY PEDAL STATUS_____________________________________
        %tms.pedal.control = s_tms.inputSingleScan;                          % *** should set the == 0 to be == pedalup (and set pedalup as a variable in the ni_config) ***
	
	
        %% PRESENT TMS?_____________________________________________________
	%if inrange
        %    [tms] = mt_present_TMS(s_tms,tms);
        %end


        %% ACQUIRE EMG ALL THE TIME (sometimes after TMS, sometimes not)____
        if ~isempty(emg_asynch_data)                                         % WHEN EMG_ASYNCH_DATA COLLECTED DATA


            %% DETECT TRIGGER (has there been a recent TMS pulse?)__________
            [trigger] = mt_trigger(emg_asynch_data(:,emg.trigger), s_asynch.Rate);% WHETHER TRIGGER DETECTED


            %% ACQUIRE EMG FROM LATEST CHUNK OF DATA________________________
            if trigger.active                                                % IF DATA HAS TRIGGER
	    
                % extract data for each pulse
                [asynch_data, options.mep, wait_for_data] = mt_acquire_emg_asynch(emg_asynch_data(:,emg.muscle).*ni_gain, s_asynch.Rate, trigger.onset_ms, emg.mep.record); % EXTRACT MEP WINDOW

                % extract data for each RMS before the pulse
                [emg_before, options.rms] = mt_acquire_emg_asynch(emg_asynch_data(:,emg.muscle).*ni_gain, s_asynch.Rate, trigger.onset_ms, emg.baseline);


                %% SAVE MEP WINDOW (useful for averaging multiple pulses)___
                if ~wait_for_data

                    % UPDATE REPETITION (TMS pulses to average before measuring MEP)
                    R = R + 1;                                              % UPDATE R WHEN WE ACQUIRED MEP WINDOW
                    tms.currenttrial = tms.currenttrial + 1;                % and current repetition of this intensity
									    % *** make terms consistent - trials and repetitions ***

                    % SAVE VARIABLES
                    emg.data.raw(idx.intensity, tms.intensity.same, tms.currenttrial,:) = asynch_data;
                    emg.baseline.raw(idx.intensity, tms.intensity.same, tms.currenttrial,:) = emg_before;


                    % plot figure (if it's rmt, show individual trial each time, if it's amt, show averaged trials since start)
                    if strcmp(version.mt, 'Rest')                           % *** change this to a SWITCH loop
									    % *** these two lines do the same thing, and there is no reason to restrict Rest to R=1 repetition - why not allow averaging also for rest?
		    
                        display.averagedtrial = reshape(mean(emg.data.raw(idx.intensity, tms.intensity.same, tms.currenttrial, :), 3), [], 1);
			
                    elseif strcmp(version.mt, 'Active')
		    
                        display.averagedtrial = reshape(mean(emg.data.raw(idx.intensity, tms.intensity.same, 1:tms.currenttrial, :), 3), [], 1);
			
                    end
		    mt_plot(ax, 1:emg.asynch.samplesize, display.averagedtrial, abs(emg.mep.record.before), s_asynch.Rate, emg.range-emg.display.tolerate, display.plot);
		    
                    % show trial number on UI (can not move, if we want to show single trial number in each repetition)
                    input.trial.Text = num2str(tms.currenttrial);


                    % CLEAN BUFFER AND REOPEN S_ASYNCH
                    stop(s_asynch);                                         % STOP ASYNCH
                    emg_asynch_data = [];                                   % CLEAN BUFFER
                    emg_asynch_time = [];                                   % CLEAN BUFFER
                    s_asynch.startBackground();                             % START ASYNCH
		    
                end                                                         % END OF WAIT FOR DATA LOOP

            end                                                             % END OF ACQUIRE EMG LOOP

        end                                                                 % END OF EMG_DATA ASYNCH LOOP
        


        %% CHECK WHETHER ENOUGH TRIALS HAVE BEEN COMPLETED
        trial.count = R == tms.reps;                                        % R = trials? (true/false)
								            % *** is this variable used only on these two lines? -> remove one line ***
      
        if trial.count && ~wait_for_data

            R = 0;                                                          % reset R to 0 (re-start the average on next repeat)

            %% AVERAGE MEP (across trials of 1:R)			    % *** this is doing the same for rest and active - no need to restrict averaging to active; use all relevant non-NaN data as MEP
            if strcmp(version.mt, 'Rest')
	    
                average.raw = nanmean(emg.data.raw(idx.intensity, tms.intensity.same, tms.currenttrial, :), 3);
                average.baseline = nanmean(emg.baseline.raw(idx.intensity, tms.intensity.same, tms.currenttrial, :), 3);
		
            elseif strcmp(version.mt, 'Active')
	    
                average.raw = nanmean(emg.data.raw(idx.intensity, tms.intensity.same, 1:tms.currenttrial, :), 3);
                average.baseline = nanmean(emg.baseline.raw(idx.intensity, tms.intensity.same, 1:tms.currenttrial, :), 3);
            end
            
            % save average                                                  % *** see above - reduce this to two lines ***
            if strcmp(version.mt, 'Rest')
	    
                emg.data.average(idx.intensity, tms.intensity.same, tms.currenttrial,:) = average.raw;
                emg.baseline.average(idx.intensity,tms.intensity.same,tms.currenttrial,:) = average.baseline;
		
            elseif strcmp(version.mt, 'Active')
	    
                emg.data.average(idx.intensity, tms.intensity.same,1,:) = average.raw;
                emg.baseline.average(idx.intensity,tms.intensity.same,1,:) = average.baseline;
		
            end

            %% MEASURE MEP
            options.mep.baseline = 1:(abs(emg.mep.record.before)-1);
            [mep, options.mep] = MEP(average.raw, s_asynch.Rate, abs(emg.mep.record.before), options.mep);


            %% MEASURE BASELINE
            emg.baseline.amplitude = max(average.baseline) - min(average.baseline);   % change to emg.amplitude.baseline *** should add this to the MEP script - P2P and RMS of baseline


            %% ASSESS MEP
            mep.inrange = mep.amp(1) >= emg.baseline.amplitude && mep.amp(1) >= emg.mep.min && mep.amp(1) <= emg.mep.max; % WHETHER MEP IS IN RANGE
            

            %% save variables
            if strcmp(version.mt, 'Rest')
	    
                emg.mep.summary(idx.intensity,tms.intensity.same,tms.currenttrial,:) = [mep.inrange,mep.amp(1),emg.baseline.amplitude,i];
		
            elseif strcmp(version.mt, 'Active')
	    
                emg.mep.summary(idx.intensity,tms.intensity.same,1,:) = [mep.inrange,mep.amp(1),emg.baseline.amplitude,i];
		
            end


            %% UPDATE mt
            if mep.inrange
	    
                mt(idx.intensity,tms.intensity.same,1) = mt(idx.intensity,tms.intensity.same,1) + 1;% HIT = SET mt(i,1)+1
		
            else
	    
                mt(idx.intensity,tms.intensity.same,2) = mt(idx.intensity,tms.intensity.same,2) + 1;% MISS = SET mt(i,2)+1
		
            end


            %% DISPLAY PROGRESS TO USER____________________________________
            % disp (['Trial: ',int2str(tms.currenttrial), ', Intensity: ',int2str(i),'%MSO, baseline p2p: ',num2str(emg.baseline.amplitude,3),'mV, MEP: ',num2str(mep.amp(1),3),'mV, ',int2str(mep.inrange)]);
            input.MEP.Text = sprintf('%.2f mV', mep.amp(1));
            input.baseline.Text = sprintf('%.2f mV', emg.baseline.amplitude);
	    
            if mep.inrange
	    
                input.MEP_in_range.Text = 'Yes';
		
            else
	    
                input.MEP_in_range.Text = 'No';
            end


            %% ASSESS mt                                                    % *** 'count' is not a good name here - count is 1,2,3,4,5 but this is a boolean variable better might be if hit.count == hit.required or similar in the loop below ***
            hit.count = mt(idx.intensity, tms.intensity.same, 1) == tms.hit;  % mt(i,1) == tms.hit? (true/false)
            miss.count = mt(idx.intensity, tms.intensity.same, 2) == tms.miss;% mt(i,2) == tms.miss? (true/false)


            %% UPDATE DISCTIBUTIOINS PER ALGORITHM__________________________
	    
            if quest.condition                                              % QUEST
	    
                quest.q = QuestUpdate(quest.q, tms.intensity.quest,hit.count);% UPDATE QUEST DISTRIBUTION
		
                tms.intensity.quest = round(QuestMean(quest.q));            % UPDATE INTENSITY
		
                tms.intensity.quest = max(tms.intensity.min, min(tms.intensity.max, tms.intensity.quest)); % ? not sure, should intensity be restricted in the range ([intensity.min : intensity.max])
		
            else                                                            % BINARY SEARCH

                if hit.count                                                % UPDATE MAX INTENSITY

                    tms.intensity.max = i - 1;                              % SET MAX TO ONE STEP LOWER THAN THE CURRENT INTENSITY
									    % *** if this is absolute intensity (not an index), then it should be - tms.resolution ***
		    
                elseif miss.count	                                    % UPDATE MIN INTENSITY

                    tms.intensity.min = i + 1;                              % SET MIN TO ONE STEP HIGHER THAN THE CURRENT INTENSITY
		                                                            % *** if this is absolute intensity (not an index), then it should be + tms.resolution ***
		    
                end
		
            end


            %% EXIT CURRENT INTENSITY_______________________________________
	    
            if hit.count || miss.count
	    
                input.history.ratio.Text = sprintf('%d / %d', mt(idx.intensity, tms.intensity.same, 1), mt(idx.intensity, tms.intensity.same, 2));% SHOW HIT/MISS
		
                input = updateIntensity(input);                             % Update / create intensity button
		
                %% save variables
                tms.intensity.sequence = [tms.intensity.sequence,i];        % SAVE INTENSITY SEQUENCE
                tms.intensity.index = [tms.intensity.index, idx.intensity];
                has_value = true;                                           % EXIT CURRENT INTENSITY
                TMS.disarm();                                               % DISARM TMS
                tms.state.arm = false;                                      % TMS ARM CONTROL
                tms.currenttrial = 0;                                       % clear tms.currenttrial
		
            end

        end

    end

end                                                                         % END THE MAIN INTENSITY CONTROL LOOP


%% TOTAL TIME TAKEN_________________________________________________________
system.end = GetSecs;
system.total = system.end - system.start;


%% DISPLAY RESULT TO USER______________________________________________________
% RMT threshold, final intensity, counts at threshold (Hit:Miss), total % trials to criterion, mean baseline RMS & P2P (all trials - measure of noisiness
input.MTtype.Text = settings.MT;
input.trials.Text = num2str(sum(mt(:,:,1:2), 'all', 'omitnan').*tms.reps);
input.mean_baseline.Text = sprintf('%.1f mV',mean(emg.mep.summary(:,:,:,3), 'all', 'omitnan'));
input.mean_p2p.Text = sprintf('%.1f mV',mean(emg.mep.summary(:,:,:,2), 'all', 'omitnan'));
input.timetoken.Text =  sprintf('%.0f mins', system.total./60);
input.threshold.Text = sprintf('%d%%',MT.value);
input.ratio.Text = sprintf('%d / %d', mt(MT.index,1,1), mt(MT.index,1,2));


%% SAVE FILE________________________________________________________________
save(fullfile(save_folder,[fileName,'.mat']));


%% CLEAN UP_________________________________________________________________
TMS.disconnect();                                                           % disconnect MAGIC toolbox from TMS
stop(s_asynch);                                                             % stop background NIDAq data streaming
Screen('CloseAll');                                                         % close all psychtoolbox screens *** need to add - if display is being used ***
%clear all;                                                                  % clear the memory *** this may not be a great idea during development - e.g., if saving didn't work ***