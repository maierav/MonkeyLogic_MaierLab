% July 2014
% MAC


% PLAN:
% write gen function with 8 conditions (4 orientaitons, 2 directions)
% condition number determins orientation and deirection (switch case in gen function)
% have gen function figure out maximum bar length (cannot leave screen it seems, so it is the hypononus of the shorter side)
% also have gen function return path and starting position




% give names to the TaskObjects defined in the conditions file:
fixation_point = 2;
moving_bar  = 1;

% define time intervals (in ms):


% 
% refreshrate = TrialRecord.ScreenInfo.RefreshRate;
% moreinfo = TrialRecord.CurrentConditionStimulusInfo{bar}.MoreInfo;
% 
% save('C:\Users\MLab\Documents\gitMonkeyLogic\DEV\tr.mat','TrialRecord');
% 
% xpath = moreinfo(1,:)
% ypath = moreinfo(2,:)
% success = set_object_path(bar, xpath, ypath)
% mov_duration = length(xpath) / refreshrate * 1000
% 
% 
% toggleobject(bar);
% idle(mov_duration);
% toggleobject(bar); 

save('C:\Users\MLab\Documents\gitMonkeyLogic\DEV\tr.mat','TrialRecord');

refreshrate = TrialRecord.ScreenInfo.RefreshRate;
moreinfo    = TrialRecord.CurrentConditionStimulusInfo{moving_bar}.MoreInfo;
xpath = moreinfo(1,:);
ypath = moreinfo(2,:);
bar_duration = length(xpath) / refreshrate * 1000; % bar play time is a function of # of frames, see gMovingBars

%toggleobject(fixation_point,'EventMarker',35);
idle(500);

sucess = set_object_path(moving_bar, xpath, ypath);
user_text(sprintf('set_object_path sucess = %u',sucess))
user_text(sprintf('[%f %f] to [%f %f]',xpath(1),ypath(1),xpath(end),ypath(end)))
user_text(sprintf('play = %f',bar_duration));


toggleobject(moving_bar,'EventMarker',23,'Status','on','StartPosition',1,'PositionStep',1); % TaskObject ON
ontarget = eyejoytrack('holdfix', moving_bar, 100, bar_duration);
%idle(bar_duration);
toggleobject(moving_bar,'EventMarker',24); % TaskObject OFF


%toggleobject(fixation_point,'EventMarker',35);



