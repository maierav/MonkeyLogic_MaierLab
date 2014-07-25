%trainfixation (timing script)
% modified from DMS ~MAC, Nov/Dec 2012
% continued development March/April 2013

% This task requires that either an "eye" input or joystick (attached to the
% eye input channels) is available to perform the necessary responses.
%
% During a real experiment, a task such as this should make use of the
% "eventmarker" command to keep track of key actions and state changes (for
% instance, displaying or extinguishing an object, initiating a movement, etc).

% set editable vars
editable({'fix_radius','wait_for_fix','fix_dur_LL','fix_dur_UL','auto_juice','n_juice_LL','n_juice_UL','iti_dur','punish_dur'});

% give names to the TaskObjects defined in the conditions file:
fixation_point = 1;

% fixation window (in degrees):
fix_radius = 10;

% define time intervals (in ms):
% fixed intervals:
wait_for_fix = 1000;
punish_dur = 200;
iti_dur = 2000; 
% random intervals:
fix_dur_LL = 1200;
fix_dur_UL = 1700;
fix_dur = randi([fix_dur_LL fix_dur_UL]);

% set number of juice pumps
auto_juice = 1;
n_juice_LL = 2;
n_juice_UL = 4;
n_juice = randi([n_juice_LL n_juice_UL]);

% set ITI, "The desired duration can be reset to the value from the main menu by calling set_iti with duration == -1"
set_iti(iti_dur)

% TASK:

% initial fixation:
toggleobject(fixation_point);
ontarget = eyejoytrack('acquirefix', fixation_point, fix_radius, wait_for_fix);
if ~ontarget,
    trialerror(4); % no fixation
    toggleobject(fixation_point)
    idle(punish_dur) % punishment delay
    return
end
ontarget = eyejoytrack('holdfix', fixation_point, fix_radius, fix_dur);
if ~ontarget,
    trialerror(3); % broke fixation
    toggleobject(fixation_point)
    idle(punish_dur) % punishment delay
    return
end

% fix off and reward
trialerror(0); % correct
if auto_juice == 1
    goodmonkey(50, 'NumReward', n_juice, 'PauseTime', 100);
end
toggleobject(fixation_point)
