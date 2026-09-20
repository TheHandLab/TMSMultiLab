%% START UP THE USER INTERFACE______________________________________________
%
function [settings, position, ax, input, updateIntensity] = mt_startUI()

    % set position of the window - *** can this be a vector [a, b, c, d] ****
    position.left = 200;
    position.bottom = 200;
    position.width = 1000;% *** is this *right* not width? ***
    position.height = 800; % *** is this *top* not height? ***


    %% OPEN A UI FIGURE_____________________________________________________
    fig = uifigure('Name', 'Experiment settings', 'Position', [position.left, position.bottom, position.width, position.height]);
    maingrid = uigridlayout(fig, [1, 1]);
    maingrid.Padding = [20, 20, 20, 20];
    fig.UserData.choose = [];


    %% SET UP SUBGROUPS FOR TABS____________________________________________
    tg = uitabgroup(maingrid);
    tab1 = uitab(tg, 'Title', 'Folder');
    tab2 = uitab(tg, 'Title', 'Setup');
    tab3 = uitab(tg, 'Title', 'View');


    %% TAB 1: FOLDERS AND IDS________________________________________________________________________________________________________________________ *** change all parameters to be in same order ***
																		     % *** set some things as default/variables - e.g figure('FontSize', '15')
    
    % OUTPUT FOLDER
    uilabel(tab1,                               'Text', 'Output Folder',     'FontSize', 15, 'FontWeight', 'bold',      'Position', [80 650 150 25]);
    input.savefolder = uieditfield(tab1,        'text',                                                                 'Position', [80 600 700 35]);
    uibutton(tab1,                      'push', 'Text', '...',                                                          'Position', [805 600 50 35], 'ButtonPushedFcn', @(btn,event) selectFolder(fig, input.savefolder));

    %  SUBJECT ID
    uilabel(tab1,                               'Text', 'Subject ID',        'FontSize', 15, 'FontWeight', 'bold',      'Position', [80 560 150 25]);
    input.subjectID = uieditfield(tab1,         'text',                                                                 'Position', [80 520 150 35]);
    
    % *** ADD SUBJECT HEIGHT, WEIGHT, AGE, SEX -> FOR PREDICTING LATENCY, AMPLITUDE ***
    
    % MUSCLE
    uilabel(tab1,                               'Text', 'Muscle',            'FontSize', 15  'FontWeight', 'bold',      'Position', [80 480 150 25]);
    input.muscle = uieditfield(tab1,            'text',                                                                 'Position', [80 440 150 35]);


    %% TAB 2. THRESHOLD AND ALGORITHM________________________________________________________________________________________________________________
    setupGrid = uigridlayout(tab2, [3 1]);
    setupGrid.RowHeight = {50, 300, '1x'};
    setupGrid.ColumnWidth = {'1x'};
    setupGrid.Padding = [20 20 20 20];

    % THRESHOLD MODE (Rest / Active)
    input.modeGroup = uibuttongroup(setupGrid,  'BorderType', 'none');
    input.modeGroup.Layout.Row = 1;
    input.modeGroup.Layout.Column = 1;

    rmt.Button = uiradiobutton(input.modeGroup, 'Text', 'Rest',              'FontSize', 16, 'FontWeight', 'bold',      'Position', [250 20 100 25]);
    amt.Button = uiradiobutton(input.modeGroup, 'Text', 'Active',            'FontSize', 16, 'FontWeight', 'bold',      'Position', [450 20 100 25]);

    % RESTING MOTOR THRESHOLD                                                      % *** not clear why algorithm is done separately for rest and active - any algorithm can be used for any type of threshold ***
    rmt.Panel = uipanel(setupGrid,              'BorderType', 'none');
    rmt.Panel.Layout.Row = 2;
    rmt.Panel.Layout.Column = 1;
    uilabel(rmt.Panel,                          'Text','Version',            'FontSize', 15, 'FontWeight','bold',       'Position', [50 280 150 25]); % *** use same font size throughout (eg font, font+2, font+4) ***
    rmt.Version = uieditfield(rmt.Panel,        'text',                                                                 'Position', [50 240 300 35]);
    input.rmt.VersionDropdown = uidropdown(rmt.Panel, 'Items',{'Select...', 'Auto RMT-Finder', 'Fast Auto RMT-Finder'}, 'Position', [365 240 150 35], 'ValueChangedFcn', @(dd, event) updateText(dd, rmt.Version));

    % ESTIMATED THRESHOLD ('Hotspot')
    uilabel(rmt.Panel,                          'Text', 'Hotspot',           'FontSize', 15, 'FontWeight', 'bold',      'Position', [50 200 150 25]);
    input.rmt.Hotspot = uieditfield(rmt.Panel,  'numeric',  'HorizontalAlignment', 'left'                               'Position', [50 160 300 35]);

    % DISPLAY OPTIONS *** this option only available if PsychtoolBox / Screen is available ***
    input.display= uicheckbox(rmt.Panel,        'Text', 'Display feedback?', 'FontSize', 15, 'FontWeight', 'bold',      'Position', [50 100 400 25], 'Value', false);

    % ACTIVE MOTOR THRESHOLD
    amt.Panel = uipanel(setupGrid,              'BorderType', 'none');
    amt.Panel.Layout.Row = 2;
    amt.Panel.Layout.Column = 1;
    uilabel(amt.Panel,                          'Text', 'RMT',               'FontSize', 15, 'FontWeight', 'bold',      'Position', [50 280 150 25]);
    input.amt.RMT = uieditfield(amt.Panel,      'numeric', 'HorizontalAlignment', 'left'                                'Position', [50 240 300 35]);
    uilabel(amt.Panel,                          'Text', 'Algorithm',         'FontSize', 15, 'FontWeight', 'bold',      'Position', [50 200 150 25]);
    input.amt.Algorithm = uieditfield(amt.Panel,'text',                                                                 'Position', [50 160 300 35]);
    input.amt.AlgorithmDropdown = uidropdown(amt.Panel, 'Items', {'Select...', 'QUEST', 'Binary search'},               'Position', [365 160 150 35], 'ValueChangedFcn', @(dd, event) updateText(dd, input.amt.Algorithm));

    % MVC LEVEL
    uilabel(amt.Panel,                          'Text', 'MVC Level',         'FontSize', 15, 'FontWeight', 'bold',      'Position', [50 120 150 25]);
    input.MVC = uieditfield(amt.Panel,          'text',                                                                 'Position', [50 80 300 35]);
    amt.MVCDropdown = uidropdown(amt.Panel,     'Items', ["Select...", string(0:100)],                                  'Position', [365 80 150 35],  'ValueChangedFcn', @(dd, event) updateText(dd, input.MVC));

    % SET PANEL DEFAULTS
    rmt.Button.Value = true;
    rmt.Panel.Visible = 'on';
    amt.Panel.Visible = 'off';

    % CALLBACK FUNCTION
    input.modeGroup.SelectionChangedFcn = @(src, event) changeMode(event, rmt.Panel, amt.Panel);


    %% TAB 3. RUN THRESHOLD-FINDER___________________________________________________________________________________________________________________
    
    % SET UP VIEWING PANEL
    viewGrid = uigridlayout(tab3, [6 1]);
    viewGrid.RowHeight = {30, 60, '1x', 150, 30};
    viewGrid.ColumnWidth = {'1x'};
    viewGrid.Padding = [40 20 40 30];
    viewGrid.RowSpacing = 5;

    % START BUTTON
    startGrid = uigridlayout(viewGrid, [1 2]);
    startGrid.Layout.Row = 1;
    startGrid.Layout.Column = 1;
    startGrid.ColumnWidth = {60, '1x'};
    startGrid.Padding = [0 0 0 0];
    startButton = uibutton(startGrid,           'push', 'Text', 'Start',     'FontSize', 15, 'FontWeight', 'bold',                                    'ButtonPushedFcn', @(btn, event) startExperiment(fig, input));
    startButton.Layout.Column = 1;

    % CURRENT STATUS
    currentGrid = uigridlayout(viewGrid, [1 10]);
    currentGrid.Layout.Row = 2;
    currentGrid.Layout.Column = 1;
    currentGrid.ColumnWidth = {140, 70, 50, 50, 50, 80, 120, 50, 80, 150};
    currentGrid.Padding = [0 0 0 0];
    currentGrid.ColumnSpacing = 5;

    % CURRENT INTENSITY
    uilabel(currentGrid,                        'Text','Current intensity:', 'FontSize', 15, 'FontWeight', 'bold');
    input.intensity = uilabel(currentGrid,      'Text', '-- %',              'FontSize', 18, 'FontWeight', 'bold');

    % TRIAL
    uilabel(currentGrid,                        'Text', 'Trial:',            'FontSize', 15, 'FontWeight', 'bold');
    input.trial = uilabel(currentGrid,          'Text', '--',                'FontSize', 18, 'FontWeight', 'bold');

    % MEP AMPLITUDE
    uilabel(currentGrid,                        'Text', 'MEP:',              'FontSize', 15, 'FontWeight', 'bold');
    input.MEP = uilabel(currentGrid,            'Text', '-- mV',             'FontSize', 18, 'FontWeight', 'bold');

    % MEP in range
    uilabel(currentGrid,                        'Text', 'MEP in Range:',     'FontSize', 15, 'FontWeight', 'bold');
    input.MEP_in_range = uilabel(currentGrid,   'Text', '--',                'FontSize', 18, 'FontWeight', 'bold');

    % BASELINE
    uilabel(currentGrid,                        'Text', 'Baseline:',         'FontSize', 15, 'FontWeight', 'bold');
    input.baseline = uilabel(currentGrid,       'Text', '-- mV',             'FontSize', 18, 'FontWeight', 'bold');

    % PLOTTING PANEL
    plotPanel = uipanel(viewGrid);
    plotPanel.Layout.Row = 3;
    plotPanel.Layout.Column = 1;
    plotGrid = uigridlayout(plotPanel, [1 2]);
    plotGrid.ColumnWidth = {150, '1x'};

    % LEFT SUB-PANEL (HISTORY)
    historyPanel = uipanel(plotGrid);
    historyPanel.BorderType = 'line';

    % INTEINSITY BOXES (UP TO 10)
    intensityGrid = uigridlayout(historyPanel, [10 1]);
    intensityGrid.RowHeight = repmat({25}, 1, 10);
    intensityGrid.ColumnWidth = {'1x'};

    % STRUCTURE FOR HISTORY
    input.boxNum = 1;
    input.intensityValue = NaN;
    input.lastIntensity = NaN;
    updateIntensity = @updateIntensityUI;

    % RIGHT SUB-PANEL (MAIN PLOT)
    ax = uiaxes(plotGrid);
    xlabel(ax, 'Time');
    ylabel(ax, 'Amplitude');
    grid(ax, 'on');

    % FINAL RESULT PANEL (%MT threshold, final intensity, counts at threshold (Hit:Miss), total % trials to criterion, mean baseline RMS & P2P (all trials - measure of noisiness); total time taking  (save time ended)

    % RESULTS PANEL
    resultPanel = uipanel(viewGrid);
    resultPanel.Layout.Row = 4;
    resultPanel.Layout.Column = 1;

    % LEFT RESULTS SUB-PANEL
    resultGrid = uigridlayout(resultPanel, [1 2]);
    resultGrid.ColumnWidth = {'1x', '2x'};
    resultGrid.RowHeight = {'1x'};
    resultGrid.Padding = [10 5 10 5];
    resultGrid.ColumnSpacing = 10;

    % SELECTED INTENSITY RESULT
    intensityResultGrid = uigridlayout(resultGrid, [1 2]);
    intensityResultGrid.Layout.Row = 1;
    intensityResultGrid.Layout.Column = 1;
    intensityResultGrid.Padding = [0 0 0 0];
    
    % HITS / MISSES
    uilabel(intensityResultGrid,                'Text', 'Hit/Miss:',         'FontSize', 15, 'FontWeight', 'bold');
    input.history.ratio = uilabel(intensityResultGrid, 'Text', '--',         'FontSize', 18, 'FontWeight', 'bold');

    % RIGHT RESULTS SUB-PANEL
    finalResultGrid = uigridlayout(resultGrid, [4 4]);
    finalResultGrid.Layout.Row = 1;
    finalResultGrid.Layout.Column = 2;
    finalResultGrid.ColumnWidth = {180, 100, 180, 160};
    finalResultGrid.Padding = [0 0 0 0];

    % ROW 1
    % MT TYPE (RMT or AMT)
    uilabel(finalResultGrid,                    'Text', 'MT:',               'FontSize', 15, 'FontWeight', 'bold');
    input.MTtype = uilabel(finalResultGrid,     'Text', '--',                'FontSize', 18, 'FontWeight', 'bold');

    % TOTAL TIME TAKEN
    uilabel(finalResultGrid,                    'Text', 'Total Time Taken:', 'FontSize', 15, 'FontWeight', 'bold');
    input.timetoken = uilabel(finalResultGrid,  'Text', '-- s',              'FontSize', 18, 'FontWeight', 'bold');

    % TOTAL TRIALS
    uilabel(finalResultGrid,                    'Text', 'Total Trials:',     'FontSize', 15, 'FontWeight', 'bold');
    input.trials = uilabel(finalResultGrid,     'Text', '--',                'FontSize', 18, 'FontWeight', 'bold');

    % ROW 3 *** 2? ***
    % THRESHOLD
    uilabel(finalResultGrid,                    'Text', 'Threshold:',        'FontSize', 15,  'FontWeight', 'bold');
    input.threshold = uilabel(finalResultGrid,  'Text', '-- %',              'FontSize', 18,  'FontWeight', 'bold');

    % Mean baseline
    uilabel(finalResultGrid,                    'Text', 'Mean Baseline:',    'FontSize', 15,  'FontWeight', 'bold');
    input.mean_baseline = uilabel(finalResultGrid, 'Text', '--',             'FontSize', 18,  'FontWeight', 'bold');

    % ROW 4
    % HIT / MISS
    uilabel(finalResultGrid,                    'Text', 'Hit/Miss:',         'FontSize', 15,  'FontWeight', 'bold');
    input.ratio = uilabel(finalResultGrid,      'Text', '-- ',               'FontSize', 18,  'FontWeight', 'bold');

    % MEAN P2P
    uilabel(finalResultGrid,                    'Text', 'Mean MEP amplitude:','FontSize', 15, 'FontWeight', 'bold');
    input.mean_p2p = uilabel(finalResultGrid,   'Text', '--',                 'FontSize', 18, 'FontWeight', 'bold');


    %% 
    uiwait(fig);
    settings = fig.UserData.settings;
    input.choose = fig.UserData.choose;
    

    %% ADD INTENSITY BUTTON_________________________________________________
    function input = updateIntensityUI(input)

        if input.intensityValue ~= input.lastIntensity

            % Create button
            button = uibutton(intensityGrid);
            button.Layout.Row = input.boxNum;
            button.Layout.Column = 1;
            button.Text = input.intensity.Text;

            % Store information for this button
            button.UserData.idx = input.boxNum;
            button.UserData.ratio = input.history.ratio.Text;

            % Button callback
            button.ButtonPushedFcn = @(btn,event) update_Selected_Intensity(btn.UserData);

            input.boxNum = input.boxNum + 1;

            % updata last intensity
            input.lastIntensity = input.intensityValue;

        end

    end


    %% UPDATE INTENSITY FUNCTION____________________________________________
    function update_Selected_Intensity(data)

        input.history.ratio.Text = data.ratio;

    end



end	% *** SHOULD THIS BE ABOVE THE TWO FUNCTIONS? ***


%% FUNCTIONS________________________________________________________________

%% SELECT FOLDER____________________________________________________________
function selectFolder(fig, folderField)

    folderPath = uigetdir(pwd, 'Select Input Folder');

    if folderPath ~= 0

        folderField.Value = folderPath;
	
    end

    figure(fig);

end


%% UPDATE TEXT______________________________________________________________
function updateText(dd, textField)

    textField.Value = dd.Value;
    
end


%% CHANGE MODE______________________________________________________________
function changeMode(event, rmtPanel, amtPanel)

    selectedMode = event.NewValue.Text;

    if strcmp(selectedMode, 'Rest')

        rmtPanel.Visible = 'on';
        amtPanel.Visible = 'off';

    elseif strcmp(selectedMode, 'Active')

        rmtPanel.Visible = 'off';
        amtPanel.Visible = 'on';
	
    end

end


%% START EXPERIMENT_________________________________________________________
function startExperiment(fig,input)

    saveSettings(fig,input);

    uiresume(fig);

end


%% SAVE SETTINGS____________________________________________________________
function saveSettings(fig, input)

    % Common settings
    settings.outputFolder = input.savefolder.Value;
    settings.subjectID    = input.subjectID.Value;
    settings.muscle       = input.muscle.Value;
    settings.MT = input.modeGroup.SelectedObject.Text;                      % Selected mode
    

    %% ACCORDING TO THRESHOLD MODE_________________________________________
    if strcmp(settings.MT, 'Rest')                                          % RESTING THRESHOLDS	*** not clear why - eg you can't use Binary Search with RMT (Fast + Binary Search = 'Fast Auto RMT-Finder') - these need to be options ***
    
        % Version
        if strcmp(input.rmt.VersionDropdown.Value, 'Auto RMT-Finder')
	
            settings.version = 'auto';
	    
        elseif strcmp(input.rmt.VersionDropdown.Value, 'Fast Auto RMT-Finder')
	
            settings.version = 'fast';
	    
        end

        settings.hotSpot = input.rmt.Hotspot.Value;                         % Hotspot
        
        settings.display = input.display.Value;                             % Display

        settings.algorithm = false;                                         % algorithm

        settings.MVC = '0';                                                 % set MVC=0

        settings.RMT = input.rmt.Hotspot.Value;                             % set RMT = hotspot

    elseif strcmp(settings.MT, 'Active')                                    % ACTIVE THRESHOLDS

        settings.RMT = input.amt.RMT.Value;                                 % RMT

        % Algorithm
        if strcmp(input.amt.AlgorithmDropdown.Value, 'QUEST')
	
            settings.algorithm = true;
	    
        elseif strcmp(input.amt.AlgorithmDropdown.Value, 'Binary search')
	
            settings.algorithm = false; % *** binary search is ALSO an algoritm *** - this needs to change
        end

        settings.MVC = input.MVC.Value;                                     % MVC

        settings.display = true;                                            % Active always shows feedback *** not clear why - this should be an option ***

        settings.version = 'amt';                                           % version *** this is giving the same information as settings.MT, remove one of them ***

    end


    %% FINISH UP
    fig.UserData.settings = settings;                                       % Store settings
    uiresume(fig);                                                          % Continue main program

end