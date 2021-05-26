function figures=plot_forward(t,T,...
                              modelTimes,marketTimes,...
                              paramFmin,x,y,marketZeroRates)
%PLOT_FORWARD plots the t-forward zero-coupon prices for at future date t
% with maturitiy T. It one year steps from t to T in the plots.
%   Input:
%       t (px1 array): contains the starting points, t>0
%       T (double): contains the end of the curve, e.g. 30 years
%       modelTimes (Nx1 array): contains the timeline of the model
%       marketTimes (nx1 array): contains the times of the market rates
%       params (8x1 array): params= $[\phi_1^x,...,\phi_1^y,...\phi_3^y,x_t0,y_t0]$
%       x (NxM array): contains the simulated paths of the CIR process x
%       y (NxM array): contains the simulated paths of the CIR process y
%       marketZeroRates (nx1 array): contains the market zero rates
%   Output:
%       figures (figure cell array): contains the figure handles

% if nargin>4
%     for i=1:2:length(varargin)
%         switch varargin{i}
%     end
% end

linspecs.model.linestyle = {'-','--'};
linspecs.model.marker = {'x',''};
linspecs.model.color = {'r','m'};
linspecs.market.linestyle = {'-'};
linspecs.market.marker = {'o'};
linspecs.market.color = {'k'};
linspecs.errorbar.linestyle = {'-'};
linspecs.errorbar.marker = {'o'};
linspecs.errorbar.color = {'k'};

i=1;
for tforward=t
    
figures(i) = figure('units','normalized',...
              'outerposition',[0 0 1 1]); hold on;
figures(i).WindowState = 'minimized';
figure_properties(figures(i));
legendEntries = {};
plots = [];

[~,forwardTimes,forwardModel]=...
    ccRateModel(paramFmin,tforward,T,x,y,modelTimes);
forwardTimes=forwardTimes-tforward;
[~,~,forwardMarket]=ccRateMarket(tforward,T,marketZeroRates,marketTimes);
meanModelForwards=mean(forwardModel,2);

plot_market_forward();
plot_model_forward();
plot_error_bars();
legend(plots,legendEntries,...
      'Location','southoutside',...
      'NumColumns',length(legendEntries),...
      'Interpreter','latex'); 
xlabel('Time to maturity in years')
ylabel(sprintf('%d-forward zero coupn prices',tforward))
i=i+1;
end

    function plot_error_bars()
        err=abs(forwardMarket-meanModelForwards);
        plots(end+1)=errorbar(forwardTimes,...
                     forwardMarket,...
                     err,...
                     'LineStyle',linspecs.errorbar.linestyle{1},...
                     'Color',linspecs.errorbar.color{1});
        legendEntries{end+1}='Error bar';
        txt=text(forwardTimes,...
                 meanModelForwards,...
                 num2str(err,'%1.3f'),...
                 'VerticalAlignment','bottom',...
                 'horizontalalign','left',...
                 'fontsize',12, ...
                 'Rotation',-90);
    end
    function plot_model_forward()
        plots(end+1)=plot(forwardTimes,...
                          meanModelForwards,...
                         'LineStyle',linspecs.model.linestyle{1},...
                         'Marker',linspecs.model.marker{1},...
                         'Color',linspecs.model.color{1});
        legendEntries{end+1}=sprintf('Mean of model forward curve $T\\mapsto P(%d,T)$',...
                                     tforward);
        s=std(forwardModel,0,2);
        CI99 = 3.291*s./sqrt(size(forwardModel,2)); % 99.9%
        plots(end+1)=plot(forwardTimes,...
                 meanModelForwards-CI99,...
                 'LineStyle',linspecs.model.linestyle{2},...
                 'Color',linspecs.model.color{2});
        plt=plot(forwardTimes,...
                 meanModelForwards+CI99,...
                 'LineStyle',linspecs.model.linestyle{2},...
                 'Color',linspecs.model.color{2});
        legendEntries{end+1}='$99.9\,\%$ confidence interval';
    end
    function plot_market_forward()
        plots(end+1)=plot(forwardTimes,...
                          forwardMarket,...
                         'LineStyle',linspecs.market.linestyle{1},...
                         'Marker',linspecs.market.marker{1},...
                         'Color',linspecs.market.color{1});
        legendEntries{end+1}=sprintf('Market forward curve $T\\mapsto P^M(%d,T)$',...
                                     tforward);
    end
end

% %% Version for continous compounded interest rate
% function figures=plot_forward(t,T,...
%                               modelTimes,marketTimes,...
%                               paramFmin,x,y,marketZeroRates)
% %PLOT_FORWARD plots the forward curves for t years. It one year steps
% % from t to T.
% %   Input:
% %       t (px1 array): contains the starting points, t>0
% %       T (double): contains the end of the curve, e.g. 30 years
% %       modelTimes (Nx1 array): contains the timeline of the model
% %       marketTimes (nx1 array): contains the times of the market rates
% %       params (8x1 array): params= $[\phi_1^x,...,\phi_1^y,...\phi_3^y,x_t0,y_t0]$
% %       x (NxM array): contains the simulated paths of the CIR process x
% %       y (NxM array): contains the simulated paths of the CIR process y
% %       marketZeroRates (nx1 array): contains the market zero rates
% %   Output:
% %       figures (figure cell array): contains the figure handles
% 
% % if nargin>4
% %     for i=1:2:length(varargin)
% %         switch varargin{i}
% %     end
% % end
% 
% linspecs.model.linestyle = {'-','--'};
% linspecs.model.marker = {'x',''};
% linspecs.model.color = {'r','m'};
% linspecs.market.linestyle = {'-'};
% linspecs.market.marker = {'o'};
% linspecs.market.color = {'k'};
% linspecs.errorbar.linestyle = {'-'};
% linspecs.errorbar.marker = {'o'};
% linspecs.errorbar.color = {'k'};
% 
% i=1;
% for tforward=t
%     
% figures(i) = figure('units','normalized',...
%               'outerposition',[0 0 1 1]); hold on;
% figures(i).WindowState = 'minimized';
% figure_properties(figures(i));
% legendEntries = {};
% plots = [];
% 
% [forwardModel,forwardTimes]=...
%     ccRateModel(paramFmin,tforward,T,x,y,modelTimes);
% forwardTimes=forwardTimes-tforward;
% forwardMarket=ccRateMarket(tforward,T,marketZeroRates,marketTimes);
% meanModelForwards=mean(forwardModel,2);
% 
% plot_market_forward();
% plot_model_forward();
% plot_error_bars();
% legend(plots,legendEntries,...
%       'Location','southoutside',...
%       'NumColumns',length(legendEntries),...
%       'Interpreter','latex'); 
% xlabel('Time to maturity in years')
% ylabel('Yield in decimals')
% i=i+1;
% end
% 
%     function plot_error_bars()
%         err=abs(forwardMarket-meanModelForwards);
%         plots(end+1)=errorbar(forwardTimes,...
%                      forwardMarket,...
%                      err,...
%                      'LineStyle',linspecs.errorbar.linestyle{1},...
%                      'Color',linspecs.errorbar.color{1});
%         legendEntries{end+1}='Error bar';
%         txt=text(forwardTimes,...
%                  meanModelForwards,...
%                  num2str(err,'%1.3f'),...
%                  'VerticalAlignment','bottom',...
%                  'horizontalalign','left',...
%                  'fontsize',12, ...
%                  'Rotation',-90);
%     end
%     function plot_model_forward()
%         plots(end+1)=plot(forwardTimes,...
%                           meanModelForwards,...
%                          'LineStyle',linspecs.model.linestyle{1},...
%                          'Marker',linspecs.model.marker{1},...
%                          'Color',linspecs.model.color{1});
%         legendEntries{end+1}=sprintf('Mean of model forward curve $T\\mapsto R_{%d,T}$',...
%                                      tforward);
%         s=std(forwardModel,0,2);
%         CI99 = 3.291*s./sqrt(size(forwardModel,2)); % 99.9%
%         plots(end+1)=plot(forwardTimes,...
%                  meanModelForwards-CI99,...
%                  'LineStyle',linspecs.model.linestyle{2},...
%                  'Color',linspecs.model.color{2});
%         plt=plot(forwardTimes,...
%                  meanModelForwards+CI99,...
%                  'LineStyle',linspecs.model.linestyle{2},...
%                  'Color',linspecs.model.color{2});
%         legendEntries{end+1}='$99.9\%$ confidence interval';
%     end
%     function plot_market_forward()
%         plots(end+1)=plot(forwardTimes,...
%                           forwardMarket,...
%                          'LineStyle',linspecs.market.linestyle{1},...
%                          'Marker',linspecs.market.marker{1},...
%                          'Color',linspecs.market.color{1});
%         legendEntries{end+1}=sprintf('Market forward curve $T\\mapsto R_{%d,T}$',...
%                                      tforward);
%     end
% end
%% Auxiliary functions
function figure_properties(fig)
    fontsize=22;
    linewidth=2;
    set(gca,'FontSize',fontsize)
    set(fig,'defaultlinelinewidth',linewidth)
    set(fig,'defaultaxeslinewidth',linewidth)
    set(fig,'defaultpatchlinewidth',linewidth)
    set(fig,'defaultAxesFontSize',fontsize)
end