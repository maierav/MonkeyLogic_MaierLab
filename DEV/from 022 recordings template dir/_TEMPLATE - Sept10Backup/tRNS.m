% July 2014
% MAC

% set editable vars
editable({'fix_radius','wait_for_fix','fix_dur','punish_dur','iti_dur','reward_schedule_type','n_juice','minrew_trial'});

% give names to the TaskObjects defined in the conditions file:
fix  = 1;
mov  = 2;

% fixation window (in degrees):
fix_radius = 10;

% define time intervals (in ms):
wait_for_fix = 1000;
fix_dur = 100;
movie_dur = TrialRecord.CurrentConditionStimulusInfo{mov}.MoreInfo(2);
punish_dur = 0;
iti_dur = 1000; 


% set ITI, "The desired duration can be reset to the value from the main menu by calling set_iti with duration == -1"
set_iti(iti_dur);

%TASK:

% send block and condition number
eventmarker(116 + TrialRecord.CurrentBlock)
eventmarker(116 + TrialRecord.CurrentCondition)

% initial fixation:
toggleobject(fix,'EventMarker',35);
ontarget = eyejoytrack('acquirefix', fix, fix_radius, wait_for_fix);
if ~ontarget,
    trialerror(4); % no fixation
    toggleobject(fix,'EventMarker',36);
    idle(punish_dur); % punishment delay
    return
end

% hold fixation
ontarget = eyejoytrack('holdfix', fix, fix_radius, fix_dur);
if ~ontarget,
    trialerror(3); % broke fixation
    toggleobject(fix,'EventMarker',36); 
    idle(punish_dur) % punishment delay
    return
end

% show mov
moviestep = TrialRecord.CurrentConditionStimulusInfo{mov}.MoreInfo(1);
toggleobject(mov,'MovieStep',moviestep,'EventMarker',23)
ontarget = eyejoytrack('holdfix', fix, fix_radius, movie_dur);
if ~ontarget,
    trialerror(3); % broke fixation
    toggleobject(mov,'EventMarker',24)
    idle(punish_dur); % punishment delay
    return
end
toggleobject(mov,'EventMarker',24)

% all objects off
trialerror(0); % correct
toggleobject([fix mov],'status','off','EventMarker',36);
%reward
n_juice = 1; 
reward_schedule_type = 4; % 0 = constant, 1 = random, 2 = pyramid
minrew_trial = 5;
TrialRecord.minrew_trial = minrew_trial;
juice = tRewardSchedule(reward_schedule_type,n_juice,TrialRecord);
user_text(sprintf('juice pumps = %u',juice))
goodmonkey(50, 'NumReward', juice, 'PauseTime', 150);




