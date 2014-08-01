function [rns x y moreinfo] = gMovieRNS(TrialRecord)

% random noise stimuli for rf mapping
% July 2014
% MAC

framen = 10;
moviestep = 0.5;
moviewraps = 1;

frameln   = TrialRecord.ScreenInfo.FrameLength; % ms/frame, actually measured by ML
movie_play_dur  = frameln/moviestep * framen * moviewraps;  %msperframe * numberofframes * numberofrepeats  

pixperdeg = TrialRecord.ScreenInfo.PixelsPerDegree;
xdegrees  = 6;
ydegrees  = 6;

xpix = floor(xdegrees * pixperdeg);
ypix = floor(ydegrees * pixperdeg);

rns = zeros(xpix,ypix,framen,10);
channel = rns(:,:,1,:);
color = randi([1  numel(channel)],[1 numel(channel)/2]);
channel(color) = 1;
for i=1:4
    rns(:,:,i,:) = channel;
end

x = 2.5;
y = -2.5;

% save each trials RNS
[fpath fname] = fileparts(TrialRecord.BhvFileName);
newdir = [fpath filesep 'rns'];
if exist(newdir,'dir') ~= 7
    mkdir(newdir)
end
filename = fullfile(newdir,sprintf('%s-tr%03d.rns',fname,TrialRecord.CurrentTrialNumber));
fid = fopen(filename, 'w');
fwrite(fid,rns,'uint8');
fclose(fid);
% save rns info
if TrialRecord.CurrentTrialNumber == 1
    rnsinfo.size = size(rns); % pixels
    rnsinfo.x_pos    = x; % dva
    rnsinfo.y_pos    = y; % dva
    rnsinfo.x_ln     = xdegrees; % dva
    rnsinfo.y_ln     = ydegrees; % dva
    rnsinfo.n   = framen;
    rnsinfo.moviestep     = moviestep;
    rnsinfo.n_movie_wraps = moviewraps;
    rnsinfo.ms_per_frame      =  frameln/moviestep;
    rnsinfo.movie_play_dur    =  movie_play_dur;
    filename = fullfile(newdir,sprintf('%s-rnsinfo.mat',fname));
    save(filename,'rnsinfo','-mat');
end
    
% pass params timing info to timing file
moreinfo = [moviestep movie_play_dur];

end


