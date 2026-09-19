%% INSTRUCTIONS FOR THE TASK________________________________________________	% *** change script to EMG_instructions or DISPLAY_INSTRUCTIONS ***
										% *** change variable names to instructions.task.t1..t3, instructions.ready, instructions.relax, instructions.feedback, instructions.start, instructions.rmt, instructions.amt
										% *** rmt / amt instructions could be harmonized - your job is to keep your muscle activity within the target box. sometimes this target will be very low - complete rest... ***

%% TASK INSTRUCTIONS________________________________________________________
ins.t1= 'You will see a fixation cross on the screen. Please look at the fixation cross and get ready.';
ins.t2= 'When START appears, please contract the target muscle as much as you can';
ins.t3= 'Each contraction will last for 2 seconds. Please keep the muscle contracted during this time.';


%% PARTICIPANT READY INSTRUCTIONS___________________________________________
ready.t1= 'Before start, make sure you are ready';
ready.t2= 'Are you ready?';


%% RELAX INSTRUCTIONS_______________________________________________________
relax.t1= 'Please relax';


%% ENCOURAGING FEEDBACK_____________________________________________________
enc.t1= 'You are doing excellent job';                                      % not sure whether we keep this


%% start
start.t1= 'START';


%% maintain in target percentage
main.amt.t1 = 'Now you will perform an activity-matching task.';		% *** change all this to *activity-matching* not force matching ***
main.amt.t2 = 'When you contract your muscle, it produces electrial activity, shown on screen by the bar.';

main.amt.t3 = 'During the task, please contract you muscle to control the red bar on the screen.';
main.amt.t4 = 'Please keep contracting until the red bar reaches the white line.';
main.amt.t5 = 'When you reach the white line, it will turn red. Please hold the bar at that position and keep the line red.';
main.amt.t6 = 'While you are holding the bar on the target, we may deliver TMS to your head at any time.';
main.amt.t7 = 'If you feel tired at any time, please relax your hand. When you are ready, repeat the process.';

main.rmt.t1 = 'Please keep your muscle relaxed during the test.';
main.rmt.t2 = 'You will see a white target line on the screen.';
main.rmt.t3 = 'When you fully relax your muscle, the red bar representing your muscle activity will go down.';
main.rmt.t4 = 'When your muscle activity is below the target line, the target line will turn red.';
main.rmt.t5 = 'Please keep your muscle relaxed and keep the target line red throughout the test.';
main.rmt.t6 = 'While you are keeping your muscle relaxed, we may deliver TMS to your head at any time.';


%% fixation cross *** this should be in display_configure.m change fix.line to fix.cross? ***
fix.line = [
    wsize(3)/2-display.crossSize,wsize(3)/2+display.crossSize,wsize(3)/2,wsize(3)/2;
    wsize(4)/2,wsize(4)/2,wsize(4)/2-display.crossSize,wsize(4)/2+display.crossSize
];