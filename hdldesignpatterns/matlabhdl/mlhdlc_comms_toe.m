%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MATLAB design: Time Offset Estimation
%
%% Introduction:
%
% The generated hardware core for this design operates at 1/os_rate 
% where os_rate is the oversampled rate. That is, for 8 oversampled clock cycles 
% this core iterates once. The output is at the symbol rate.
%
% Key design pattern covered in this example:
% (1) Data is sent in a vector format, stored in a register and accessed
% multiple times
% (2) The core also illustrates basic mathematical operations
% 

%   Copyright 2011-2015 The MathWorks, Inc.

%#codegen
function [tauh,q] = mlhdlc_comms_toe(r,mu)

persistent tau
persistent rBuf

os_rate = 8;
if isempty(tau)
    tau = 0;
    rBuf = zeros(1,3*os_rate);
end

rBuf = [rBuf(1+os_rate:end) r];

taur = round(tau);

% Determine lead/lag values and compute offset error
zl = rBuf(os_rate+taur-1);
zo = rBuf(os_rate+taur);
ze = rBuf(os_rate+taur+1);
offsetError = zo*(ze-zl);

% update tau
tau = tau + mu*offsetError;

tauh = tau;

q = zo;
