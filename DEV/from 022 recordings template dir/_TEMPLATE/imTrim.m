function [resizedIMAGE] = imTrim(IMAGE,trim,I,J,x,y)


IMAGE  = IMAGE(abs(y(:,1)) <= I/2*(1-trim), abs(x(1,:)) <= J/2*(1-trim), :);
[nI nJ ~] = size(IMAGE);
Imod = (64-mod(nJ,64))/2;
Jmod = (64-mod(nI,64))/2;
resizedIMAGE = padarray(IMAGE,[floor(Imod) floor(Jmod) 0],NaN,'post');
resizedIMAGE = padarray(IMAGE,[ceil(Imod) ceil(Jmod) 0],NaN,'pre');


end