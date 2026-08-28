function [settings,position,ax,input,updateIntensity] = mt_startUI ()

position.left = 200;
position.bottom = 200;
position.width = 1000;
position.height = 800;


%% UI for all configurable variables
fig = uifigure('Name', 'Experiment settings', 'Position',[position.left,position.bottom,position.width,position.height]);
maingrid = uigridlayout(fig,[1,1]);
maingrid.Padding = [20,20,20,20];
fig.UserData.choose = [];

%% subgroup
tg = uitabgroup(maingrid);
tab1 = uitab(tg,'Title','Folder');
tab2 = uitab(tg,'Title','Setup');
tab3 = uitab(tg,'Title','View');

%% output folder 
uilabel(tab1, ...
    'Text', 'Output Folder', ...
    'FontWeight', 'bold', ...
    'Position', [80 650 150 25],'FontSize',15);


input.savefolder = uieditfield(tab1, 'text', ...
    'Position', [80 600 700 35]);

uibutton(tab1, 'push', ...
    'Text', '...', ...
    'Position', [805 600 50 35], ...
    'ButtonPushedFcn', @(btn,event) selectFolder(fig,input.savefolder));

%%  subject ID
uilabel(tab1, ...
    'Text', 'Subject ID', ...
    'FontWeight', 'bold', ...
    'Position', [80 560 150 25],'FontSize',15);


input.subjectID = uieditfield(tab1, 'text',...
    'Position', [80 520 150 35]);






%% 2. RMT or AMT
setupGrid = uigridlayout(tab2,[3 1]);
setupGrid.RowHeight = {50,300,'1x'};
setupGrid.ColumnWidth = {'1x'};
setupGrid.Padding = [20 20 20 20];

%% Mode area
input.modeGroup = uibuttongroup(setupGrid, ...
    'BorderType','none');

input.modeGroup.Layout.Row = 1;
input.modeGroup.Layout.Column = 1;

rmt.Button = uiradiobutton(input.modeGroup, ...
    'Text','Rest', ...
    'FontSize',16, ...
    'FontWeight','bold', ...
    'Position',[250 20 100 25]);

amt.Button = uiradiobutton(input.modeGroup, ...
    'Text','Active', ...
    'FontSize',16, ...
    'FontWeight','bold', ...
    'Position',[450 20 100 25]);

%% Panel of rmt

rmt.Panel = uipanel(setupGrid, ...
'BorderType','none');

rmt.Panel.Layout.Row = 2;
rmt.Panel.Layout.Column = 1;


%% Version label
uilabel(rmt.Panel, ...
    'Text','Version', ...
    'FontWeight','bold', ...
    'FontSize',15, ...
    'Position',[50 280 150 25]);

rmt.Version = uieditfield(rmt.Panel,'text', ...
    'Position',[50 240 300 35]);

input.rmt.VersionDropdown = uidropdown(rmt.Panel, ...
    'Items',{'Select...', ...
             'Auto RMT-Finder', ...
             'Fast Auto RMT-Finder', ...
             }, ...
    'Position',[365 240 150 35], ...
    'ValueChangedFcn', ...
    @(dd,event) updateText(dd,rmt.Version));

%% Hotspot
uilabel(rmt.Panel, ...
    'Text','Hotspot', ...
    'FontWeight','bold', ...
    'FontSize',15, ...
    'Position',[50 200 150 25] ...
    );

input.rmt.Hotspot = uieditfield(rmt.Panel,'numeric', ...
    'Position',[50 160 300 35], ...
    'HorizontalAlignment','left');

%% display
input.display= uicheckbox(rmt.Panel, ...
    'Text',' Display : Show feedback on screen', ...
    'FontSize',15, ...
    'FontWeight','bold', ...
    'Position',[50 100 400 25], ...
    'Value',false);


%% Panel of amt

amt.Panel = uipanel(setupGrid, ...
'BorderType','none');
amt.Panel.Layout.Row = 2;
amt.Panel.Layout.Column = 1;

%% RMT
uilabel(amt.Panel, ...
    'Text','RMT', ...
    'FontWeight','bold', ...
    'FontSize',15, ...
    'Position',[50 280 150 25]);

input.amt.RMT = uieditfield(amt.Panel,'numeric', ...
    'Position',[50 240 300 35], ...
    'HorizontalAlignment','left');

%% Algorithm
uilabel(amt.Panel, ...
    'Text','Algorithm', ...
    'FontWeight','bold', ...
    'FontSize',15, ...
    'Position',[50 200 150 25]);

input.amt.Algorithm = uieditfield(amt.Panel,'text', ...
    'Position',[50 160 300 35]);

input.amt.AlgorithmDropdown = uidropdown(amt.Panel, ...
    'Items',{'Select...', ...
             'QUEST', ...
             'Binary search'}, ...
    'Position',[365 160 150 35], ...
    'ValueChangedFcn', ...
    @(dd,event) updateText(dd,input.amt.Algorithm));


%% MVC Level
uilabel(amt.Panel, ...
    'Text','MVC Level', ...
    'FontWeight','bold', ...
    'FontSize',15, ...
    'Position',[50 120 150 25]);

input.MVC = uieditfield(amt.Panel,'text', ...
    'Position',[50 80 300 35]);

amt.MVCDropdown = uidropdown(amt.Panel, ...
    'Items',["Select...", string(0:100)], ...
    'Position',[365 80 150 35], ...
    'ValueChangedFcn', ...
    @(dd,event) updateText(dd,input.MVC));



%% change panel
rmt.Button.Value = true;
rmt.Panel.Visible = 'on';
amt.Panel.Visible = 'off';


%% callback

input.modeGroup.SelectionChangedFcn = ...
    @(src,event) changeMode(event,rmt.Panel,amt.Panel);



%% tab3 = View
viewGrid = uigridlayout(tab3,[6 1]);
viewGrid.RowHeight = {30, 60, '1x', 150, 30};
viewGrid.ColumnWidth = {'1x'};
viewGrid.Padding = [40 20 40 30];
viewGrid.RowSpacing = 5;

%% Start
startGrid = uigridlayout(viewGrid,[1 2]);
startGrid.Layout.Row = 1;
startGrid.Layout.Column = 1;
startGrid.ColumnWidth = {60,'1x'};
startGrid.Padding = [0 0 0 0];

startButton = uibutton(startGrid,'push', ...
    'Text','Start', ...
    'FontSize',15, ...
    'FontWeight','bold', ...
    'ButtonPushedFcn', ...
    @(btn,event) startExperiment(fig,input));

startButton.Layout.Column = 1;


%% current statu
currentGrid = uigridlayout(viewGrid,[1 10]);
currentGrid.Layout.Row = 2;
currentGrid.Layout.Column = 1;
currentGrid.ColumnWidth = ...
    {140, 70, ...
      50, 50, ...
      50, 80, ...
     120, 50, ...
      80, 150};
currentGrid.Padding = [0 0 0 0];
currentGrid.ColumnSpacing = 5;

%% Current Intensity
uilabel(currentGrid, ...
    'Text','Current Intensity:', ...
    'FontSize',15, ...
    'FontWeight','bold');

input.intensity = uilabel(currentGrid, ...
    'Text','-- %', ...
    'FontSize',18, ...
    'FontWeight','bold');

%% Trial
uilabel(currentGrid, ...
    'Text','Trial:', ...
    'FontSize',15, ...
    'FontWeight','bold');

input.trial = uilabel(currentGrid, ...
    'Text','--', ...
    'FontSize',18, ...
    'FontWeight','bold');

%% MEP amplitude
uilabel(currentGrid, ...
    'Text','MEP:', ...
    'FontSize',15, ...
    'FontWeight','bold');

input.MEP= uilabel(currentGrid, ...
    'Text','-- mV', ...
    'FontSize',18, ...
    'FontWeight','bold');

%% MEP in range
uilabel(currentGrid, ...
    'Text','MEP in Range:', ...
    'FontSize',15, ...
    'FontWeight','bold');

input.MEP_in_range = uilabel(currentGrid, ...
    'Text','--', ...
    'FontSize',18, ...
    'FontWeight','bold');
%% baseline
uilabel(currentGrid, ...
    'Text','Baseline:', ...
    'FontSize',15, ...
    'FontWeight','bold');

input.baseline = uilabel(currentGrid, ...
    'Text','-- mV', ...
    'FontSize',18, ...
    'FontWeight','bold');





% plot panel
plotPanel = uipanel(viewGrid);
plotPanel.Layout.Row = 3;
plotPanel.Layout.Column = 1;

plotGrid = uigridlayout(plotPanel,[1 2]);
plotGrid.ColumnWidth = {150,'1x'};

% left box
historyPanel = uipanel(plotGrid);
historyPanel.BorderType = 'line';

%% each intensity box (10 intensities)
intensityGrid = uigridlayout(historyPanel,[10 1]);
intensityGrid.RowHeight = repmat({25},1,10);
intensityGrid.ColumnWidth = {'1x'};


%% create struct for history 
input.boxNum = 1;
input.intensityValue = NaN;
input.lastIntensity = NaN;
updateIntensity = @updateIntensityUI;





% right plot
ax = uiaxes(plotGrid);
xlabel(ax,'Time');
ylabel(ax,'Amplitude');
grid(ax,'on');


%% Final result (% RMT threshold, final intensity, counts at threshold (Hit:Miss), total % trials to criterion, mean baseline RMS & P2P (all trials - measure of noisiness
% total time taking  (save time ended))

%% Final results
resultPanel = uipanel(viewGrid);
resultPanel.Layout.Row = 4;
resultPanel.Layout.Column = 1;


%% Split result panel into left and right
resultGrid = uigridlayout(resultPanel,[1 2]);
resultGrid.ColumnWidth = {'1x','2x'};
resultGrid.RowHeight = {'1x'};
resultGrid.Padding = [10 5 10 5];
resultGrid.ColumnSpacing = 10;


%% Left: selected intensity result
intensityResultGrid = uigridlayout(resultGrid,[1 2]);
intensityResultGrid.Layout.Row = 1;
intensityResultGrid.Layout.Column = 1;
intensityResultGrid.Padding = [0 0 0 0];
%% ratio  

uilabel(intensityResultGrid, ...
    'Text','Hit/Miss:', ...
    'FontSize',15, ...
    'FontWeight','bold');

input.history.ratio = uilabel(intensityResultGrid, ...
    'Text','--', ...
    'FontSize',18, ...
    'FontWeight','bold');




%% Right: final result
finalResultGrid = uigridlayout(resultGrid,[4 4]);
finalResultGrid.Layout.Row = 1;
finalResultGrid.Layout.Column = 2;
finalResultGrid.ColumnWidth = {180, 100, 180, 160};
finalResultGrid.Padding = [0 0 0 0];



%% first row 
%% MT type (RMT or AMT)
uilabel(finalResultGrid, ...
    'Text','MT:', ...
    'FontSize',15, ...
    'FontWeight','bold');

input.MTtype = uilabel(finalResultGrid, ...
    'Text','--', ...
    'FontSize',18, ...
    'FontWeight','bold');

%% Total time taken
uilabel(finalResultGrid, ...
    'Text','Total Time Taken:', ...
    'FontSize',15, ...
    'FontWeight','bold');

input.timetoken = uilabel(finalResultGrid, ...
    'Text','-- s', ...
    'FontSize',18, ...
    'FontWeight','bold');


%% Total trials
uilabel(finalResultGrid, ...
    'Text','Total Trials:', ...
    'FontSize',15, ...
    'FontWeight','bold');

input.trials = uilabel(finalResultGrid, ...
    'Text','--', ...
    'FontSize',18, ...
    'FontWeight','bold');

%% third row

%% Threshold
uilabel(finalResultGrid, ...
    'Text','Threshold:', ...
    'FontSize',15, ...
    'FontWeight','bold');

input.threshold = uilabel(finalResultGrid, ...
    'Text','-- %', ...
    'FontSize',18, ...
    'FontWeight','bold');

%% Mean baseline
uilabel(finalResultGrid, ...
    'Text','Mean Baseline:', ...
    'FontSize',15, ...
    'FontWeight','bold');

input.mean_baseline = uilabel(finalResultGrid, ...
    'Text','--', ...
    'FontSize',18, ...
    'FontWeight','bold');

%% forth row

%% Hit/Miss

uilabel(finalResultGrid, ...
    'Text','Hit/Miss:', ...
    'FontSize',15, ...
    'FontWeight','bold');

input.ratio = uilabel(finalResultGrid, ...
    'Text','-- ', ...
    'FontSize',18, ...
    'FontWeight','bold');


%% Mean P2P
uilabel(finalResultGrid, ...
    'Text','Mean MEP amplitude:', ...
    'FontSize',15, ...
    'FontWeight','bold');

input.mean_p2p = uilabel(finalResultGrid, ...
    'Text','--', ...
    'FontSize',18, ...
    'FontWeight','bold');






% delete(fig);


uiwait(fig);

settings = fig.UserData.settings;

input.choose = fig.UserData.choose;

%% add intensity button
    function input = updateIntensityUI(input)

        if input.intensityValue ~= input.lastIntensity

            % Create button
            button = uibutton(intensityGrid);
            button.Layout.Row = input.boxNum;
            button.Layout.Column = 1;
            button.Text = input.intensity.Text;

            % Store information for this button
            button.UserData.idx = input.boxNum;
            button.UserData.ratio = input.history.ratio.Text ;

            % Button callback
            button.ButtonPushedFcn = @(btn,event) ...
                update_Selected_Intensity(btn.UserData);

            input.boxNum = input.boxNum + 1;

            % updata last intensity
            input.lastIntensity = input.intensityValue;

        end

    end

    function update_Selected_Intensity(data)

        input.history.ratio.Text = data.ratio;

    end



end

%% functions 

%% select folder
function selectFolder(fig,folderField)
    folderPath = uigetdir(pwd, 'Select Input Folder');

    if folderPath ~= 0
        folderField.Value = folderPath;
    end

    figure(fig);

end


%% text feed
function updateText(dd, textField)
    textField.Value = dd.Value;
end

function changeMode(event,rmtPanel,amtPanel)

    selectedMode = event.NewValue.Text;

    if strcmp(selectedMode,'Rest')

        rmtPanel.Visible = 'on';
        amtPanel.Visible = 'off';

    elseif strcmp(selectedMode,'Active')

        rmtPanel.Visible = 'off';
        amtPanel.Visible = 'on';
    end

end


function startExperiment(fig,input)

    saveSettings(fig,input);

    uiresume(fig);

end




% 
% 
%% save settings
function saveSettings(fig, input)

    %% Common settings
    settings.outputFolder = input.savefolder.Value;
    settings.subjectID    = input.subjectID.Value;

    %% Selected mode
    settings.MT = input.modeGroup.SelectedObject.Text;
    

    %% RMT
    if strcmp(settings.MT, 'Rest')
        % Version
        if strcmp(input.rmt.VersionDropdown.Value, 'Auto RMT-Finder')
            settings.version = 'auto';
        elseif strcmp(input.rmt.VersionDropdown.Value, ...
                'Fast Auto RMT-Finder')
            settings.version = 'fast';
        end

        % Hotspot
        settings.hotSpot = input.rmt.Hotspot.Value;

        % Display
        settings.display = input.display.Value;

        % algorithm
        settings.algorithm = false;

        % MVC
        settings.MVC = '0';

        %RMT
        settings.RMT = input.rmt.Hotspot.Value;

    %% Active
    elseif strcmp(settings.MT, 'Active')

        % RMT
        settings.RMT = input.amt.RMT.Value;

        % Algorithm
        if strcmp(input.amt.AlgorithmDropdown.Value, 'QUEST')
            settings.algorithm = true;
        elseif strcmp(input.amt.AlgorithmDropdown.Value, 'Binary search')
            settings.algorithm = false;
        end

        % MVC
        settings.MVC = input.MVC.Value;

        % Active always shows feedback
        settings.display = true;

        % version
        settings.version = 'amt';

    end


    %% Store settings
    fig.UserData.settings = settings;

    %% Continue main program
    uiresume(fig);

end
% 
