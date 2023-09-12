%#codegen
function pid_out = mlhdlc_pid(err_d)

%   Copyright 2011-2015 The MathWorks, Inc.

%SampleRate = 20000; % Sample rate
%Ts = 1/SampleRate;  % System sample rate
sat_limt=7.999;     % Saturation in controller

channel_size = length(err_d);
Pvector = (1:channel_size) * 10;
Dvector = (1:channel_size) * 3e-1;
gc1 = 200; %1/(Ts*10);

persistent h1;
if isempty(h1)
    h1 = dsp.Delay;
end

h1n = step(h1, err_d);
sout = err_d - h1n;

gout1 = sout .* gc1;
P = err_d .* Pvector;
D = gout1 .* Dvector;

sout2 = P + D;

pid_out = coder.nullcopy(sout2);
if any(sout2 > sat_limt)
    for ii=1:length(pid_out)
        pid_out(ii) = sat_limt;
    end
elseif any(sout2 < -sat_limt)
    for ii=1:length(pid_out)
        pid_out(ii) = -sat_limt;
    end
else
    pid_out = sout2;
end

end