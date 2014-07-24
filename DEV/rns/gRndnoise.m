%generate random noise stimuli for RF mapping 
%use with gen() function in ML 

%noisei is the image data for the noise stimulus 
%x, y are the x,y coordinates where the image will be displayed on screen

function [noisei,x,y] = grndnoise(TrialRecord,varargin)

global RNDNOISE

if ~isfield(TrialRecord,'PixelsPerDegree')
    vdist = 48; 
    screen.sz = [54 54] ; 
    screen.res = [1280 1024]; 
    [pixperdeg degperpix]= visangle(vdist,screen)
    TrialRecord.PixelsPerDegree = pixperdeg; 
else 
    pixperdeg = TrialRecord.PixelsPerDegree; 
end

degpatch = 0.25; %0.25 deg for each luminance patch
pixpatch = floor(pixperdeg*degpatch); 

if isempty(RNDNOISE)
J = screen.sz(; I = 960; 
ex = mod(J,64); 
if ex ~= 0 
    J = J - ex; 
end
ex = mod(I,64); 
if ex ~= 0 
    I = I - ex; 
end

%generate random noise
reps = 50; 

h_noisei = randi([0,1],[J I reps]);
rndnoise  = h_noisei; 

RNDNOISE = rndnoise; 
end

noisei = RNDNOISE(:,:,1); 
RNDNOISE(:,:,1) = []; 



x = 0; 
y = 0; 

%write the image data for this trial to a file 

end



