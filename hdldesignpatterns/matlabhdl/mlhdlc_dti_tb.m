% some cleanup

%   Copyright 2012-2023 The MathWorks, Inc.

clear dti

% input signal
x_in = 5*sin(2.*pi.*(0:0.001:2)).';


len = length(x_in);
y_out = zeros(1,len);
is_clipped_out = zeros(1,len);

for ii=1:len
    data = x_in(ii);
    % call to the design 'mlhdlc_sfir' that is targeted for hardware
    init_val = 0;
    gain_val = 1;
    upper_limit = 500;
    lower_limit = -500;
    
    % call to the design that does DTI
    [y_out(ii), is_clipped_out(ii)] = mlhdlc_dti(data, init_val, gain_val, upper_limit, lower_limit);
    
end

figure('Name', [mfilename, '_plot']);
subplot(2,1,1);
plot(1:len,x_in);
xlabel('Time')
ylabel('Amplitude')
title('Input Signal (Sin)')

subplot(2,1,2); plot(1:len,y_out);
xlabel('Time')
ylabel('Amplitude')
title('Output Signal (DTI)')
