% July 2014
% MAC


% PLAN:
% write gen function with 8 conditions (4 orientaitons, 2 directions)
% condition number determins orientation and deirection (switch case in gen function)
% have gen function figure out maximum bar length (cannot leave screen it seems, so it is the hypononus of the shorter side)
% also have gen function return path and starting position




% give names to the TaskObjects defined in the conditions file:
bar  = 1;

% define time intervals (in ms):
mov_duration = 1000;

refreshrate = TrialRecord.ScreenInfo.RefreshRate;
xdegrees    = floor(TrialRecord.ScreenInfo.Ydegrees/2);
ydegrees    = floor(TrialRecord.ScreenInfo.Ydegrees/2);
target = min([xdegrees ydegrees]) - 2;

xpath = 0:target/refreshrate:target;
ypath = 0:target/refreshrate:target;
set_object_path(bar, xpath, ypath);

toggleobject(bar);
idle(mov_duration,'PositionStep',-1);
toggleobject(bar); 






