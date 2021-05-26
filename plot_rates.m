function figures=plot_rates(modelTimes,x,y,r,varargin)
%PLOT_RATES plots the trajectories of the CIR- model r=x-y. 
%   Input:
%       modelTimes (Nx1 array): contains the timeline of the model
%       x (NxM arra): first CIR process x
%       y (NxM array): second CIR process y
%       r (NxM array): r=x-y
%   Output:
%       figures (figure cell array): contains the figure handles

% if nargin>4
%     for i=1:2:length(varargin)
%         switch varargin{i}
%     end
% end

linspecs.r.linestyle = {'-','-','--'};
linspecs.r.marker = {'','',''};
linspecs.r.color = {[211,211,211]./255,'b','m'};
linspecs.x.linestyle = {'--'};
linspecs.x.marker = {'o'};
linspecs.x.color = {'g'};
linspecs.y.linestyle = {'--'};
linspecs.y.marker = {'o'};
linspecs.y.color = {'r'};
linspecs.percentile.linestyle={':'};
linspecs.percentile.market = {''};
linspecs.percentile.color = {[1 1 0]};

% percentiles
p=[1, 5, 25, 50, 75, 95, 99];

% find a negative trajectory
indNegR=r<-0.1;
temp=sum(indNegR,1);
% mean(squeeze(temp));
[sortedTemp,indTemp] = sort(temp);
I=find(sortedTemp<=mean(sortedTemp),1,'last');
I=indTemp(I);
% [~,I]=min(temp);
% [~,I]=max(temp);
% figure 1
figures(1) = figure('units','normalized',...
              'outerposition',[0 0 1 1]); hold on;
figures(1).WindowState = 'minimized';
figure_properties(figures(1));
legendEntries = {};
plots = [];

ind=1:1:length(modelTimes);

% plot trajectories
plot_R_cloud(ind);
% plot negative trajectory, s.th. r=x-y
plot_Zero_Axis(ind);
plot_R_trajectory(ind,I);
plot_X_trajectory(ind,I);
plot_Y_trajectory(ind,I);
plot_percentiles(ind,p)
legend(plots,legendEntries,...
      'Location','southoutside',...
      'NumColumns',4,...
      'Interpreter','latex'); 
xlabel('Time in years')
ylabel('Spot interest rate')

% figure 2
figures(2) = figure('units','normalized',...
              'outerposition',[0 0 1 1]); hold on;
figures(2).WindowState = 'minimized';
figure_properties(figures(2));
legendEntries = {};
plots = [];

modelOneYear=find(modelTimes<=1,1,'last');
ind=1:1:modelOneYear;

% plot trajectories
plot_R_cloud(ind);
% plot negative trajectory, s.th. r=x-y
plot_Zero_Axis(ind);
plot_R_trajectory(ind,I);
plot_X_trajectory(ind,I);
plot_Y_trajectory(ind,I);
plot_percentiles(ind,p)
legend(plots,legendEntries,...
      'Location','southoutside',...
      'NumColumns',4,...
      'Interpreter','latex'); 
xlabel('Time in years')
ylabel('Spot interest rate')

    function plot_R_cloud(ind)
        tempR=r(ind,:);
        tempR(end,:)=NaN;
        plt=patch(reshape(modelTimes(ind),[],1).*ones(1,size(r,2)),...
                 tempR,...
                 .1*ones(size(tempR)),...
                 'EdgeColor',[108,110,107]./255,'EdgeAlpha',.02,...
                 'LineWidth',.1);
%                  'LineStyle',linspecs.r.linestyle{1},...
%                  'Color',linspecs.r.color{1});
        plots(end+1)=plt(1);
        legendEntries{end+1}='All trajectories of r';
    end
    function plot_R_trajectory(ind,trajectory)
        plots(end+1)=plot(modelTimes(ind),...
                 r(ind,trajectory),...
                 'LineStyle',linspecs.r.linestyle{2},...
                 'Color',linspecs.r.color{2});
        legendEntries{end+1}='One trajectory of r';
    end
    function plot_X_trajectory(ind,trajectory)
        plots(end+1)=plot(modelTimes(ind),...
                 x(ind,trajectory),...
                 'LineStyle',linspecs.x.linestyle{1},...
                 'Color',linspecs.x.color{1});
        legendEntries{end+1}='One trajectory of x';
    end
    function plot_Y_trajectory(ind,trajectory)
        plots(end+1)=plot(modelTimes(ind),...
                 -y(ind,trajectory),...
                 'LineStyle',linspecs.y.linestyle{1},...
                 'Color',linspecs.y.color{1});
        legendEntries{end+1}='One trajectory of -y';
    end
    function plot_Zero_Axis(ind)
        plot(modelTimes(ind),...
                 zeros(length(ind),1),...
                 'LineStyle','-',...
                 'Color','k');
    end
    function plot_percentiles(ind,p)
        p=reshape(p,[],1);
        if length(linspecs.percentile.color)<length(p)
            clr=linspecs.percentile.color{1}.*linspace(1/length(p),1,length(p)+1)';
            linspecs.percentile.color=num2cell(clr(2:end,:),2);
        end
        P=prctile(r(ind,:),p,2);
        for iP = 1:1:length(p)
            plots(end+1)=plot(modelTimes(ind),P(:,iP),...
                'LineStyle',linspecs.percentile.linestyle{1},...
                'Color',linspecs.percentile.color{iP});
            legendEntries{end+1}=sprintf('$%d\\,\\%%$ percentile of $r(t)$',p(iP));
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