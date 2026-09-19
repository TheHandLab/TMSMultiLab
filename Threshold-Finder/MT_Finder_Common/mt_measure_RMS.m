%% CALCULATE THE RMS OF THE INPUT DATA______________________________________ *** is there an existing Matlab function for this?
% data (N×1) - Input data.
function [rms] = mt_measure_RMS(data)

    %% Remove DC offset
    rms.chunk = data - mean(data);                                           % reduce these two lines to one

    %% Calculate the RMS
    rms.value = sqrt(mean(rms.chunk.^2));

end