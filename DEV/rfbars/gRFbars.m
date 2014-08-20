% Aug 2014
% MAC

% Automatic mapping of visual cortex receptive fields: A fast and precise algorithm ?
% Mario Fiorani, João C.B. Azzi, Juliana G.M. Soares, Ricardo Gattass, ,
% DOI: 10.1016/j.jneumeth.2013.09.012

% "8 directions with 10 trials per direction seem appropriate for mapping RFs and coarsely inferring functional properties."
% The stimulus consisted of a thin white bar (0.2° × 30°)
% that appeared over a dark background
% in one of four random orientations (0°, 45°, 90°, or 135°)
% and crossed the screen in one of the directions perpendicular to its orientation
% at a velocity of 10°/s (3 s/trial).

function [image x y moreinfo frames startpos targetpos] = gRFbars(TrialRecord)

% gather screen info
pixperdeg   = TrialRecord.ScreenInfo.PixelsPerDegree;
refreshrate = TrialRecord.ScreenInfo.RefreshRate;
bg          = TrialRecord.ScreenInfo.BackgroundColor;
xdegrees    = TrialRecord.ScreenInfo.Xdegrees/2 - 0.5;
ydegrees    = TrialRecord.ScreenInfo.Ydegrees/2 - 0.5;

% set bar params
% orientations = [0  0 90 90 45 45 135 135]; % zero is vertical, must have a case for all included oris
% directions   = [1 -1  1 -1  1 -1   1  -1]; % 1 or -1 for forward and reverse
% barcolors    = [1  1  1  1  1  1   1   1]; % 1 for white or 0 for black

orientations = [0 90 45 135]; % zero is vertical, must have a case for all included oris
directions   = [1 1 1 1]; % 1 or -1 for forward and reverse
barcolors    = [1  1  1  1]; % 1 for white or 0 for black


ori = orientations(TrialRecord.CurrentCondition);
dir = directions(TrialRecord.CurrentCondition);
col = barcolors(TrialRecord.CurrentCondition);

velocity = 10; %dva/sec
width = 0.2; %dva, height set below

switch ori
    % start position should be the smaller cord (negative typically)
    
    case 0 % horzontal;
        height = xdegrees*2;
        startpos  = [0    -1*(ydegrees-width)]; %dva
        targetpos = [0       (ydegrees-width)]; %dva
        scaler = [1 1];
        
    case 90 % horzontal;
        height = ydegrees*2;
        startpos  = [-1*(xdegrees-width)   0]; %dva
        targetpos = [   (xdegrees-width)   0]; %dva
        scaler = [1 1];
        
    case 45
        height = min([xdegrees ydegrees]);
        a = height / sqrt(2);
        startpos  = -1*[a    a];
        targetpos =    [a    a];
        scaler = [-1 1];
        
    case 135
        height = min([xdegrees ydegrees]);
        a = height / sqrt(2);
        startpos  = -1*[a    a];
        targetpos =    [a    a];
        scaler = [1 1];
end
startpos  = fix(startpos);
targetpos = fix(targetpos);
height    = floor(height);

% make image matrix for bar
width = round(width * pixperdeg); % now in pix
height = round(height * pixperdeg); % now in pix

bar = zeros(width,height); % bar as a matrix is vertical x horozontal (y x x)
bar(:,:) = 1;
bar = imrotate(bar,ori);
b = bar == 1;
bar(b) = col;    

if length(unique(bg)) == 1
    % 2 dimen b/w matrix okay, fill in background color
    bar(~b) = unique(bg);
    image = bar;
else
    rgbimage = [];
    % need RGB matrix
    for rgb = 1:3
        X = bar;
        X(~b) = bg(rgb);
        rgbimage = cat(3,rgbimage,X);
    end
    rgbimage = cat(3,rgbimage,zeros(size(bar)));
    image = rgbimage;
end

% calculate movement trajectory
% all values in dva, these are for a dir = 1
D = pdist([startpos;targetpos]);
t = D/velocity; % t is a function of frames and refresh rate
frames = t*refreshrate; % number of frames to travel D distance at the given Velocity

xpath = [startpos(1) : D / frames :targetpos(1)] .* scaler(1);
ypath = [startpos(2) : D / frames :targetpos(2)] .* scaler(2);

if startpos(1) == targetpos(1)
    xpath = zeros(size(ypath));
    xpath(:) = startpos(1);
elseif startpos(2) == targetpos(2)
    ypath = zeros(size(xpath));
    ypath(:) = startpos(2);
end


moreinfo = [xpath ; ypath];

if dir == -1 % "reverse"
    moreinfo = fliplr(moreinfo);
end
x = moreinfo(1,1);
y = moreinfo(2,1);

 
