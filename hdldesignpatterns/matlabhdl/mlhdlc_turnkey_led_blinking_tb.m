
%

%   Copyright 2013-2015 The MathWorks, Inc.

for i=1:16
    [yout, ~] = mlhdlc_turnkey_led_blinking(i-1, 0);
    [yout2, ~] = mlhdlc_turnkey_led_blinking(i-1, 1);
end

