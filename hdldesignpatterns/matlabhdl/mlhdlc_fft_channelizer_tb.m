% Create filter coefficients

M = 24;     % Number of bands
taps = 12;  % number of taps
lowpass = firpm(M*taps-1,[0 .02 .07 1],[1 1 0 0]);
coeffs = fi(reshape(lowpass,M,taps),1,19);

% Create input data
fs = 1000;
f = [100 200 300];
t = 0:1/fs:1;
sinewaves = [sin(2*pi*t*f(1));sin(2*pi*t*f(2));sin(2*pi*t*f(3))];
sinewave = sum(sinewaves, 1);
sinewave_fixpt = fi(sinewave, 1, 12, 9);

LUT = ((0:24:287)+(0:23)')';
LUT = int32(LUT(:));

% Save filter coefficients and look up table for delay line ordering
save coeffs.mat coeffs
save LUT.mat LUT

numFrames = floor(numel(sinewave)/taps);
outsize = taps + 1;
polyPhase_out = zeros(numFrames,outsize);
for idx = 1:numFrames
    startidx = (idx-1)*taps+1;
    endidx = idx*taps;
    current_input = sinewave_fixpt(startidx:endidx).';
    polyPhase_out(idx, :) = mlhdlc_fft_channelizer(current_input);
end
