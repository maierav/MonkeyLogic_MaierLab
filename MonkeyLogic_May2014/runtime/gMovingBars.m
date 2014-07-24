% X x Y x 4 x N object to function as a Movie (equivalent to "Mov") with N frames.

function [movie x y] = gMovingBars(TrialRecord)

pixperdeg = TrialRecord.ScreenInfo.PixelsPerDegree;
xdegrees = TrialRecord.ScreenInfo.Xdegrees/2;
ydegrees = TrialRecord.ScreenInfo.Ydegrees/2;
xpix = floor(xdegrees * pixperdeg);
ypix = floor(ydegrees * pixperdeg);

movie = zeros(xpix,ypix,4,5);
channel = movie(:,:,1,:);
color = randi([1  numel(channel)],[1 numel(channel)/2]);
channel(color) = 1;
for i=1:4
    movie(:,:,i,:) = channel;
end

x = 0;
y = 0;