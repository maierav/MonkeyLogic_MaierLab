% June 2014
% MAC

% shows static stimuli and sends event codes

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

% % set editable vars
editable({'obj_duration','iti_duration'});

% give names to the TaskObjects defined in the conditions file:
mov  = 1;

% define time intervals (in ms):
obj_duration   = 500;
iti_duration   = 100;


% obj epoch
toggleobject(mov)
idle(obj_duration)
toggleobject(mov)









