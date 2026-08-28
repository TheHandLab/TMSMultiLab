function [wait,clock, update_time] = mt_wait(interval, initial_time)
%% rmtf_wait meansures the elapsed time interval and returns true when the interval reaches the specified duration.

% Inputs:
% interval     -> Time interval to wait (s).
% initial_time -> Start time (s).

% Outputs:
% wait         -> True if the specified time interval has elapsed.
% clock        -> Current time (s).
% update_time  -> Target time (initial_time + interval).


% Get curent time
clock = GetSecs;

% Calculate the target time.
update_time = initial_time+interval;

% Check whether the specified time interval has elapsed.
if clock >= update_time
    wait = false;
else
    wait = true;
end

end
