
%

%   Copyright 2014-2015 The MathWorks, Inc.

x = linspace(0,3,1024);
for ii=length(x):-1:1
    y(ii) = mlhdlc_replacement_exp(x(ii));
end

plot(x, y);