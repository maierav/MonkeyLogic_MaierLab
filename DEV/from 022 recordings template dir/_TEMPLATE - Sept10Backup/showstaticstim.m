% Kanizsa2 Project
% June 2014

% Monkey Logic timing script for futher recordings with Kanizsa Illusory Figures

% Schmid Lab Event Markers: MARKERS USED HERE
    %defaults
    % 9 = start trial
    % 13 = skipped movie frame
    % 18 = end trial
    %object eventmarkers
    % 1 = fixation point on; 
    % 2 = fixation point off;
    % 3 = stimulus OFF
    %task event markers
    %  4 = fixation starts
    %  5 = no initial fixation;
    %  6 = broke initial fixation
    %  7 = broke fixation during stimulus presentation
    %  8 = broke fixation between stimuli presentations
    % 10 = correct; 
    % 11 = reward
    %stimuli markers
    % 20 = add this to condition number for on
    % should never go higher than 256

% set editable vars
editable({'fix_radius','fix_acquire','fix_duration','obj1_duration','punish_duration','minrew_trial','reward_schedule_type','n_juice'});

% give names to the TaskObjects defined in the conditions file:
fix   = 1; 
obj1  = 2;
reward_schedule_type = 0; % 0 = constant, 1 = random, 2 = pyramid
minrew_trial = 5;
n_juice = 1; 
TrialRecord.minrew_trial = minrew_trial;
% fixation window (in degrees):
fix_radius = 1;

% define time intervals (in ms): 
fix_acquire     = 1200 ;
fix_duration    = 1000; 
obj1_duration   = 1500;
punish_duration = 2000; 
% DEV: do we want to have some jitter in the timing of events?
% DEV: do we want to keep fixaiton on longer than the stimulus?

% initial fixation:
toggleobject(fix,'status','on','EventMarker',1);
ontarget = eyejoytrack('acquirefix', fix, fix_radius, fix_acquire);
if ~ontarget,
    trialerror(4); % no fixation
    eventmarker(5); % event marker for "no initial fixation", DEV: do you use both this and the trail error function?
    toggleobject(fix,'status','off','EventMarker',2)
    idle(punish_duration) % punishment delay
    return
end

% pre-stimulus fixation epoch
eventmarker(4); % event marker for "fixation starts"
ontarget = eyejoytrack('holdfix', fix, fix_radius, fix_duration);
if ~ontarget,
    trialerror(3); % broke fixation
    eventmarker(6); % event marker for "broke initial fixation"
    toggleobject(fix,'status','off','EventMarker',2)
    idle(punish_duration) % punishment delay
    return
end

% obj1 epoch
toggleobject(obj1,'status','on','EventMarker',20+TrialRecord.CurrentCondition);
ontarget = eyejoytrack('holdfix', fix, fix_radius, obj1_duration);
if ~ontarget,
    trialerror(3); % broke fixation
    eventmarker(6); % event marker for "broke fixation during stimulus presentation"
    toggleobject([obj1 fix],'status','off','EventMarker',2)
    idle(punish_duration) % punishment delay
    return
end

% fixation and stimuli off
toggleobject([obj1 fix],'status','off','EventMarker',2)
trialerror(0); % correct
eventmarker(10); % event marker for "correct"


% give reward, 
juice = tRewardSchedule(reward_schedule_type,n_juice,TrialRecord);
user_text(sprintf('juice pumps = %u',juice))
goodmonkey(50, 'NumReward', juice, 'PauseTime', 150);
eventmarker(11); % event marker for "reward"






