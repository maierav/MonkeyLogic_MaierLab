function [rns x y] = gStaticRNS(TrialRecord)

% random noise stimuli for rf mapping BACKGROUND
% AUG 2014
% MAC

pixperdeg = TrialRecord.ScreenInfo.PixelsPerDegree;
xdegrees  = [-1:4]; %range of RNS in the horzontal demension
ydegrees  = [-4:1]; %range of RNS in the vertical demenstion

x = mean(xdegrees);  % where to center the image
y = mean(ydegrees);

xpix = floor(range(xdegrees) * pixperdeg);
ypix = floor(range(ydegrees) * pixperdeg);

rns = zeros(xpix,ypix,4);
frame = normrnd(.5,.25,[xpix ypix]);
frame(frame > 1) = 1;
frame(frame < 0) = 0;
for rgb=1:3
    rns(:,:,rgb) = frame;
end

% save each trials RNS
[fpath fname] = fileparts(TrialRecord.BhvFileName);
newdir = [fpath filesep 'rns'];
if exist(newdir,'dir') ~= 7
    mkdir(newdir)
end
filename = fullfile(newdir,sprintf('%s-tr%03d.srns',fname,TrialRecord.CurrentTrialNumber));
fid = fopen(filename, 'w');
fwrite(fid,rns,'uint8');
fclose(fid);
% save rns info
if TrialRecord.CurrentTrialNumber == 1
    srnsinfo.size = size(rns); % pixels
    srnsinfo.x_pos    = x; % dva
    srnsinfo.y_pos    = y; % dva
    srnsinfo.x_ln     = xdegrees; % dva
    srnsinfo.y_ln     = ydegrees; % dva
    filename = fullfile(newdir,sprintf('%s-srnsinfo.mat',fname));
    save(filename,'srnsinfo','-mat');
end
    

end


