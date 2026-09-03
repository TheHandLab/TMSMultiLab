%% DEFINE CONSTANTS FOR HOW THE ALGORITHM WILL RUN
% This section defines the EMG acceptance criteria, MEP measurement
% windows, threshold-search rules, TMS intensity limits, and inter-pulse
% intervals used by the resting motor threshold procedure.
% Please check these settings before running the program.

% EMG-RELATED
emg.range = 5;                                                              % mV (setting in powerlab)
emg.display.tolerate = 4;  



% RMS-RELATED
emg.rms.duration = 150;                                                     % duration in ms for RMS recording to check background EMG signal (seconds)
% emg.rms.after = -2;                                                       % when to stop record the RMS (relative to the TMS pulse, seconds)
% emg.rms.before = emg.rms.after - emg.rms.duration;                        % when to record the RMS (relative to the TMS pulse, seconds)
emg.rms.min = 0;                                                            % minimum acceptable RMS to trigger a TMS pulse (same unit as the powerlab)
emg.rms.max = 0.05; %0.01;                                                         % maximum acceptable RMS to trigger a TMS pulse (same unit as the powerlab)

% BASELINE-RELATED
emg.baseline.before = -150;
emg.baseline.after = -1;



% MEP-RELATED
emg.mep.on = 10;                                                            % start of MEP measurement window after TMS
emg.mep.off = 50;                                                           % end of MEP measurement window after TMS

switch version.mt
    case 'Active'
        emg.mep.min = 0.2;                                                  % minimum acceptable MEP amplitude for a Hit (mV)
    case 'Rest'
        emg.mep.min = 0.05;                                                 % minimum acceptable MEP amplitude for a Hit (mV)
end

emg.mep.max = Inf;                                                          % maximum acceptable MEP amplitude for a Hit (mV)
emg.mep.record.before = -300;                                               % start of recorded EMG epoch relative to TMS (ms)
emg.mep.record.after = 700;                                                 % end of recorded EMG epoch relative to TMS (ms)   

% emg.mep.subtract_baseline = true / false % subtract emg p-to-peak from mep?


%% figure 
display.plot.label.x = 'Time (s)';
display.plot.label.y = 'mV';
display.plot.title = 'Matlab EMG';
display.plot.xrange = [-200,500];
display.plot.window.baseline = [emg.baseline.before,emg.baseline.after];
display.plot.window.MEP = [10,50];





