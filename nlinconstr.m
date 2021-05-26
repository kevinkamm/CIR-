function [c,ceq] = nlinconstr(params,varargin)
%NLINCONSTR provides nonlinear constraints for CIR- model
%    Input:
%       params (8x1 array): params= $[\phi_1^x,...,\phi_1^y,...\phi_3^y,x_t0,y_t0]$
%    Output:
%       [c,0] (8x1 array, 0): contains the nonlinear constraints for given
%                             parameters in the form c(x)<=0, ceq(x)=0
%

if ~isempty(varargin)
    for k=1:1:length(varargin)
        switch varargin{k}
            case 'constraints'
                constr = varargin{k+1};
            otherwise
                constr = [0,0,0,0,0,0,0,0,0];
        end
    end
end
    

% parameters for $x_t$
phi1x = params(1);
phi2x = params(2);
phi3x = params(3);
xt0   = params(7);

% parameters for $y_t$
phi1y = params(4);
phi2y = params(5);
phi3y = params(6);
yt0   = params(8);

% $\sigma_x \in \mathbb{R} \Leftrightarrow \phi_1^x \geq \phi_2^x$
c(1) = phi2x - phi1x;
% $\sigma_y \in \mathbb{R} \Leftrightarrow \phi_2^y \geq \phi_1^y$
c(2) = phi1y - phi2y;
% Positive mean-reversion speed $2\phi_2^x \geq \phi_1^x$
c(3) = phi1x - 2*phi2x;
% Positive mean-reversion speed $2\phi_2^y \geq \phi_1^y$
c(4) = phi1y - 2*phi2y;
% Positive mean $\phi_3^x \geq 0$
c(5) = -phi3x;
% Positive mean $\phi_3^y \geq 0$
c(6) = -phi3y;
% Positive starting initial datum
c(7) = -xt0;
% Positive starting initial datum
c(8) = -yt0;
% Start with negative interest rate
c(9) = xt0 - yt0;

c = c + constr;
ceq =  0;