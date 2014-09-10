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
editable({'fix_radius','fix_on_idle','wait_for_fix','wait_for_sac','fix_dur_LL','fix_dur_UL','minrew_trial','reward_schedule_type','iti_dur','punish_dur'});

% give names to the TaskObjects defined in the conditions file:
acquirefix_point = 1;
holdfix_point = 2;
acquiresac_point = 3;
holdsac_point = 4;
punish_image = 5; 

% fixation window (in degrees):
fix_radius = 5;

% define time intervals (in ms):
% fixed intervals:
fix_on_idle = 10;
wait_for_fix = 1000;
wait_for_sac = 500;
punish_dur = 2000;
iti_dur = 1000; 
% random intervals:
fix_dur_LL = 400;
fix_dur_UL = 600;
fix_dur = randi([fix_dur_LL fix_dur_UL]);

% reward stuff
reward_schedule_type = 4; % 0 = constant, 1 = random, 2 = pyramid
minrew_trial = 5;
TrialRecord.minrew_trial = minrew_trial;

% set ITI, "The desired duration can be reset to the value from the main menu by calling set_iti with duration == -1"
set_iti(iti_dur);

% TASK:

% fixation to first location:
toggleobject(acquirefix_point);
idle(fix_on_idle); % small idle before aquirefix initiates to emphasize fix point diffrences 
ontarget = eyejoytrack('acquirefix', acquirefix_point, fix_radius, wait_for_fix);
if ~ontarget,
    trialerror(4); % no fixation
    toggleobject(acquirefix_point);
    idle(punish_dur);  user_text('punishment delay'); % punishment delay
    return
end

% hold fixation at first location
toggleobject([acquirefix_point holdfix_point]);
ontarget = eyejoytrack('holdfix', holdfix_point, fix_radius, fix_dur);
if ~ontarget,
    trialerror(3); % broke fixation
    toggleobject([punish_image holdfix_point]); user_text('punish screen');    
    idle(punish_dur); user_text('punishment delay'); % punishment delay
    toggleobject(punish_image);
    return
end

% turn off dot at first location, and on at second location
toggleobject([holdfix_point acquiresac_point]);
idle(fix_on_idle); % small idle before aquirefix initiates to emphasize fix point diffrences 
ontarget = eyejoytrack('acquirefix', acquiresac_point, fix_radius, wait_for_sac);
if ~ontarget,
    trialerror(4); % no fixation
    toggleobject(acquiresac_point);
    idle(punish_dur);  user_text('punishment delay'); % punishment delay
    return
end


% hold fixation at second location
toggleobject([acquiresac_point holdsac_point]);
ontarget = eyejoytrack('holdfix', holdsac_point, fix_radius, fix_dur);
if ~ontarget,
    trialerror(3); % broke fixation
    toggleobject([punish_image holdsac_point]); user_text('punish screen');    
    idle(punish_dur); user_text('punishment delay'); % punishment delay
    toggleobject(punish_image);
    return
end


% correct trial
trialerror(0); % correct


% give reward, 
n_juice = 1;
juice = tRewardSchedule(reward_schedule_type,n_juice,TrialRecord);
user_text(sprintf('juice pumps = %u',juice))
goodmonkey(50, 'NumReward', juice, 'PauseTime', 150);
eventmarker(11); % event marker for "reward"
