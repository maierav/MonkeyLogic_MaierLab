%trainfixation (timing script)
% modified from DMS ~MAC, Nov/Dec 2012
% continued development March/April 2013, June 2013
% modified to be a color matching task Aug 2014

% This task requires that either an "eye" input or joystick (attached to the
% eye input channels) is available to perform the necessary responses.
%
% During a real experiment, a task such as this should make use of the
% "eventmarker" command to keep track of key actions and state changes (for
% instance, displaying or extinguishing an object, initiating a movement, etc).

% set editable vars
editable({'fix_radius','holdfix_idle','wait_for_fix','max_reaction_time','saccade_time','fix_dur_LL','fix_dur_UL','pumps','reward_schedule','iti_dur_LL','iti_dur_UL','punish_dur'});

% set number of juice pumps
pumps = 1;
reward_schedule = 0; 

% give names to the TaskObjects defined in the conditions file:
acquirefix_point = 1;
holdfix_point = 2;
target_obj = 3;
distractor_obj = 4;
punish_image = 5; 

% fixation window (in degrees):
fix_radius = 5;

% define time intervals (in ms):
% fixed intervals:
holdfix_idle = 50;
wait_for_fix = 1000;
max_reaction_time = 500;
saccade_time = 80;
punish_dur = 2000;
% random intervals:
fix_dur_LL = 400;
fix_dur_UL = 600;
iti_dur_LL = 1000;
iti_dur_UL = 1200;
fix_dur = randi([fix_dur_LL fix_dur_UL]);
iti_dur = randi([iti_dur_LL iti_dur_UL]);

% set ITI, "The desired duration can be reset to the value from the main menu by calling set_iti with duration == -1"
set_iti(iti_dur);

% TASK:

% fixation to first location:
toggleobject(acquirefix_point);
ontarget = eyejoytrack('acquirefix', acquirefix_point, fix_radius, wait_for_fix);
if ~ontarget,
    trialerror(4); % no fixation
    toggleobject(acquirefix_point);
    idle(punish_dur);  user_text('punishment delay'); % punishment delay
    return
end

% hold fixation at first location
idle(holdfix_idle); % short idle before holdfix initiates
toggleobject([acquirefix_point holdfix_point]);
ontarget = eyejoytrack('holdfix', holdfix_point, fix_radius, fix_dur);
if ~ontarget,
    trialerror(3); % broke fixation
    toggleobject([punish_image holdfix_point]); user_text('punish screen');    
    idle(punish_dur); user_text('punishment delay'); % punishment delay
    toggleobject(punish_image);
    return
end

% choice presentation and response
toggleobject([holdfix_point target_obj distractor_obj]);  % simultaneously turns off fix point and displays target & distractor
[ontarget rt] = eyejoytrack('holdfix', holdfix_point, fix_radius, max_reaction_time);
if ontarget, % wait_for_sac has elapsed and is still on fix spot
    trialerror(1); % no response
    toggleobject([target_obj distractor_obj punish_image]); user_text('punish screen');    
    idle(punish_dur); user_text('punishment delay'); % punishment delay
    toggleobject(punish_image);
    return
end
ontarget = eyejoytrack('acquirefix', [target_obj distractor_obj], fix_radius, saccade_time);
if ~ontarget,
    trialerror(2); % no or late response (did not land on either the target or distractor)
    toggleobject([target_obj distractor_obj punish_image]); user_text('punish screen');    
    idle(punish_dur); user_text('punishment delay'); % punishment delay
    toggleobject(punish_image);
    return
elseif ontarget == 2,
    trialerror(6); % chose the wrong (second) object among the options [target distractor]
    toggleobject([target_obj distractor_obj punish_image]); user_text('punish screen');
    idle(punish_dur); user_text('punishment delay'); % punishment delay
    toggleobject(punish_image);
    return
end

% hold fixation at target
ontarget = eyejoytrack('holdfix', target_obj, fix_radius, fix_dur);
if ~ontarget,
    trialerror(5); % broke fixation
    toggleobject([target_obj distractor_obj punish_image]); user_text('punish screen');    
    idle(punish_dur); user_text('punishment delay'); % punishment delay
    toggleobject(punish_image);
    return
end

% correct trial reward
trialerror(0); % correct
n_pumps = uRewardSchedule(reward_schedule,pumps,TrialRecord);
goodmonkey(50, 'NumReward', n_pumps, 'PauseTime', 100);


%turn off target and distrctor
toggleobject([target_obj distractor_obj])

