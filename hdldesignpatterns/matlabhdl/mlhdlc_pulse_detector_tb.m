clear mlhdlc_pulse_detector

%% Input data
% Create pulse to detect
rng('default');
PulseLen = 64;
theta = rand(PulseLen,1);
pulse = exp(1i*2*pi*theta);

% Insert pulse to Tx signal
SignalLen = 5000;
PulseLoc = randi(SignalLen-PulseLen*2);

TxSignal = zeros(SignalLen,1);
TxSignal(PulseLoc:PulseLoc+PulseLen-1) = pulse;

% Add noise
Noise = complex(randn(SignalLen,1),randn(SignalLen,1));
RxSignal = TxSignal + Noise;

% Scale signal
scale1 = max([abs(real(RxSignal)); abs(imag(RxSignal))]);
RxSignal = RxSignal/scale1;

% Create filter coefficients
CorrFilter = conj(flip(pulse))/PulseLen;

threshold = 0.03;
midSample = zeros(size(RxSignal));
detected  = false(size(RxSignal));
for ii=1:numel(RxSignal)
    [midSample(ii), detected(ii)] = mlhdlc_pulse_detector(RxSignal(ii), CorrFilter, ...
                                                          threshold);
end

figure(1); clf
plot(detected.*midSample);
