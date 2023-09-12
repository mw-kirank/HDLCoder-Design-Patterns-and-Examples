%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MATLAB design: Non-restoring Square Root 
% 
% Key Design pattern covered in this example: 
% (1) Using a user-defined system object
% (2) The 'step' method can be called only per system object in a design iteration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Q_o,Vld_o] = mlhdlc_sysobj_nonrestsqrt(D_i, Init_i)

%   Copyright 2014-2015 The MathWorks, Inc.

    persistent hSqrt;
    
    if isempty(hSqrt)
            hSqrt = mlhdlc_msysobj_nonrestsqrt();
    end        

    [Q_o,Vld_o] = step(hSqrt, D_i,Init_i);
end