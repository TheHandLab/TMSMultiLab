function data_midpoint = rmtf_midpoint(data_min,data_max)
% rmtf_midpoint calculate the rounded midpoint between two values.

%% Inputs
% data_min -> lower value
% data_max -> upper value

%% Output
% data_midpoint -> Rounded midpoint of the two input values.
   
data_midpoint = round(mean([data_min,data_max]));

end