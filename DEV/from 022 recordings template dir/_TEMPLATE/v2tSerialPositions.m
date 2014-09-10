%tSerialPositions
%KD

editable('fix_radius','reward_schedule_type','n_juice','minrew_trial');

% give names to the TaskObjects defined in the conditions file:
fix_screen   = 1;
obj1_screen  = 2; % see what is listed as 'Task Object 2' in conditions file
obj2_screen  = 3; % see what is listed as 'Task Object 3' in conditions file
obj3_screen  = 4; % see what is listed as 'Task Object 4' in conditions file
obj4_screen  = 5; % see what is listed as 'Task Object 5' in conditions file
obj5_screen  = 6; % see what is listed as 'Task Object 6' in conditions file

numobj = 6;

% fixation window (in degrees):
fix_radius = 1;

% define time intervals (in ms):
fix_acquire   = 1000 ;
fix_duration  = 800;
obj_duration  = 200;
blank_duration = 100; 
punish_duration = 2500;
n_juice = 1;

% control optional task features
reward_schedule_type = 0; % 0 = constant, 1 = random, 2 = pyramid
minrew_trial = 400;
TrialRecord.minrew_trial = minrew_trial;

% send block and condition number
eventmarker(116 + TrialRecord.CurrentBlock);
eventmarker(116 + TrialRecord.CurrentCondition);

% initial fixation:
toggleobject([obj5_screen obj4_screen obj3_screen obj2_screen obj1_screen fix_screen],'status','on','EventMarker',35); % see note above
ontarget = eyejoytrack('acquirefix', fix_screen, fix_radius, fix_acquire);
if ~ontarget,
    trialerror(4); % no fixation
    toggleobject([obj5_screen obj4_screen obj3_screen obj2_screen obj1_screen fix_screen],'status','off')
    return
end
eventmarker(8); % event marker for fixation occurs
ontarget = eyejoytrack('holdfix', fix_screen, fix_radius, fix_duration);
if ~ontarget,
    trialerror(3); % broke fixation
    toggleobject([obj5_screen obj4_screen obj3_screen obj2_screen obj1_screen fix_screen],'status','off')
    idle(punish_duration) % punishment delay
    return
end

evcodes = [27:2:33]; 
% obj1 epoch
toggleobject(fix_screen,'status','off','EventMarker',25) %effectively turning on 2nd task object % note later on that fix screen off turns on task object 2 %so all event codes are off by one!!!
for allobj = 2:numobj
    obj_screen = allobj;
    % run for-loop through all objects except fixation
    ontarget = eyejoytrack('holdfix', obj_screen, fix_radius, obj_duration);
    if ~ontarget,
        trialerror(3); % broke fixation
        toggleobject([obj5_screen obj4_screen obj3_screen obj2_screen obj1_screen fix_screen],'status','off')
        return
    end
    
    %show blank_duration (100ms) blank before the next bar appears...
    toggleobject(fix_screen,'status','on','EventMarker',35) %make event code the same as that for fix only
    ontarget = eyejoytrack('holdfix', fix_screen, fix_radius, blank_duration);
    
    % prepare for next object...
    if allobj == numobj
         toggleobject([fix_screen obj_screen],'status','off');%effectively turning on next task object
 
    else
    toggleobject([fix_screen obj_screen],'status','off','EventMarker',evcodes(allobj-1));%effectively turning on next task object
    end
end

% everything off
toggleobject([obj5_screen obj4_screen obj3_screen obj2_screen obj1_screen fix_screen],'status','off')
trialerror(0); % correct

% give reward
juice = tRewardSchedule(reward_schedule_type,n_juice,TrialRecord);
user_text(sprintf('juice pumps = %u',juice))
goodmonkey(50, 'NumReward', juice, 'PauseTime', 150);
eventmarker(96); % event marker for reward delivered
set_iti(500);



