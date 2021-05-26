function zcPrice = Pt0T(params,t0,T)
%Pt0T computes zero-coupon price of CIR- model for given parameters
%    Input:
%       params (8x1 array): params= $[\phi_1^x,...,\phi_1^y,...\phi_3^y,x_t0,y_t0]$
%       t0 (double): contains the current time
%       T (nx1 array): contains the maturities
%    Output:
%       zcPrice (nx1 array): contains the zero-coupon prices for given 
%                            initial time t0 and maturities T
%

% parameters for $x_t$
phi1x = params(1);
phi2x = params(2);
phi3x = params(3);
xt0    = params(7);

% parameters for $y_t$
phi1y = params(4);
phi2y = params(5);
phi3y = params(6);
yt0    = params(8);

tau = T-t0;

[Ax,Bx] = RiccatiCIR(phi1x,phi2x,phi3x,tau);
[Ay,By] = RiccatiCIR(phi1y,phi2y,phi3y,tau);
zcPrice = Ax.*exp(-Bx.*xt0).*Ay.*exp(By.*yt0);
end