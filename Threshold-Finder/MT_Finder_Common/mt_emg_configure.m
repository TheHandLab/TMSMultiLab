%% DEFINE CONSTANTS FOR HOW THE ALGORITHM WILL RUN__________________________
% This section defines the EMG acceptance criteria, MEP measurement
% windows, threshold-search rules, TMS intensity limits, and inter-pulse
% intervals used by the resting motor threshold procedure.
% Please check these settings before running the program.

%% EMG-RELATED______________________________________________________________
emg.range = 5;                                                              % mV (setting in EMG amplifier) *** should this be a GAIN? ***
emg.display.tolerate = 4;                                                   % *** what does this do? ***


%% RMS-RELATED______________________________________________________________
emg.rms.duration = 150;                                                     % ms, duration in ms for RMS recording to check background EMG signal
                                                                            % *** is there a reason to have different windows for the baseline and RMS? they are both 150ms; use the same for all? ***
									    
% emg.rms.after = -2;                                                       % ms, when to stop record the RMS (relative to the TMS pulse)
% emg.rms.before = emg.rms.after - emg.rms.duration;                        % when to record the RMS (relative to the TMS pulse, seconds)
									    % *** why are these not used - delete? ***

emg.rms.min = 0;                                                            % mV, minimum acceptable RMS to trigger a TMS pulse (same unit as the EMG amplifier)
emg.rms.max = 0.05; %0.01;                                                  % mV, maximum acceptable RMS to trigger a TMS pulse (same unit as the EMG amplifier)


%% BASELINE-RELATED_________________________________________________________
emg.baseline.before = -150;                                                 % ms, start time relative to TMS to measure the baseline
emg.baseline.after = -1;                                                    % ms, end time relative to TMS to measure the baseline


%% MEP-RELATED______________________________________________________________
emg.mep.on = 10;                                                            % ms, start of MEP measurement window after TMS
emg.mep.off = 50;                                                           % ms, end of MEP measurement window after TMS
switch version.mt

    case 'Active'
        emg.mep.min = 0.2;                                                  % mV, minimum acceptable MEP amplitude for a Hit
	
    case 'Rest'
        emg.mep.min = 0.05;                                                 % mV, minimum acceptable MEP amplitude for a Hit
end

emg.mep.max = Inf;                                                          % mV, maximum acceptable MEP amplitude for a Hit
emg.mep.record.before = -300;                                               % ms, start of recorded EMG epoch relative to TMS
emg.mep.record.after = 700;                                                 % ms, end of recorded EMG epoch relative to TMS

% emg.mep.subtract_baseline = true / false % subtract emg p-to-peak from mep?


%% PLOT SETTINGS____________________________________________________________ 
display.plot.label.x = 'Time (s)';
display.plot.label.y = 'mV';
display.plot.title = 'Matlab EMG';
display.plot.xrange = [-200, 500];
display.plot.window.baseline = [emg.baseline.before, emg.baseline.after];
display.plot.window.MEP = [10, 50];                                         % *** this is the same as emg.mep.on | off - either use those variables in the plot, or replace the values here





