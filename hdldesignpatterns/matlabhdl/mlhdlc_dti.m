%#codegen
function [y, is_clipped] = mlhdlc_dti(u_in, init_val, gain_val, upper_limit, lower_limit)
% Discrete Time Integrator in MATLAB Function block

%   Copyright 2012-2015 The MathWorks, Inc.

%
% Forward Euler method, also known as Forward Rectangular, 
% or left-hand approximation.  The resulting expression for the 
% output of the block at step n is
%
% y(n) = y(n-1) + K * u(n-1)
%


%%%%%%%%%%%
% Setup
%%%%%%%%%%%

% numeric type to clip the accumulator value after each addition

% variable to hold state between consecutive calls to this block
persistent u_state;
if isempty(u_state)
    u_state = init_val;
end

% clip flag status
positive_sat_occurred = 1;
negative_sat_occurred = -1;
no_sat_occurred = 0;

%%%%%%%%%%%%%%%%%
% Compute Output
%%%%%%%%%%%%%%%%%

if (u_state >= upper_limit)
    yt = upper_limit;
    is_clipped = positive_sat_occurred;
elseif (u_state <= lower_limit)
	yt = lower_limit;
    is_clipped = negative_sat_occurred;
else    
    yt = u_state;
    is_clipped = no_sat_occurred;
end

y = yt;


%%%%%%%%%%%%%%%%%
% Update State
%%%%%%%%%%%%%%%%%

tprod = gain_val * u_in;
u_state = yt + tprod;
