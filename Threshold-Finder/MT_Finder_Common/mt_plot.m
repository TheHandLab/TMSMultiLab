function mt_plot(ax,xData,yData,pulseTime,Rate,yRange,options)
%% plot data with a pulse

% X-axis label
if ~isfield(options, 'label') || ~isfield(options.label, 'x')
    options.label.x = 'Time (s)';
end

% Y-axis label
if ~isfield(options, 'label') || ~isfield(options.label, 'y')
    options.label.y = 'mV';
end

% Figure title
if ~isfield(options, 'title')
    options.title = 'Matlab EMG';
end

if ~isfield(options, 'title')
    options.title = 'Matlab EMG';
end
if ~isfield(options, 'xrange')
    options.xrange = [-200,500];
end
if ~isfield(options, 'window')
    options.window = struct();
end

if ~isfield(options.window, 'baseline')
    options.window.baseline = [-150,-1];
end

if ~isfield(options.window, 'MEP')
    options.window.MEP = [10,50];
end

%% Number of samples
nSamples = length(xData);

%% Time relative to TMS pulse
% pulseTime is the time (in ms) where TMS pulse occurs

%% convert pulsetime to sample
pulseSample = pulseTime*(Rate./1000); 

%% change units
x = ((1:nSamples) - pulseSample) ./ Rate;
xrange = options.xrange./(Rate./(Rate./1000));
baseline = options.window.baseline./(Rate./(Rate./1000));
MEPwindow = options.window.MEP./(Rate./(Rate./1000));

%% Update plot
cla(ax);
hold(ax, 'on');
%% plot figure
plot(ax,x,yData,'LineWidth',1.5);
plot(ax,[0,0],[-yRange,yRange],'k-');
plot(ax,[baseline(1),baseline(1)],[-yRange,yRange],'r-');
plot(ax,[baseline(2),baseline(2)],[-yRange,yRange],'r-');
plot(ax,[MEPwindow(1),MEPwindow(1)],[-yRange,yRange],'b-');
plot(ax,[MEPwindow(2),MEPwindow(2)],[-yRange,yRange],'b-');

%% xlimit
xlim(ax,xrange);

%% label
xlabel(ax,options.label.x);
ylabel(ax,options.label.y);

%% title
title(ax, options.title);

end