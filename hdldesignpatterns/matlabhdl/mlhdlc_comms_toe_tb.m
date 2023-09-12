function mlhdlc_comms_toe_tb
%

%   Copyright 2011-2015 The MathWorks, Inc.

os_rate = 8;
Ns = 128;
SNR = 100;
mu = .5; % smoothing factor for time offset estimates

% create simulated signal
rng('default'); % always default to known state  
b = round(rand(1,Ns));
d = reshape(repmat(b*2-1,os_rate,1),1,Ns*os_rate);

x = [zeros(1,Ns*os_rate) d zeros(1,Ns*os_rate)];
y = awgn(x,SNR);

w = fir1(3*os_rate+1,1/os_rate)';
z = filter(w,1,y);
r = z(4:end); % give it an offset to make things interesting

%tau = 0;
Nsym = floor(length(r)/os_rate);
tauh = zeros(1,Nsym-1); q = zeros(1,Nsym-1);
for i1 = 1:Nsym-1
    rVec = r(1+(i1-1)*os_rate:i1*os_rate);
    
    % Call to the Timing Offset Estimation Algorithm
    [tauh(i1),q(i1)] = mlhdlc_comms_toe(rVec,mu);
end

indexes = 1:os_rate:length(tauh)*os_rate;
indexes = indexes+tauh+os_rate-1-os_rate*2;

Fig1Loc=figposition([5 50 90 40]);
H_f1=figure(1); clf;
set(H_f1,'position',Fig1Loc);
subplot(2,1,1)
plot(r,'b');
hold on
plot(indexes,q,'ro');
axis([indexes(1) indexes(end) -1.5 1.5]);
title('Received Signal with Time Correct Detections');
subplot(2,1,2)
plot(tauh);
title('Estimate of Time Offset');

function y=figposition(x)
%FIGPOSITION Positions figure window irrespective of the screen resolution
% Y=FIGPOSITION(X) generates a vector the size of X. 
% This specifies the location of the figure window in pixels
% 
screenRes=get(0,'ScreenSize');
% Convert x to pixels
y(1,1)=(x(1,1)*screenRes(1,3))/100;
y(1,2)=(x(1,2)*screenRes(1,4))/100;
y(1,3)=(x(1,3)*screenRes(1,3))/100;
y(1,4)=(x(1,4)*screenRes(1,4))/100;

