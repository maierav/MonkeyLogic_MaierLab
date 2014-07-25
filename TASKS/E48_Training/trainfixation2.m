%trainfixation (timing script)
% modified from DMS ~MAC, Nov/Dec 2012
% continued development March/April 2013, June 2013

% This task requires that either an "eye" input or joystick (attached to the
% eye input channels) is available to perform the necessary responses.
%
% During a real experiment, a task such as this should make use of the
% "eventmarker" command to keep track of key actions and state changes (for
% instance, displaying or extinguishing an object, initiating a movement, etc).

% set editable vars
editable({'fix_radius','fix_on_idle','wait_for_fix','fix_dur_LL','fix_dur_UL','auto_juice','n_juice_LL','n_juice_UL','iti_dur','punish_dur'});

% give names to the TaskObjects defined in the conditions file:
acquirefix_point = 1;
holdfix_point = 2;
punish_image = 3; 

% fixation window (in degrees):
fix_radius = 10;

% define time intervals (in ms):
% fixed intervals:
fix_on_idle = 0;
wait_for_fix = 1000;
punish_dur = 2000;
iti_dur = 1500; 
% random intervals:
fix_dur_LL = 800;
fix_dur_UL = 1000;
fix_dur = randi([fix_dur_LL fix_dur_UL]);

% set number of juice pumps
auto_juice = 1;
n_juice_LL = 2;
n_juice_UL = 4;
n_juice = randi([n_juice_LL n_juice_UL]);

% set ITI, "The desired duration can be reset to the value from the main menu by calling set_iti with duration == -1"
set_iti(iti_dur);

% TASK:

% initial fixation:
toggleobject(acquirefix_point);
idle(fix_on_idle); % small idle before aquirefix initiates to emphasize fix point diffrences 
ontarget = eyejoytrack('acquirefix', acquirefix_point, fix_radius, wait_for_fix);
if ~ontarget,
    trialerror(4); % no fixation
    toggleobject(acquirefix_point);
    idle(punish_dur);  user_text('punishment delay'); % punishment delay
    return
end

% hold fixation
toggleobject([acquirefix_point holdfix_point]);
ontarget = eyejoytrack('holdfix', holdfix_point, fix_radius, fix_dur);
if ~ontarget,
    trialerror(3); % broke fixation
    toggleobject([punish_image holdfix_point]); user_text('punish screen');    
    idle(punish_dur); user_text('punishment delay'); % punishment delay
    toggleobject(punish_image);
    return
end

% fix off and reward
trialerror(0); % correct
toggleobject(holdfix_point);
if auto_juice == 1
    goodmonkey(50, 'NumReward', n_juice, 'PauseTime', 100);
    user_text('juice!');
end
