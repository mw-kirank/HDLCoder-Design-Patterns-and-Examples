function [LED, Read_back] = mlhdlc_turnkey_led_blinking(Blink_frequency, Blink_direction)
%

%   Copyright 2013-2015 The MathWorks, Inc.

persistent freqCounter LEDCounter

if isempty(freqCounter)
    freqCounter = 0;
    LEDCounter = 255;
end

if Blink_frequency <= 0
    Blink_frequency = 0;
elseif Blink_frequency >= 15
    Blink_frequency = 15;
end

blinkFrequencyOut = LookupTable(Blink_frequency);
if blinkFrequencyOut == freqCounter
    freqMatch = 1;
else
    freqMatch = 0;
end

freqCounter = freqCounter + 1;

if freqMatch
    freqCounter = 0;
end

if Blink_direction
    LED = 255 - LEDCounter;
else
    LED = LEDCounter;
end

if LEDCounter == 255
    LEDCounter = 0;
elseif freqMatch
    LEDCounter = LEDCounter + 1;
end

Read_back = LED;
end


function y = LookupTable(idx)
s =  2.^(26:-1:11)';

y = s(idx+1);
end