% DETECT DIGITAL TTL TRIGGER FROM A CHANNEL_________________________________
%
% Inputs:
% data (Nx1)  -> trigger channel (only contains one trigger)
% samplehz    -> sampling frequency (Hz)
% trigger     -> *** what should be passed in? ***
%
% Outputs:
% trigger.range           -> 
% trigger.threshold       -> Detection threshold used
% trigger.onset_sample    -> Trigger onset sample indices
% trigger.offset_sample   -> Trigger offset sample indices
% trigger.onset_ms        -> Trigger onset times (ms)
% trigger.offset_ms       -> Trigger offset times (ms)
% trigger.duration_sample -> Trigger durations (samples)
% trigger.duration_ms     -> Trigger durations (ms)

function [trigger] = mt_trigger(data, samplehz, trigger)


    %% Make sure data is a column vector____________________________________
    data = data(:);                                                          % what happens if nargin==1 or nargin==3


    %% DETERMINE TRIGGER THRESHOLD__________________________________________
    if nargin == 2                                                          % what happens if nargin==1 or nargin==3

        trigger.range = max(data) - min(data);                              % Find data range  
    
        if trigger.range <= 1.5                                             % likely digital trigger (0 / 1) *** we can tell what kind of trigger it is by where it has come from: digital channel = digital trigger ***

            trigger.threshold = 0.5;
	
        else
            trigger.threshold = (max(data) + min(data)) ./ 2;               % likely analogue voltage trigger - *** function says this is only for digital triggers ***
        end

    end

    %% CONVERT TO BINARY SIGNAL____________________________________________
    trigger.binary = data > trigger.threshold;


    %% DETECT RISING EDGE (TRIGGER ONSET)__________________________________
    onset = find(diff(trigger.binary)==1) + 1;


    %% CHECK FOR MULTIPLE TRIGGERS_________________________________________
    if length(onset) > 1
        error('Multiple triggers detected');
    end


    %% DETECT FALLING EDGE (TRIGGER OFFSET)________________________________
    offset = find(diff(trigger.binary)==-1) + 1;


    %% CHECK IF TRIGGER IS ALREADY HIGH AT THE FIRST SAMPLE________________
    if trigger.binary(1)
        onset = [1; onset];
    end


    %% CHECK IF TRIGGER IS STILL HIGH AT LAST SAMPLE_______________________
    if trigger.binary(end)
        offset = [offset; length(data)];
    end


    %% PROCESS TRIGGER INFORMATION_________________________________________
    if isempty(onset)                                                       % if a trigger does not exist, save all variables as empty
    
        trigger.onset_sample = [];                                          % samples, trigger onset
        trigger.offset_sample = [];                                         % samples, trigger offset
        trigger.onset_ms = [];                                              % ms, trigger onset time
        trigger.offset_ms = [];                                             % ms, trigger offset time
        trigger.duration_sample = [];                                       % samples, trigger duration
        trigger.duration_ms = [];                                           % ms, trigger duration
        trigger.active = false;                                             % boolean, there is no trigger
	
    else
    
        trigger.onset_sample = onset;                                       % Trigger onset sample indices                                
        trigger.offset_sample = offset;                                     % Trigger offset sample indices
        trigger.onset_ms = (onset-1)/samplehz*1000;                         % ms, trigger onset time
        trigger.offset_ms = (offset-1)/samplehz*1000;                       % ms, trigger offset time
        trigger.duration_sample = offset-onset;                             % samples, trigger duration
        trigger.duration_ms = trigger.duration_sample/samplehz*1000;        % ms, trigger duration
        trigger.active = true;                                              % boolean, there is a trigger
	
    end

end