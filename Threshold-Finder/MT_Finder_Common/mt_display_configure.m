%% OPEN PSYCHTOOLBOX SCREEN_________________________________________________
win_number = 1;								    % which screen window to use for subject feedback (0, 1, ...)
win_background_color = [0 0 0];						    % background colour
Screen('Preference', 'SkipSyncTests', 3);                                   % start psychtoolbox
[win, wsize] = Screen('Openwindow', win_number, win_background_color);      % open window


%% DISPLAY CONSTANTS________________________________________________________
display.endY = 50;                                                          % pixels, end coordinate of y axis
display.startY = wsize(4) - display.endY;                                   % pixels, start coordinate of y axis
display.Yrange = display.startY - display.endY;                             % pixels, y axis range                                   
display.crossSize = 20;                                                     % pixels, the size of fixition cross                                        
display.boxbottom = display.startY;                                         % pixels, coordinate on the screen
display.center = wsize(3) ./ 2;                                             % pixels, coordinate of center

% EMG activity bar
display.barWidth = 150;                                                     % pixels, EMG feedback bar width
									    % *** add option for activity bar colour ***

% target activity bar
display.line.Width = 3;                                                     % pixels, target line width
display.line.overlength = 100;                                              % pixels, additional length of target line compared to EMG bar
display.line.color = [255,0,0];                                             % line color when target reached
									    % *** add vaiable for target not reached colour ***


%% constant of emg	*** move these to EMG configure script
emg.filter.size = 60;                                                       % filter window
emg.startin = 0;                                                            % in window control
emg.inwindow.tolerate = 0.2;                                                % Time the participant stays within the target window before delivering the TMS pulse