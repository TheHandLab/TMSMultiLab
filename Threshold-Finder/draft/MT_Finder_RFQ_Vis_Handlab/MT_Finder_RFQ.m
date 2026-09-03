 %% experiment settings 
settings = mtrfq_startUI ();


%% CONFIGURE
mt_version = settings.version;   % 1 = Auto RMT-Finder
                    % 2 = Fast Auto RMT-Finder
                    % 3 = ?
                    % 4 = ?

% ENVIRONMENT______________________________________________________________
% DOES MAGIC EXIST?
% DO ALL LIBRARIES EXIST?
addpath(genpath(settings.inputFolder));

%
subject = settings.subjectID; % prompt user for filename here
save_folder =  settings.outputFolder;


%% CONSTANTS_______________________________________________________________

%% SET UP EMG
mt_emg_configure;                                                         % CONFIGURE EMG & RMS

%% SET UP TMS DEVICE
rmtf_tms_configure;                                                         % CONFIGURE MAGIC TMS COMMUNICATION

%% SET UP National Instruments DEVICE
rmtf_ni_configure;                                                          % CONFIGURE NI CARD

%% SET mt
rmtf_set_mt;                                                                % INITIALIZE mt VECTOR 

%% DISPLAY CONSTANT
mtfr_display_configure;

%% QUEST CONFIGURE
mtrfq_Quest_parameters;

%% MVC INSTRUCTIONS
mtfr_MVC_instructions;

%% MEASURE BASELINE RMS
mtfr_baseline_RMS;

%% MEASURE MVC
mtfr_MVC_RMS;

% %% several percentage of MVC
% mtfr_MVC_criterion;
% 
% %% Measure baseline (can be a option)
% [model] = mtfr_MVC_model(mvc.raw.data(:,:),mvc.value,mvc.inwindow.start,4000,mvc.proportion);

%% instructions
mtfr_present_instruction(win, wsize, main);
WaitSecs(2);
KbWait;


%% WHILE LOOP CONTROL
run_next_intensity = true;                                                  % TRANSITION TO THE NEXT INTESNITY

while run_next_intensity                                                    % INTENSITY CONTROL

    %% Choice of QUEST or Robbins–Monro stochastic approximation
    if quest.condition
        %% FIND THE CURRENT INTENSITY (rounded midpoint of min and max)
        i = round(tms.intensity.quest./tms.resolution).*tms.resolution; 
        idx = find (mt(:,3) == i);
    else
        %% FIND THE CURRENT INTENSITY (rounded midpoint of min and max)
        i = round(mean([tms.intensity.min,tms.intensity.max])./tms.resolution).*tms.resolution;% CALCULATE MIDPOINT BETWEEN MIN INTENSITY AND MAX INTENSITY
        idx = find(mt(:,3) == i);
    end

    %% HAS CURRENT i BEEN TESTED? 
    if ~quest.condition                                                     % If users don't use QUEST  
        has_value = sum(isnan(mt(idx,1:2)))~=2;                             % is there a NaN in both columns 1 (hits) and 2 (misses)?
    else
        has_value = true;                                                   % If users use QUEST
    end

    if has_value                                                            % IF CURRENT i HAS VALUE
        run_next_intensity = false;                                         % STOP TEST
        MT.index = find(mt(:,1) >= tms.hit, 1, 'first');                    % INDEX FOR MOTOR THRESHOLD = first intensity with at least 5 hits
        MT.value = mt(MT.index, 3);                                         % FIND THE MOTOR THRESHOLD
    end
    
    rms.data = [];
    rms.time = [];
    %% IF CURRENT i has not been tested
    while ~has_value                                                        % IF CURRENT i HAS NOT BEEN TESTED

        %% SET TMS, mt, T, AND CLOCK
        rmtf_set_initialization;                                            % INITIALIZATION
                                                                            % mt = empty array for results
                                                                            % T = n trials included in average MEP
                                                                            % clock = time since start of last trial

        %% PROCESS CALLBACKS
        drawnow;                                                            % ALLOW THE BACKGROUD CALLBACK TO UPDATA THE EMG DATA

        
        %% IS THE TIME DIFFERENCE BETWEEN THE NEXT PULSE AND THE PREVIOUS PULSE GREATER THAN TMS INTERVAL
        % IF RANDOM INTERVAL, SPECIFY HERE...
        if mt_version == 1
            tms.interval = 7.5 + (rand - 0.5) * 5;
        end
        
        [wait,tms.clock,tms.update.time] = rmtf_wait(tms.interval, tms.trigger.time);% CHECK TIME INTERIVAL SINCE LAST PULSE
                                                                            % WAIT allows you to:
                                                                            % 1) keep collecting data after the previous TMS pulse
                                                                            % AND
                                                                            % 2) not present TMS until long enough has passed

        



        %% MEASURE RMS
        [RMS] = rmtf_measure_RMS(emg_asynch_chunk(:,emg.muscle) * ni_gain); % MEASURE RMS FOR EACH CHUNK OF DATA
        rms.data = [rms.data; RMS.value];
        rms.time = [rms.time; tms.clock];
        

        %% DISPLAT REAL-TIME FEEDBACK
        mt_mvc_display

        %% ACQUIRE EMG ALL THE TIME (sometimes after TMS, sometimes not)
        if ~isempty(emg_asynch_data)                                        % WHEN EMG_ASYNCH_DATA COLLECTED DATA


            %% DETECT TRIGGER (has there been a recent TMS pulse?)
            [trigger] = rmtf_trigger(emg_asynch_data(:,emg.trigger), s_asynch.Rate); % WHETHER TRIGGER DETECTED


            %% ACQUIRE EMG FROM LATEST CHUNK OF DATA
            if trigger.active
                %% extract data for each pulse
                [asynch_data,options.mep,wait_for_data] = rmtf_acquire_emg_asynch( ... % EXTRACT MEP WINDOW
                    emg_asynch_data(:,emg.muscle) * ni_gain, ...
                    s_asynch.Rate,trigger.onset_ms,emg.mep.record);            %emg.mep.record.start/end has the same data

                %% extract data for each RMS before the pulse
                [emg_before,options.rms] = rmtf_acquire_emg_asynch (emg_asynch_data ...
                    (:,emg.muscle) * ni_gain,s_asynch.Rate, trigger.onset_ms,emg.baseline);% update function rms.start/end


                %% SAVE MEP WINDOW (This is useful for averaging multiple pulses)
                if ~wait_for_data

                    %% UPDATE T (TMS pulses to average before measuring MEP)
                    T = T + 1;                                              % UPDATE T WHEN WE ACQUIRED MEP WINDOW
                    tms.currenttrial = tms.currenttrial + 1;                % and current repetition of this intensity

                    %% save variables
                    emg.data.raw(idx,tms.currenttrial,:) = asynch_data;
                    emg.baseline.raw(idx,tms.currenttrial,:) = emg_before;

                    %% CLEAN BUFFER AND REOPEN S_ASYNCH
                    stop(s_asynch);                                                 % STOP ASYNCH
                    emg_asynch_data = [];                                           % CLEAN BUFFER
                    emg_asynch_time = [];                                           % CLEAN BUFFER
                    s_asynch.startBackground();                                     % START ASYNCH
                end

            end

        end
        


        %% CHECK WHETHER ENOUGH TRIALS HAVE BEEN COMPLETED
        trial.count = T == tms.reps;                                      % T = trials? (true/false)
      
        if trial.count && ~wait_for_data

            T = 0;                                                          % reset T to 0 (re-start the average on next repeat)

            %% AVERAGE MEP (across trials of 1:T)
            average.raw = nanmean(emg.data.raw(idx,:,:),2);
            average.baseline = nanmean(emg.baseline.raw(idx,:,:),2);
            emg.data.average(idx,tms.measure,:) = average.raw;
            emg.baseline.average(idx,tms.measure,:) = average.baseline;

            %% MEASURE MEP
            options.mep.baseline = 1:(abs(emg.mep.record.before)-1);
            [mep,options.mep] = MEP(average, s_asynch.Rate, abs(emg.mep.record.before),options.mep);


            %% MEASURE BASELINE
            emg.baseline.amplitude = max(emg.baseline.average(idx,tms.measure,:)) - min(emg.baseline.average(idx,tms.measure,:));              % change to emg.amplitude.baseline


            %% ASSESS MEP
            % mep.criterion = emg.mep.min + emg.baseline.amplitude;                    % include the baseline peak-to-peak emg before TMS
            % mep.criterion = emg.mep.min + model.criterion;
            mep.inrange = mep.amp(1)>= emg.baseline.amplitude && mep.amp(1)>=emg.mep.min && mep.amp(1) <= emg.mep.max; % WHETHER MEP IS IN RANGE
            

            %% save variables
            emg.mep.summary(idx,tms.currenttrial,:) = [mep.inrange,mep.amp(1),emg.baseline.amplitude,i];


            %% UPDATE mt
            if mep.inrange
                mt(idx,1) = mt(idx,1) + 1;                                  % HIT = SET mt(i,1)+1
            else
                mt(idx,2) = mt(idx,2) + 1;                                  % MISS = SET mt(i,2)+1
            end


            %% DISPLAY PROGRESS TO USER____________________________________
            disp (['Trial: ',int2str(tms.currenttrial), ', Intensity: ',int2str(i),'%MSO, baseline p2p: ',num2str(emg.baseline.amplitude,3),'mV, MEP: ',num2str(mep.amp(1),3),'mV, ',int2str(mep.inrange)]);


            %% ASSESS mt
            hit.count = mt(idx,1) == tms.hit;                               % mt(i,1) == tms.hit? (true/false)
            miss.count = mt(idx,2) == tms.miss;                             % mt(i,2) == tms.miss? (true/false)
            
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
                tms.intensity.sequence = [tms.intensity.sequence,i];        % SAVE INTENSITY SEQUENCE
                tms.intensity.index = [tms.intensity.index, idx];
                has_value = true;                                           % EXIT CURRENT INTENSITY
                TMS.disarm();                                               % DISARM TMS
                tms.currenttrial = 0;                                       % clear tms.currenttrial
            end

        end

    end

end

save(fullfile(save_folder,['RMT_Finder_',subject,'.mat']));



%% 

TMS.disconnect();
stop(s_asynch);
Screen('Close all');