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
obj  = 1;

% define time intervals (in ms):
obj_duration   = 500;
iti_duration   = 100;

% set ITI, "The desired duration can be reset to the value from the main menu by calling set_iti with duration == -1"
set_iti(iti_duration);

% get the computer time for the trial start
TrialRecord.Tstart(TrialRecord.CurrentTrialNumber) = toc(uint64(1));

% obj epoch
toggleobject(obj,'status','on','EventMarker',20+TrialRecord.CurrentCondition);
idle(obj_duration)
toggleobject(obj,'status','off','EventMarker',3);

% get the computer time for the trial end
TrialRecord.Tend(TrialRecord.CurrentTrialNumber) = toc(uint64(1));

% calculate and save ITI to table
if(TrialRecord.CurrentTrialNumber > 1)
    ITIeff = TrialRecord.Tstart(TrialRecord.CurrentTrialNumber) - TrialRecord.Tend(TrialRecord.CurrentTrialNumber-1);
else
    ITIeff = NaN;
end
% record ITI to table
global runID
if TrialRecord.CurrentTrialNumber == 1;
    runID = strrep((datestr(now)),':','-');
end
tblnm = fullfile('C:\Users\MLab\Documents\MATLAB\Local ML Experiments\Michele_MonkeyLogic_experiments\ITItest',...
    'ITI DAT',strcat(runID,'.dat'));
if(exist(tblnm,'file') ~= 2)  % create the table file
    tblptr = fopen(tblnm, 'w');
    fprintf(tblptr,'Tstart  Tend  ITIeff  TrialNo  BlockNo  CondNo\n');
else
    tblptr = fopen(tblnm, 'a');
end
fprintf(tblptr,' %.4f  %.4f  %.4f  %6d  %6d   %6d\n',...
    TrialRecord.Tstart(TrialRecord.CurrentTrialNumber), ...
    TrialRecord.Tend(TrialRecord.CurrentTrialNumber), ...
    ITIeff, ...
    TrialRecord.CurrentTrialNumber,  ...
    TrialRecord.CurrentBlock, ...
    TrialRecord.CurrentCondition);
fclose(tblptr);







