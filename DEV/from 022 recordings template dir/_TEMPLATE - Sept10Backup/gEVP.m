% gen a large white squre for EVP

function [image] = gEVP(TrialRecord,varargin)

global EVP


if isempty(EVP)
    J = 1280; I = 960;
    
    ex = mod(J,64);
    if ex ~= 0
        J = J - ex;
    end
    ex = mod(I,64);
    if ex ~= 0
        I = I - ex;
    end
    
    EVP = ones([I J 3]);
    
end

image = EVP;
    
end