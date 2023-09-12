function [y1, y2] = mlhdlc_kalman_c(z)
%#codegen

%   Copyright 2011-2015 The MathWorks, Inc.

% Initialize state transition matrix
dt=1;
A=[ 1 0 dt 0 0 0;...
    0 1 0 dt 0 0;...
    0 0 1 0 dt 0;...
    0 0 0 1 0 dt;...
    0 0 0 0 1 0 ;...
    0 0 0 0 0 1 ];

% Measurement matrix
H = [ 1 0 0 0 0 0; 0 1 0 0 0 0 ];
Q = eye(6);
R = 1000 * eye(2);

% Initial conditions
persistent x_est p_est
if isempty(x_est)
    x_est = zeros(6, 1);
    p_est = zeros(6, 6);
    %h = NumericTypeScope;
end

% Predict state and covariance and position (process update)
x_prd = A * x_est;
p_prd = A * p_est * A' + Q;
z_prd = H * x_prd;

% Compute Kalman gain
S = H * p_prd' * H' + R;
B = H * p_prd';

% backslash or mldivide is not supported for fixed point inputs; 
%klm_gain = (S \ B)';

invS = mat_inv_2x2(S);
klm_gain = (invS*B)';

% Estimate state and covariance (measurement update)
x_est = x_prd + klm_gain * (z - z_prd);
p_est = p_prd - klm_gain * H * p_prd;

% Compute the estimated measurements
y = H * x_est;

y1 = y(1);
y2 = y(2);

end

function invM = mat_inv_2x2(M)
detM = M(1,1)*M(2,2) - M(1,2)*M(2,1);
adjoint = [M(2,2) -M(1,2); -M(2,1) M(1,1)]; %transposed cofactor

if(abs(detM) < 1.e-10)
    invM = zeros(2,2); % equals zero, not invertible
else
    % invM = [1/detM 0; 0 1/detM]*adjoint;
    cDetM = 1;
    invM = (cDetM/detM)*adjoint;
end

end

