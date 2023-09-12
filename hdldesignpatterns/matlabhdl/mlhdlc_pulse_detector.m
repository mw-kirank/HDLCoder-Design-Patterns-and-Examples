function [midSample, detected] = mlhdlc_pulse_detector(RxSignal, filterCoeffs, ...
                                                       threshold)

filterOut = discreteFIR(RxSignal, filterCoeffs);

power = real(filterOut)*real(filterOut) + imag(filterOut)*imag(filterOut);

[midSample, detected] = findPeaks(threshold, power);

end

function outdatabuf= discreteFIR(indatabuf, filterCoeffs)
% FIR Filter

persistent tap_delay
if isempty(tap_delay)
  tap_delay = complex(zeros(1,length(filterCoeffs)));
end

% Perform sum of products
outdatabuf = tap_delay * filterCoeffs(end:-1:1);

% Shift tap delay line
tap_delay = [tap_delay(2:length(filterCoeffs)) indatabuf];

end

function [MidSample,detected] = findPeaks(threshold, inData)
% Find peak within a window of input values

persistent tap_delay
if isempty(tap_delay)
  tap_delay = complex(zeros(1, 11));
end

MidIdx = ceil(11/2);

% Compare each value in the window to the middle sample via subtraction
MidSample = tap_delay(MidIdx);
CompareOut = tap_delay - MidSample; % this is a vector

% if all values in the result are negative and the middle sample is
% greater than a threshold, it is a local max
detected = all(CompareOut <= 0) && (MidSample > threshold);

% Shift tap delay line
tap_delay = [tap_delay(2:end) inData];

end
