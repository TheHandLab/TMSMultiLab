function [trigger] = mt_trigger(data, samplehz,trigger)
% rmtf_trigger detect TTL trigger (digital) from a trigger channel

% Inputs:
% data (Nx1)  -> trigger channel (only contains one trigger)
% samplehz    -> sampling frequency (Hz)

% Outputs:
% trigger.onset_sample    -> Trigger onset sample indices.
% trigger.offset_sample   -> Trigger offset sample indices.
% trigger.onset_ms        -> Trigger onset times (ms).
% trigger.offset_ms       -> Trigger offset times (ms).
% trigger.duration_sample -> Trigger durations (samples).
% trigger.duration_ms     -> Trigger durations (ms).
% trigger.threshold       -> Detection threshold used.

%% Make sure data is a column vector
data = data(:);

%% determine threshold
if nargin == 2 

    trigger.range = max(data) - min(data);                                  % Find data range  
    
    if trigger.range <= 1.5                                                 % likely digital trigger (0 / 1)
        trigger.threshold = 0.5;
    else
        trigger.threshold = (max(data) + min(data))/2;                      % likely analogue voltage trigger
    end

end

%% convert to binary signal
trigger.binary = data > trigger.threshold;

%% detect rising edge (trigger onset)
onset = find(diff(trigger.binary)==1) + 1;

%% check for multiple triggers
if length(onset) > 1
    error('Multiple triggers detected');
end

%% detect falling edge (trigger offset)
offset = find(diff(trigger.binary)==-1) + 1;

%% Trigger already high at first sample
if trigger.binary(1)
    onset = [1; onset];
end

%% Trigger still high at last sample
if trigger.binary(end)
    offset = [offset; length(data)];
end

%% check whether a trigger exists
if isempty(onset)                                                           % if a trigegr is not exist, save all variables as NaN
    trigger.onset_sample = [];                                              % Trigger onset sample indices.
    trigger.offset_sample = [];                                             % Trigger offset sample indices
    trigger.onset_ms = [];                                                  % Trigger onset times (ms).
    trigger.offset_ms = [];                                                 % Trigger offset times (ms).
    trigger.duration_sample = [];                                           % Trigger durations (samples).
    trigger.duration_ms = [];                                               % Trigger durations (ms).
    trigger.active = false;                                                 % There isn't a trigger
else
    trigger.onset_sample = onset;                                           % Trigger onset sample indices.                                    
    trigger.offset_sample = offset;                                         % Trigger offset sample indices
    trigger.onset_ms = (onset-1)/samplehz*1000;                             % Trigger onset times (ms).
    trigger.offset_ms = (offset-1)/samplehz*1000;                           % Trigger offset times (ms).
    trigger.duration_sample = offset-onset;                                 % Trigger durations (samples).
    trigger.duration_ms = trigger.duration_sample/samplehz*1000;            % Trigger durations (ms).
    trigger.active = true;                                                  % There is a trigger
end

end