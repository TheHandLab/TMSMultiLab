%% set posiible intensities that could use for detecting threshold 
% tms.intensity.min: the min possible value
% tms.intensity.max: the max possible value
% tms.resolution: granularity
% The first column of the mt vector is set to values ranging from tms.intensity.min : resolution : tms.intensity.max

% ROWS
% 1 INTENSITY
% 2 IF THERE IS SAME INTENSITY HAS BEEN TEST MULTIPLE TIMES

% COLUMNS
% 1 HITS at this intensity
% 2 MISSES at this intensity
% 3 INTENSITY = tms.resolution : tms.resolution : tms.intensity.max
% 4 INDEX to this intensity


% intensity here
tms.intensity.range = tms.intensity.min : tms.resolution: tms.intensity.max;% MSO


% index here
tms.index.range = 1:length(tms.intensity.range);                            % position in array

% max trial number for same intensity
tms.max_same = quest.decision_trials;

% set vector
mt = nan(length(tms.index.range),tms.max_same,4);                            % vector for possible intensities (mt(min %MSO : max %MSO,[valid,invalid]); 1->if has tested same intensity multiple times, 5-> columns
mt(:,:,3) = repmat(tms.intensity.range(:), 1, tms.max_same);                 % column 3: intensity
mt(:,:,4) = repmat(tms.index.range(:), 1, tms.max_same);                    % column 4: index 

%% for QUEST, if quest test a intensity multiple
% if quest test a intensity multiple times, column 5:number of this intensity has been tested

% save variables
tms.maxtrial = 10;
emg.data.raw = nan(length(tms.index.range),quest.decision_trials,tms.maxtrial,emg.asynch.samplesize);     % raw data of each pulse
emg.data.average = nan(length(tms.index.range),quest.decision_trials,tms.maxtrial,emg.asynch.samplesize); % averaged data
emg.baseline.raw = nan(length(tms.index.range),quest.decision_trials,tms.maxtrial,emg.baseline.samplesize);  % raw data of emg before the pulse
emg.mep.summary = nan(length(tms.index.range),quest.decision_trials,tms.maxtrial,4);                       % columns: 1-> miss or hit, 2-> mep amplitude, 3-> rms amplitude 4-> criterion 5-> intensity


