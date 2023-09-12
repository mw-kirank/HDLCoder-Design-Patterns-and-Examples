
%

%   Copyright 2011-2015 The MathWorks, Inc.


Fs = 256;              % Sampling frequency
Ts = 1/Fs;             % Sample time
t = 0:Ts:1-Ts;         % Time vector from 0 to 1 second
f1 = Fs/2;             % Target frequency of chirp set to Nyquist
in = sin(pi*f1*t.^2);  % Linear chirp from 0 to Fs/2 Hz in 1 second
out = zeros(size(in)); % Output the same size as the input

for ii=1:length(in)
    out(ii) = mlhdlc_df2t_filter(in(ii));
end

% Plot
figure('Name', [mfilename, '_plot']);
subplot(2,1,1);
plot(in);
xlabel('Time')
ylabel('Amplitude')
title('Input Signal (with Noise)')

subplot(2,1,2);
plot(out);
xlabel('Time')
ylabel('Amplitude')
title('Output Signal (filtered)')
