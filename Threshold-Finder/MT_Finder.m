% SET UP ENVIRONMENT_________________________________________________________
mt_environment;


%% START THE SCRIPT__________________________________________________________
system.start = GetSecs;                                                      % save  time started to calculate the total time taken
run_time = datestr(now, 'yyyy_mm_dd_HH_MM');                                 % current time


%% START THE USER INTERFACE, CONFIGURE EXPERIMENT SETTINGS___________________
[settings, position, ax, input, updateIntensity] = mt_startUI ();


%% CONFIGURE VERSION OF Threshold-Finder_____________________________________
%% MT choice - > RMT or AMT
version.mt = settings.MT;                                                    % *** do we need two different variables with the same info here? ***

%% auto or fast or amt
version.type = settings.version;   % auto  (in tms_configure)                % *** do we need two different variables with the same info here? ***
                                   % fast
                                   % amt 


%% SET THE SUBJECT NUMBER AND FOLDERS_______________________________________
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

save_folder = fullfile(settings.outputFolder, subject);                     % folder path
if ~exist(save_folder, 'dir')
    mkdir(save_folder);                                                     % create subject folder
end


%% CONSTANTS________________________________________________________________
mt_emg_configure;                                                           % CONFIGURE EMG & RMS

mt_tms_configure;                                                           % CONFIGURE MAGIC TMS COMMUNICATION

mt_ni_configure;                                                            % CONFIGURE National Instruments DEVICE

mt_Quest_parameters;                                                        % CONFIGURE QUEST

mt_set_mt;                                                                  % INITIALIZE mt VECTOR
                                                                            % *** it's probably a bad idea to have one variable with the same name as the first two characters of all the scripts - change to something else? ***


%% IF USER CHOOSES TO DISPLAY CURRENT EMG SIGNAL ON SCREEN__________________
if settings.display

    mt_display_configure;                                                   % CONFIGURE THE DISPLAY

    mt_MVC_instructions;                                                    % CONFIGURE THE MVC INSTRUCTIONS

    mt_baseline_RMS;                                                        % MEASURE BASELINE RMS

    mt_MVC_RMS;                                                             % MEASURE MVC

    %% SHOW INSTRUCTIONS
    if strcmp(version.mt, 'Active')
        mt_present_instruction(win, wsize, main.amt);                       % active contraction
	
    elseif strcmp(version.mt, 'Rest')
        mt_present_instruction(win, wsize, main.rmt);                       % rest
	
    end
    WaitSecs(2);
    KbWait;
    
end


%% PROMPT USER TO START Threshold-Finder BY PRESSING A SAFETY PEDAL_________
% disp('System ready. Press the safety pedal to start.');
% tms.pedal.control = s_tms.inputSingleScan;
% while tms.pedal.control == 0
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
	                                                                    % *** idx.same is only used on these two lines - delete one line ? ***

        has_value = false;                                                  % Set to false to run this intensity
	                                                                    % *** `has_value` is not an informative variable name - change to `run_this_intensity` ? ***
 
 
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
        tms.intensity.same = 1;                                             % *** in this else clause, this variable is always 1 simplify? ***

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


    %%%%% FROM HERE NICK %%%%%
    
    
    %% IF CURRENT i has not been tested
    while ~has_value                                                        % IF CURRENT i HAS NOT BEEN TESTED
        
        %% safety pedal
        tms.pedal.control = s_tms.inputSingleScan;

        %% SET TMS, mt, T, AND CLOCK
        mt_set_initialization;                                              % INITIALIZATION
                                                                            % mt = empty array for results
                                                                            % R = r trials included in average MEP
                                                                            % clock = time since start of last trial

        %% PROCESS CALLBACKS
        drawnow;                                                            % ALLOW THE BACKGROUD CALLBACK TO UPDATA THE EMG DATA

        
        %% IS THE TIME DIFFERENCE BETWEEN THE NEXT PULSE AND THE PREVIOUS PULSE GREATER THAN TMS INTERVAL
        % IF RANDOM INTERVAL, SPECIFY HERE...
        if  strcmp(version.type, 'auto')
            tms.interval = 7.5 + (rand - 0.5) * 5;
        end
        
        [wait, tms.clock, tms.update.time] = mt_wait(tms.interval, tms.trigger.time);% CHECK TIME INTERVAL SINCE LAST PULSE
                                                                            % WAIT allows you to:
                                                                            % 1) keep collecting data after the previous TMS pulse
                                                                            % AND
                                                                            % 2) not present TMS until long enough has passed


        %% MEASURE RMS
        [RMS] = mt_measure_RMS(emg_asynch_chunk(:,emg.muscle) * ni_gain);   % MEASURE RMS FOR EACH CHUNK OF DATA
        
        %% PRESENT TMS
        if settings.display 
            %% DISPLAT REAL-TIME FEEDBACK
            mt_MVC_display;

        elseif ~settings.display && strcmp(version.mt, 'Rest')
            
            %% ASSESS RMS
            RMS.inrange = RMS.value >= emg.rms.min && RMS.value <= emg.rms.max; % ASSESS WHETHER RMS IS IN RANGE
            
            %% PRESENT TMS IF RMS IS IN RANGE AND IT HAS BEEN LONG ENOUGH SINCE THE LAST PULSE
            if RMS.inrange && ~wait  % && tms.pedal.control == 1    
                [tms] = mt_present_TMS(s_tms,tms);                            % PRESENT TMS IF ALL CRITERIONS MET
            end
        end

        %% ACQUIRE EMG ALL THE TIME (sometimes after TMS, sometimes not)
        if ~isempty(emg_asynch_data)                                        % WHEN EMG_ASYNCH_DATA COLLECTED DATA


            %% DETECT TRIGGER (has there been a recent TMS pulse?)
            [trigger] = mt_trigger(emg_asynch_data(:,emg.trigger), s_asynch.Rate); % WHETHER TRIGGER DETECTED


            %% ACQUIRE EMG FROM LATEST CHUNK OF DATA
            if trigger.active                                               %% if data has trigger
                %% extract data for each pulse
                [asynch_data,options.mep,wait_for_data] = mt_acquire_emg_asynch( ... % EXTRACT MEP WINDOW
                    emg_asynch_data(:,emg.muscle) * ni_gain, ...
                    s_asynch.Rate,trigger.onset_ms,emg.mep.record);           

                %% extract data for each RMS before the pulse
                [emg_before,options.rms] = mt_acquire_emg_asynch (emg_asynch_data ...
                    (:,emg.muscle) * ni_gain,s_asynch.Rate, trigger.onset_ms,emg.baseline);


                %% SAVE MEP WINDOW (This is useful for averaging multiple pulses)
                if ~wait_for_data

                    %% UPDATE T (TMS pulses to average before measuring MEP)
                    R = R + 1;                                              % UPDATE R WHEN WE ACQUIRED MEP WINDOW
                    tms.currenttrial = tms.currenttrial + 1;                % and current repetition of this intensity

                    %% save variables
                    emg.data.raw(idx.intensity, tms.intensity.same, tms.currenttrial,:) = asynch_data;
                    emg.baseline.raw(idx.intensity, tms.intensity.same, tms.currenttrial,:) = emg_before;

                    %% plot figure (if it's rmt, show individual trial each time, if it's amt, show averaged trials since start)
                    if strcmp(version.mt, 'Rest')
                    display.averagedtrial = reshape(mean(emg.data.raw( ...
                        idx.intensity, tms.intensity.same,tms.currenttrial,:),3),[],1);
                    elseif strcmp(version.mt, 'Active')
                        display.averagedtrial = reshape(mean(emg.data.raw( ...
                            idx.intensity, tms.intensity.same, 1:tms.currenttrial, :), 3), [], 1);
                    end
                    mt_plot(ax,1:emg.asynch.samplesize, ...
                        display.averagedtrial,abs(emg.mep.record.before), ...
                        s_asynch.Rate,emg.range-emg.display.tolerate,display.plot);
                    
                    %% show trial number on UI (can not move, if we want to show single trial number in each repetition)
                    input.trial.Text = num2str(tms.currenttrial);


                    %% CLEAN BUFFER AND REOPEN S_ASYNCH
                    stop(s_asynch);                                         % STOP ASYNCH
                    emg_asynch_data = [];                                   % CLEAN BUFFER
                    emg_asynch_time = [];                                   % CLEAN BUFFER
                    s_asynch.startBackground();                             % START ASYNCH
                end

            end

        end
        


        %% CHECK WHETHER ENOUGH TRIALS HAVE BEEN COMPLETED
        trial.count = R == tms.reps;                                        % R = trials? (true/false)
      
        if trial.count && ~wait_for_data

            R = 0;                                                          % reset R to 0 (re-start the average on next repeat)

            %% AVERAGE MEP (across trials of 1:T)
            if strcmp(version.mt, 'Rest')
                average.raw = nanmean(emg.data.raw(idx.intensity,tms.intensity.same,tms.currenttrial,:),3);
                average.baseline = nanmean(emg.baseline.raw(idx.intensity,tms.intensity.same,tms.currenttrial,:),3);
            elseif strcmp(version.mt, 'Active')
                average.raw = nanmean(emg.data.raw(idx.intensity,tms.intensity.same,1:tms.currenttrial,:),3);
                average.baseline = nanmean(emg.baseline.raw(idx.intensity,tms.intensity.same,1:tms.currenttrial,:),3);
            end
            
            % save average
            if strcmp(version.mt, 'Rest')
                emg.data.average(idx.intensity,tms.intensity.same,tms.currenttrial,:) = average.raw;
                emg.baseline.average(idx.intensity,tms.intensity.same,tms.currenttrial,:) = average.baseline;
            elseif strcmp(version.mt, 'Active')
                emg.data.average(idx.intensity,tms.intensity.same,1,:) = average.raw;
                emg.baseline.average(idx.intensity,tms.intensity.same,1,:) = average.baseline;
            end

            %% MEASURE MEP
            options.mep.baseline = 1:(abs(emg.mep.record.before)-1);
            [mep,options.mep] = MEP(average.raw, s_asynch.Rate, abs(emg.mep.record.before),options.mep);


            %% MEASURE BASELINE
            emg.baseline.amplitude = max(average.baseline) - min(average.baseline);   % change to emg.amplitude.baseline


            %% ASSESS MEP
            mep.inrange = mep.amp(1)>= emg.baseline.amplitude && mep.amp(1)>=emg.mep.min && mep.amp(1) <= emg.mep.max; % WHETHER MEP IS IN RANGE
            

            %% save variables
            if strcmp(version.mt, 'Rest')
                emg.mep.summary(idx.intensity,tms.intensity.same,tms.currenttrial,:) = [mep.inrange,mep.amp(1),emg.baseline.amplitude,i];
            elseif strcmp(version.mt, 'Active')
                emg.mep.summary(idx.intensity,tms.intensity.same,1,:) = [mep.inrange,mep.amp(1),emg.baseline.amplitude,i];
            end


            %% UPDATE mt
            if mep.inrange
                mt(idx.intensity,tms.intensity.same,1) = mt(idx.intensity,tms.intensity.same,1) + 1;   % HIT = SET mt(i,1)+1
            else
                mt(idx.intensity,tms.intensity.same,2) = mt(idx.intensity,tms.intensity.same,2) + 1;   % MISS = SET mt(i,2)+1
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

            %% ASSESS mt
                hit.count = mt(idx.intensity,tms.intensity.same,1) == tms.hit;                               % mt(i,1) == tms.hit? (true/false)
                miss.count = mt(idx.intensity,tms.intensity.same,2) == tms.miss;                             % mt(i,2) == tms.miss? (true/false)

            %% choice of QUEST
            if quest.condition
                quest.q = QuestUpdate(quest.q, tms.intensity.quest,hit.count); % UPDATE THE QUEST
                tms.intensity.quest = round(QuestMean(quest.q));               % UPDATE INTENSITY
                tms.intensity.quest = max(tms.intensity.min, ...
                    min(tms.intensity.max, tms.intensity.quest));              % ? not sure, should intensity be restricted in the range ([intensity.min : intensity.max])
            else

                if hit.count
                    %% update max intensity
                    tms.intensity.max = i - 1;                                  % SET Max = i - 1
                elseif miss.count
                    %% update min intensity
                    tms.intensity.min = i + 1;                                  % SET Min = i + 1
                end
            end


            %% Exit CURRENT INTENSITY
            if hit.count || miss.count  
                %% SHOW HIT/MISS
                input.history.ratio.Text = sprintf('%d / %d', mt(idx.intensity,tms.intensity.same,1), mt(idx.intensity,tms.intensity.same,2));
                %% Update / create intensity button
                input = updateIntensity(input);
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

%% total time taken  (save time ended)
system.end = GetSecs;
system.total = system.end - system.start;


%% DISPLAY RESULT TO USER
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
Screen('CloseAll');                                                         % close all psychtoolbox screens
%clear all;                                                                  % clear the memory *** this may not be a great idea during development - e.g., if saving didn't work ***