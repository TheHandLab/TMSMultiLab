%% INITIALISE THE TMS_______________________________________________________ *** change script name to include TMS? ***
% Initialize these variables when the current intensity (i) is NaN.
% Once tms is armed, this condition will no longer be true.
% This ensures that the TMS can only be armed once.

if ~tms.state.arm                                                            % IF TMS IS NOT ARMED *** can this be done before calling the script? ***

    TMS.setAmplitudeA(i);                                                    % SET TMS INTENSITY, i


    %% IF NOT ALREADY TESTED, SET THIS INTENSITY AS INITIALISED_____________
    if sum(isnan(mt(idx.intensity, tms.intensity.same, 1:2)))==2             % if this intensity has two NaNs in the output variable mt
    
        mt(idx.intensity, tms.intensity.same, 1:2) = 0;                      % SET BOTH INDEXES TO ZERO
	
    end

    %% RESET TRIAL VARIABLES________________________________________________
    R = 0;                                                                  % RESET REPETITIONS PER INTENSITY AVERAGE TO ZERO
    clock = GetSecs;                                                        % RESET CLOCK FOR THE NEXT PULSE *** should this be done immediately after TMS to save time? ***
    TMS.arm();                                                              % ARM TMS *** this should also be checked immediately before presenting the TMS pulse, to avoid missing pulses ***
                                                                            % check for errors?
    tms.state.arm = true;                                                   % *** TRUE TMS STATE CAN BE RECEIVED VIA MAGIC - don't rely on this ***
    
end