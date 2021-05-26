function [R,varargout]=ccRateMarket(t,T,marketZeroRates,marketTimes)
%CCRATEMARKET calculates the continuously compounded spot interest rate
% in the CIR- model from t years to T years in 1-year steps (in total p=T-t steps)
%    Input:
%       t (double): initial time
%       T (double): terminal time
%       marketZeroRates (nx1 array): contains the market zero rates
%       marketTimes (nx1 array): contains the times of the market rates
%    Output:
%       R (px1 array): contains the market cc rates R^M(t,T) for the p dates
%                      between t and T years
%       varargout{1}: if desired returns maturities at which the forward curve
%                     is evaluated
%       varargout{2}: if desired returns zero coupon prices P^M(t,T)

maturities = (t+1:1:T)';
tau=maturities-t;
t0ind=find(marketTimes<=t,1,'last');

interpolRates=interp1(marketTimes,marketZeroRates,maturities,'linear');
temp=interpolRates.*maturities-marketZeroRates(t0ind).*marketTimes(t0ind);
zcPrice=exp(-temp);
R=(interpolRates.*maturities-marketZeroRates(t0ind).*marketTimes(t0ind))./tau;
if nargout>1
    varargout{1}=maturities;
end
if nargout>2
    varargout{2}=zcPrice;
end
end

% %% Alternative with market discount factors
% function [f,varargout]=ccRateMarket(t,T,marketDF,marketTimes)
% %CCRATEMARKET calculates the continuously compounded spot interest rate
% % in the CIR- model from t years to T years in 1-year steps (in total p=T-t steps)
% %    Input:
% %       t (double): initial time
% %       T (double): terminal time
% %       marketZeroRates (nx1 array): contains the market zero rates
% %       marketTimes (nx1 array): contains the times of the market rates
% %    Output:
% %       f (pxM array): contains the simulated cc rates for the p dates
% %                      between t and T years
% %       varargout{1}: if desired returns maturities at which the forward curve
% %                     is evaluated
% 
% maturities = (t+1:1:T)';
% tau=maturities-t;
% t0ind=find(marketTimes<=t,1,'last');
% 
% interpolRates=interp1(marketTimes,marketDF,maturities,'linear');
% f=(log(marketDF(t0ind)-log(interpolRates)))./tau;
% if nargout>1
%     varargout{1}=maturities;
% end
% end