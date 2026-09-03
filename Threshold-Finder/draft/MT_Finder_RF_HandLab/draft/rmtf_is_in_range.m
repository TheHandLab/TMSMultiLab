function [inrange] = rmtf_is_in_range(data,range_min,range_max)
%% rmtf_is_in_range -> check whether a value is within a specified range

% Inputs:
% data      -> Value to be evaluated.
% range_min -> Lower bound of the range.
% range_max -> Upper bound of the range.

% Output:
% inrange   -> True if the value is within the specified range;
%               otherwise false.

% Check whether the value is within the specified range.
if data >= range_min && data <= range_max
    inrange = true;
else
    inrange = false;
end

end