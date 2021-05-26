function f = fmin(params,marketDF,marketTimes)
%FMIN provides the objective function for CIR- model calibration
%    Input:
%       params (8x1 array): params= $[\phi_1^x,...,\phi_1^y,...\phi_3^y,x_t0,y_t0]$
%       marketDF (nx1 array): contains the market discount factor
%       marketTimes (nx1 array): contains the market year fractions
%    Output:
%       f (double): contains the value of the least squares problem
%
cirPrice = Pt0T(params,0,marketTimes);
f = sum((marketDF./cirPrice - 1).^2,1);
end
