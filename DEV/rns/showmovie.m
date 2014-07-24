% July 2014
% MAC

% % set editable vars
% editable({'obj_duration','iti_duration'});

% give names to the TaskObjects defined in the conditions file:
mov  = 1;

% define time intervals (in ms):
moviestep    = TrialRecord.CurrentConditionStimulusInfo{mov}.MoreInfo(1);
mov_duration = TrialRecord.CurrentConditionStimulusInfo{mov}.MoreInfo(2);


% show mov
toggleobject(mov,'MovieStep',moviestep)
idle(mov_duration)
toggleobject(mov)






