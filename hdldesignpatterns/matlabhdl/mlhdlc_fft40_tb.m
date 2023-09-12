fs = 20;  % Sampling frequency
t = 0:1/fs:2*pi*10;

% create a chirp input signal
fstart = 100;
fstop  = 300;
% chrp = 100*chirp(t,fstart,t(end),fstop,'complex');

F = 5;
X = complex(cos(2*pi*F*t), sin(2*pi*F*t));

X_fi = fi(X(1:1240), 1, 18, 16);

fft_out = X_fi;
frameSize = 40;
frame = zeros(40,1,'like',X_fi);
for ii=1:frameSize:numel(X_fi)
    frame(:) = X_fi(ii:ii+frameSize-1);
    fft_out(ii:ii+frameSize-1) = mlhdlc_fft40(frame);
end

figure(1);
% Plot one frame to show sine wave at 5Hz
freqs = 0:fs/frameSize:(fs-fs/frameSize);
subplot(3,1,1),plot(freqs, abs(fft_out(1:frameSize)));

% compare with matlab fft
matlab_fft = fft(X(1:40));
subplot(3,1,2),plot(freqs, abs(matlab_fft(1:frameSize)));

% plot difference
subplot(3,1,3),plot(freqs, abs(abs(fft_out(1:frameSize))-abs(fft_out(1:frameSize))));
