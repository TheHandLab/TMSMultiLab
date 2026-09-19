%% DISPLAY SEVERAL LINES OF INSTRUCTIONS FOR DIFFERENT CONDITIIONS__________ 
function [feedback] = mt_present_instruction(win, wsize, text, feedback)

    feedback.color = [255,255,255];                                         % color of instructions	*** move to configure display ***
    feedback.wait = 0;                                                      % time for waiting     	*** move to configure display ***             
    feedback.center = wsize(4) ./ 2;                                        % center of the display	*** move to configure display ***
    feedback.linespace = 80;                                                % vertical line spaing 	*** move to configure display ***

    feedback.line =  size(fieldnames(text), 1);                             % number of lines to display
    feedback.startY = feedback.center - (feedback.line-1)./2 .* feedback.linespace;% first line of coordinate

    for i = 1:feedback.line
        feedback.yposition = feedback.startY + (i-1) .* feedback.linespace; % line coordinate
        DrawFormattedText(win, text.(sprintf('t%d', i)), 'center', feedback.yposition, feedback.color); % draw line
    end

    Screen('Flip', win);                                                    % flip window
    WaitSecs(feedback.wait);                                                % if waiting is needed
    
end