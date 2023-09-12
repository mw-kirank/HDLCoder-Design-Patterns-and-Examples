
%

%   Copyright 2014-2015 The MathWorks, Inc.

close all

x = linspace(-10,10,1e3);
for itr = 1e3:-1:1
    y(itr) = mlhdlc_approximate_sigmoid_design( x(itr) );
end
plot( x, y );
title('Sigmoid function')
