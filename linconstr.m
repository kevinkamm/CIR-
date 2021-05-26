function [A,varargout] = linconstr(varargin)
%LINCONSTR provides nonlinear constraints for CIR- model
%    Input:
%       varargin (cell array): contains ('key',value) pairs
%           key 'b': its value contains the right-hand side of the 
%                    linear inequality constraints
%                    default: [0 0 0 0]
%    Output:
%       A (9x8 array): contains the linear constraints for given
%                      parameters in the form A*x<=b
%       varargout (cell array): if [A,b]=linconstr() is called, the right
%                               ride-hand side will be outputted
%

b = [0,0,0,0];
for k=1:2:nargin
    switch varargin{k}
        case 'b'
            b = varargin{k+1};
    end
end

% % parameters for $x_t$
% phi1x = params(1);
% phi2x = params(2);
% phi3x = params(3);
% xt0   = params(7);
% 
% % parameters for $y_t$
% phi1y = params(4);
% phi2y = params(5);
% phi3y = params(6);
% yt0   = params(8);

A=zeros(4,8);
% % $\sigma_x \in \mathbb{R} \Leftrightarrow \phi_1^x \geq \phi_2^x$
% c(1) = phi2x - phi1x;
A(1,1:2)=[-1 1];
% % $\sigma_y \in \mathbb{R} \Leftrightarrow \phi_2^y \geq \phi_1^y$
% c(2) = phi1y - phi2y;
A(2,4:5)=[1 -1];
% % Positive mean-reversion speed $2\phi_2^x \geq \phi_1^x$
% c(3) = phi1x - 2*phi2x;
A(3,1:2)=[1 -2];
% % Positive mean-reversion speed $2\phi_2^y \geq \phi_1^y$
% c(4) = phi1y - 2*phi2y;
A(4,4:5)=[1 -2];

switch nargout
    case 2
        varargout{1} = b;
end
end
%% Version without lower boundary conditions

% function [A,varargout] = linconstr(varargin)
% %LINCONSTR provides nonlinear constraints for CIR- model
% %    Input:
% %       varargin (cell array): contains ('key',value) pairs
% %           key 'b': its value contains the right-hand side of the 
% %                    linear inequality constraints
% %                    default: [0 0 0 0 -1 -1 0 0]
% %    Output:
% %       A (9x8 array): contains the linear constraints for given
% %                      parameters in the form A*x<=b
% %       varargout (cell array): if [A,b]=linconstr() is called, the right
% %                               ride-hand side will be outputted
% %
% 
% b = [0,0,0,0,-1,-1,0,0];
% for k=1:2:nargin
%     switch varargin{k}
%         case 'b'
%             b = varargin{k+1};
%     end
% end
% 
% % % parameters for $x_t$
% % phi1x = params(1);
% % phi2x = params(2);
% % phi3x = params(3);
% % xt0   = params(7);
% % 
% % % parameters for $y_t$
% % phi1y = params(4);
% % phi2y = params(5);
% % phi3y = params(6);
% % yt0   = params(8);
% 
% A=zeros(8,8);
% % % $\sigma_x \in \mathbb{R} \Leftrightarrow \phi_1^x \geq \phi_2^x$
% % c(1) = phi2x - phi1x;
% A(1,1:2)=[-1 1];
% % % $\sigma_y \in \mathbb{R} \Leftrightarrow \phi_2^y \geq \phi_1^y$
% % c(2) = phi1y - phi2y;
% A(2,4:5)=[1 -1];
% % % Positive mean-reversion speed $2\phi_2^x \geq \phi_1^x$
% % c(3) = phi1x - 2*phi2x;
% A(3,1:2)=[1 -2];
% % % Positive mean-reversion speed $2\phi_2^y \geq \phi_1^y$
% % c(4) = phi1y - 2*phi2y;
% A(4,4:5)=[1 -2];
% % % Positive mean & Feller condition $\phi_3^x \geq 1$
% % c(5) = -phi3x;
% A(5,3)=-1;
% % % Positive mean & Feller condition $\phi_3^y \geq 1$
% % c(6) = -phi3y;
% A(6,6)=-1;
% % % Positive starting initial datum
% % c(7) = -xt0;
% A(7,7)=-1;
% % % Positive starting initial datum
% % c(8) = -yt0;
% A(8,8)=-1;
% 
% switch nargout
%     case 2
%         varargout{1} = b;
% end
% end