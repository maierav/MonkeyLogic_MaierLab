%tDMS (timing script)

% Sept 2014
% MAC


% fixation window (in degrees):
fix_radius = 2;
saccade_radius = 3;

% set number of juice pumps
pumps = 1;
reward_schedule = 0; 

% define time intervals (in ms):
wait_for_fix = 2000;
pre_holdfix_idle = 50;
initial_fix_time = 500;
sample_time = 800;
delay_time = 1500;
max_reaction_time = 500;
saccade_time = 80;
hold_target_time = 300;
punish_dur = 1000;
iti_dur = 1000;

% set ITI, "The desired duration can be reset to the value from the main menu by calling set_iti with duration == -1"
set_iti(iti_dur);

% give names to the TaskObjects defined in the conditions file:
fixpoint_acquire = 7;
fixpoint_hold    = 8;
stim_sample     = 1; 
stim_target     = 2;
stim_distractor = 3;
punish_brokefix  =  4;
punish_noresponse = 5;
punish_incorrect =  6;

% TASK:

% initial fixation:
toggleobject(fixpoint_acquire,'eventmarker',35);
ontarget = eyejoytrack('acquirefix', fixpoint_acquire, fix_radius, wait_for_fix);
if ~ontarget,
    trialerror('no fixation');
    toggleobject(fixpoint_acquire,'eventmarker',36);
    return
end

% small idle:
idle(pre_holdfix_idle)

% hold fixation:
toggleobject([fixpoint_acquire fixpoint_hold],'eventmarker',8); 
ontarget = eyejoytrack('holdfix', fixpoint_hold, fix_radius, initial_fix_time);
if ~ontarget,
    trialerror('break fixation'); 
    toggleobject([fixpoint_hold punish_brokefix]);
    idle(punish_dur);  user_text('break fix punishment delay');
    toggleobject(punish_brokefix);
    return
end

% sample epoch:
toggleobject(stim_sample,'eventmarker',23); % turn on sample
ontarget = eyejoytrack('holdfix', fixpoint_hold, fix_radius, sample_time);
if ~ontarget,
    trialerror('break fixation'); 
    toggleobject([fixpoint_hold stim_sample punish_brokefix]);
    idle(punish_dur);  user_text('break fix punishment delay');
    toggleobject(punish_brokefix);
    return
end
toggleobject(stim_sample,'eventmarker',24); % turn off sample

% delay epoch, hold fixation:
ontarget = eyejoytrack('holdfix', fixpoint_hold, fix_radius, delay_time);
if ~ontarget,
    trialerror('break fixation'); 
    toggleobject([fixpoint_hold punish_brokefix]);
    idle(punish_dur);  user_text('punishment delay, break fix');
    toggleobject(punish_brokefix);
    return
end

% choice presentation and response (none, late, correct, incorect)
toggleobject([fixpoint_hold stim_target stim_distractor],'eventmarker',25); % simultaneously turns of fix point and displays target & distractor
[ontarget rt] = eyejoytrack('holdfix', fixpoint_hold, fix_radius, max_reaction_time); % rt will be used to update the graph on the control screen
if ontarget, % max_reaction_time has elapsed and is still on fix spot
    trialerror('no response'); % no response
    toggleobject([stim_target stim_distractor punish_noresponse])
    idle(punish_dur);  user_text('punishment delay, no response');
    toggleobject(punish_noresponse);
    return
end
ontarget = eyejoytrack('acquirefix', [stim_target stim_distractor], saccade_radius, saccade_time);
if ~ontarget,
    trialerror('late response'); % did not land on either the target or distractor, could be a "no response"
    toggleobject([stim_target stim_distractor punish_noresponse])
    idle(punish_dur);  user_text('punishment delay, late/no response');
    toggleobject(punish_noresponse);
    return
elseif ontarget == 2,
    % chose the wrong (second) object among the options [target distractor]
    trialerror('incorrect response'); 
    toggleobject([stim_target stim_distractor punish_incorrect])
    idle(punish_dur);  user_text('punishment delay, incorrect response');
    toggleobject(punish_incorrect);
    return
end

% hold target 
ontarget = eyejoytrack('holdfix', stim_target, saccade_radius, hold_target_time);
if ~ontarget,
    trialerror('break fixation'); 
    toggleobject([stim_target stim_distractor punish_brokefix]);
    idle(punish_dur);  user_text('punishment delay, break fix');
    toggleobject(punish_brokefix);
    return
end

% correct trial reward
trialerror(0); % correct
n_pumps = uRewardSchedule(reward_schedule,pumps,TrialRecord);
goodmonkey(50, 'NumReward', n_pumps, 'PauseTime', 100);
eventmarker(96);

toggleobject([stim_target stim_distractor],'eventmarker',26); %turn off remaining objects