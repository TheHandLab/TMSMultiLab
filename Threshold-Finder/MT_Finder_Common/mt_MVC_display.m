%% DISPLAY A BAR SHOWING MUSCLE ACTIVIITY___________________________________ *** rewrite as a function that receives only the screen sizes and emg levels to display ***
									     % *** this function is doing 3 things - simplify ***

%% SAVE DATA________________________________________________________________ *** this should be done somewhere else ***
rms.data = [rms.data; RMS.value];
rms.time = [rms.time; tms.clock];

if size(rms.data,1) > emg.filter.size                                       % If we have enough data

    % display bar
    [rms.filter, bar,target, display] = mt_display_bar(display.MVC, baseline.value, rms.data(end-emg.filter.size+1:end), win, wsize, display);

    % if pulse has just been delivered, remove the artifact after the pulse *** the above line displays something, so why is this happening again? better to send the trigger time to this function and exclude it?
    if trigger.active && (GetSecs - tms.trigger.time) .* 1000 <= emg.mep.off
    
        rms.trigger.index = find(rms.time >= tms.trigger.time, 1, 'first');
	
        [rms.filter, bar, target, display] = mt_display_bar(display.MVC, baseline.value, rms.data(rms.trigger.index-emg.filter.size+1:rms.trigger.index), win, wsize, display);
    end


    % flip window
    Screen('Flip',win);

    if target.inwindow.count
    
        %% start timer when rms is the first time in the target window
        if emg.startin == 0                                                 % if this is the first frame inside window
            emg.startin = tms.clock;                                        % record start time
        end


        %% duration in the target window
        emg.timeinwindow = tms.clock - emg.startin;                         % duration in the target window


        %% PRESENT TMS IF RMS IS IN RANGE AND IT HAS BEEN LONG ENOUGH SINCE THE LAST PULSE
        if emg.timeinwindow > emg.inwindow.tolerate && ~wait                % && tms.pedal.control == 1                % Force has remained within the target window for 0.1 sec (emg.inwindow.tolerate)
            [tms] = mt_present_TMS(s_tms,tms);                              % PRESENT TMS IF ALL CRITERIONS MET
        end
    end
end