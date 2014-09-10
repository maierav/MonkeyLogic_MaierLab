function [rns x y moreinfo] = gMovieRNS(TrialRecord)

% random noise stimuli for rf mapping
% July 2014
% MAC

framen = 60;
moviestep = 0.5;
moviewraps = 1;

frameln   = TrialRecord.ScreenInfo.FrameLength; % ms/frame, actually measured by ML
movie_play_dur  = frameln/moviestep * framen * moviewraps;  %msperframe * numberofframes * numberofrepeats  

pixperdeg = TrialRecord.ScreenInfo.PixelsPerDegree;
xdegrees  = [-1:4]; %range of RNS in the horzontal demension
ydegrees  = [-4:1]; %range of RNS in the vertical demenstion

x = mean(xdegrees);  % where to center the image
y = mean(ydegrees);

xpix = floor(range(xdegrees) * pixperdeg);
ypix = floor(range(ydegrees) * pixperdeg);

%rns = zeros(xpix,ypix,4,framen);
%channel = rns(:,:,1,:);
%color = randi([1  numel(channel)],[1 numel(channel)/2]);
%channel(color) = 1;
%for i=1:4
%    rns(:,:,i,:) = channel;
%end

rns = zeros(xpix,ypix,4,framen);
for f = 1:framen    
    frame = normrnd(.5,.25,[xpix ypix]);
    frame(frame > 1) = 1;
    frame(frame < 0) = 0;
    for rgb=1:3
        rns(:,:,rgb,f) = frame;
    end
end


% save each trials RNS
[fpath fname] = fileparts(TrialRecord.BhvFileName);
newdir = [fpath filesep 'rns'];
if exist(newdir,'dir') ~= 7
    mkdir(newdir)
end
filename = fullfile(newdir,sprintf('%s-tr%03d.mrns',fname,TrialRecord.CurrentTrialNumber));
fid = fopen(filename, 'w');
fwrite(fid,rns,'uint8');
fclose(fid);
% save rns info
if TrialRecord.CurrentTrialNumber == 1
    mrnsinfo.size = size(rns); % pixels
    mrnsinfo.x_pos    = x; % dva
    mrnsinfo.y_pos    = y; % dva
    mrnsinfo.x_ln     = xdegrees; % dva
    mrnsinfo.y_ln     = ydegrees; % dva
    mrnsinfo.n   = framen;
    mrnsinfo.moviestep     = moviestep;
    mrnsinfo.n_movie_wraps = moviewraps;
    mrnsinfo.ms_per_frame      =  frameln/moviestep;
    mrnsinfo.movie_play_dur    =  movie_play_dur;
    filename = fullfile(newdir,sprintf('%s-mrnsinfo.mat',fname));
    save(filename,'mrnsinfo','-mat');
end
    
% pass params timing info to timing file
moreinfo = [moviestep movie_play_dur];

end


