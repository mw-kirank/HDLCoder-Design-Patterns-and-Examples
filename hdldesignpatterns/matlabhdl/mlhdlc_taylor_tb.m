%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MATLAB test bench for the simple Taylor case
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get the input from 0 to pi
x = 0:0.01:2*pi;
y = zeros(1, numel(x));
for i=1:numel(y)
    y(i) = mlhdlc_taylor(x(i));
end

% Obtain a plot for x and y
plot(x, y, '*');
hold on;
plot(x, sin(x), '--');
legend('TaylorApprox', 'built-in sin');
hold off;