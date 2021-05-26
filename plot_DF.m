function figures=plot_DF(modelTimes,modelDF,marketTimes,marketDF,varargin)
%PLOT_DF plots the discount factors of given market and model. It uses
% linear interpolation for the marketDF and modelDF in the figures
%   Input:
%       modelTimes (Nx1 array): contains the timeline of the model
%       modelDF (NxM arra): contains the model discount factors 
%                           $T\mapsto D(0,T)$
%       marketTimes (nx1 array): contains the times of the market discount
%                               factors
%       marketDF (nx1 array): contains the model discount factors 
%                             D^M(0,T)=P^M(0,T)
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

linspecs.model.linestyle = {'-','-','--','--'};
linspecs.model.marker = {'','',''};
linspecs.model.color = {[211,211,211]./255,'r','m','m'};
linspecs.market.linestyle = {'-'};
linspecs.market.marker = {'o'};
linspecs.market.color = {'k'};
linspecs.errorbar.linestyle = {'-'};
linspecs.errorbar.marker = {'o'};
linspecs.errorbar.color = {'r'};
linspecs.percentile.linestyle={':'};
linspecs.percentile.market = {''};
linspecs.percentile.color = {[0 1 0]};

% percentiles
p=[10, 25, 50, 75, 90];

% mean abs errors
mu = mean(modelDF,2);
s = std(modelDF,0,2);

tind = zeros(size(marketTimes));
for i=1:1:size(marketTimes,1)
    tind(i) = find(modelTimes<=marketTimes(i),1,'last');
end
DF_mean_err = abs(mu(tind)-marketDF);

figures(1) = figure('units','normalized',...
              'outerposition',[0 0 1 1]); hold on;
figures(1).WindowState = 'minimized';
figure_properties(figures(1));
legendEntries = {};
plots = [];

indMarket=1:1:length(marketTimes);
indModel=1:1:length(modelTimes);

% plot_model_DF_trajectories();
plot_market_DF(indMarket);
plot_model_DF_mean(indModel);
plot_error_bars(indMarket);
% plot_percentiles(indModel,p);
legend(plots,legendEntries,...
      'Location','southoutside',...
      'NumColumns',3,...
      'Interpreter','latex'); 
xlabel('Time in years')
ylabel('Discount Factor')

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
plot_market_DF(indMarket);
plot_model_DF_mean(indModel);
plot_error_bars(indMarket);
% plot_percentiles(indModel,p);
legend(plots,legendEntries,...
      'Location','southoutside',...
      'NumColumns',3,...
      'Interpreter','latex'); 
xlabel('Time in years')
ylabel('Discount Factor')

    function plot_error_bars(ind)
        plots(end+1)=errorbar(marketTimes(ind),...
                     marketDF(ind),...
                     DF_mean_err(ind),...
                     'LineStyle',linspecs.market.linestyle{1},...
                     'Color',linspecs.market.color{1});
        legendEntries{end+1}='Error bar';
        temp=mu(tind);
        txt=text(marketTimes(ind),...
                 temp(ind),...
                 num2str(gather(DF_mean_err(ind)),'%1.3f'),...
                 'VerticalAlignment','bottom','horizontalalign','left','fontsize',9, ...
                 'Rotation',-90 ...
            );
    end
    function plot_market_DF(ind)
        plots(end+1)=plot(marketTimes(ind),...
                 marketDF(ind),...
                 'LineStyle',linspecs.market.linestyle{1},...
                 'Marker',linspecs.market.marker{1},...
                 'Color',linspecs.market.color{1});
        legendEntries{end+1}='Market DF $T \mapsto D^M(0,T)$';
    end
    function plot_model_DF_trajectories(ind)
        plots(end+1)=plot(modelTimes(ind),...
                 modelDF(ind),...
                 'LineStyle',linspecs.model.linestyle{1},...
                 'Color',linspecs.model.color{1});
        legendEntries{end+1}='Model trajectories';
    end
    function plot_model_DF_mean(ind)
        plots(end+1)=plot(modelTimes(ind),...
                 mu(ind),...
                 'LineStyle',linspecs.model.linestyle{2},...
                 'Color',linspecs.model.color{2});
        legendEntries{end+1}='Mean of model DF $\mu(0,T)= E[D(0,T)]$';
%         CI95 = 1.96*s(ind)/sqrt(size(modelDF,2));
%         plots(end+1)=plot(modelTimes(ind),...
%                  mu(ind)-CI95,...
%                  'LineStyle',linspecs.model.linestyle{3},...
%                  'Color',linspecs.model.color{3});
% %         legendEntries{end+1}='$\mu-\sigma$';
%         plt=plot(modelTimes(ind),...
%                  mu(ind)+CI95,...
%                  'LineStyle',linspecs.model.linestyle{3},...
%                  'Color',linspecs.model.color{3});
%         legendEntries{end+1}='$95\%$ confidence interval';
%         CI99 = 2.576*s(ind)/sqrt(size(modelDF,2)); % 99%
        CI99 = 3.291*s(ind)/sqrt(size(modelDF,2)); % 99.9%
        plots(end+1)=plot(modelTimes(ind),...
                 mu(ind)-CI99,...
                 'LineStyle',linspecs.model.linestyle{4},...
                 'Color',linspecs.model.color{4});
%         legendEntries{end+1}='$\mu-\sigma$';
        plt=plot(modelTimes(ind),...
                 mu(ind)+CI99,...
                 'LineStyle',linspecs.model.linestyle{4},...
                 'Color',linspecs.model.color{4});
        legendEntries{end+1}='$99.9\,\%$ confidence interval';
    end
    function plot_percentiles(ind,p)
        p=reshape(p,[],1);
        if length(linspecs.percentile.color)<length(p)
            clr=linspecs.percentile.color{1}.*linspace(1/length(p),1,length(p)+1)';
            linspecs.percentile.color=num2cell(clr(2:end),2);
        end
        P=prctile(modelDF(ind,:),p,2);
        for iP = 1:1:length(p)
            plots(end+1)=plot(modelTimes(ind),P(:,iP),...
                'LineStyle',linspecs.percentile.linestyle{1},...
                'Color',linspecs.percentile.color{iP});
            legendEntries{end+1}=sprintf('$%d\\,\\%%$ percentile',p(iP));
        end
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