% Ref: http://en.wikipedia.org/wiki/Black%E2%80%93Scholes
%
% output @C, Value of a call option at time @t, for time-to-expiry @T,
% for spot price @S, of asset, obtained at strike price @K, and a 
% compounding rate @r, with a volatility @sigma 
%
function C = mlhdlc_european_call( t_now, T_expiry, S_spot_price, r_rate, sigma_volatility)

%   Copyright 2014-2015 The MathWorks, Inc.

	T_remain = T_expiry - t_now;
	c0 = (sigma_volatility*sqrt(T_remain));
	c1 = mlhdlc_european_call_invdiv(c0);
	c2 = S_spot_price*(1/98);
	d1 = c1*(log(c2)+(r_rate+sigma_volatility^2*0.5)*T_remain);
	d2 = d1 - c0;
    q = -r_rate*T_remain;
	C = mlhdlc_european_call_normcdf(d1)*S_spot_price - mlhdlc_european_call_normcdf(d2)*98*exp(q);
end
