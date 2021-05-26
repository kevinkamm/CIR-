function figures=plot_Mean_Variance(modelTimes,marketTimes,mu,var,r,varargin)
%PLOT_MEAN_VARIANCE plots the mean and variance of the CIR- model r=x-y. 
%   Input:
%       modelTimes (Nx1 array): contains the timeline of the model
%       mu (NxM arra): mean of r for all times t in modeltimes
%       var (NxM array): variance of r for all times t in modeltimes
%       r (NxM array): contains the short rate of the CIR- model
%   Output:
%       figures (figure cell array): contains the figure handles

% if nargin>4
%     for i=1:2:length(varargin)
%         switch varargin{i}
%     end
% end

linspecs.mu.linestyle = {'-','-','--'};
linspecs.mu.marker = {'','',''};
linspecs.mu.color = {[211,211,211]./255,'b','m'};
linspecs.var.linestyle = {'--'};
linspecs.var.marker = {'o'};
linspecs.var.color = {'g'};
linspecs.market.marker = {'|'};
linspecs.market.color = {'k'};

% figure 1
figures(1) = figure('units','normalized',...
              'outerposition',[0 0 1 1]); hold on;
figures(1).WindowState = 'minimized';
figure_properties(figures(1));
legendEntries = {};
plots = [];

ind=1:1:length(modelTimes);

% plot mean and variance
plot_Mean(ind);
plot_Var(ind)
legend(plots,legendEntries,...
       'Location','southoutside',...
       'NumColumns',length(legendEntries),...
       'Interpreter','latex'); 
xlabel('Time in years')
ylabel('Values of Mean and Variance')

% figure 2
figures(2) = figure('units','normalized',...
              'outerposition',[0 0 1 1]); hold on;
figures(2).WindowState = 'minimized';
figure_properties(figures(2));
legendEntries = {};
plots = [];

modelOneYear=find(modelTimes<=1,1,'last');
ind=1:1:modelOneYear;

% plot mean and variance
plot_Mean(ind);
plot_Var(ind)
legend(plots,legendEntries,...
       'Location','southoutside',...
       'NumColumns',length(legendEntries),...
       'Interpreter','latex'); 
xlabel('Time in years')
ylabel('Values of Mean and Variance')

% figure 3
figures(3) = figure('units','normalized',...
              'outerposition',[0 0 1 1]); hold on;
figures(3).WindowState = 'minimized';
figure_properties(figures(3));
legendEntries = {};
plots = [];
plot_Histogram(length(modelTimes));
legend(plots,legendEntries,...
       'Location','southoutside',...
       'NumColumns',length(legendEntries),...
       'Interpreter','latex');

    function plot_Mean(ind)
        plt=plot(modelTimes(ind),...
                 mu(ind),...
                 'LineStyle',linspecs.mu.linestyle{1},...
                 'Color',linspecs.mu.color{1});
        plots(end+1)=plt(1);
        legendEntries{end+1}='Mean $\mu$ of r';
    end
    function plot_Var(ind)
        plots(end+1)=plot(modelTimes(ind),...
                 mu(ind)+sqrt(var(ind)),...
                 'LineStyle',linspecs.var.linestyle{1},...
                 'Color',linspecs.var.color{1});
         plot(modelTimes(ind),...
                 mu(ind)-sqrt(var(ind)),...
                 'LineStyle',linspecs.var.linestyle{1},...
                 'Color',linspecs.var.color{1});
        legendEntries{end+1}='$\mu\pm\sigma$';
    end
    function plot_Histogram(ti)
%         m=mean(r(ti,:));
%         s=std(r(ti,:));
        m=mu(ti);
        s=sqrt(var(ti));
        rmin=min(r(ti,:));
        rmax=max(r(ti,:));
        x=linspace(rmin,rmax,100);
        y=normpdf(x,m,s);
        plots(end+1)=plot(x,y,'b--');
        legendEntries{end+1}=sprintf('Pdf of normal distribution with $\\mu=%3.3g$ and $\\sigma=%3.3g$',...
            m,s);
        plots(end+1)=histogram(r(ti,:),'Normalization','pdf');
        legendEntries{end+1}=sprintf('Distribution of $r_t$ at $t=%3.2g$',modelTimes(ti));
    end
end
function figure_properties(fig)
    fontsize=22;
    linewidth=4;
    set(gca,'FontSize',fontsize)
    set(fig,'defaultlinelinewidth',linewidth)
    set(fig,'defaultaxeslinewidth',linewidth)
    set(fig,'defaultpatchlinewidth',linewidth)
    set(fig,'defaultAxesFontSize',fontsize)
end