%genSerialPositions based on bulls eye

% genSerialPositions
% KAD

clear all
for odir = 1:2
    clearvars -except odir
% PARAMS
tic()

% Screen / Image
screen.sz    = [36.5 27.5];    %cm, set empty to allow MatLab to query system setting
screen.res   = [1280 960];     %pixels, must match ML menue and system, set empty to allow MatLab to query system setting
viewdistance = [32];     %cm
trim         = 0.5;      % percentage of image to trim
bg_color     = [0.5 0.5 0.5]; %background color of screen

% Find conversion between pixels and degrees
%[pixperdeg degperpix screen]= visangle(viewdistance,screen);
pixperdeg    = 23.07;

% Fixation
fix_diameter  = 0.3;     % dva
fix_color     = [1 0 0]; % RGB

% RF (cartesian in degrees)
rf_x  = 2.5;
rf_y  = 0.5;
rf_width = 1.5; %diameter/in dva

% Bars
bar_tilt        = 135;  % grating tilt, counterclockwise, 0/180 = vertical, 90/360 horzontal; don't enter negative angles
bar_color       = [1 1 1]; % RGB
bar_length      = 80; %length of each bar in dva, make very long bar and cut out
bar_width       = .2; %dva
num_bars        = 5;

if odir == 2
    bar_tilt = bar_tilt + 90;
else
end
    
% map out where RF is located on image
clear IMAGE

J = screen.res(1);
I = screen.res(2);
[x, y] = meshgrid(-J/2:1:(J/2-1), (I/2):-1:(-I/2+1));
IMAGE  = NaN([I J 3]);

center_x = floor(rf_x .* pixperdeg);
center_y = floor(rf_y .* pixperdeg);

% first run for optimal orientation then run for orthogonal orientation

% find locations for a long bar, then "cut out" segments of bar to display
%locations middle of RF in one direction
[onelocs] = genNewBar(center_x,center_y,pixperdeg,x,y,bar_tilt,bar_length,bar_width);

%locations middle of RF in opposite direction
%center_x and center_y are now end_x and end_y. find new center_x and new
%center_y.

m     = tan(deg2rad(bar_tilt)); %slope/orientation
b     = (m .* center_x) - abs(center_y);

end_x = floor( (bar_length*(1/sqrt(1 + m.^2)) ).* pixperdeg) + center_x;
end_y = floor(((bar_length .* (m./sqrt(1 + m.^2))) ).* pixperdeg) + abs(center_y);

new_center_x = -(ceil( (bar_length*(1/sqrt(1 + m.^2)) ).* pixperdeg) - center_x);
new_center_y = - (ceil(((bar_length .* (m./sqrt(1 + m.^2))) ).* pixperdeg) - center_y);
[twolocs] = genNewBar(new_center_x,new_center_y,pixperdeg,x,y,bar_tilt,bar_length,bar_width);

bothlocs = [onelocs twolocs];

% color = [.3 .2 .8];
% for rgb = 1:3
%     RGBchannel = IMAGE(:,:,rgb);
%     RGBchannel(bothlocs) =  color(rgb);
%     IMAGE(:,:,rgb) = RGBchannel;
% end
% 
% % add background where NaNs remain
% for rgb = 1:3
%     RGBchannel = IMAGE(:,:,rgb);
%     RGBchannel(isnan(RGBchannel)) =  bg_color(rgb);
%     IMAGE(:,:,rgb) = RGBchannel;
% end

%rf location &  surrounding bounds
r = round(rf_width * pixperdeg);
rfloc = sqrt((x-center_x).^2 + (y-center_y).^2) <= r;

for b = 1:num_bars-1
    
    rb = round( (rf_width*4*b + 2*rf_width)* pixperdeg)./2;
    boundlocs(:,:,b) = sqrt((x-center_x).^2 + (y-center_y).^2) <= rb ;
    
end

boundlocs = cat(3,rfloc,boundlocs); % rf and bounds around it

% rings, in one bound only (values unique to each bound)
ringlocs = zeros(I,J,num_bars);
for b = 1:num_bars
    
    if b ==1
        ringlocs(:,:,b) = boundlocs(:,:,b);
    else
        
        holder = boundlocs(:,:,b);
        for bb = 1:b-1
            delete = find(boundlocs(:,:,bb));
            holder(delete) = 0;
        end
        
        ringlocs(:,:,b) = holder;
        
    end
    
    clear holder
end
ringlocs = logical(ringlocs);
%
% %check ringlocs
% clear IMAGE
% J = screen.res(1);
% I = screen.res(2);
% [x, y] = meshgrid(-J/2:1:(J/2-1), (I/2):-1:(-I/2+1));
% IMAGE  = NaN([I J 3]);
%
% color = [0 0 1];
% for rgb = 1:3
%     RGBchannel = IMAGE(:,:,rgb);
%     locs = logical(ringlocs(:,:,5));
%     RGBchannel(locs) = color(rgb);
%     IMAGE(:,:,rgb) = RGBchannel;
% end
%
% % add background where NaNs remain
% for rgb = 1:3
%     RGBchannel = IMAGE(:,:,rgb);
%     RGBchannel(isnan(RGBchannel)) =  bg_color(rgb);
%     IMAGE(:,:,rgb) = RGBchannel;
% end
% figure,
% imshow(IMAGE);


% %plot the bounds to know where they land on image
% clear IMAGE
% J = screen.res(1);
% I = screen.res(2);
% [x, y] = meshgrid(-J/2:1:(J/2-1), (I/2):-1:(-I/2+1));
% IMAGE  = NaN([I J 3]);
% 
% color = [0 0 1];
% for rgb = 1:3
%     RGBchannel = IMAGE(:,:,rgb);
%     RGBchannel(boundlocs(:,:,4)) = color(rgb);
%     IMAGE(:,:,rgb) = RGBchannel;
% end
% 
% color = [0 1 0];
% for rgb = 1:3
%     RGBchannel = IMAGE(:,:,rgb);
%     RGBchannel(boundlocs(:,:,3)) =  color(rgb);
%     IMAGE(:,:,rgb) = RGBchannel;
% end
% 
% color = [1 0 0];
% for rgb = 1:3
%     RGBchannel = IMAGE(:,:,rgb);
%     RGBchannel(boundlocs(:,:,2)) =  color(rgb);
%     IMAGE(:,:,rgb) = RGBchannel;
% end
% 
% color = [0 0 0];
% for rgb = 1:3
%     RGBchannel = IMAGE(:,:,rgb);
%     RGBchannel(boundlocs(:,:,1)) =  color(rgb);
%     IMAGE(:,:,rgb) = RGBchannel;
% end
% 
% color = [1 1 1];
% for rgb = 1:3
%     RGBchannel = IMAGE(:,:,rgb);
%     RGBchannel(rfloc) =  color(rgb);
%     IMAGE(:,:,rgb) = RGBchannel;
% end
% 
% r = round(fix_diameter/2 * pixperdeg);
% fixdotloc = sqrt(x.^2 + y.^2) <= r;
% 
% for rgb = 1:3
%     RGBchannel = IMAGE(:,:,rgb);
%     RGBchannel(fixdotloc) =  fix_color(rgb);
%     IMAGE(:,:,rgb) = RGBchannel;
% end
% 
% color = [1 0 0];
% for rgb = 1:3
%     RGBchannel = IMAGE(:,:,rgb);
%     RGBchannel(bothlocs) =  color(rgb);
%     IMAGE(:,:,rgb) = RGBchannel;
% end
% 
% % add background where NaNs remain
% for rgb = 1:3
%     RGBchannel = IMAGE(:,:,rgb);
%     RGBchannel(isnan(RGBchannel)) =  bg_color(rgb);
%     IMAGE(:,:,rgb) = RGBchannel;
% end
% 
% figure, imshow(IMAGE);
% title(gca,'bounds around RF with possible bar locations');


%%
%full pass on either side of RF

labelone = (-1:-1:-num_bars) + 1; 
labeltwo = (1:1:num_bars) - 1; 
for eachside = 1:2
    
    for b = 1:num_bars
        
        clear IMAGE
        J = screen.res(1);
        I = screen.res(2);
        [x, y] = meshgrid(-J/2:1:(J/2-1), (I/2):-1:(-I/2+1));
        IMAGE  = NaN([I J 3]);
        
        if eachside ==1
            if b ==1
                for rgb = 1:3
                    RGBchannel = IMAGE(:,:,rgb);
                    RGBchannel(intersect(bothlocs,find(ringlocs(:,:,1)))) =  bar_color(rgb);
                    IMAGE(:,:,rgb) = RGBchannel;
                end
            else
                
                for rgb = 1:3
                    RGBchannel = IMAGE(:,:,rgb);
                    RGBchannel(intersect(onelocs,find(ringlocs(:,:,b)))) =  bar_color(rgb);
                    IMAGE(:,:,rgb) = RGBchannel;
                end
                
            end
        else
            if b ==1
                for rgb = 1:3
                    RGBchannel = IMAGE(:,:,rgb);
                    RGBchannel(intersect(bothlocs,find(ringlocs(:,:,1)))) =  bar_color(rgb);
                    IMAGE(:,:,rgb) = RGBchannel;
                end
            else
                
                for rgb = 1:3
                    RGBchannel = IMAGE(:,:,rgb);
                    RGBchannel(intersect(twolocs,find(ringlocs(:,:,b)))) =  bar_color(rgb);
                    IMAGE(:,:,rgb) = RGBchannel;
                end
                
            end
        end
        
        % add fixation
        r = round(fix_diameter/2 * pixperdeg);
        fixdotloc = sqrt(x.^2 + y.^2) <= r;
        for rgb = 1:3
            RGBchannel = IMAGE(:,:,rgb);
            RGBchannel(fixdotloc) =  fix_color(rgb);
            IMAGE(:,:,rgb) = RGBchannel;
        end
        
        %trim image to save space
        [IMAGE] = imTrim(IMAGE,trim,I,J,x,y);

        % add background where NaNs remain
        for rgb = 1:3
            RGBchannel = IMAGE(:,:,rgb);
            RGBchannel(isnan(RGBchannel)) =  bg_color(rgb);
            IMAGE(:,:,rgb) = RGBchannel;
        end
        
        if odir == 1
        if eachside == 1
           imwrite(IMAGE,strcat('pos',num2str(labelone(b)),'.bmp'));
        else
           imwrite(IMAGE,strcat('pos',num2str(labeltwo(b)),'.bmp'));
        end
        else
            
              if eachside == 1
           imwrite(IMAGE,strcat('opp','pos',num2str(labelone(b)),'.bmp'));
        else
           imwrite(IMAGE,strcat('opp','pos',num2str(labeltwo(b)),'.bmp'));
        end
            
        end
        figure, imshow(IMAGE);
        clear bounds;
    end
end

end

% fix only
cond = 'fixonly';
clear IMAGE
J = screen.res(1);
I = screen.res(2);
[x, y] = meshgrid(-J/2:1:(J/2-1), (I/2):-1:(-I/2+1));
IMAGE  = NaN([I J 3]);
% add fixation
r = round(fix_diameter/2 * pixperdeg);
fixdotloc = sqrt(x.^2 + y.^2) <= r;
for rgb = 1:3
    RGBchannel = IMAGE(:,:,rgb);
    RGBchannel(fixdotloc) =  fix_color(rgb);
    IMAGE(:,:,rgb) = RGBchannel;
end

 %trim image to save space
 [IMAGE] = imTrim(IMAGE,trim,I,J,x,y);

% add background where NaNs remain
for rgb = 1:3
    RGBchannel = IMAGE(:,:,rgb);
    RGBchannel(isnan(RGBchannel)) =  bg_color(rgb);
    IMAGE(:,:,rgb) = RGBchannel;
end

imwrite(IMAGE,strcat(cond,'.bmp'));

toc()

