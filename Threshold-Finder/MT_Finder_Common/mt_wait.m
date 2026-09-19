%% MEASURES ELAPSED TIME INTERVAL AND RETURNS TRUE WHEN REACHES THE SPECIFIED DURATION
% Inputs:
% interval     -> Time interval to wait (s)
% initial_time -> Start time (s)
%
% Outputs:
% wait         -> True if the specified time interval has elapsed.
% clock        -> Current time (s).
% update_time  -> Target time (initial_time + interval)
function [wait, clock, update_time] = mt_wait(interval, initial_time)       % *** is this function needed? ***

    clock = GetSecs;                                                        % Get curent time
    
    update_time = initial_time+interval;                                    % Calculate the target time

    % Check whether the specified time interval has elapsed
    if clock >= update_time
    
        wait = false;
	
    else
    
        wait = true;
	
    end

end