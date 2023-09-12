function mlhdlc_hdlram_tb
%

%   Copyright 2012-2015 The MathWorks, Inc.

clear test_hdlram;

data = 100:200;
ring_out = zeros(1, length(data));

for ii=1:100
    ring_in = data(ii);
    ring_out(ii) = mlhdlc_hdlram(ring_in);
end


figure('Name', [mfilename, '_plot']);
subplot(2,1,1);
plot(1:100,data(1:100));
title('Input data to the ring counter')

subplot(2,1,2); 
plot(1:100,ring_out(1:100));
title('Output data')

end