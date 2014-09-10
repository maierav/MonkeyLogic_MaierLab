% August 2014
% MAC
% works with gMovingBars

% set editable vars
editable('fix_radius','fix_acquire','hold_delay','punish_duration','reward_schedule_type','n_juice','min_trial');

% give names to the TaskObjects defined in the conditions file:
fixation_point = 1;
moving_bar     = 2;

% fixation window (in degrees):
fix_radius = 1;

% define time intervals (in ms):
fix_acquire     = 500;  % idle time for aquiring fixation, esentially additive to fix_delay
hold_delay      = 50;
punish_duration = 3000;
% *see below for bar_duration / fix_duration* 

% get screen info and set bar path
refreshrate = TrialRecord.ScreenInfo.RefreshRate;
moreinfo    = TrialRecord.CurrentConditionStimulusInfo{moving_bar}.MoreInfo;
xpath = moreinfo(1,:);
ypath = moreinfo(2,:);
bar_duration = length(xpath) / refreshrate * 1000; % bar play time is a function of # of frames, see below & see gMovingBars
sucess = set_object_path(moving_bar, xpath, ypath);

% control optional task features
reward_schedule_type = 3; % 0 = constant, 1 = random, 2 = pyramid, 3 = binomial 
n_juice = 5;
min_trial = 800; 
TrialRecord.minrew_trial = min_trial; 

% TASK:

% send block and condition number
eventmarker(116 + TrialRecord.CurrentBlock)
eventmarker(116 + TrialRecord.CurrentCondition)

% turn on moving bar (ONLY SLOUTION TO AVOID "JUMPING" BUG)
% bar will not "play" until 1st eyejoytrack call
toggleobject(moving_bar,'EventMarker',23); % TaskObject ON 
toggleobject(fixation_point,'EventMarker',35); % fixation dot ON

% aquire fixation 
ontarget = eyejoytrack('acquirefix', fixation_point, fix_radius, fix_acquire);
eventmarker(76) % start move TaskObject-1 (DEV: timing?)
if ~ontarget,
    trialerror(4); % no fixation
    toggleobject([moving_bar fixation_point],'EventMarker',24); % Fix & bar off   
    idle(punish_duration);  user_text('punishment delay'); % punishment delay
    return
end

% hold fixation 
eventmarker(8);% fixation occurs, DEV: timing?
ontarget = eyejoytrack('holdfix', fixation_point, fix_radius, bar_duration*2);
if ~ontarget,
    eventmarker(97);% broke fixation
    trialerror(3); % broke fixation
    toggleobject([moving_bar fixation_point],'EventMarker',24); % Fix & bar off   
    idle(punish_duration); user_text('punishment delay'); % punishment delay
    return
end
toggleobject(moving_bar,'EventMarker',24); % TaskObject OFF


% correct trial
trialerror(0); % correct

% give reward
%juice = tRewardSchedule(reward_schedule_type,n_juice,TrialRecord);
toggleobject(fixation_point,'status','off','EventMarker',36'); % fix point off
trialerror(0); % correct
%user_text(sprintf('juice pumps = %u',juice))
eventmarker(96);% Reward delivered, DEV: timing???
%goodmonkey(50, 'NumReward', juice, 'PauseTime', 150);



