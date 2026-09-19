%% parameters for QUEST_____________________________________________________ % *** change script name to QUEST_configure
quest.guess = settings.RMT*0.85;                                            % %MSO, MEAN OF INITIAL QUEST DISTRIBUTION
                                                                            % *** this only applies to AMT - need to make this work for all kinds of MT ***
                                                                            
quest.SD = quest.guess;                                                     % %MSO, SD OF INITIAL QUEST DISTRIBUTION
quest.threshold = 0.75;                                                     % proportion, THE p(MEP) that QUEST IS SEARCHING FOR
quest.beta = 3.5;                                                           % SLOPE OF THE PSYHOPHYSICAL FUNCTION
quest.delta = 0.01;                                                         % proportion, OF TRIALS BLIND / MISTAKEN RESPONSES (FALSE POSITIVES)
quest.gamma = 0.01;                                                         % RESPONSE IF THE SIGNAL IS ZERO
quest.grain = 0.1; %tms.resolution;                                         % RESOLUTION OF UNDERLYING DISTRIBUTION (%MSO)
quest.range = 2 .* quest.guess;                                             % %MSO, RANGE OF DISTRIBUTION

%% CREATE THE QUEST DISTRIBUTION____________________________________________
quest.q = QuestCreate(quest.guess, quest.SD(1), quest.threshold, quest.beta, quest.delta, quest.gamma, quest.grain, quest.range);
quest.q.normalizePdf=1;

                                                                            % *** these two tms parameters should be moved out of the quest_config ***
tms.intensity.quest = QuestQuantile(quest.q);                               % first Intensity
tms.intensity.same = 1;                                                     % Binary research only test intensity once, but QUEST may test mulitple times. this variable control this 

quest.range = tms.intensity.quest : tms.resolution:tms.intensity.min;       % *** why is quest.range being re-set here - see above ? - the distribution has already been created ***
quest.decision_trials = 10;                                                 % when to stop QUEST
quest.max_trials = 30;                                                      % *** what is this line doing, if decision = 10?


%% whether choose QUEST
quest.condition = settings.algorithm;                                       % *** why duplicate this variable? if algorithm=quest, then configure quest, otherwise don't configure it ***