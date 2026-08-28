function [model] = mtfr_MVC_model(data,MVC,pulse_time,sampling_rate,MVC_proportion,options)
%% This function can be used to detect the baseline criterion for AMT.
%% Not sure whether we should use it.


% data -> trials x N, each trial corresponding to each percentage of MVC
% pulse time -> is a vector contains the start time that force in target
% window for each trial (trial x 1)
% sampling rate 
% MVC_proportion -> vector for MVC proportion (1xN)

%% options
options.window.size = 120;                                                  % window for detect peak to peak amplitude for data (120 = (50-20)*(4000./1000))
options.target.proportion = 0.3;                                            % Percentage of MVC
options.figure = false;                                                     % figure contorl



model.proportion.size = size(MVC_proportion,1);                             % proportion size -> MVC_proportion=[0.1;0.2;0.3;0.4];  size is 4                                      
model.data.intarget = nan(model.proportion.size,size(data,2));              % data in target window 
model.data.index = nan(model.proportion.size,1);                            % when did the grip in target window
model.window.size = floor(size(data,2) ./ options.window.size);             % how many MEP windows  
model.window.data = nan(model.proportion.size,model.window.size,options.window.size); % (trials,window,data)
model.window.amplitude = nan(model.proportion.size,model.window.size,1);    % vertor of amplitude
model.window.cutoff = nan(model.proportion.size,2);                         % 95th percentile of normalized distribution



%% extract data for each target window
for m = 1:model.proportion.size    
    
    model.data.index(m) = round(pulse_time(m) * (sampling_rate / 1000));    % when did participant'force above the target
    model.data.size(m) = size(data,2) - model.data.index(m);
    model.data.intarget(m,1:model.data.size(m)) = data(m,model.data.index(m)+1:end);  % extract data after the start time in window
    
    %% seperate data to each window
    for w = 1:model.window.size
        model.window.data(m,w,:) = data(m,(w-1)*options.window.size+1:w*options.window.size); % MEP window 
        model.window.amplitude(m,w,:) = max(model.window.data(m,w,:)) - min(model.window.data(m,w,:)); % peak to peak amplitude
    end

    %% find the percentile

    model.window.cutoff(m,:) = prctile(reshape(model.window.amplitude(m,:,:),[],1),[2.5,97.5]); % find 95th percentile of normalized distribution
    model.proportion.title (m,:) = sprintf('%d%% MVC', MVC_proportion(m)*100);                  % percentage of MVC
    
end

%% create linear regression model
model.proportion.value = MVC_proportion .* MVC;                             % value of MVC proportion
model.mdl = fitlm(model.proportion.value(:),model.window.cutoff(:,2));      % model fit
model.intercept = model.mdl.Coefficients.Estimate(1);                       % the intercept
model.slope = model.mdl.Coefficients.Estimate(2);                           % slope   
model.equation = model.intercept + model.slope*MVC_proportion;              % equation
model.criterion = model.intercept + model.slope*options.target.proportion*MVC;

if options.figure
    %% x axis
    x = 1:model.proportion.size;                                            
    %% plot figure
    plot(x, model.window.cutoff(:,2),'o','MarkerSize',8,'Color','r','MarkerFaceColor','r');
    hold on
    % add lebal
    xticks(x);
    xticklabels(model.proportion.title);
    

    %% regression
    plot(x,model.equation,'o-','MarkerSize',8,'Color','b','MarkerFaceColor','b');


end




% %% average
% average_matlab_left=nan(4,32,25);
% average_matlab_right=nan(4,32,25);
% matlab_different_left=nan(4,32,1);
% matlab_different_right=nan(4,32,1);
% for maxg=1:4                                                                % each MVC percentage 
%     for i=1:32                                                              % 160./5
%     average_matlab_left(maxg,i,:)=mean(matlab_window_left(maxg,1+(i-1)*5:i*5,:),2); % window of 5 samples
%     matlab_different_left(maxg,i,:)=max(average_matlab_left(maxg,i,:))-min(average_matlab_left(maxg,i,:)); % find max and min in each window
%     end
% end


