%% DELIVER A TMS PULSE UNDER DIFFERENT TRIGGERING CONDITIONS________________
%
% The TMS pulse can be triggered without conditions, based on the baseline
% EMG criterion, or based on both the baseline EMG criterion and the
% required inter-pulse interval.
%
% Inputs:
% s_tms -> NI session used to send the TMS trigger to LabChart.
%         This session must be created before calling this function.
% tms  -> Structure containing the TMS trigger status.
% RMS  -> Logical value indicating whether the baseline EMG criterion is met.
% wait -> Logical value indicating whether the required inter-pulse
%          interval has elapsed
function [tms] = mt_present_TMS(s_tms, tms)                                 % this function only does anything if nargin==2

    % Initialise tms fields if they do not exist
    if nargin == 1
        tms = struct();                                                     % tms is already a variable outside this function - could be confusing?
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
        s_tms.outputSingleScan([1, 0]);                                     % Present TMS
        tms.trigger.condition = true;                                       % TMS condition (false = has not given pulse, ture = has given pulse)
        tms.trigger.time = GetSecs;                                         % Acquire time 
    
        if tms.trigger.condition                                            % *** this is always true - see 2 lines above ***
            s_tms.outputSingleScan([0,0]);                                  % Stop TMS *** this needs to wait for ~5ms to ensure the trigger is sent
        end
    end

end
