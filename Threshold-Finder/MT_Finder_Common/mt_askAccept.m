%% EXPERIMENTER INPUT TO ACCEPT THE RECORDED VALUE__________________________ *** this could also be used for MEP decisions ***

function accepted = mt_askAccept()

    KbReleaseWait;                                                          % WAIT UNTIL ALL KEYS HAVE BEEN RELEASED

    while true % *** while *what* is true? ***
    
        reply = input('Accepted (y) or Not accepted (n)?\n', 's');          % *** is input also the name of the GUI? ***

        reply = strtrim(reply);                                             % REMOVE SPACES FROM REPLY

        if strcmpi(reply, 'y')                                              % if lower-case y is received *** what about upper case ***
            accepted = true;                                                % accept the response
            return;                                                         % stop the function until make decision *** can the while variable be used here ***

        elseif strcmpi(reply, 'n')                                          % if lower-case n is received *** what about upper case ***
            accepted = false;                                               % do not accept
            return;                                                         % stop the function until make decision *** can the while variable be used here ***

        else
            fprintf('Please enter y or n.\n');                              % *** the while loop can be while reply ~= n & reply ~=y ***
        end
	
    end

end