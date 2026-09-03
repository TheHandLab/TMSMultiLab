function [data_with_MEP, options, wait_for_data] = ...
    mt_acquire_emg_asynch(data, samplehz, pulsetime, options)
%% Acquire data before and after the TMS pulse 

% Inputs: 
% data  ->  Nx1 single-channel time-series data
% samplehz -> sampling frequency in Hz
% pulsetime -> pulse time in ms relative to the beginning of data

% options:
% options.before -> milliseconds before pulse, normally negative
% options.after  -> milliseconds after pulse

% Outpus:
% data_with_MEP -> data contains MEP
% wait_for_data -> true  -> data are not yet sufficient
% wait_for_data -> false -> MEP window was successfully extracted

if nargin < 4 || isempty(options)
    options = struct();
end

if ~isfield(options, 'before')
    options.before = -20;
end

if ~isfield(options, 'after')
    options.after = 100;
end

% Ensure data are arranged as a column
data = data(:);

% Convert the MEP window from milliseconds to sample indices
options.start_index = round( ...
    (pulsetime + options.before) * samplehz / 1000) + 1;

options.end_index = round( ...
    (pulsetime + options.after) * samplehz / 1000);


% Default: no waiting required
data_with_MEP = [];
wait_for_data = false;

% Check whether the requested window starts before available data
if options.start_index < 1
    wait_for_data = true;
    return
end

% Check whether enough post-stimulus data have arrived
if options.end_index > numel(data)
    wait_for_data = true;
    return
end

% Extract the MEP window
data_with_MEP = data(options.start_index:options.end_index);

end
