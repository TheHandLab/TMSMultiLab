function [tms] = mt_present_TMS(s_tms,tms)
%% Deliver a TMS pulse under different triggering conditions.

% The TMS pulse can be triggered without conditions, based on the baseline
% EMG criterion, or based on both the baseline EMG criterion and the
% required inter-pulse interval.

% Inputs:
% s_tms -> NI session used to send the TMS trigger to LabChart.
%         This session must be created before calling this function.
% tms  -> Structure containing the TMS trigger status.
% RMS  -> Logical value indicating whether the baseline EMG criterion is met.
% wait -> Logical value indicating whether the required inter-pulse
%          interval has elapsed

% Initialise tms fields if they do not exist
if nargin == 1
    tms = struct();
end

% Initialise trigger fields if they do not exist
if ~isfield(tms, 'trigger')
    tms.trigger = struct();
end

% Initialise condition fields if they do not exist
if ~isfield(tms.trigger, 'condition')
    tms.trigger.condition = false;
end

% Initialise time fields if they do not exist
if ~isfield(tms.trigger, 'time')
    tms.trigger.time = [];
end

if nargin == 2
    s_tms.outputSingleScan([1,0]);                                         % Present TMS 
    tms.trigger.condition = true;                                          % TMS condition (false = has not given pulse, ture = has given pulse)
    tms.trigger.time = GetSecs;                                            % Acquire time 
    
    if tms.trigger.condition                                               
        s_tms.outputSingleScan([0,0]);                                     % Stop TMS
    end
end

end
