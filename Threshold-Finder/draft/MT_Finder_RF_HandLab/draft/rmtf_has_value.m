function has_value = rmtf_has_value(data)
%% rmtf_has_value checks whether the input value(s) are not NaN.
% has_value = 1: the input is not NaN.
% has_value = 0: the input is NaN.

if isnan(data)
    has_value = 0;
else
    has_value = 1;
end

end


