function [rms] = mt_measure_RMS(data)
%% rmtf_measure_RMS calculates the root mean square (RMS) of the input data.
% data (N×1) - Input data.


%% Remove DC offset
rms.chunk = data - mean(data);

%% Calculate the RMS
rms.value = sqrt(mean(rms.chunk.^2));

end