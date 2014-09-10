function [pixidx,end_x,end_y,m,b,idxrow,idxcol] = genNewBar(center_x,center_y,pixperdeg,x,y,bar_tilt,bar_length,bar_width)

%center_x and center_y are in units of pixel grid
%rf_x and rf_y are in visual degrees
%easier to feed starting points in terms of pixel grid 

m     = tan(deg2rad(bar_tilt)); %slope/orientation
b     = (m .* center_x) - abs(center_y);


end_x = floor( (bar_length*(1/sqrt(1 + m.^2)) ).* pixperdeg) + center_x; 
end_y = floor(((bar_length .* (m./sqrt(1 + m.^2))) ).* pixperdeg) + abs(center_y);
 
if bar_tilt == 90 | bar_tilt == 270 %vertical bar
    
    if  center_y < end_y
        ypts = 1:length(center_y:end_y);
    else
        ypts = 1:length(center_y:-1:end_y);
    end
    xx(ypts) = center_x;
    yy = center_y : end_y;
    
elseif bar_tilt == 0 | bar_tilt == 180 %horizontal bar
    
    if  center_x < end_x
        ypts = 1:length(center_x:end_x);
    else
        ypts = 1:length(center_x:-1:end_x);
    end
    xx = center_x: end_x;
    yy(ypts) = center_y;
else %other orientations
    xx = double(unique(ceil(linspace(center_x,end_x,10000))));
    yy = double(ceil((m .* (xx - center_x)) + center_y));
end

% make bar desired width 
pixwide = floor(pixperdeg .*bar_width); 
if mod(pixwide,2) ~= 0
    pixwide = pixwide + 1; 
end
halfpix = floor(pixwide/2); 
intpix  = [-halfpix:halfpix];

if bar_tilt == 90 | bar_tilt == 270 %vertical bars
    for i = 1:length(intpix)
        yy = [yy yy];
        xx = [xx double(xx + intpix(i))];
    end
else
    for i = 1:length(intpix)
        yy = [yy double(yy + intpix(i))];
        xx = [xx xx];
    end
end

%%%%%%%% !!!! %%%%%%
xax = x(1):1:x(end); %x axis of grid
xaxidx = 1:numel(xax); 
yax = y(1):-1:y(end); %y axis of grid
yaxidx = 1:numel(yax); 
whichx = find(ismember(xax,xx)); % indices in xax where there is at least one xx 
whichy = find(ismember(yax,yy)); % indices in yax where there is at least one yy 

for i = 1:length(whichx)
 logx(:,i) = xx == xax(whichx(i)); %logical with all (unique) whichx's  
end

for i = 1:length(whichy)
 logy(:,i) = yy == yax(whichy(i)); %logical with all (unique) whichx's
end

idxrow = [];
idxcol = [];
for xs = 1:size(logx,2)
    for ys = 1:size(logy,2)
        
        bothone = find((logx(:,xs) + logy(:,ys)) == 2);
        
        if ~isempty(bothone)
            
            for bs = numel(bothone)
                
                idxrow = [xaxidx(whichx(xs)) idxrow];
                idxcol = [yaxidx(whichy(ys)) idxcol];
               
                
            end
            
        end
        
    end
end

%sub2ind(size(IMAGE),row,col); get row and column using indices form xax
%and yax

[pixidx] = sub2ind(size(x),idxcol,idxrow); 