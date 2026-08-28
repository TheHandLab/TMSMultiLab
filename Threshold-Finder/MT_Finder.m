% ENVIRONMENT______________________________________________________________
% DOES MAGIC EXIST?
% DO ALL LIBRARIES EXIST?
addpath(genpath('D:\TMSMultiLab'));
% total time taking  (save time started)
system.start = GetSecs;

%% experiment settings 
[settings,position,ax,input,updateIntensity] = mt_startUI ();


%% CONFIGURE
%% MT choice - > RMT or AMT
version.mt = settings.MT; 

%% auto or fast or amt
version.type = settings.version;   % auto  (in tms_configure)
                                   % fast
                                   % amt 

%% subject number and folder
subject = ['S' settings.subjectID];                                         % prompt user for filename here
run_time = datestr(now, 'yyyy_mm_dd_HH_MM');                                % time 
if settings.algorithm
    fileName = [subject '_AMT_QUEST_' run_time];                            % file name
elseif  strcmp(version.type, 'auto')
    fileName = [subject '_RMT_Auto_' run_time];                              % file name
elseif strcmp(version.type, 'fast')
    fileName = [subject '_RMT_fast_' run_time];                               % file name
elseif strcmp(version.type, 'amt') && ~settings.algorithm
    fileName = [subject '_AMT_BR_' run_time];                               % file name
end
save_folder = fullfile(settings.outputFolder, subject);                     % folder path
if ~exist(save_folder, 'dir')
    mkdir(save_folder);
end                                                                         % create subject folder



%% CONSTANTS_______________________________________________________________

%% SET UP EMG
mt_emg_configure;                                                         % CONFIGURE EMG & RMS

%% SET UP TMS DEVICE
mt_tms_configure;                                                         % CONFIGURE MAGIC TMS COMMUNICATION

%% SET UP National Instruments DEVICE
mt_ni_configure;                                                          % CONFIGURE NI CARD 

%% QUEST CONFIGURE
mt_Quest_parameters;

%% SET mt
mt_set_mt;                                                                % INITIALIZE mt VECTOR

%% IF USER CHOOSE DISPLAY 
if settings.display
    %% DISPLAY CONSTANT
    mt_display_configure;

    %% MVC INSTRUCTIONS
    mt_MVC_instructions;

    %% MEASURE BASELINE RMS
    mt_baseline_RMS;

    %% MEASURE MVC
    mt_MVC_RMS;

    %% SHOW INSTRUCTIONS
    if strcmp(version.mt, 'Active')
        mt_present_instruction(win, wsize, main.amt);                   
    elseif strcmp(version.mt, 'Rest')
        mt_present_instruction(win, wsize, main.rmt);
    end
    WaitSecs(2);
    KbWait;
end



%% safe padel
% disp('System ready. Press the safety pedal to start.');
% tms.pedal.control = s_tms.inputSingleScan;
% while tms.pedal.control == 0
%     tms.pedal.control = s_tms.inputSingleScan;                              % check inputs
% end


%% WHILE LOOP CONTROL
run_next_intensity = true;                                                  % TRANSITION TO THE NEXT INTESNITY

while run_next_intensity                                                    % INTENSITY CONTROL

    %% Choice of QUEST or Binary research
    if quest.condition
        %% FIND THE CURRENT INTENSITY (rounded midpoint of min and max)
        i = round(tms.intensity.quest./tms.resolution).*tms.resolution; 
    else
        %% FIND THE CURRENT INTENSITY (rounded midpoint of min and max)
        i = round(mean([tms.intensity.min,tms.intensity.max])./tms.resolution).*tms.resolution;% CALCULATE MIDPOINT BETWEEN MIN INTENSITY AND MAX INTENSITY
    end

   %% disp i 
    input.intensity.Text = sprintf('%d%%',i);

    %% Find intensity index
    idx.intensity = find(mt(:,1,3) == i);
  
    if quest.condition

        %% How many times has THIS intensity already been tested?
        idx.same = nnz(~isnan(mt(idx.intensity,:,1)));

        %% Next repeat number
        tms.intensity.same = idx.same + 1;

        %% Has this intensity already been tested?
        has_value = false;
 
        %% FIND MT
        if size(tms.intensity.sequence,2) >= quest.decision_trials - 1
            %% Final threshold estimated from QUEST posterior
            MT.value = round(QuestMean(quest.q) ./ tms.resolution) .* tms.resolution;
            %% Find corresponding intensity index
            MT.index = find(mt(:,1,3) == MT.value);
            %% Stop experiment
            run_next_intensity = false;
        end

    else

        %% Binary search
        tms.intensity.same = 1;

        %% Has this intensity already been tested?
        has_value = sum(isnan(mt(idx.intensity,tms.intensity.same,1:2))) ~= 2;
        
        %% FIND MT
        if has_value
            run_next_intensity = false;
            MT.index = find(mt(:,tms.intensity.same,1) >= tms.hit, 1,'first');
            MT.value = mt(MT.index,tms.intensity.same,3);
        end
    end

    
    %% rms buffer to display bar 
    if settings.display
        rms.data = [];
        rms.time = [];
    end

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
        
        [wait,tms.clock,tms.update.time] = mt_wait(tms.interval, tms.trigger.time);% CHECK TIME INTERIVAL SINCE LAST PULSE
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
                    emg.data.raw(idx.intensity,tms.currenttrial,:) = asynch_data;
                    emg.baseline.raw(idx.intensity,tms.currenttrial,:) = emg_before;

                    %% plot figure (if it's rmt, show individual trial each time, if it's amt, show averaged trials since start)
                    display.averagedtrial = reshape(mean(emg.data.raw( ...
                        idx.intensity,1:tms.currenttrial,:),2),[],1);
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
            average.raw = nanmean(emg.data.raw(idx.intensity,1:tms.currenttrial,:),2);
            average.baseline = nanmean(emg.baseline.raw(idx.intensity,1:tms.currenttrial,:),2);
            
            % save average
            if strcmp(version.mt, 'Rest')
                emg.data.average(idx.intensity,tms.currenttrial,:) = average.raw;
                emg.baseline.average(idx.intensity,tms.currenttrial,:) = average.baseline;
            elseif strcmp(version.mt, 'Active')
                emg.data.average(idx.intensity,1,:) = average.raw;
                emg.baseline.average(idx.intensity,1,:) = average.baseline;
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
                emg.mep.summary(idx.intensity,tms.currenttrial,:) = [mep.inrange,mep.amp(1),emg.baseline.amplitude,i];
            elseif strcmp(version.mt, 'Active')
                emg.mep.summary(idx.intensity,1,:) = [mep.inrange,mep.amp(1),emg.baseline.amplitude,i];
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

end

%% total time taken  (save time ended)
system.end = GetSecs;
system.total = system.end - system.start;


%% DISPLAY RESULT TO USER
% RMT threshold, final intensity, counts at threshold (Hit:Miss), total % trials to criterion, mean baseline RMS & P2P (all trials - measure of noisiness
input.MTtype.Text = settings.MT;
input.trials.Text = num2str(sum(mt(:,:,1:2), 'all', 'omitnan').*tms.reps);
input.mean_baseline.Text = sprintf('%.1f mV',mean(emg.mep.summary(:,:,3), 'all', 'omitnan'));
input.mean_p2p.Text = sprintf('%.1f mV',mean(emg.mep.summary(:,:,2), 'all', 'omitnan'));
input.timetoken.Text =  sprintf('%.0f mins', system.total./60);
input.threshold.Text = sprintf('%d%%',MT.value);
input.ratio.Text = sprintf('%d / %d', mt(MT.index,1,1), mt(MT.index,1,2));







%% save file
save(fullfile(save_folder,[fileName,'.mat']));


%% clean all
TMS.disconnect();
stop(s_asynch);
Screen('CloseAll');