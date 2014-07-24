% Flashattend Project
% Jan 2014
% MAC

clear all;

% PARAMS

% Screen / Image
screen.sz    = [];    %cm, set empty to allow MatLab to query system setting
screen.res   = [];    % pixels, must match ML menue and system, set empty to allow MatLab to query system setting
viewdistance = [50];     %cm
trim         = 0.1;      % percentage of image to trim

% Fixation
fix_diameter  = 0.2;     % dva
fix_color     = [0 0 0]; % RGB
bg_color      = [0.5 0.5 0.5]; %RGB

% Target
target_diameter     = 2;    % dva, size of target
target_eccentricity = 10;    % dva
target_azimuth      = 45;   % polar degrees, location of 1st target in cartesian quad 1
target_sf           = 1;    % cycles / degree
target_tilt         = 45;    % grating tilt, counterclockwise, 0/180 = vertical, 90/360 horzontal
target_number       = 4;
target_contrast     = 1;    % contrast of grating
target_colors       = [0 0 0; 1 0 0]; % RGB

% Cue
cue_length          = 0.5;     % dva;
cue_color           = [1 1 1]; % RGB


% find conversion between pixels and degrees
 [pixperdeg degperpix screen]= visangle(viewdistance,screen);

% make target gratings
d = round(target_diameter * pixperdeg);
J = d; I = d;
c = target_contrast;                % contrast
f = 1/round(target_sf * pixperdeg); % sf in 1/pixels
t = target_tilt * pi/180;           % tilt

[x,y] = meshgrid(-J/2:1:(J/2-1), (I/2):-1:(-I/2+1));
target = 0.5 * ... % grating, full data range [0 1]
    (1 + c*sin(2*pi*f*( y*sin(t) + x*cos(t) )));

% convert to true color RGB matrix
GRATING  = ones([I J 3]);
for rgb = 1:3
    % get the indices for particular RGB colormap
    RGBgun = linspace(target_colors(1,rgb),target_colors(2,rgb),225); % 8 bit RGB gun
    ci = ceil(length(RGBgun)*target);
    GRATING(:,:,rgb) = RGBgun(ci);
end

% apply circular mask  (DEV: would be nice to do this (here and later) without iteration, linear indexing instead? bsxfun?)
mask = sqrt(x.^2 + y.^2) > d/2;
for rgb = 1:3
    RGBchannel = GRATING(:,:,rgb);
    RGBchannel(mask) =  bg_color(rgb);
    TARGET(:,:,rgb) = RGBchannel;
end

% make full screen images for fixation, cue, targets, and target+cue
% save each as image file to be used in ML

genimages = {...
    {'fix'}...
    {'fix','target'}...
    {'fix', 'cue'}...
    {'fix','target','cue'};...
    };
for i = 1:length(genimages)
    
    clear IMAGE
    
    J = screen.res(1); I = screen.res(2);
    [x, y] = meshgrid(-J/2:1:(J/2-1), (I/2):-1:(-I/2+1));
    IMAGE  = NaN([I J 3]);
    
    
    screenobjects = genimages{i}; % include these objects in image
    for o = 1:length(screenobjects);
        
        object = screenobjects{o};
        switch object
            case 'fix'
                r = round(fix_diameter/2 * pixperdeg);
                fix_color     = [0 0 0]; % RGB
                fixdotloc = sqrt(x.^2 + y.^2) <= r;
                for rgb = 1:3
                    RGBchannel = IMAGE(:,:,rgb);
                    RGBchannel(fixdotloc) =  fix_color(rgb);
                    IMAGE(:,:,rgb) = RGBchannel;
                end
                
            case 'target'
                for n = 1:target_number
                    spacing = (n-1) * (360/target_number);
                    
                    theta = (target_azimuth + spacing) * pi/180;
                    roh   = target_eccentricity * pixperdeg;
                    [X,Y] = pol2cart(theta,roh);
                    X = round(X); Y = round(Y);
                    
                    d = round(target_diameter * pixperdeg);
                    targetloc = ((x >= X-d/2 & x < X+d/2) & (y >= Y-d/2 & y < Y+d/2));
                    for rgb = 1:3
                        RGBchannel = IMAGE(:,:,rgb);
                        RGBchannel(targetloc) = squeeze(TARGET(:,:,rgb));
                        IMAGE(:,:,rgb) = RGBchannel;
                    end
                    
                end
                
            case 'cue'
                n = target_number;
                spacing = (n-1) * (360/target_number);
                theta = (target_azimuth + spacing) * pi/180;
                
                for roh =   0:(cue_length * pixperdeg)
                    [X,Y] = pol2cart(theta,roh);
                    X = round(X); Y = round(Y);
                    %cueloc = x == X & y == Y;
                    d = round(fix_diameter/4 * pixperdeg);
                    cueloc = ((x >= X-d/2 & x < X+d/2) & (y >= Y-d/2 & y < Y+d/2));
                    for rgb = 1:3
                        RGBchannel = IMAGE(:,:,rgb);
                        RGBchannel(cueloc) = cue_color(rgb);
                        IMAGE(:,:,rgb) = RGBchannel;
                    end
                end
                
        end
    end
    
    % add background where NaNs remain
    for rgb = 1:3
        RGBchannel = IMAGE(:,:,rgb);
        RGBchannel(isnan(RGBchannel)) =  bg_color(rgb);
        IMAGE(:,:,rgb) = RGBchannel;
    end
    
    % crop image (helps with ML)
    IMAGE  = IMAGE(abs(y(:,1)) <= I/2*(1-trim), abs(x(1,:)) <= J/2*(1-trim), :);
    
    % SAVE
    imwrite(IMAGE,strcat(screenobjects{:},'.bmp'))
end
save

