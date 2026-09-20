%% This function displays a bar and a target. The bar can represent any EMG variable
% Each RMS vector corresponds to one display frame. When used in a while loop,
% this function provides real-time feedback.
%
% Inputs
%    MVC of grip force
%    baseline of grip force
%    RMS(Nx1) -> vevtor for rms 
%    win
%    wsize related to the psychtoolbox
%    options
%        ...
%
% Outputs
%    ...
%
function [rms, bar, target, options] = mt_display_bar(MVC, baseline, RMS, win, wsize, options)

    %% PROCESS OPTIONAL PARAMETERS__________________________________________
    if ~isfield(options, 'boxbottom')
        options.boxbottom = 1000;                                           % Starting position of the bar
    end

    if ~isfield(options, 'Yrange')
        options.Yrange = 950;                                               % display range of y axis                                                     
    end

    if ~isfield(options, 'gain')
        options.gain = 0.3;                                                 % MVC target proportions
    end

    if ~isfield(options, 'center')
        options.center = wsize(3) ./ 2;                                     % position of display center
    end

    if ~isfield(options, 'barWidth')
        options.barWidth = 150;                                             % grip bar width
    end

    if ~isfield(options, 'line') || ~isfield(options.line, 'color')         % target line color
        options.line.color = [255, 0, 0];
    end
    
    if ~isfield(options, 'line') || ~isfield(options.line, 'Width')
        options.line.Width = 3;                                             % target line width
    end 

    if ~isfield(options, 'line') || ~isfield(options.line, 'overlength')
        options.line.overlength = 100;                                      % how long is the line longer than the bar
    end

    if ~isfield(options,'target') || ~isfield(options.target,'mode')
        options.target.mode = 'Above';                                      % how long does line longer than bar (above or below)
    end


    %% subject needs to keep grip above or below the target line
    switch lower(options.target.mode)
    
        case 'above'
	
            options.target.tolerate = 0.1;                                  % *** if always the same numbers (0.1), above/below can be used as +1 / -1 * the window ***
	                                                                    % *** why not define a bottom and top, and just check if inrange? ***
									    % *** the tolerance should be a variable ***
	    
        case 'below'
	
            options.target.tolerate = -0.1;
	    
    end

    bar.scale = options.Yrange ./ (MVC - baseline);                         % box scaling factor to convert EMG to pixels, where 100% = whole screen

    rms.mean = mean(RMS);                                                   % filter the rms

    bar.current_high = options.boxbottom - rms.mean .* bar.scale;           % height of the bar, related to the current rms


    %% target line coordinates
    target.line.Ypostion = options.boxbottom - (MVC-baseline) .* options.gain .* bar.scale;% line position in pixels (converted from dyna)_left hand
    target.line.position = [options.center - options.barWidth ./ 2 - options.line.overlength, target.line.Ypostion, options.center + options.barWidth ./ 2 + options.line.overlength, target.line.Ypostion];


    %% target window
    target.window.bottom = options.boxbottom - (MVC-baseline) .* (options.gain) .* bar.scale;   % bottom of window *** is this actually the TOP on the screen? (because pixels measured from top left? ***
    target.window.top = options.boxbottom - (MVC-baseline).*(options.gain + options.target.tolerate) .* bar.scale;  % top of window


    %% CHECK WHETHER THE CURRENT BAR HEIGHT IS INRANGE______________________
    if strcmp(options.target.mode, 'Above')

        target.inwindow.count = (bar.current_high <= target.window.bottom) && (bar.current_high>=target.window.top); % participants reach the target? *** count is not a count - it is a boolean, so should be just inwindow? ***
    
    elseif strcmp(options.target.mode, 'Below')

        target.inwindow.count = (bar.current_high >= target.window.bottom) && (bar.current_high<=target.window.top); % participants reach the target?
    
    end


    %% target Line color change
    if target.inwindow.count   % participants reach the target
  
        options.line.color = [255,0,0];                                     % change to red line *** options should not supposed to change within the function - need two variables for in and out of range ***
    
    else

        options.line.color = [255,255,255];                                 % keep white line
    
    end


    %% draw target line
    Screen('Drawline', win, options.line.color, target.line.position(1), target.line.position(2), target.line.position(3), target.line.position(4), options.line.Width);


    %% calculate bar position
    bar.position = [options.center - options.barWidth ./2, bar.current_high, options.center + options.barWidth ./2, options.boxbottom];% rectangle coordinates for the grip box (right hand)


    %% show bar
    if ~isempty(bar.position) && bar.current_high<options.boxbottom          % if participants grip

        Screen('FillRect', win, [255 0 0], bar.position);                    % show grip bar
	
    end

    %% timer
    target.clock = GetSecs;                                                  % record time for time loop to control TMS *** this should not be in the display_bar function! ***

end