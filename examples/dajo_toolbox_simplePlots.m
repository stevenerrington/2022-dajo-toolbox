%% Plot inhibition function
% The inhibition function is a key component of the stop-signal task, and
% provides evidence to meet one of the assumptions of the race model:
% increasing likelihood of errors at longer stop-signal delays.

% To plot this, we will take the SSD (ms) and plot this across the x-axis
% and then take the p(respond | stop-signal) / p(error) for each SSD. These
% values have already been extracted above in our beh_getStoppingInfo
% function, and are available in our stopSignalBeh variable

x_SSD = stopSignalBeh.inh_SSD; % SSD (ms)
y_pnc = stopSignalBeh.inh_pnc; % p(respond | stop-signal) / p(error)

% We can also plot the fitted weibull function to these values. This will
% show the continous probability of error over SSD times.
x_weibull = stopSignalBeh.inh_weibull.x; % SSD (ms)
y_weibull = stopSignalBeh.inh_weibull.y; % Weibull predicted p(respond | stop-signal) / p(error)

% After we have arranged this data, we can look to produce the final figure
% We can first look to create the actual figure holder. Here, I produce it
% with these additional arguments ('Renderer', 'painters', 'Position') as
% this allows for the figure to be vectorised for use in Adobe Illustrator
% or equivalent. The 'Position' argument also allows us to shape the size
% of the figure during curation too.
figure('Renderer', 'painters', 'Position', [100 100 300 300]);
hold on % as we are drawing multiple features.
scatter(x_SSD,y_pnc,'Filled','MarkerFaceColor','k'); % Plot the observed data, with filled black circles
plot(x_weibull,y_weibull, 'k') % Plot the predicted data, with a solid black line

xlabel('SSD (ms)'); ylabel('p(respond | stop-signal)') % Label axis!
title('Example inhibition function') % ...and provide a title.

%% Plot example no-stop response times
% First we define the trials of interest that we'd like to look at. In this
% example, we are going to plot no-stop trials, regardless of value or
% laterality. 
input_trials = []; input_trials = behavior.ttx.nostop.all.all;

% We then use these trials to extract the trial specific response times
% (RTs) from our (already extracted) RTs for the whole session.
obs_nostopRT = RTdist.all(input_trials);

% Once we've got these values, we can go ahead and make our figure. Just
% like above, we start with making a figure holder that is vectorised and
% of a particular dimension.
figure('Renderer', 'painters', 'Position', [100 100 400 600])

% Once we've got going we can then create subplots to look at this data in
% different ways. 

subplot(3,1,1) % For the first subplot...
histogram(obs_nostopRT,0:25:750,'LineStyle','none') %...  we can create a histogram (with 25 ms bins from 0 to 750 ms)...
xlim([0 750]) % ...and make sure we're just looking at this range in our figure
ylabel('Frequency'); %... and we always want to label figures!

subplot(3,1,2) % For the second subplot...
plot(RTdist.nostop(:,1),RTdist.nostop(:,2),'k') %...  we can plot our already extracted cumulative distribution function (cdf)...
xlim([0 750]) % ... and again make sure we're just looking at the same range of interest.
ylabel('CDF'); %... and we always want to label figures!

subplot(3,1,3) % And, finally, for the third subplot...
plot([-1000:2000],behavior.eyes.X.target(input_trials,:),'color',[0 0 0 0.5]) % we can plot every horizontal eye movement on the trials of interest
xlim([0 750]); ylim([-5 5]) % and make sure this plot matches the others.
xlabel('Time from target (ms)'); ylabel('Horizontal Eye Position (a.u.)');  %... and we always want to label figures!

%% Plot trial averaged SDF
% Just as we did above, we are first going to define key parameters of the
% data we want to look at.

% We will start with inputting the trials of interest
input_trials = []; input_trials = behavior.ttx.nostop.all.all;
% ...and then putting labels for the unit and event of interest
unit = 'DSP27a'; event = 'tone'; 
% ...before defining the time frame for the spike density function (SDF;
% signal_time) and the epoch we want to look at around the event
% (event_time).
signal_time = [-1000:2000]; event_time = [-200 1200];

% Repeating above, we start with making a figure holder that is vectorised and
% of a particular dimension.
figure('Renderer', 'painters', 'Position', [100 100 400 300]);
% We can then plot the entirity of the SDF...
plot(signal_time,nanmean(neurophys.spk.(unit).(event)),'k')
% ... and then cut it to the epoch of interest
xlim(event_time);

% As always, we need to label figures!
xlabel(['Time from ' event '(ms)']);
ylabel('Firing rate (spk/sec)');