%% This script sets up your local environment_______________________________
% The lines below will need to be edited to work with your local filesystem
% if you prefer, you can permanently add the directories to your Matlab path (addpath... savepath...), then comment-out these lines


% ADD TMSMultiLab Repository to the path____________________________________
% this file is part of the TMSMultiLab repository, but if you do not have it, clone from here:
% https://github.com/TMSMultiLab/TMSMultiLab
addpath(genpath('D:\TMSMultiLab'));


%% ADD MAGIC TOOLBOX Repository to the path_________________________________
% this toolbox controls your TMS device
% https://github.com/nigelrogasch/MAGIC/releases
% addpath(genpath('C:\MATLAB\R2023a\Toolbox')		*** CHECK THIS ***


% ADD PSYCHTOOLBOX (QUEST) to the path______________________________________
% https://www.psychtoolbox.net/
% https://github.com/Psychtoolbox-3/Psychtoolbox-3
% addpath(genpath('C:\MATLAB\R2023a\PsychToolBox')	*** CHECK THIS ***


% ARE ALL DEPENDENCIES PRESENT?_____________________________________________
% check the dependencies here				*** CHECK THIS ***
% 
% data acquisition toolbox required for NI-DAq interface
% 