function mlhdlc_filter_tb
%

%   Copyright 2011-2015 The MathWorks, Inc.

% Initialization
clear mlhdlc_filter;
close all;
Fs      = 48e3; % Sampling frequency
F0      = 1000; % Chirp Initial frequency
T       = .01;  % Time in seconds to simulate
% Stimulus
t          = 0:1/Fs:T;
signal     = chirp(t,F0,T,Fs/2);  % Start @ F0, cross Fs/2 at t=T
NumSamples = length(signal);
rng('default');
noise      = (rand(1,NumSamples)-0.5)/2;
input      = noise + signal;
results    = zeros(1, NumSamples);


%Testbench
for i = 1:NumSamples
  % Design function
  results(i) = mlhdlc_filter(input(i));
end



figure('Name', [mfilename, '_inout']);
subplot(2,1,1); plot(signal,'b');
title('Stimulus');
hold on;
subplot(2,1,1); plot(noise,'r');
legend('Input','Noise');
% Plot input and output of filter
subplot(2,2,3); plot(input);
title('Combined Input');
subplot(2,2,4); plot(results);
title('Filtered Output');
hold off;
 
% Plot PSD of input and output
figure('Name', [mfilename, '_psd']);
subplot(2,1,1), pwelch(input,64,[],[],Fs);   % Input PSD
title('Input Power Spectral Density');
subplot(2,1,2), pwelch(results,64,[],[],Fs); % Output PSD
grid on
title('Output Power Spectral Density');
