%% when users choose display (no matter amt or rmt) 
%% this script will show a bar responding to the muscle activity 

%% save data
rms.data = [rms.data; RMS.value];
rms.time = [rms.time; tms.clock];

if size(rms.data,1) > emg.filter.size                                       % If we have enough data
    %% display bar
    [rms.filter,bar,target,display] = mt_display_bar(display.MVC, ...
        baseline.value,rms.data(end-emg.filter.size+1:end), ...
        win,wsize,display);

    %% If the pulse has been delivered, remove the artifact after the pulse.
    if trigger.active && (GetSecs - tms.trigger.time)*1000 <= emg.mep.off
        rms.trigger.index = find(rms.time >= tms.trigger.time,1,'first');
        [rms.filter,bar,target,display] = mt_display_bar(display.MVC, ...
            baseline.value,rms.data(rms.trigger.index-emg.filter.size+1:rms.trigger.index), ...
            win,wsize,display);
    end

    %% filp window
    Screen('Flip',win);

    if target.inwindow.count
        %% start timer when rms is the first time in the target window
        if emg.startin == 0                                                 % if this is the first frame inside window
            emg.startin = tms.clock;                                        % record start time
        end


        %% duration in the target window
        emg.timeinwindow = tms.clock - emg.startin;                         % duration in the target window


        %% PRESENT TMS IF RMS IS IN RANGE AND IT HAS BEEN LONG ENOUGH SINCE THE LAST PULSE
        if emg.timeinwindow > emg.inwindow.tolerate && ~wait && tms.pedal.control == 1                % Force has remained within the target window for 0.1 sec (emg.inwindow.tolerate)
            [tms] = mt_present_TMS(s_tms,tms);                              % PRESENT TMS IF ALL CRITERIONS MET
        end
    end
end