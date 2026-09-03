function [count] = rmtf_count(T,trials)
%% Check whether two values are equal.

% Inputs:
% T -> value
% trials -> value

% Output:
% count -> True if these two values are equal

if T == trials
    count = 1;
else
    count = 0;
end

end

