clear all;close all;fclose('all');
% rng('default');
%% Data sets
fileNames={'TermStructureEUR_20191230','TermStructureEUR_20201130'};
fileNamesSwap={'CalibrazioneEur_191231','CalibrazioneEur_201211'};
% Choose the dataset
dataIndex=1;
calibrationTimeTable=1; %set to zero if not wanted
%% Load the term structure
fileDir='TermStructure';
fileName=fileNames{dataIndex};
file = [fileDir,'\',fileName,'.xls'];
sheet = 'Term_Str_Valori';
disp('Loading Termstructure data')

dataset = xlsread(file,sheet);

% zero rates converted from percent to decimal
marketZeroRates = dataset(:,1)/100;
% market discount factor in decimals
marketDF = dataset(:,2);
% times of market discount factors and rates in years
marketTimes = dataset(:,3);

%% Load the swaption strikes
disp('Loading Swaption data')
fileDirSwap='Swaption';
fileNameSwap=fileNamesSwap{dataIndex};
fileSwap = [fileDirSwap,'\',fileNameSwap,'.xls'];
sheetSwap = 'Principale';

strikeSwap = xlsread(fileSwap,sheetSwap,'R14:V20');
maturitySwap = xlsread(fileSwap,sheetSwap,'Q14:Q20');
tenorSwap = xlsread(fileSwap,sheetSwap,'R13:V13');
marketSwapPrice = xlsread(fileSwap,sheetSwap,'J14:N20');


disp('Finished loading data')
%% Calibration time test
ctimes=[];
MREs=[];
params=[];
if calibrationTimeTable
    disp('Computing Calibration Time Table')
    [ctimes,MREs,params]=calibrationTimes(marketDF,marketTimes);
end
%% Calibrate the CIR model to the term-structure
% We will use *fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon,options)* with:
% * fun = fmin objective function
% * x0 result from ga
% * A, b linear inequality constraints Ax <= b, b=zeros(size(param))
%   A is evaluated in linconstr()
% * Aeq, beq = [] no linear equality constraints
% * only positive parameters lb <= params <= ub
% * nonlcon = [] no nonlinear constraints 

% linear constraint matrix
% b = [0,0,0,0,0,0,0,0,0];
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

paramGa=(ub+lb)./2;
errGa=-1;
ctimeGa=-1;
disp('Start local optimization')
ticFmin=tic;
[paramFmin,errFmin] = fmincon(@(params)fmin(params,marketDF,marketTimes),...
             paramGa,...
             A,b,...
             [],[],...
             lb,ub,...
             [],...
             opts);
ctimeFmin=toc(ticFmin);
fprintf('Finished local optimization with err=%1.3e after %3.3f seconds\n',errFmin,ctimeFmin)
meanRelL1Err = mean(abs(marketDF./Pt0T(paramFmin,0,marketTimes) - 1));
meanRelL2Err = mean((marketDF./Pt0T(paramFmin,0,marketTimes) - 1).^2);
%% Simulate CIR- model
% Choose the parameters for simulation
t0 = 0;
T = marketTimes(end);
dt=1/256;
% dt=1/512;
N = ceil((T-t0)/dt + 1);
modelTimes = linspace(t0,T,N);
M = 1e4;
disp('Start simulation')
ticSim=tic;
[x,y,r,modelDF,modelParam] = sim_CIR(paramFmin,t0,T,N,M);
ctimeSim=toc(ticSim);
fprintf('Simulation done after %3.3f seconds\n',ctimeSim);
tind = zeros(size(marketTimes));
for i=1:1:size(marketTimes,1)
    tind(i) = find(modelTimes<=marketTimes(i),1,'last');
end
dfMeanErr = abs(mean(modelDF(tind,:),2)-marketDF);
fprintf('Max error for discount factor %1.3e\n',max(dfMeanErr))
%% Compute the mean and variance of the CIR- model
[mu,var] = mean_variance(paramFmin,modelTimes);
fprintf('For T=%1.3g the mean is %1.3e and variance %1.3e\n',...
        modelTimes(end),mu(end),var(end))
%% Compute forwards
disp('Compute forwards')
Tforward=30;
for t=[1,3,5,10,25]
forwardModel=ccRateModel(paramFmin,t,Tforward,x,y,modelTimes);
forwardMarket=ccRateMarket(t,Tforward,marketZeroRates,marketTimes);
fprintf('Mean squared error for %d year forward curve  %1.3e\n',...
        t,mean((mean(forwardModel,2)-forwardMarket).^2,1));
end
%% Compute Swaption matrix
disp('Compute swaption matrix')
[priceSwap,errorSwap]=swaption_matrix(paramFmin,x,y,modelTimes,modelDF,...
                          strikeSwap,maturitySwap,tenorSwap,marketSwapPrice);
%% Plot zero coupon prices
disp('Plotting Zero-coupon prices')
zcPricesModel=Pt0T(paramFmin,0,modelTimes)';
zcFigures=plot_ZC(modelTimes,marketTimes,zcPricesModel,marketDF);
% %% To Device
% gpuDevice(1);
% [marketTimes,modelTimes,...
% marketDF,modelDF,...
% paramFmin,...
% x,y,r...
% ]=toDevice(marketTimes,modelTimes,...
% marketDF,modelDF,...
% paramFmin,...
% x,y,r);
%% Plot discount factors
disp('Plotting DF')
dfFigures=plot_DF(modelTimes,modelDF,marketTimes,marketDF);
%% Plot interest rates
disp('Plotting rates')
rFigures=plot_rates(modelTimes,x,y,r);
%% Plot mean, variance and distribution
disp('Plotting mean, var and distribution')
mvFigures=plot_Mean_Variance(modelTimes,marketTimes,mu,var,r);
%% Plot forward zc prices
disp('Plotting t-forward zc prices using market cc-rates')
fFigures=plot_forward([1,3,5],T,...
                      modelTimes,marketTimes,...
                      paramFmin,x,y,marketZeroRates);
% %% To Host
% [marketTimes,modelTimes,...
% marketDF,modelDF,...
% paramFmin,...
% x,y,r...
% ]=toHost(...
% marketTimes,modelTimes,...
% marketDF,modelDF,...
% paramFmin,...
% x,y,r...
% );
%% Create output
disp('Saving figures and creating output')
output(fileName,...
       marketTimes,marketDF,marketZeroRates,...
       paramFmin,modelParam,...
       ctimes,MREs,params,...
       dt,M,...
       errGa,errFmin,meanRelL1Err,meanRelL2Err,dfMeanErr,...
       ctimeGa,ctimeFmin,ctimeSim,...
       zcFigures,dfFigures,rFigures,mvFigures,fFigures,...
       maturitySwap,tenorSwap,errorSwap,marketSwapPrice,strikeSwap)
disp('Done')
% %% Auxilary functions
% function [marketTimes,modelTimes,...
%           marketDF,modelDF,...
%           paramFmin,...
%           x,y,r...
%           ]=toDevice(...
%           marketTimes,modelTimes,...
%           marketDF,modelDF,...
%           paramFmin,...
%           x,y,r...
%           )
% marketTimes=gpuArray(marketTimes);
% modelTimes=gpuArray(modelTimes);
% marketDF=gpuArray(marketDF);
% modelDF=gpuArray(modelDF);
% paramFmin=gpuArray(paramFmin);
% x=gpuArray(x);
% y=gpuArray(y);
% r=gpuArray(r);
% end
% function [marketTimes,modelTimes,...
%           marketDF,modelDF,...
%           paramFmin,...
%           x,y,r...
%           ]=toHost(...
%           marketTimes,modelTimes,...
%           marketDF,modelDF,...
%           paramFmin,...
%           x,y,r...
%           )
% marketTimes=gather(marketTimes);
% modelTimes=gather(modelTimes);
% marketDF=gather(marketDF);
% modelDF=gather(modelDF);
% paramFmin=gather(paramFmin);
% x=gather(x);
% y=gather(y);
% r=gather(r);
% end