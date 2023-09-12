
%

%   Copyright 2011-2015 The MathWorks, Inc.

clear mlhdlc_iir_filter;

Fs = 800; 

[z,p,k] = butter(15,300/Fs,'high');
[sos,g] = zp2sos(z,p,k);	     % Convert to SOS form
% Hd = dfilt.df2tsos(sos,g);   % Create a dfilt object
% h = fvtool(Hd);	             % Plot magnitude response
% set(h,'Analysis','freq')	     % Display frequency response 

L = 1000; 
t = (0:L-1)'/Fs;  
x = 5*sin(2*pi*50*t) + 10*cos(2*pi*340*t); 
rng('default'); % always default to known state  
x = x + .5*randn(size(x));  % noisy signal
y = zeros(size(x));

% Call to the design
sos = sos.';
for i=1:numel(x)
    y(i) = mlhdlc_iir_filter(x(i), sos(:), g);
end

close all;
figure('Name', [mfilename, '_psd_plot']);
pwelch(x, 128);
hold on;
pwelch(y, 128);
yh = get(gca,'Children');
set(yh(1),'Color','r');
