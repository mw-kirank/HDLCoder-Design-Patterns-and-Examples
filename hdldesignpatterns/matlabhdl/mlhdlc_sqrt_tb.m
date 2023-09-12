%

% Copyright 2013-2015 The MathWorks, Inc.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MATLAB test bench for the Sqrt calculation routine
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 

clear mlhdlc_sqrt;

% Choose a wordlength of 10 bits; the sqrt output is delayed by 10
% cycles of the clock due to our pipelined implementation.

% Inputs whose sqrt we want to compute.
% You may optionally change the wordlength and fractionlength properties of
% this routine and use it to see the resulting latency. Hardware usage is
% directly equal to number of bits in wordlength, while latency is
% its inverse.
%rng('default'); % always default to known state  
rng();
q = fi(sort(2^7*rand(1,30)),0,10,3);

% pump the numbers through the pipelined sqrt function
for itr = 1:length(q)
    [z(itr),xin(itr)] = mlhdlc_sqrt( q(itr) ); %#ok<SAGROW>
    % at each clock cycle, print the output sqrt value in floating point as well as binary
    abs_error = abs(sqrt(double(xin(itr))) - double(z(itr)));
    disp(['Iter = ',num2str(itr,'%2.02d'),'| Input = ',num2str(double(xin(itr)),'%3.3f'),'| Output = ', bin(z(itr)),...
          ' (',num2str(double(z(itr)),'%2.02f'),') | actual = ',...
          num2str(sqrt(double(xin(itr))),'%02.06f'),' | abserror = ',num2str(abs_error,'%01.06f'),''])
end


z = z(1+q.WordLength:end);
xin = xin(1+q.WordLength:end);
% show the absolute error in the calculations of the sqrt function by
% computing the square of the answer.
semilogy(1:length(z),double(z),'-om',1:length(z),[double(z).^2],'-ob',1:length(z),double(xin),'-k',...
         1:length(z),sqrt(double(xin)),'-r',1:length(z),1e-2 + abs(double(z) - sqrt(double(xin))),'-og') %#ok<NBRAK>
axis([0,length(z),1e-3,max(double(q))])
legend({'o/p : y = x^{0.5}','squared-o/p : y^2','i/p : x','sqrt i/p : x^{0.5}','abs err'},'Location','SouthEast')
title('Error analysis for bisection method, y = sqrt(x)')
xlabel('Sample #')
ylabel('Numeric value')
