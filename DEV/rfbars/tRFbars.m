% August 2014
% MAC
% works with gMovingBars

% set editable vars
editable('fix_radius','fix_acquire','fix_duration','punish_duration','wait_for_sac','reward_schedule_type','n_juice','min_trial');

% give names to the TaskObjects defined in the conditions file:
fixation_point = 1;
moving_bar     = 2;

% fixation window (in degrees):
fix_radius = 1;

% define time intervals (in ms):
fix_delay       = 500;     % wait 500 ms before aquiring fixation
fix_acquire     = 1000;  % idle time for aquiring fixation, esentially additive to fix_delay
fix_duration    = 200;  % time after aquiring fixation befor stimulus turns on
punish_duration = 3000;
% *see below for bar_duration*

% get screen info and set bar path
refreshrate = TrialRecord.ScreenInfo.RefreshRate;
moreinfo    = TrialRecord.CurrentConditionStimulusInfo{moving_bar}.MoreInfo;
xpath = moreinfo(1,:);
ypath = moreinfo(2,:);
bar_duration = length(xpath) / refreshrate * 1000; % bar play time is a function of # of frames, see gMovingBars
sucess = set_object_path(moving_bar, xpath, ypath);
user_text(sprintf('set_object_path sucess = %u',sucess))
user_text(sprintf('[%f %f] to [%f %f]',xpath(1),ypath(1),xpath(end),ypath(end)))
user_text(sprintf('play = %f',bar_duration));

save('C:\Users\MLab\Documents\gitMonkeyLogic\DEV\tr.mat','TrialRecord');


% control optional task features
reward_schedule_type = 3; % 0 = constant, 1 = random, 2 = pyramid, 3 = binomial 
n_juice = 5;
min_trial = 800; 
TrialRecord.minrew_trial = min_trial; 

% TASK:

% send block and condition number
eventmarker(116 + TrialRecord.CurrentBlock)
eventmarker(116 + TrialRecord.CurrentCondition)

% aquire fixation 
toggleobject(fixation_point,'EventMarker',35);
idle(fix_delay);
ontarget = eyejoytrack('acquirefix', fixation_point, fix_radius, fix_acquire);
if ~ontarget,
    trialerror(4); % no fixation
    toggleobject(fixation_point,'EventMarker',36);
    idle(punish_duration);  user_text('punishment delay'); % punishment delay
    return
end

% hold fixation 
eventmarker(8);% fixation occurs, DEV: timing?
ontarget = eyejoytrack('holdfix', fixation_point, fix_radius, fix_duration);
if ~ontarget,
    eventmarker(97);% broke fixation
    trialerror(3); % broke fixation
    toggleobject(fixation_point,'EventMarker',36);    
    idle(punish_duration); user_text('punishment delay'); % punishment delay
    return
end

% hold fixation and play bar
toggleobject(moving_bar,'EventMarker',23); % TaskObject ON
ontarget = eyejoytrack('holdfix', fixation_point, fix_radius, bar_duration);
%idle(bar_duration);
toggleobject(moving_bar,'EventMarker',24); % TaskObject OFF
if ~ontarget,
    eventmarker(97);% broke fixation
    trialerror(3); % broke fixation
    toggleobject(fixation_point,'EventMarker',36); % Fix point off   
    idle(punish_duration); user_text('punishment delay'); % punishment delay
    return
end


% ontarget = eyejoytrack('holdfix', fixation_point, fix_radius, bar_duration);
% % if ~ontarget,
% %     eventmarker(97);% broke fixation
% %     trialerror(3); % broke fixation
% %     toggleobject(moving_bar,'EventMarker',24); % TaskObject OFF
% %     toggleobject(fixation_point,'EventMarker',36); % Fix point off   
% %     idle(punish_duration); user_text('punishment delay'); % punishment delay
% %     return
% % end
% toggleobject(moving_bar,'EventMarker',24); % TaskObject OFF



% correct trial
trialerror(0); % correct

% give reward
%juice = tRewardSchedule(reward_schedule_type,n_juice,TrialRecord);
toggleobject(fixation_point,'status','off'); 
trialerror(0); % correct
%user_text(sprintf('juice pumps = %u',juice))
eventmarker(96);% Reward delivered, DEV: timing???
%goodmonkey(50, 'NumReward', juice, 'PauseTime', 150);



