%% CONFIGURE A NATIONAL INSTRUMENTS CARD

%% INITILIALISE / CONNECT TO THE CARD
daq.reset;                                                                  % reset

% DEVICE
ni_device = 'Dev1';


%% NI SESSION 1: MAIN EMG DATA ACQUISITION_________________________________
ni_gain = 2.5;                                                               % multiply the incoming NI voltage data by this amount to reflect actual voltages (system-dependent)

% CHANNELS TO USE
% channel #1, #2, #3, #4
channel.input.emg = 4:7;                                                      % Analogue inputs used for EMG channels (input)

% channel #5
channel.input.tms = 'Port0/Line1';                                            % Digital input from TMS machine (input)               

% WHICH EMG CHANNEL IS THE TARGET MUSCLE
emg.muscle = 1;                                                               % which channle will be tested for muscle

% WHICIH EMG CHANNEL HAS THE ANALOGUE TMS OUTPUT TRIGGER
emg.trigger = 5;                                                              % trigger channel for TMS

% SYNCHRONOUS SETUP
% %daq.HardwareInfo.getInstance('DisableReferenceClockSynchronization',true);  % this disables reference clock synchronisation, an incompatibility between the PXI/PCI chassis, NI Card, and some clock
% % SYNCHRONOUS ON-DEMAND COMMUNICATION (SINGLE SCAN ONLY)
% s_synch = daq.createSession('ni');                                          % setup NIDAQ session and object
% s_synch.addAnalogInputChannel(ni_device,channel.input.emg,'Voltage');       % add analogue inputs used for EMG channels
% s_synch.addDigitalChannel(ni_device,channel.input.safe,'InputOnly');        % add digital input for safety pedal  
% s_synch.addDigitalChannel(ni_device,channel.input.tms,'InputOnly');         % add digital input from TMS machine
% %s_synch.addDigitalChannel(ni_device,channel.output.tms,'OutputOnly');      % add digital output to TMS machine

% ASYNCHRONOUS SETUP
% GLOBAL VARIABLES FOR ASYNCHRONOUS EMG DATA ACQUISITION 
global emg_asynch_data emg_asynch_time emg_asynch_chunk emg_asynch_chunktime emg_callback_count   % Global variables
emg_asynch_data = [];                                                          % Initialize EMG data buffer                                        
emg_asynch_time = [];                                                          % Initialize EMG timestamp buffer

% ASYNCHRONOUS FOREGROUND COMMUNICATION
s_asynch = daq.createSession('ni');                                           % setup NIDAQ session and object
[chan,index] = s_asynch.addAnalogInputChannel(ni_device,channel.input.emg,'Voltage'); % add analogue inputs used for EMG channels
for c = 1:length(chan)                                                        
    chan(c).InputType = 'SingleEnded';                                        % Use single-ended input configuration
    chan(c).Range = [-10 10];                                                 % Set input voltage range (V)                         
end 
s_asynch.addDigitalChannel(ni_device,channel.input.tms,'InputOnly');          % add digital input from TMS machine
s_asynch.Rate = 4000;                                                         % Set sampling rate (same as the powerlab emg data)
% s_asynch.DurationInSeconds=4;                                               % Set acquisition buffer duration (s)
emg.rms.samplesize = emg.rms.duration * s_asynch.Rate ./1000;
s_asynch.NotifyWhenDataAvailableExceeds = emg.rms.samplesize;                 % Trigger the callback every RMS window of acquired datas.(Rate./k.samplehz)      
lh = s_asynch.addlistener('DataAvailable', @(scr,event) mt_callback(scr,event)); % Register callback function for incoming data (a listener)
s_asynch.IsContinuous = true;                                                 % Set continuous background acquisition
s_asynch.startBackground();                                                   % Start data acquisition in the background

% Convert the recording-window boundaries from milliseconds to samples
% relative to the TMS pulse
emg.asynch.start.samplesize = emg.mep.record.before * s_asynch.Rate ./1000;  % Start sample for the EMG recording window relative to the TMS pulse. 
emg.asynch.end.samplesize = emg.mep.record.after * s_asynch.Rate ./1000;      % End sample for the EMG recording window relative to the TMS pulse
emg.asynch.samplesize = emg.asynch.end.samplesize - emg.asynch.start.samplesize;% Number of samples recorded for each TMS pulse
emg.asynch.data = nan(tms.reps,emg.asynch.samplesize);                        % Preallocate memory for EMG data across trials
emg.baseline.samplesize = abs(emg.baseline.after - emg.baseline.before)*(s_asynch.Rate ./1000);







%% NI SESSION 2: CONTROLLING TMS AND OTHER PERIPHERALS_____________________

% TMS TRIGGER
channel.output.tms = 'Port0/Line6';                                          % Digital output to TMS machine (output) 

% OPTIONAL CHANNEL FOR SAFETY PEDAL
channel.input.safe = 'Port0/Line0';                                          % Digital input from safety pedal (input)


s_tms = daq.createSession('ni');                                             % setup NIDAQ session and object
s_tms.addDigitalChannel(ni_device,channel.output.tms,'OutputOnly');          % digital output(s) for trigger
s_tms.addDigitalChannel(ni_device,channel.input.safe,'InputOnly');           % digital output(s) for trigger
s_tms.addAnalogOutputChannel(ni_device,'ao0','Voltage');                     % Add an analog output channel for TMS trigger generation
