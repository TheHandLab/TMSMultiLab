function accepted = mt_askAccept()
%% assess should we accept the value 


%% keyboad condition
KbReleaseWait;

while true
    reply = input( ...
        'Accepted (y) or Not accepted (n)?\n', 's');

    reply = strtrim(reply);

    if strcmpi(reply, 'y')
        accepted = true;                                                    % accept
        return;                                                             % stop the funtion until make decision

    elseif strcmpi(reply, 'n')
        accepted = false;                                                   % do not accept
        return;     

    else
        fprintf('Please enter y or n.\n');
    end
end

end