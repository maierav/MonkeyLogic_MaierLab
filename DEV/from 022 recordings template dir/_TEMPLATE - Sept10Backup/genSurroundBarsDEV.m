%genSurroundBars
%KD

clear all

% PARAMS
tic()

% Screen / Image
screen.sz    = [36.5 27.5];    %cm, set empty to allow MatLab to query system setting
screen.res   = [1280 960];     %pixels, must match ML menue and system, set empty to allow MatLab to query system setting
viewdistance = [32];           %cm
trim         = 0.1;            %percentage of image to trim
bg_color     = [0.5 0.5 0.5];  %background color of screen

% Find conversion between pixels and degrees
%[pixperdeg degperpix screen]= visangle(viewdistance,screen);
pixperdeg    = 23.07;

% Fixation
fix_diameter  = 0.3;     % dva
fix_color     = [1 0 0]; % RGB

% RF (cartesian in degrees)
rf_x  = 2 ;
rf_y  = 0.5;
rf_width = 1; %diameter/in dva

% Bars
bar_tilt     = 135;  % grating tilt, counterclockwise, 0/180 = vertical, 90/360 horzontal; don't enter negative angles
bar_color    = [1 1 1]; % RGB
bar_length   = rf_width; %length of each bar in dva, make very long bar and cut out
bar_width    = .2; %dva
num_bars     = 5;
bar_spacing  = round(1 .* pixperdeg); %enter dva


%%
% map out where RF is located on image
clear IMAGE

J = screen.res(1);
I = screen.res(2);
[x, y] = meshgrid(-J/2:1:(J/2-1), (I/2):-1:(-I/2+1));
IMAGE  = NaN([I J 3]);

center_x = floor(rf_x .* pixperdeg);
center_y = floor(rf_y .* pixperdeg);

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

%%
% bar in RF alone
[rfbarlocs,starting_x,starting_y,ending_x,ending_y] = genNewBarwMidpt(center_x,center_y,pixperdeg,x,y,bar_tilt,bar_length,bar_width);


%%
% make ring of oriented bars around RF

% find starting points in 2nd boundary. to make sure bars are of equal
% lengths, find 1 pixel ring on the extreme end of the 2nd bound and then
% use those values

b = 2; %2nd boundary
rb = round( (rf_width*4*(b-1) + 2*rf_width)* pixperdeg./2)-1; % here b-1 because of shift with addition of RF to boundlocs
inring = sqrt((x-center_x).^2 + (y-center_y).^2) <=  rb;
insidebound = setdiff(find(ringlocs(:,:,2)),find(inring));
[col,row] = ind2sub(size(x),insidebound);


%check that finding this boundary is working....
clear IMAGE
J = screen.res(1);
I = screen.res(2);
[x, y] = meshgrid(-J/2:1:(J/2-1), (I/2):-1:(-I/2+1));
IMAGE  = NaN([I J 3]);

for rgb = 1:3
    RGBchannel = IMAGE(:,:,rgb);
    RGBchannel(insidebound) =  bar_color(rgb);
    IMAGE(:,:,rgb) = RGBchannel;
end

% add fixation
r = round(fix_diameter/2 * pixperdeg);
fixdotloc = sqrt(x.^2 + y.^2) <= r;
for rgb = 1:3
    RGBchannel = IMAGE(:,:,rgb);
    RGBchannel(fixdotloc) =  fix_color(rgb);
    IMAGE(:,:,rgb) = RGBchannel;
end

% add background where NaNs remain
for rgb = 1:3
    RGBchannel = IMAGE(:,:,rgb);
    RGBchannel(isnan(RGBchannel)) =  bg_color(rgb);
    IMAGE(:,:,rgb) = RGBchannel;
end

figure, imshow(IMAGE);

conditions = {'fixonly';'rfonly';'sameangle';'oppositeangle';'samesurralone';'oppsurralone'};

for allc = 1:size(conditions,1);
    
    cond = conditions{allc}; % 'same angle' or 'opposite angle' or 'rf only'
    switch cond
        
        case 'fixonly'
            
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
            
        case 'rfonly'
            
            clear IMAGE
            J = screen.res(1);
            I = screen.res(2);
            [x, y] = meshgrid(-J/2:1:(J/2-1), (I/2):-1:(-I/2+1));
            IMAGE  = NaN([I J 3]);
            
            for rgb = 1:3
                RGBchannel = IMAGE(:,:,rgb);
                RGBchannel(rfbarlocs) =  bar_color(rgb);
                IMAGE(:,:,rgb) = RGBchannel;
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
            
           
            imwrite(IMAGE,strcat(cond,'.bmp'));
            
            figure, imshow(IMAGE);
            
            
%         case 'sameangle'
%             
%             % choose six regularly spaced bars around this circular boundary
%             % first above and below the RF bar
%             vertx = find(x(1,row) == center_x);
%             for si = 1:2
%                 
%                 mid_x = x(1,row(vertx(si)));
%                 mid_y = y(col(vertx(si)),1);
%                 [h_surrlocs] = genNewBarwMidpt(mid_x,mid_y,pixperdeg,x,y,bar_tilt,bar_length,bar_width);
%                 surrlocs{si} = h_surrlocs;
%                 
%             end
%             
%             %then find the value(s) of y that fall halfway between the RF center and
%             %the top and bottom points (all together form vertical line) found above
%             topbotgridvals = y(col(vertx,1));
%             fourgridvals   = linspace(topbotgridvals(1),topbotgridvals(2),4);
%             if length(fourgridvals) ~=4
%                 error('linspace not good solution\n');
%             end
%             twogridvals  = fourgridvals(2:3);
%             
%             verty = find(y(col,1) == twogridvals(1));
%             for i = 1:4
%                 si = si + 1;
%                 
%                 mid_x = x(1,row(verty(i)));
%                 mid_y = y(col(verty(i)),1);
%                 [h_surrlocs] = genNewBarwMidpt(mid_x,mid_y,pixperdeg,x,y,bar_tilt,bar_length,bar_width);
%                 surrlocs{si} = h_surrlocs;
%                 
%             end
%             % then bottom corners
%             clear verty;
%             verty = find(y(col,1) == twogridvals(2));
%             for i = 1:4
%                 si = si + 1;
%                 
%                 mid_x = x(1,row(verty(i)));
%                 mid_y = y(col(verty(i)),1);
%                 [h_surrlocs] = genNewBarwMidpt(mid_x,mid_y,pixperdeg,x,y,bar_tilt,bar_length,bar_width);
%                 surrlocs{si} = h_surrlocs;
%                 
%             end
%             
%             clear IMAGE
%             J = screen.res(1);
%             I = screen.res(2);
%             [x, y] = meshgrid(-J/2:1:(J/2-1), (I/2):-1:(-I/2+1));
%             IMAGE  = NaN([I J 3]);
%             
%             % add bar in RF
%             for rgb = 1:3
%                 RGBchannel = IMAGE(:,:,rgb);
%                 RGBchannel(rfbarlocs) =  bar_color(rgb);
%                 IMAGE(:,:,rgb) = RGBchannel;
%             end
%             
%             % add bars in surround
%             for i = 1:size(surrlocs,2)
%                 surrbarlocs = surrlocs{i};
%                 for rgb = 1:3
%                     RGBchannel = IMAGE(:,:,rgb);
%                     RGBchannel(surrbarlocs) =  bar_color(rgb);
%                     IMAGE(:,:,rgb) = RGBchannel;
%                 end
%                 clear surrbarlocs
%             end
%             
%             
%             % add fixation
%             r = round(fix_diameter/2 * pixperdeg);
%             fixdotloc = sqrt(x.^2 + y.^2) <= r;
%             for rgb = 1:3
%                 RGBchannel = IMAGE(:,:,rgb);
%                 RGBchannel(fixdotloc) =  fix_color(rgb);
%                 IMAGE(:,:,rgb) = RGBchannel;
%             end
%             
%               %trim image to save space
%             [IMAGE] = imTrim(IMAGE,trim,I,J,x,y);
%             
%             % add background where NaNs remain
%             for rgb = 1:3
%                 RGBchannel = IMAGE(:,:,rgb);
%                 RGBchannel(isnan(RGBchannel)) =  bg_color(rgb);
%                 IMAGE(:,:,rgb) = RGBchannel;
%             end
%             
%        
%             imwrite(IMAGE,strcat(cond,'.bmp'));
%             figure, imshow(IMAGE);
            
%         case 'oppositeangle'
%             
%             opp_bar_tilt = bar_tilt + 90;
%             
%             % choose six regularly spaced bars around this circular boundary
%             % first above and below the RF bar
%             vertx = find(x(1,row) == center_x);
%             for si = 1:2
%                 
%                 mid_x = x(1,row(vertx(si)));
%                 mid_y = y(col(vertx(si)),1);
%                 [h_surrlocs] = genNewBarwMidpt(mid_x,mid_y,pixperdeg,x,y, opp_bar_tilt,bar_length,bar_width);
%                 surrlocs{si} = h_surrlocs;
%                 
%             end
%             
%             %then find the value(s) of y that fall halfway between the RF center and
%             %the top and bottom points (all together form vertical line) found above
%             topbotgridvals = y(col(vertx,1));
%             fourgridvals   = linspace(topbotgridvals(1),topbotgridvals(2),4);
%             if length(fourgridvals) ~=4
%                 error('linspace not good solution\n');
%             end
%             twogridvals  = fourgridvals(2:3);
%             
%             verty = find(y(col,1) == twogridvals(1));
%             for i = 1:4
%                 si = si + 1;
%                 
%                 mid_x = x(1,row(verty(i)));
%                 mid_y = y(col(verty(i)),1);
%                 [h_surrlocs] = genNewBarwMidpt(mid_x,mid_y,pixperdeg,x,y, opp_bar_tilt,bar_length,bar_width);
%                 surrlocs{si} = h_surrlocs;
%                 
%             end
%             % then bottom corners
%             clear verty;
%             verty = find(y(col,1) == twogridvals(2));
%             for i = 1:4
%                 si = si + 1;
%                 
%                 mid_x = x(1,row(verty(i)));
%                 mid_y = y(col(verty(i)),1);
%                 [h_surrlocs] = genNewBarwMidpt(mid_x,mid_y,pixperdeg,x,y, opp_bar_tilt,bar_length,bar_width);
%                 surrlocs{si} = h_surrlocs;
%                 
%             end
%             
%             clear IMAGE
%             J = screen.res(1);
%             I = screen.res(2);
%             [x, y] = meshgrid(-J/2:1:(J/2-1), (I/2):-1:(-I/2+1));
%             IMAGE  = NaN([I J 3]);
%             
%             % add bar in RF
%             for rgb = 1:3
%                 RGBchannel = IMAGE(:,:,rgb);
%                 RGBchannel(rfbarlocs) =  bar_color(rgb);
%                 IMAGE(:,:,rgb) = RGBchannel;
%             end
%             
%             % add bars in surround
%             for i = 1:size(surrlocs,2)
%                 surrbarlocs = surrlocs{i};
%                 for rgb = 1:3
%                     RGBchannel = IMAGE(:,:,rgb);
%                     RGBchannel(surrbarlocs) =  bar_color(rgb);
%                     IMAGE(:,:,rgb) = RGBchannel;
%                 end
%                 clear surrbarlocs
%             end
%             
%             
%             % add fixation
%             r = round(fix_diameter/2 * pixperdeg);
%             fixdotloc = sqrt(x.^2 + y.^2) <= r;
%             for rgb = 1:3
%                 RGBchannel = IMAGE(:,:,rgb);
%                 RGBchannel(fixdotloc) =  fix_color(rgb);
%                 IMAGE(:,:,rgb) = RGBchannel;
%             end
%             
%               %trim image to save space
%             [IMAGE] = imTrim(IMAGE,trim,I,J,x,y);
%             
%             % add background where NaNs remain
%             for rgb = 1:3
%                 RGBchannel = IMAGE(:,:,rgb);
%                 RGBchannel(isnan(RGBchannel)) =  bg_color(rgb);
%                 IMAGE(:,:,rgb) = RGBchannel;
%             end
%            
%             
%             imwrite(IMAGE,strcat(cond,'.bmp'));
%             figure, imshow(IMAGE);
%             
            case 'sameangle'
            
            % choose six regularly spaced bars around this circular boundary
            % first above and below the RF bar
            vertx = find(x(1,row) == center_x);
          
            regspbtw = ceil([linspace(vertx(2),length(row),4) linspace(1,vertx(1),4)]);
            for si = 1:8
                
                mid_x = x(1,row(regspbtw(si)));
                mid_y = y(col(regspbtw(si)),1);
                [h_surrlocs] = genNewBarwMidpt(mid_x,mid_y,pixperdeg,x,y,bar_tilt,bar_length,bar_width);
                surrlocs{si} = h_surrlocs;
                
            end
            SAMEsurrlocs = surrlocs; 
            clear IMAGE
            J = screen.res(1);
            I = screen.res(2);
            [x, y] = meshgrid(-J/2:1:(J/2-1), (I/2):-1:(-I/2+1));
            IMAGE  = NaN([I J 3]);
            
            % add bar in RF
            for rgb = 1:3
                RGBchannel = IMAGE(:,:,rgb);
                RGBchannel(rfbarlocs) =  bar_color(rgb);
                IMAGE(:,:,rgb) = RGBchannel;
            end
            
            % add bars in surround
            for i = 1:size(surrlocs,2)
                surrbarlocs = surrlocs{i};
                for rgb = 1:3
                    RGBchannel = IMAGE(:,:,rgb);
                    RGBchannel(surrbarlocs) =  bar_color(rgb);
                    IMAGE(:,:,rgb) = RGBchannel;
                end
                clear surrbarlocs
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
            
       
            imwrite(IMAGE,strcat(cond,'.bmp'));
            figure, imshow(IMAGE);
            
        case 'oppositeangle'
            clear surrlocs; 
            opp_bar_tilt = bar_tilt + 90; 
            % choose six regularly spaced bars around this circular boundary
            % first above and below the RF bar
            vertx = find(x(1,row) == center_x);
            %             for si = 1:2
            %
            %                 mid_x = x(1,row(vertx(si)));
            %                 mid_y = y(col(vertx(si)),1);
            %                 [h_surrlocs] = genNewBarwMidpt(mid_x,mid_y,pixperdeg,x,y,bar_tilt,bar_length,bar_width);
            %                 surrlocs{si} = h_surrlocs;
            %
            %             end
            
            %then find the value(s) of y that fall halfway between the RF center and
            %the top and bottom points (all together form vertical line) found above
            %regspbtw = ceil([linspace(vertx(2),length(row),4); linspace(1,vertx(1),4)]);
            for si = 1:8
                
                mid_x = x(1,row(regspbtw(si)));
                mid_y = y(col(regspbtw(si)),1);
                [h_surrlocs] = genNewBarwMidpt(mid_x,mid_y,pixperdeg,x,y,opp_bar_tilt,bar_length,bar_width);
                surrlocs{si} = h_surrlocs;
                
            end
            OPPsurrlocs = surrlocs; 
            clear IMAGE
            J = screen.res(1);
            I = screen.res(2);
            [x, y] = meshgrid(-J/2:1:(J/2-1), (I/2):-1:(-I/2+1));
            IMAGE  = NaN([I J 3]);
            
            % add bar in RF
            for rgb = 1:3
                RGBchannel = IMAGE(:,:,rgb);
                RGBchannel(rfbarlocs) =  bar_color(rgb);
                IMAGE(:,:,rgb) = RGBchannel;
            end
            
            % add bars in surround
            for i = 1:size(surrlocs,2)
                surrbarlocs = surrlocs{i};
                for rgb = 1:3
                    RGBchannel = IMAGE(:,:,rgb);
                    RGBchannel(surrbarlocs) =  bar_color(rgb);
                    IMAGE(:,:,rgb) = RGBchannel;
                end
                clear surrbarlocs
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
            
            
            imwrite(IMAGE,strcat(cond,'.bmp'));
            figure, imshow(IMAGE);
            
        case 'samesurralone'
                         clear IMAGE
            J = screen.res(1);
            I = screen.res(2);
            [x, y] = meshgrid(-J/2:1:(J/2-1), (I/2):-1:(-I/2+1));
            IMAGE  = NaN([I J 3]);
            
            % add bars in surround
            for i = 1:size(SAMEsurrlocs,2)
                surrbarlocs = SAMEsurrlocs{i};
                for rgb = 1:3
                    RGBchannel = IMAGE(:,:,rgb);
                    RGBchannel(surrbarlocs) =  bar_color(rgb);
                    IMAGE(:,:,rgb) = RGBchannel;
                end
                clear surrbarlocs
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
            
            
            imwrite(IMAGE,strcat(cond,'.bmp'));
            figure, imshow(IMAGE);
            
        case 'oppsurralone'
                        clear IMAGE
            J = screen.res(1);
            I = screen.res(2);
            [x, y] = meshgrid(-J/2:1:(J/2-1), (I/2):-1:(-I/2+1));
            IMAGE  = NaN([I J 3]);
            
          
            
            % add bars in surround
            for i = 1:size(OPPsurrlocs,2)
                surrbarlocs = OPPsurrlocs{i};
                for rgb = 1:3
                    RGBchannel = IMAGE(:,:,rgb);
                    RGBchannel(surrbarlocs) =  bar_color(rgb);
                    IMAGE(:,:,rgb) = RGBchannel;
                end
                clear surrbarlocs
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
            
            
            imwrite(IMAGE,strcat(cond,'.bmp'));
            figure, imshow(IMAGE);
            
    end
    
end