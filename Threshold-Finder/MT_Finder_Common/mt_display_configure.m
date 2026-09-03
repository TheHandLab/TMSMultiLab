%% display constant
win_number = 1;
win_background_color = [0 0 0];
Screen('Preference', 'SkipSyncTests', 3);                                   % start psychtoolbox
[win,wsize]=Screen('Openwindow',win_number,win_background_color);           % open window

%% constant of Display
display.endY = 50;                                                          % end coordinate of y axis
display.startY = wsize(4)-display.endY;                                     % start coordinate of y axis
display.Yrange = display.startY - display.endY;                             % y range                                   
display.crossSize = 20;                                                     % the size of fixition cross                                        
display.boxbottom = display.startY;                                         % coordinate on the screen
display.center = wsize(3)/2;                                                % coordinate of center
display.barWidth = 150;                                                     % force bar width 
display.line.Width = 3;                                                     % target line width
display.line.overlength = 100;                                              % the length that target longer than bar
display.line.color = [255,0,0];                                             % line color

%% constant of emg
emg.filter.size = 60;                                                       % filter window
emg.startin = 0;                                                            % in window control
emg.inwindow.tolerate = 0.2;                                                % Time the participant stays within the target window before delivering the TMS pulse.


