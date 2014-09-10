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
editable('fix_radius','fix_acquire','fix_duration','punish_duration','reward_schedule_type','n_juice','min_trial');

% give names to the TaskObjects defined in the conditions file:
fixation_point = 1;

% fixation window (in degrees):
fix_radius = 1;

% define time intervals (in ms):
fix_acquire = 1000 ;
fix_delay = 500; %wait 500 ms before aquiring fixation
fix_duration = 1000;
punish_duration = 3000;
n_juice = 5;
allowed_break_fix_time = 100;
Fix_Retry = 111; 
retry_count = 1; 
min_trial = 800; 
TrialRecord.minrew_trial = min_trial; 
bhv_variable('Allowed_Break_Fix_Time', allowed_break_fix_time);

% control optional task features
reward_schedule_type = 3; % 0 = constant, 1 = random, 2 = pyramid, 3 = binomial 

% TASK:

% initial fixation:
toggleobject(fixation_point);

%don't abort trial for first X (fix_delay) number of ms
idle(fix_delay); 
ontarget = eyejoytrack('acquirefix', fixation_point, fix_radius, fix_acquire);

if ~ontarget,
    trialerror(4); % no fixation
    toggleobject(fixation_point)
    user_text(sprintf('not in window after fix delay')); 
    return
end

while true
    ontarget = eyejoytrack('holdfix',  fixation_point, fix_radius, fix_duration);
    if ontarget % has held for full time
        Successful_Target_Hold=1;
          trialerror(0); %successful fixation 
           user_text(sprintf('did not leave window')); 

        break
    else  % allow re-fixation = # retry_count
        assert (retry_count >= 0, 'STOP! retry_count is less than zero')
        if retry_count == 0  % No more chances
            Successful_Target_Hold=0;
            trialerror(3); %broke fixation
            user_text(sprintf('broke fix, no retries left')); 
            break
        else
            retry_count = retry_count - 1;
            eventmarker(Fix_Retry);
            user_text(sprintf('retries left: %d',retry_count)); 
        end
    end % if ontarget
    % if retry_count is 1, 2, 3, 4, or 5, (re)acquire fix
    % Wait for monkey to re-acquire fixation window.  Declare failure if he takes too long.
    ontarget = eyejoytrack('acquirefix', fixation_point, fix_radius, allowed_break_fix_time);
    if ~ontarget
          Successful_Target_Hold=0;
          trialerror(3); %broke fixation
          user_text(sprintf('left window, no return')); 
        break
    end % if ~ontarget
end %  while true
% now use the variable Successful_Target_Hold
% Failure to maintain target image
if Successful_Target_Hold == 0
    toggleobject(fixation_point, 'status', 'off'); % turn off chosen pic
    trialerror(3); %broke fixation 

    return
end

% give reward
juice = tRewardSchedule(reward_schedule_type,n_juice,TrialRecord);
toggleobject(fixation_point,'status','off'); 
trialerror(0); % correct
user_text(sprintf('juice pumps = %u',juice))
goodmonkey(50, 'NumReward', juice, 'PauseTime', 150);



