% July 2014
% MAC

% set editable vars
editable({'fix_radius','wait_for_fix','fix_dur','punish_dur','iti_dur'});

% give names to the TaskObjects defined in the conditions file:
fix  = 1;
static = 2;
mov  = 3;

% fixation window (in degrees):
fix_radius = 10;

% define time intervals (in ms):
wait_for_fix = 1000;
fix_dur = 100;
movie_dur = TrialRecord.CurrentConditionStimulusInfo{mov}.MoreInfo(2);
punish_dur = 2000;
iti_dur = 1000; 


% set ITI, "The desired duration can be reset to the value from the main menu by calling set_iti with duration == -1"
set_iti(iti_dur);

%TASK:

% send block and condition number
eventmarker(116 + TrialRecord.CurrentBlock)
eventmarker(116 + TrialRecord.CurrentCondition)

% initial fixation:
toggleobject([fix static],'EventMarker',35);
ontarget = eyejoytrack('acquirefix', fix, fix_radius, wait_for_fix);
if ~ontarget,
    trialerror(4); % no fixation
    toggleobject([fix static],'EventMarker',36);
    idle(punish_dur); % punishment delay
    return
end

% hold fixation
ontarget = eyejoytrack('holdfix', fix, fix_radius, fix_dur);
if ~ontarget,
    trialerror(3); % broke fixation
    toggleobject([fix static],'EventMarker',36); 
    idle(punish_dur) % punishment delay
    return
end

% show mov
moviestep = TrialRecord.CurrentConditionStimulusInfo{mov}.MoreInfo(1);
toggleobject([mov static],'MovieStep',moviestep,'EventMarker',23)
ontarget = eyejoytrack('holdfix', fix, fix_radius, movie_dur);
if ~ontarget,
    trialerror(3); % broke fixation
    toggleobject([fix mov],'EventMarker',24)
    idle(punish_dur); % punishment delay
    return
end
toggleobject(mov,'EventMarker',24)

% all objects off
trialerror(0); % correct
toggleobject([fix static mov],'status','off','EventMarker',36);

%DEV: need to add juice and event marker (96)



