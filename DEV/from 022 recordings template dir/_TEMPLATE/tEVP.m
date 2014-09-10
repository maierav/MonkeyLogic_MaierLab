% EVP
% July 2014
% MAC & KD

% Monkey Logic timing script to show large screen flash for EVP / CSD localization
% uses default event codes, see MonkeyLogic/root/directory/codes.txt.

editable('obj1_duration','iti_duration');

% give names to the TaskObjects defined in the conditions file:
obj1  = 1;

% define time intervals (in ms):
obj1_duration = 50;
iti_duration  = 50;
set_iti(iti_duration);

% send block and condition number
eventmarker(116 + TrialRecord.CurrentBlock)
eventmarker(116 + TrialRecord.CurrentCondition)

% obj1 epoch
toggleobject(obj1,'status','on','EventMarker',23)
idle(obj1_duration)
toggleobject(obj1,'status','off','EventMarker',24);

