% Flashattend Project
% Jan 2014
% revised May 2014, added event codes
% MAC

% Monkey Logic timing script to replicate NIH flashattend experiment
% uses default event codes, see MonkeyLogic/root/directory/codes.txt.

editable('fix_radius','reward_schedule_type','n_juice','minrew_trial');


% give names to the TaskObjects defined in the conditions file:
fix_screen   = 1; 
obj1_screen  = 2;
obj2_screen  = 3;

% fixation window (in degrees):
fix_radius = 1;

% define time intervals (in ms):
fix_acquire   = 1500 ;
fix_duration  = 500;
obj1_duration = 800;
obj2_duration = 1000;
punish_duration = 2500;
n_juice = 1;

% control optional task features
reward_schedule_type = 0; % 0 = constant, 1 = random, 2 = pyramid
minrew_trial = 5;
TrialRecord.minrew_trial = minrew_trial;

% TASK:  (DEV, this could probably just be a for loop since each task phase is the same)
% turn all three task objects on at the same time, and then toggle OFF
% this avoids "flashes" bwtween stimuli

% send block and condition number
eventmarker(116 + TrialRecord.CurrentBlock)
eventmarker(116 + TrialRecord.CurrentCondition)

% initial fixation:
toggleobject([obj2_screen obj1_screen fix_screen],'status','on','EventMarker',35); % see note above
ontarget = eyejoytrack('acquirefix', fix_screen, fix_radius, fix_acquire);
if ~ontarget,
    trialerror(4); % no fixation
    toggleobject([obj2_screen obj1_screen fix_screen],'status','off')
    return
end
eventmarker(8); % event marker for fixation occurs
ontarget = eyejoytrack('holdfix', fix_screen, fix_radius, fix_duration);
if ~ontarget,
    trialerror(3); % broke fixation
    toggleobject([obj2_screen obj1_screen fix_screen],'status','off')
    idle(punish_duration) % punishment delay
    return
end


% obj1 epoch
toggleobject(fix_screen,'status','off','EventMarker',23)
ontarget = eyejoytrack('holdfix', fix_screen, fix_radius, obj1_duration);
if ~ontarget,
    trialerror(3); % broke fixation
    toggleobject([obj2_screen obj1_screen fix_screen],'status','off')
    return
end

% obj2 epoch
toggleobject(obj1_screen,'status','off','EventMarker',25);
ontarget = eyejoytrack('holdfix', fix_screen, fix_radius, obj2_duration);
if ~ontarget,
    trialerror(3); % broke fixation
    toggleobject([obj2_screen obj1_screen fix_screen],'status','off')
    return
end

% everything off
toggleobject([obj2_screen obj1_screen fix_screen],'status','off')
trialerror(0); % correct


% give reward
juice = tRewardSchedule(reward_schedule_type,n_juice,TrialRecord);
user_text(sprintf('juice pumps = %u',juice))
goodmonkey(50, 'NumReward', juice, 'PauseTime', 150);
eventmarker(96); % event marker for reward delivered




