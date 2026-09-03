function data = rmtf_update_valid(data, valid, update_num)
%% Update the data based on the validation result.

% data -> input value.
% valid = 1 -> data is valid; otherwise, valid = 0.
% update_num -> how many should we add if valid

if nargin == 2 && ~exist('update_num','var')
    update_num = 1;
end

if valid
    data = data + update_num;                                               % ADD NEW VALUE TO THE DATA
end

end