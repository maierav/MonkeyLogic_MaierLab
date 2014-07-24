% X x Y x 4 x N object to function as a Movie (equivalent to "Mov") with N frames.

function [rns x y] = gMovieRNS(TrialRecord)

pixperdeg = TrialRecord.ScreenInfo.PixelsPerDegree;
xdegrees = TrialRecord.ScreenInfo.Xdegrees/2;
ydegrees = TrialRecord.ScreenInfo.Ydegrees/2;
xpix = floor(xdegrees * pixperdeg);
ypix = floor(ydegrees * pixperdeg);

rns = zeros(xpix,ypix,4,5);
channel = rns(:,:,1,:);
color = randi([1  numel(channel)],[1 numel(channel)/2]);
channel(color) = 1;
for i=1:4
    rns(:,:,i,:) = channel;
end

x = floor(xdegrees/2 -2);
y = floor(ydegrees/2 - 2);


TrialRecord.MovieStartFrame = 1;
TrialRecord.MovieStep = 0.5;

