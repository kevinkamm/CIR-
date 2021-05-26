function [R,varargout]=ccRateModel(params,t,T,x,y,modelTimes)
%CCRATEMODEL calculates the continuously compounded spot interest rate
% in the CIR- model from t years to T years in 1-year steps (in total p=T-t steps)
%    Input:
%       params (8x1 array): params= $[\phi_1^x,...,\phi_1^y,...\phi_3^y,x_t0,y_t0]$
%       t (double): initial time, assumes t>0 and to be a full year
%       T (double): terminal time, assumes T>t and to be a full year
%       x (NxM array): contains the simulated paths of the CIR process x
%       y (NxM array): contains the simulated paths of the CIR process y
%       modelTimes (Nx1 array): contains the timeline of the model
%    Output:
%       R (pxM array): contains the simulated cc rates R(t,T) for the p years
%                      between t and T years
%       varargout{1}: if desired returns maturities at which the forward curve
%                     is evaluated
%       varargout{2}: if desired returns zero coupon prices P(t,T)

% parameters for $x_t$
phi1x = params(1);
phi2x = params(2);
phi3x = params(3);
% xt0    = params(7);

% parameters for $y_t$
phi1y = params(4);
phi2y = params(5);
phi3y = params(6);
% yt0    = params(8);

maturities = (t+1:1:T)';
tau=maturities-t;

t0ind=find(modelTimes<=t,1,'last');

[Ax,Bx] = RiccatiCIR(phi1x,phi2x,phi3x,tau);
[Ay,By] = RiccatiCIR(phi1y,phi2y,phi3y,tau);
zcPrice = Ax.*exp(-Bx.*x(t0ind,:)).*Ay.*exp(By.*y(t0ind,:));
R=log(1./zcPrice)./tau;

if nargout>1
    varargout{1}=maturities;
end
if nargout>2
    varargout{2}=zcPrice;
end
end