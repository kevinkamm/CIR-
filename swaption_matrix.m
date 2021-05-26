function [price,error]=swaption_matrix(params,x,y,modelTimes,modelDF,...
                         strikeSwap,maturitySwap,tenorSwap,marketSwapPrice)
%SWAPTION_MATRIX calculates the swaption matrix
%    Input:
%       params (8x1 array): params= $[\phi_1^x,...,\phi_1^y,...\phi_3^y,x_t0,y_t0]$
%       x (NxM array): contains the simulated paths of the CIR process x
%       y (NxM array): contains the simulated paths of the CIR process y
%       modelTimes (Nx1 array): contains the timeline of the model
%       modelDF (NxM array): contains the CIR- discount factors
%       strikeSwap (qxp array): strikes(= forward swap rates) of the 
%                               swaption contract
%       maturitySwap (qx1 array): contains the maturities of the contract
%       tenorSwap (px1 array): contains the time to length of time till
%                              expiry
%       marketSwapPrices (qxp array): market prices using Black's method
%    Output:
%       price (qxpxM array): contains the trajcetories of the swaption
%                            prices
%       error (qxp array): contains the error in decimals compared to the
%                          market swaption matrix
%

% we assume annual payments 
paymentTimes=1:1:tenorSwap(end);

% for setting correct tau: T=maturity+tenor
T=reshape(maturitySwap,[],1)+reshape(paymentTimes,1,[]);
% calculate Zero coupon prices
zcPrice=PtT(params,maturitySwap,T,x,y,modelTimes);

% find tenor indices in paymentTimes
tenInd=zeros(size(tenorSwap));
for i=1:1:length(tenInd)
    tenInd(i) = find(paymentTimes<=tenorSwap(i),1,'last');
end
% find maturities in modelTimes
matInd=zeros(size(maturitySwap));
for i=1:1:length(matInd)
    matInd(i) = find(modelTimes<=maturitySwap(i),1,'last');
end

% calculate swap rate
swapRate=(1-zcPrice)./cumsum(zcPrice,2);

% compute discounted swaption price
modelDF=reshape(modelDF,size(modelDF,1),1,size(modelDF,2));
strike=reshape(strikeSwap,size(strikeSwap,1),size(strikeSwap,2),1);
price=modelDF(matInd,1,:).*max(0,swapRate(:,tenInd,:)-strike);

% compute error between model mean and market prices
error=mean(price,3)-marketSwapPrice;
end