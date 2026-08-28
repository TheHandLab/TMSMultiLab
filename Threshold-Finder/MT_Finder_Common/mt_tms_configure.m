%% DESIGN for TMS__________________________________________________________
% version.mt = [Rest, Active]
% version.type = [auto, fast, amt]


%% measurement number
switch version.mt
    case 'Rest'
        tms.reps = 1;                                                       % average this number of trials before assessing MEP amplitude
        tms.hit = 5;                                                        % need this many hits before changing intensity
        tms.miss = 6;                                                       % need this many misses before changing intensity
    case 'Active'
        tms.reps = 5;                                                       % average this number of trials before assessing MEP amplitude
        tms.hit = 1;                                                        % need this many hits before changing intensity
        tms.miss = 1;                                                       % need this many misses before changing intensity
end

tms.currenttrial =0;


% TMS interval
% Different TMS intervals are used in different versions
switch version.type
    case 'auto'                                                             % AUTO
        tms.intensity.min = 20;                                             % min TMS intensity
        tms.intensity.max = 90;                                             % max TMS intensity

    case 'fast'                                                             % RAPID AUTO
        tms.interval = 4.5;                                                 % fixed interval between TMS pulses
        tms.intensity.hotspot = settings.hotSpot;
        tms.intensity.min = tms.intensity.hotspot-10;                       % min TMS intensity
        tms.intensity.max = tms.intensity.hotspot+10;                       % max TMS intensity

    case 'amt'
        tms.interval = 4.5;                                                 % amt 
        tms.intensity.rmt = settings.RMT;                                   
        tms.intensity.min = 10;                                             % min TMS intensity
        tms.intensity.max = tms.intensity.rmt;                              % max TMS intensity
end


%% SET UP TMS MACHINE - REQUIRES MAGIC TOOLBOX_____________________________
% Please check the COM port for your TMS device before running this program
tms.port = 'COM8';                                                          % serial port address to control your Magstim TMS machine
tms.resolution = 1;                                                         % interval between successive TMS intensities, in % MSO
TMS = magstim(tms.port);                                                    % use MAGIC toolbox to control Magstim TMS
TMS.connect();                                                              % establish a connection
tms.trigger.time = 0;                                                       % initialise start time for TMS interval
tms.trigger.condition = false;                                              % has TMS been presented?
tms.intensity.sequence = [];                                                % vector contains a sequence of intensity values
tms.intensity.index = [];                                                   % vector contains a sequence of intensity index
tms.state.arm = false;                                                      % tms arm control


