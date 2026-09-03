%% Preallocation for the progromme
% Initialize these variables when the current intensity (i) is NaN.
% Once tms is armed, this condition will no longer be true.
% This ensures that the TMS can only be armed once.

if ~tms.state.arm                                                  

    %% set intensity
    TMS.setAmplitudeA(i); % i used as an INTENSITY

    %% Mark this intensity as initialized
    if sum(isnan(mt(idx.intensity,tms.intensity.same,1:2)))==2
        mt(idx.intensity,tms.intensity.same,1:2) = 0; % idx used as an index
    end

    %% Reset the TMS trials (repetitions per average MEP) pulse count (from 0 to tms.trials)
    R = 0;

    %% clock for the pulse
    clock = GetSecs;

    %% arm TMS 
    TMS.arm();

    % change arm state
    tms.state.arm = true;
end
