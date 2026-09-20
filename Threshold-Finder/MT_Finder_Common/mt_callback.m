%% Callback function for recording EMG data in the background
%
% The foreground -> the main program running in the MATLAB Command
% Window, while the background process runs asynchronously in parallel.
%
% This callback function should be used together with a listener. The
% listener should be configured before starting data acquisition.
%
% Use global variables to share data between the callback function and the
% main program.
%
% emg_asynch_chunk / emg_asynch_chunktime:
% Store one chunk of EMG data and its corresponding timestamps received
% from the listener during each callback.
%
% Each chunk currently contains 400 samples. This value can be changed in
% the listener configuration.
%
% emg_asynch_data / emg_asynch_time:
% Store the accumulated EMG data and timestamps. New data are appended
% each time the callback function is executed.
%
% If you want to access these variables inside a while or for loop, use
% 'drawnow' to allow MATLAB to process pending background callbacks and
% update the shared variables.
%
function mt_callback(~, event)

    %% Global variables
    global emg_asynch_data emg_asynch_time emg_asynch_chunk emg_asynch_chunktime   % is this re-doing something already done?

    %% Variables
    emg_asynch_chunk = event.Data;                                                 % chunk of data                         
    emg_asynch_chunktime = event.TimeStamps;                                       % chunk of timestamps
    emg_asynch_data = [emg_asynch_data; event.Data];                               % vector of data
    emg_asynch_time = [emg_asynch_time; event.TimeStamps];                         % vector of timestamps

end