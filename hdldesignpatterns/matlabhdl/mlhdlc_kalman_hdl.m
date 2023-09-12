function [y1, y2, dv_out_q] = mlhdlc_kalman_hdl(z)
%

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
persistent state x_est p_est y  x_prd  p_prd z_prd S B klm_gain dv_out...
    backslash_dv_out;

if isempty(x_est)
    state = 1;
    x_est = zeros(6, 1);
    p_est = zeros(6, 6);
    y = zeros(2,1);
    x_prd = zeros(6,1);
    p_prd = zeros(6,6);
    z_prd = zeros(2,1);
    S = zeros(2,2);
    B = zeros(2,6);
    klm_gain = zeros(6,2);
    dv_out = 0;
    backslash_dv_out = 0;
end


switch state
    case 1
        
        % Predict state and covariance and position (process update)
        x_prd = A * x_est;
        p_prd = A * p_est * A' + Q;
        
        dv_out = 0;
        state = 2;
    case 2
        z_prd = H * x_prd;
        
        % Compute Kalman gain
        S = H * p_prd' * H' + R;
        B = H * p_prd';
        state = 3;
        
    case 3
        
        % backslash or mldivide is not supported for fixed point inputs;
        %klm_gain = (S \ B)';
        
        [klm_gain,backslash_dv_out] = backslash_B(S,B);
        
        if backslash_dv_out == 0
            state = 3;
        else
            state = 4;
            backslash_dv_out = 0;
        end
        
    case 4
        
        
        % Estimate state and covariance (measurement update)
        x_est = x_prd + klm_gain * (z - z_prd);
        p_est = p_prd - klm_gain * H * p_prd;
        
        state = 5;
        
    case 5
        
        % Compute the estimated measurements
        y = H * x_est;
        
        dv_out = 1;
        state = 1;
        
    otherwise
        state = 1;
end

y1 = y(1);
y2 = y(2);
dv_out_q = dv_out;

end

function [S_backslash_B_q, dv_out_q] = backslash_B(S,B)

% Initial conditions
persistent state detS reciprocal_detS adjoint invS S_backslash_B done...
    dv_out_nr;
if isempty(state)
    state = 1;
    detS = 0;
    reciprocal_detS = 0;
    adjoint = zeros(2,2);
    invS = zeros(2,2);
    S_backslash_B = zeros(2,6);
    done = 0;
    dv_out_nr = 0;
end


switch state
    case 1
        detS = S(1,1)*S(2,2) - S(1,2)*S(2,1);
        adjoint = [S(2,2) -S(1,2); -S(2,1) S(1,1)]; %transposed cofactor
        done = 0;
        state = 2;
        
        dv_out_nr = 0;
    case 2
        %        reciprocal_detS = 1/detS;
        if dv_out_nr == 0
            [reciprocal_detS, dv_out_nr] = nr_reciprocal_hdl(detS);
            %invdetM = 1/detM;  %transposed cofactor below
            state = 2;
        elseif dv_out_nr == 1
            dv_out_nr = 0;
            state = 3;
        end
    case 3
        invS = reciprocal_detS*adjoint;
        state = 4;
    case 4
        S_backslash_B = invS*B;
        done = 1;
        state = 1;
    otherwise
        state = 1;
end

S_backslash_B_q = S_backslash_B';
dv_out_q = done;

end



function [xnew_q,dv_out_q] = nr_reciprocal_hdl(a_input)

persistent state a a_scale xnew xold ek niters dv_out;

if isempty(state)
    state = 1;
    a = 0;
    a_scale = 0;
    % starting_value = 1/sqrt(2); % 7.071067811865475e-01, -12.216-bits -> -31.216-bits
    % The value below is optimal for three iterations, according to Kornerup and
    % Muller in "Choosing Starting Values for certain Newton-Raphson
    % iterations, however; 1/sqrt(2) generally works well - which is optimal
    % for one iteration though 3 are performed here. 1/sqrt(2) is know as the
    % geometric mean as oppose to the arithmetic mean.
    % starting_value =  6.764285720982168e-01; -13.025-bits -> -34.025-bits
    xnew = 0;
    xold = 0; % starting_value
    ek = 0;
    niters = 0;
    dv_out = 0;
end

switch state
    case 1 % abs is the algorithm, but not needed with the values in this example
        a = a_input*4.768371582031250e-07; % normalize with 1/2^21
        xold = 6.764285720982168e-01; % B3
        
        a_scale = a;
        
        if a_scale < .5
            a = a*4;
        elseif a_scale >= .5 && a_scale < 1
            a = a*2;
        end
        
        dv_out = 0;
        state = 2;
    case 2
        if niters ~= 3
            ek = 1 - a*xold;
            state = 3;
        else
            niters = 0;
            xnew = xnew*4.768371582031250e-07; % normalize with 1/2^21
            state = 5;
        end
        
    case 3
        xnew = xold + ek*xold;
        state = 4;
    case 4
        xold = xnew;
        niters = niters + 1;
        state = 2;
    case 5
        if a_scale < .5
            xnew  = xnew*4;
        elseif a_scale >= .5 && a_scale < 1
            xnew  = xnew*2;
        end
        state = 6;
    case 6
        dv_out = 1;
        state = 1;
    otherwise
        state = 1;
end

xnew_q = xnew;
dv_out_q = dv_out;

end
