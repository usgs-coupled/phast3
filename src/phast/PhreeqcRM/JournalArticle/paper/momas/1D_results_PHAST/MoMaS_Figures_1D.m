close all
clear all

%% Figure 1
data = xlsread('1D_MoMaS_Figures.xlsx',1);
figure('position',[200 200 500 450])
plot(data(:,1), data(:,2),'k--'); 
hold on
plot(data(:,1), data(:,3),'k-.');
xlim([0 0.06])
legend('\Deltat 0.01','\Deltat 0.05','location','southeast')

ax1 = gca;
col=.5*[1 1 1];
%# create a second transparent axis, same position/extents, same ticks and labels
ax2 = axes('Position',get(ax1,'Position'), ...
    'Color','none', 'Box','on', ...
    'XTickLabel',get(ax1,'XTickLabel'), 'YTickLabel',get(ax1,'YTickLabel'), ...
    'XTick',get(ax1,'XTick'), 'YTick',get(ax1,'YTick'), ...
    'XLim',get(ax1,'XLim'), 'YLim',get(ax1,'YLim'));
%# show grid-lines of first axis, give them desired color, but hide text labels
set(ax1, 'XColor',col, 'YColor',col, ...
    'XTickLabel',[], 'YTickLabel',[], ...
    'XGrid','on', 'YGrid','on');
%# link the two axes to share the same limits on pan/zoom
linkaxes([ax1 ax2],'xy')

xlabel('x-distance')
ylabel('Concentration')

ax3 = axes('position',[0.4420    0.4544    0.4155    0.4214]);
hold on
plot(data(:,1), data(:,2),'k-'); 
axis tight

%# create a second transparent axis, same position/extents, same ticks and labels
ax4 = axes('Position',get(ax3,'Position'), ...
    'Color','none', 'Box','on', ...
    'XTickLabel',get(ax3,'XTickLabel'), 'YTickLabel',get(ax3,'YTickLabel'), ...
    'XTick',get(ax3,'XTick'), 'YTick',get(ax3,'YTick'), ...
    'XLim',get(ax3,'XLim'), 'YLim',get(ax3,'YLim'));
%# show grid-lines of first axis, give them desired color, but hide text labels
set(ax3, 'XColor',col, 'YColor',col, ...
    'XTickLabel',[], 'YTickLabel',[], ...
    'XGrid','on', 'YGrid','on');
%# link the two axes to share the same limits on pan/zoom
linkaxes([ax3 ax4],'xy')
set(gcf, 'paperpositionmode','auto')
print('-dmeta','1D_c_vs_x.emf')
% print('-dpng','1D_c_vs_x.png')

%% Figure 2
clear all

data = xlsread('1D_MoMaS_Figures.xlsx',2);
sub = WecSubplot('FigurePosition',[100   100   400   700],...
    'RowNo', 2,...
    'ColNo', 1,...
    'TopBorder', 50,...
    'BottomBorder', 70,...
    'RightBorder', 50,...
    'LeftBorder', 90,...
    'VerticalSeparation', 90,...
    'HorizontalSeparation', 150);

ax1 = sub.AxesHandle{1,1};
hold on
set(ax1,'xScale','log','xtick',[16 32 64 128 256],'yScale','log','ytick',[100 400 1600 6400])
plot(data(1:5,2), data(1:5,11),'k--o','markerfacecolor',[.7 .7 .7])
plot(data(7:11,2), data(7:11,11),'k--v','markerfacecolor',[.7 .7 .7])
plot(data(13:17,2), data(13:17,11),'k--square','markerfacecolor',[.7 .7 .7])
xlim([16 256])

col=.5*[1 1 1];
%# create a second transparent axis, same position/extents, same ticks and labels
ax2 = axes('Position',get(ax1,'Position'), ...
    'Color','none', 'Box','on', ...
    'XTickLabel',get(ax1,'XTickLabel'), 'YTickLabel',get(ax1,'YTickLabel'), ...
    'XTick',get(ax1,'XTick'), 'YTick',get(ax1,'YTick'), ...
    'XLim',get(ax1,'XLim'), 'YLim',get(ax1,'YLim'),...
    'XScale',get(ax1,'XScale'), 'YScale',get(ax1,'YScale'));
%# show grid-lines of first axis, give them desired color, but hide text labels
set(ax1, 'XColor',col, 'YColor',col, ...
    'XTickLabel',[], 'YTickLabel',[], ...
    'XGrid','on', 'YGrid','on');
%# link the two axes to share the same limits on pan/zoom
linkaxes([ax1 ax2],'xy')
xlabel('Number of processes')
ylabel('CPU time units')
text(1.05, 1.05, 'a)','units','normalized','FontWeight','bold','FontSize',12)

ax3 = sub.AxesHandle{2,1};
axes(ax3);
hold on
set(ax3,'xScale','log','xtick',[16 32 64 128 256],'yScale','log','ytick',[1 2 4 8 16])
plot([16 256], [1 16],'k-')
plot(data(1:5,2), data(1:5,13),'k--o','markerfacecolor',[.7 .7 .7])
plot(data(7:11,2), data(7:11,13),'k--v','markerfacecolor',[.7 .7 .7])
plot(data(13:17,2), data(13:17,13),'k--square','markerfacecolor',[.7 .7 .7])
xlim([16 256])
ylim([1 16])
legend('Ideal','Easy','Medium','Hard','location','northwest')

col=.5*[1 1 1];
%# create a second transparent axis, same position/extents, same ticks and labels
ax4 = axes('Position',get(ax3,'Position'), ...
    'Color','none', 'Box','on', ...
    'XTickLabel',get(ax3,'XTickLabel'), 'YTickLabel',get(ax3,'YTickLabel'), ...
    'XTick',get(ax3,'XTick'), 'YTick',get(ax3,'YTick'), ...
    'XLim',get(ax3,'XLim'), 'YLim',get(ax1,'YLim'),...
    'XScale',get(ax3,'XScale'), 'YScale',get(ax3,'YScale'));
%# show grid-lines of first axis, give them desired color, but hide text labels
set(ax3, 'XColor',col, 'YColor',col, ...
    'XTickLabel',[], 'YTickLabel',[], ...
    'XGrid','on', 'YGrid','on');
%# link the two axes to share the same limits on pan/zoom
linkaxes([ax3 ax4],'xy')
xlabel('Number of processes')
ylabel('Relative speedup')
text(1.05, 1.05, 'b)','units','normalized','FontWeight','bold','FontSize',12)
set(gcf, 'paperpositionmode','auto')
print('-dmeta','1D_MPI.emf')
% print('-dpng','1D_MPI.png')

%% Figure 3

sub = WecSubplot('FigurePosition',[100   100   400   700],...
    'RowNo', 2,...
    'ColNo', 1,...
    'TopBorder', 50,...
    'BottomBorder', 70,...
    'RightBorder', 50,...
    'LeftBorder', 90,...
    'VerticalSeparation', 90,...
    'HorizontalSeparation', 150);

ax1 = sub.AxesHandle{1,1};
hold on
set(ax1,'xScale','log','xtick',[1 2 4 8 16],'yScale','log','ytick',[1 2 4 8 16 32])
plot(data(25:29,2), data(25:29,11),'k-o','markerfacecolor',[.7 .7 .7])
plot(data(33:37,2), data(33:37,11),'k-v','markerfacecolor',[.7 .7 .7])
xlim([1 16])
ylim([1 32])

col=.5*[1 1 1];
%# create a second transparent axis, same position/extents, same ticks and labels
ax2 = axes('Position',get(ax1,'Position'), ...
    'Color','none', 'Box','on', ...
    'XTickLabel',get(ax1,'XTickLabel'), 'YTickLabel',get(ax1,'YTickLabel'), ...
    'XTick',get(ax1,'XTick'), 'YTick',get(ax1,'YTick'), ...
    'XLim',get(ax1,'XLim'), 'YLim',get(ax1,'YLim'),...
    'XScale',get(ax1,'XScale'), 'YScale',get(ax1,'YScale'));
%# show grid-lines of first axis, give them desired color, but hide text labels
set(ax1, 'XColor',col, 'YColor',col, ...
    'XTickLabel',[], 'YTickLabel',[], ...
    'XGrid','on', 'YGrid','on');
%# link the two axes to share the same limits on pan/zoom
linkaxes([ax1 ax2],'xy')
xlabel('Number of processes')
ylabel('Computation time (h)')
text(1.05, 1.05, 'a)','units','normalized','FontWeight','bold','FontSize',12)

ax3 = sub.AxesHandle{2,1};
axes(ax3);
hold on
set(ax3,'xScale','log','xtick',[1 2 4 8 16],'yScale','log','ytick',[1 2 4 8 16 32])
plot([1 16], [1 16],'k-')
plot(data(25:29,2), data(25:29,13),'k-o','markerfacecolor',[.7 .7 .7])
plot(data(33:37,2), data(33:37,13),'k-v','markerfacecolor',[.7 .7 .7])
xlim([1 16])
ylim([1 16])
legend('Ideal','Multithreaded','Multiprocesses','location','northwest')

col=.5*[1 1 1];
%# create a second transparent axis, same position/extents, same ticks and labels
ax4 = axes('Position',get(ax3,'Position'), ...
    'Color','none', 'Box','on', ...
    'XTickLabel',get(ax3,'XTickLabel'), 'YTickLabel',get(ax3,'YTickLabel'), ...
    'XTick',get(ax3,'XTick'), 'YTick',get(ax3,'YTick'), ...
    'XLim',get(ax3,'XLim'), 'YLim',get(ax1,'YLim'),...
    'XScale',get(ax3,'XScale'), 'YScale',get(ax3,'YScale'));
%# show grid-lines of first axis, give them desired color, but hide text labels
set(ax3, 'XColor',col, 'YColor',col, ...
    'XTickLabel',[], 'YTickLabel',[], ...
    'XGrid','on', 'YGrid','on');
%# link the two axes to share the same limits on pan/zoom
linkaxes([ax3 ax4],'xy')
xlabel('Number of processes')
ylabel('Relative speedup')
text(1.05, 1.05, 'b)','units','normalized','FontWeight','bold','FontSize',12)
set(gcf, 'paperpositionmode','auto')
print('-dmeta','1D_MPI_vs_OpenMP.emf')
% print('-dpng','1D_MPI.png')