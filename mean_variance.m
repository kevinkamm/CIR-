function [mu,var] = mean_variance(params,T)
%MEAN_VARIANCE computes the mean and variance of CIR- model for given parameters
%    Input:
%       params (8x1 array): params= $[\phi_1^x,...,\phi_1^y,...\phi_3^y,x_t0,y_t0]$
%       T (nx1 array): contains the maturities
%    Output:
%       mu (nx1 array): contains the means for given maturities T
%       var (nx1 array): contains the variances for given maturities T
%

% parameters for $x_t$
phi1x = params(1);
phi2x = params(2);
phi3x = params(3);
x0    = params(7);

% parameters for $y_t$
phi1y = params(4);
phi2y = params(5);
phi3y = params(6);
y0    = params(8);

% retrieve coeffiecents for $x_t$
kx     = 2*phi2x - phi1x;
sigmaxSquared = 2*(phi1x*phi2x - phi2x^2);
thetax = phi3x*sigmaxSquared/(2*kx);

% retrieve coeffiecents for $y_t$
ky     = 2*phi2y - phi1y;
sigmaySquared = 2*(phi2y^2 - phi1y*phi2y);
thetay = phi3y*sigmaySquared/(2*ky);

% compute CIR mean variances
[mux,varx] = mean_variance_CIR(kx,thetax,sigmaxSquared,x0,T); 
[muy,vary] = mean_variance_CIR(ky,thetay,sigmaySquared,y0,T);

% by linearity of the expectation
mu = mux-muy;
% by independence of the processes
var = varx + vary;
end
function [mu,var]=mean_variance_CIR(kz,thetaz,sigmazSquared,z0,T)
%MEAN_VARIANCE_CIR computes the mean and variance of CIR model for given parameters
%    Input:
%       kz (double) : contains the mean-reversion speed
%       thetaz (double) : contains the mean-reversion parameter
%       sigmazSquared (double) : contains the squared volatility
%       z0 (double) : contains the initial value
%       T (nx1 array): contains the maturities
%    Output:
%       mu (nx1 array): contains the means for given maturities T
%       var (nx1 array): contains the variances for given maturities T
%

temp = exp(-kz.*T);
mu = z0*exp(-kz.*T) +...
     thetaz.*(1-temp);
var = z0*sigmazSquared*(...
        temp - (temp.^2)...
      )./kz +...
      thetaz.*sigmazSquared.*...
        ((1-temp).^2)./...
        (2.*kz);
end