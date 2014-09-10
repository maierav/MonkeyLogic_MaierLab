%trainfixation (timing script)
%modified from DMS ~MAC, Nov/Dec 2012
%modified by Kacie May 27,2013 --editable variables
%modified by Taylor Peabody--made number of juice pumps (n_juice) editable
%variable; changed default fix radius to 1 degree
%modified by MAC 12/14/2013, added options for reward
%added in time window to break fixation during trial

% This task requires that either an "eye" input or joystick (attached to the
% eye input channels) is available to perform the necessary responses.
%
% During a real experiment, a task such as this should make use of the
% "eventmarker" command to keep track of key actions and state changes (for
% instance, displaying or extinguishing an object, initiating a movement, etc).

% set editable vars
editable('fix_radius','fix_acquire','fix_duration','punish_duration','wait_for_sac','reward_schedule_type','n_juice','min_trial');

% give names to the TaskObjects defined in the conditions file:
fixation_point = 1;
saccade_point  = 2;

% fixation window (in degrees):
fix_radius = 1;

% define time intervals (in ms):
fix_acquire = 1000 ;
fix_delay = 500; %wait 500 ms before aquiring fixation
fix_duration = 1000;
punish_duration = 3000;
wait_for_sac = 500;

n_juice = 1;
min_trial = 800; 
TrialRecord.minrew_trial = min_trial; 

% control optional task features
reward_schedule_type = 0; % 0 = constant, 1 = random, 2 = pyramid, 3 = binomial 

% TASK:

% send block and condition number
eventmarker(116 + TrialRecord.CurrentBlock)
eventmarker(116 + TrialRecord.CurrentCondition)

% fixation to first location:
toggleobject(fixation_point,'EventMarker',35);
idle(fix_delay);
ontarget = eyejoytrack('acquirefix', fixation_point, fix_radius, fix_acquire);
if ~ontarget,
    trialerror(4); % no fixation
    toggleobject(fixation_point,'EventMarker',36);
    idle(punish_duration);  user_text('punishment delay'); % punishment delay
    return
end

% hold fixation at first location
eventmarker(8);% fixation occurs, DEV: timing???
ontarget = eyejoytrack('holdfix', fixation_point, fix_radius, fix_duration);
if ~ontarget,
    eventmarker(97);% broke fixation
    trialerror(3); % broke fixation
    toggleobject(fixation_point,'EventMarker',36);    
    idle(punish_duration); user_text('punishment delay'); % punishment delay
    return
end

% turn off dot at first location, and on at second location
toggleobject([fixation_point saccade_point],'EventMarker',23);
ontarget = eyejoytrack('acquirefix', saccade_point, fix_radius, wait_for_sac);
if ~ontarget,
    trialerror(4); % no fixation
    toggleobject(saccade_point,'EventMarker',24);
    idle(punish_duration);  user_text('punishment delay'); % punishment delay
    return
end

% hold fixation at second location
eventmarker(8);% fixation occurs, DEV: timing???
ontarget = eyejoytrack('holdfix', saccade_point, fix_radius, fix_duration);
if ~ontarget,
    eventmarker(97);% broke fixation
    trialerror(3); % broke fixation
    toggleobject(saccade_point,'EventMarker',24);    
    idle(punish_duration); user_text('punishment delay'); % punishment delay
    return
end

% correct trial
trialerror(0); % correct

% give reward
juice = tRewardSchedule(reward_schedule_type,n_juice,TrialRecord);
toggleobject(fixation_point,'status','off'); 
trialerror(0); % correct
user_text(sprintf('juice pumps = %u',juice))
eventmarker(96);% Reward delivered, DEV: timing???
goodmonkey(50, 'NumReward', juice, 'PauseTime', 150);



