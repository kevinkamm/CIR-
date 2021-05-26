function figures=plot_ZC(modelTimes,marketTimes,zcPricesModel,marketDF)
%PLOT_ZC plots the Zero-Coupon prices of given market and model. It uses
% linear interpolation for the marketDF and zcPricesModel in the figures
%   Input:
%       modelTimes (Nx1 array): contains the timeline of the model
%       zcPricesModel (Nx1 arra): contains the model zc prices
%       marketTimes (nx1 array): contains the times of the market discount
%                               factors
%       marketDF (nx1 array): contains the model discount factors
%   Output:
%       figures (figure cell array): contains the figure handles

% if nargin>4
%     for i=1:2:length(varargin)
%         switch varargin{i}
%     end
% end

if marketTimes(1)~=0
    % add discount factor for today
    marketTimes=[0;marketTimes];
    marketDF=[1;marketDF];
end

linspecs.model.linestyle = {'-','-','--'};
linspecs.model.marker = {'','',''};
linspecs.model.color = {[211,211,211]./255,'r','m'};
linspecs.market.linestyle = {'-'};
linspecs.market.marker = {'o'};
linspecs.market.color = {'k'};
linspecs.errorbar.linestyle = {'-'};
linspecs.errorbar.marker = {'o'};
linspecs.errorbar.color = {'r'};

% mean abs errors
tind = zeros(size(marketTimes));
for i=1:1:size(marketTimes,1)
    tind(i) = find(modelTimes<=marketTimes(i),1,'last');
end
ZC_abs_err = abs(zcPricesModel(tind)-marketDF);

figures(1) = figure('units','normalized',...
              'outerposition',[0 0 1 1]); hold on;
figures(1).WindowState = 'minimized';
figure_properties(figures(1));
legendEntries = {};
plots = [];

indMarket=1:1:length(marketTimes);
indModel=1:1:length(modelTimes);

% plot_model_DF_trajectories();
plot_market_ZC(indMarket);
plot_model_ZC(indModel);
plot_error_bars(indMarket);
legend(plots,legendEntries,...
      'Location','southoutside',...
      'NumColumns',length(legendEntries),...
      'Interpreter','latex'); 
xlabel('Time in years')
ylabel('Zero Coupon Prices')

figures(2) = figure('units','normalized',...
              'outerposition',[0 0 1 1]); hold on;
figures(2).WindowState = 'minimized';
figure_properties(figures(2));
legendEntries = {};
plots = [];

marketOneYear=find(marketTimes<=1,1,'last');
modelOneYear=tind(marketOneYear);
indMarket=1:1:marketOneYear;
indModel=1:1:modelOneYear;

% plot_model_DF_trajectories();
plot_market_ZC(indMarket);
plot_model_ZC(indModel);
plot_error_bars(indMarket);
legend(plots,legendEntries,...
      'Location','southoutside',...
      'NumColumns',length(legendEntries),...
      'Interpreter','latex'); 
xlabel('Time in years')
ylabel('Zero Coupon Prices')

    function plot_error_bars(ind)
        plots(end+1)=errorbar(marketTimes(ind),...
                     marketDF(ind),...
                     ZC_abs_err(ind),...
                     'LineStyle',linspecs.market.linestyle{1},...
                     'Color',linspecs.market.color{1});
        legendEntries{end+1}='Absoulte error bar';
        temp=zcPricesModel(tind);
        txt=text(marketTimes(ind),...
                 temp(ind),...
                 num2str(ZC_abs_err(ind),'%2.4f'),...
                 'VerticalAlignment','bottom','fontsize',12, ...
                 'Rotation',-90 ...
            );
    end
    function plot_market_ZC(ind)
        plots(end+1)=plot(marketTimes(ind),...
                 marketDF(ind),...
                 'LineStyle',linspecs.market.linestyle{1},...
                 'Marker',linspecs.market.marker{1},...
                 'Color',linspecs.market.color{1});
        legendEntries{end+1}='Market zero coupon prices $P^M(0,t)$';
    end
    function plot_model_ZC(ind)
        plots(end+1)=plot(modelTimes(ind),...
                 zcPricesModel(ind),...
                 'LineStyle',linspecs.model.linestyle{2},...
                 'Color',linspecs.model.color{2});
        legendEntries{end+1}='Model zero coupon prices $P(0,t)$';
    end
end
function figure_properties(fig)
    fontsize=22;
    linewidth=2;
    set(gca,'FontSize',fontsize)
    set(fig,'defaultlinelinewidth',linewidth)
    set(fig,'defaultaxeslinewidth',linewidth)
    set(fig,'defaultpatchlinewidth',linewidth)
    set(fig,'defaultAxesFontSize',fontsize)
end