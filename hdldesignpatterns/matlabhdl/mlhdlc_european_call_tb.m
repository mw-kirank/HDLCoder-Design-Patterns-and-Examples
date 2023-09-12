
%

%   Copyright 2014-2015 The MathWorks, Inc.

t_now = 0;
T_expiry = 0.1667;
S_spot_price = 100;
K_strike_price = 98;
r_rate = 0.07;
sigma_volatility = 0.2;

tic

Texpiry = linspace(0.1,0.2,10);
Sprice = linspace(95,105,10);
for itx = 1:length(Texpiry)
    for ity = 1:length(Sprice)        
        T_expiry = Texpiry(itx);
        S_spot_price = Sprice(ity);        
        
        % call to the design
        C_orig(itx,ity) = mlhdlc_european_call( t_now, T_expiry, S_spot_price, r_rate, sigma_volatility); %#ok<*SAGROW>
        
    end
end
calculation_time = toc;

figure()
surf(Texpiry',Sprice,C_orig)
title('European call option pricing')
xlabel('Time to expiry')
ylabel('Spot price')
zlabel('Option price')
