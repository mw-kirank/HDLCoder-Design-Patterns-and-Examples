clear ('mlhdlc_lms_fcn');
% returns an adaptive FIR filter System object, HLMS, that computes the 
% filtered output, filter error, and the filter weights for a given input 
% and desired signal using the Least MeanSquares (LMS) algorithm.

% Copyright 2011-2019 The MathWorks, Inc.

stepSize = 0.01;
reset_weights =false;

hfilt = dsp.FIRFilter;                     % System to be identified
hfilt.Numerator = fir1(10, .25);

rng('default');                            % always default to known state  
x = randn(1000,1);                         % input signal
d = step(hfilt, x) + 0.01*randn(1000,1);   % desired signal

hSrc = dsp.SignalSource(x);
hDesiredSrc = dsp.SignalSource(d);

hOut = dsp.SignalSink;
hErr = dsp.SignalSink;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Call to the design
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
while (~isDone(hSrc))
    [y, e, w] = mlhdlc_lms_fcn(step(hSrc), step(hDesiredSrc), ... 
                stepSize, reset_weights);
    step(hOut, y);
    step(hErr, e);
end

figure('Name', [mfilename, '_plot']);
subplot(2,1,1), plot(1:1000, [d,hOut.Buffer,hErr.Buffer]);
title('System Identification of an FIR filter');
legend('Desired', 'Output', 'Error');
xlabel('time index'); ylabel('signal value');
subplot(2,1,2); stem([hfilt.Numerator.', w(end-10:end).']);
legend('Actual','Estimated');
xlabel('coefficient #'); ylabel('coefficient value');
