function zcPrice = PtT(params,t,T,x,y,modelTimes)
%PtT computes zero-coupon price of CIR- model for given parameters
%    Input:
%       params (8x1 array): params= $[\phi_1^x,...,\phi_1^y,...\phi_3^y,x_t0,y_t0]$
%       t (px1): contains the current times
%       T (nx1 array or pxn): contains the maturities
%       x (NxM array): contains the simulated paths of the CIR process x
%       y (NxM array): contains the simulated paths of the CIR process y
%       modelTimes (Nx1 array): contains the timeline of the model
%    Output:
%       zcPrice (pxnxM array): contains the future discount factors DtT for  
%                              giveninitial time t and maturities T. To get 
%                              the future zero coupon price use 
%                              mean(zcPrice,3)

tind=zeros(size(t));
for i=1:1:length(tind)
    tind(i) = find(modelTimes<=t(i),1,'last');
end

xt=x(tind,:);
xt=reshape(xt,size(xt,1),1,size(xt,2));
yt=y(tind,:);
yt=reshape(yt,size(yt,1),1,size(yt,2));
t=reshape(t,[],1,1);
if size(T,2)==1
    T=reshape(T,1,[],1);
else
    T=reshape(T,size(T,1),size(T,2),1);
end
tau=T-t;

% parameters for $x_t$
phi1x = params(1);
phi2x = params(2);
phi3x = params(3);

% parameters for $y_t$
phi1y = params(4);
phi2y = params(5);
phi3y = params(6);

[Ax,Bx] = RiccatiCIR(phi1x,phi2x,phi3x,tau);
[Ay,By] = RiccatiCIR(phi1y,phi2y,phi3y,tau);
zcPrice = Ax.*exp(-Bx.*xt).*Ay.*exp(By.*yt);
end