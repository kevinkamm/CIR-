function [ctimes,MREs,params]=calibrationTimes(marketDF,marketTimes)
%CALIBRATIONTIMES computes the time needed for the calibration to the
%zero-coupon curve with different starting points $\Pi$

ctimes=zeros(4,1);
MREs=zeros(4,1);
params=cell(4,1);

[A,b] = linconstr();

% optimization options
opts = optimoptions('fmincon',...
                    'MaxFunctionEvaluations',1000000,...
                    'MaxIterations',100000,...
                    'TolCon',1e-12);
% lower and upper bounds
lb=1e-5*ones(1,8);
% Feller conditions
lb(3)=1;lb(6)=1;
% for convenience
ub=1*ones(1,8);
ub(3)=2;ub(6)=2; 

% Test one with ga
ticGa=tic;
param = ga(@(params)fmin(params,marketDF,marketTimes),...
             8,...
             A,b,...
             [],[],...
             lb,ub,...
             []);
ctimeGa=toc(ticGa);
[ctime,MRE]=ctimeFmincon(param);
ctimes(1)=ctimeGa+ctime;
MREs(1)=MRE;
params{1}='\UseVerb{ga}';
         
% Test two
param=(ub+lb)./2;
[ctime,MRE]=ctimeFmincon(param);
ctimes(2)=ctime;
MREs(2)=MRE;
params{2}=num2str(param);

% Test three
param=ub;
[ctime,MRE]=ctimeFmincon(param);
ctimes(3)=ctime;
MREs(3)=MRE;
params{3}=num2str(param);

% Test four
param=lb;
[ctime,MRE]=ctimeFmincon(param);
ctimes(4)=ctime;
MREs(4)=MRE;
params{4}=num2str(param);

% Test five
pRnd=rand(size(lb));
param=lb+(ub-lb).*pRnd;
[ctime,MRE]=ctimeFmincon(param);
ctimes(5)=ctime;
MREs(5)=MRE;
params{5}=num2str(param);

% Test six
pRnd=rand(size(lb));
param=lb+(ub-lb).*pRnd;
[ctime,MRE]=ctimeFmincon(param);
ctimes(6)=ctime;
MREs(6)=MRE;
params{6}=num2str(param);

    function [ctime,MRE]=ctimeFmincon(param)
        ticFmin=tic;
        paramFmin = fmincon(@(params)fmin(params,marketDF,marketTimes),...
                     param,...
                     A,b,...
                     [],[],...
                     lb,ub,...
                     [],...
                     opts);
        ctime=toc(ticFmin);
        MRE=mean(abs(marketDF./Pt0T(paramFmin,0,marketTimes) - 1));
    end
end