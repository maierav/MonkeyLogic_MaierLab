function xglsetlut_mexgen (rhs1, rhs2)
% XGLSETLUT Set a device's lookup, or gamma, table.
%
% XGLSETLUT(D,LUT) will set device D's lookup table to the 256x3 array
% of doubles in LUT.
%
% Values in LUT should range from 0.0 to 1.0.

% Mexgen generated this file on Fri Oct 26 11:41:42 2007
% DO NOT EDIT!

xglmex (30, rhs1, rhs2);
