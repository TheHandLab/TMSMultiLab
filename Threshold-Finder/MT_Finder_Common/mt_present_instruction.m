function [feedback] = mt_present_instruction(win, wsize, text,feedback)
%% This function displays several lines of instructions at once. 


 feedback.color = [255,255,255];                                            % color of instructions
 feedback.wait = 0;                                                         % time for waiting                  
 feedback.line =  size(fieldnames(text),1);                                 % number of lines
 feedback.center = wsize(4) / 2;                                            % center of the display
 feedback.linespace = 80;                                                   % vertical distance between two lines
 feedback.startY = feedback.center - (feedback.line-1)/2 * feedback.linespace; % first line of coordinate

for i = 1:feedback.line
    feedback.yposition = feedback.startY + (i-1)*feedback.linespace;        % line coordinate
    DrawFormattedText(win, text.(sprintf('t%d', i)), 'center', feedback.yposition, feedback.color); % draw line
end

    Screen('Flip', win);                                                    % flip win
    WaitSecs(feedback.wait);                                                % if wait
    
end