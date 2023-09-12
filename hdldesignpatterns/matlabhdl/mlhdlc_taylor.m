%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MATLAB design: Simple taylor approximation for sine
% 
% Introduction:
%
% In this example, we generate teh calculation for sin(x) for x in [0, 2*pi]
% The polynomial approximation is made by splitting the interval into 4
% sub-intervals of [0, pi/2], [pi/2, pi], [pi, 3*pi/2] and [3*pi/2, 2*pi]
% The coefficients for the code is obtained by performing the Taylor
% expansion as:
        % syms x
        % f = sin(x);
        % order = 6;
        % T6sin0 = taylor(f, x, 'Order', order, 'ExpansionPoint', 0);
        % T6sin1 = taylor(f, x, 'Order', order, 'ExpansionPoint', pi/2);
        % T6sin2 = taylor(f, x, 'Order', order, 'ExpansionPoint', pi);
        % T6sin3 = taylor(f, x, 'Order', order, 'ExpansionPoint', 3*pi/2);

function y = mlhdlc_taylor(x)

%#codegen
if x<(pi/2) % x^5/120 - x^3/6 + x
    x01 = x;
    x02 = x01*x01;
    x03 = x02*x01;
    x04 = x03*x01;
    x05 = x04*x01;
    y = x05*(1/120) - x03*(1/6) + x01;
elseif (x < pi) % (x - pi/2)^4/24 - (x - pi/2)^2/2 + 1
    x11 = (x - pi/2);
    x21 = x11*x11;
    x31 = x21*x11;
    x41 = x31*x11;
    y = x41*(1/24) - x21*(1/2) + 1;
elseif (x < (3*pi/2)) % pi - x + (x - pi)^3/6 - (x - pi)^5/120
    x21 = (x - pi);
    x22 = x21*x21;
    x23 = x22*x21;
    x24 = x23*x21;
    x25 = x24*x21;
    y = x25*(-1/120)+x23*(1/6) - x21;
else %if (x < 2*pi) % (x - (3*pi)/2)^2/2 - (x - (3*pi)/2)^4/24 - 1
    x31 = (x - 3*pi/2);
    x32 = x31*x31;
    x33 = x32*x31;
    x34 = x33*x31;
    y = x32*(1/2) - (x34)*(1/24) - 1;
end

end