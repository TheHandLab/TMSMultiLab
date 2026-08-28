function [average] = rmtf_average(data)
%% Calculate the mean of the input data along the first dimension.
%% data (MxN), make sure M is the trial 

average = nanmean(data,1);

end