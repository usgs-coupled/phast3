function vis
close all

% PaperComparePlots('SAVE\test',[100 100  1100 1000],...
%     {{'SAVE\easy\results','MoMaS_2D_disp', 16, 10, 'cmap',[0 4],'streched color scale'},...
%     {'SAVE\easy\results','MoMaS_fine_2D_disp', 16, 10, 'cmap',[0 4]};...
%     {'SAVE\medium\results','MoMaS_2D_disp', 5, 10, 'jet',[0 .11]},...
%     {'SAVE\medium\results','MoMaS_fine_2D_disp', 5, 10, 'jet',[0 .11]};...
%     {'SAVE\hard\results','MoMaS_2D_disp', 27, 1000, 'jet',[0 10.5]},...
%     {'SAVE\hard\results','MoMaS_fine_2D_disp', 27, 1000, 'jet',[0 10.5]}})
% return
PaperComparePlots('SAVE\MoMaS_2D_dispersive', [100 100  1100 600],...
    {{'SAVE\easy\results','MoMaS_2D_disp', 16, 10, 'cmap',[0 4],'streched color scale'},...
    {'SAVE\easy\results','MoMaS_fine_2D_disp', 16, 10, 'cmap',[0 4]};...
    {'SAVE\medium\results','MoMaS_2D_disp', 5, 10, 'jet',[0 .11]},...
    {'SAVE\hard\results','MoMaS_2D_disp', 27, 1000, 'jet',[0 10.5]}})

PaperComparePlots('SAVE\MoMaS_2D_advective',[100 100  1100 600],...
    {{'SAVE\easy\results','MoMaS_2D_adv', 6, 1000, 'cmap',[0.13 0.25]},...
    {'SAVE\medium\results','MoMaS_2D_adv', 5, 1000, 'jet',[0 0.1]};...
    {'SAVE\hard\results','MoMaS_2D_adv', 27, 2000, 'jet',[0 26]},...
    {'SAVE\hard\results','MoMaS_fine_2D_adv', 27, 2000, 'jet',[0 26]}})

return

baseDirList = {
    'SAVE\easy\results',...
    'SAVE\medium\results',...
    'SAVE\hard\results',...
    };
baseNameList = {
    'MoMaS_2D_disp',...
    'MoMaS_2D_disp_ops_coarse',...
    'MoMaS_fine_2D_disp',...
    'MoMaS_2D_adv',...
    'MoMaS_fine_2D_adv',...
    };

plotTimes = [10, 1000, 2000, 5010, 5050, 5100];

for dir = baseDirList
    for name = baseNameList
        %         SurfacePlotsAnimation(dir{1}, name{1}, [[4 : 8, 1, 2]; 9 : 15; [16 : 18, 25 : 28]]');
        ObservationPointPlots(dir{1}, name{1}, ...
            {4 : 8, 9 : 15, 16 : 18, 27 : 28, 25 : 26})
        for time = plotTimes
            SurfacePlots(dir{1}, name{1}, time, ...
                [[4 : 8, 1, 2]; 9 : 15; [16 : 18, 25 : 28]]')
            %             RICHY2DPlots(dir{1}, name{1}, time, [9 : 15, 4;  5 : 7, 16 : 18, 27 : 28])
        end
    end
end
end

%%
function PaperComparePlots(printName, figurePosition, specification)
sub = WecSubplot('FigurePosition',figurePosition,...
    'RowNo', size(specification,1),...
    'ColNo', size(specification,2),...
    'TopBorder', 70,...
    'BottomBorder', 50,...
    'RightBorder', 80,...
    'LeftBorder', 50,...
    'VerticalSeparation', 100,...
    'HorizontalSeparation', 150);

% colormap
if length(specification{1}) > 6
    cm_temp = cmap;
    imap = 10:10:110;
    cm_temp = cm_temp(imap,:);
    x = [0 0.1 0.2 0.5 1 1.5 2 3 3.8 3.801 4];
    Nx = length(x);
    clim = [min(x) max(x)];
    dx = min(diff(x));
    y = clim(1):dx:clim(2);
    for k=1:Nx-1
        y(y>x(k) & y<=x(k+1)) = x(k+1);
    end
    cm = [...
        interp1(x(:),cm_temp(:,1),y(:)) ...
        interp1(x(:),cm_temp(:,2),y(:)) ...
        interp1(x(:),cm_temp(:,3),y(:)) ...
        ];
else
    cm = cmap;
end

% combining two colormaps
colormap([cm;jet(64)]);
CmLength   = length(colormap);   % Colormap length
BeginSlot1 = 1;                  % Beginning slot
EndSlot1   = length(cm);    % Ending slot
BeginSlot2 = EndSlot1 + 1;
EndSlot2   = CmLength;

count = 0;
for r = 1 : size(specification,1)
    for c = 1 : size(specification,2)
        baseDir   = specification{r,c}{1};
        baseName  = specification{r,c}{2};
        column    = specification{r,c}{3};
        time      = specification{r,c}{4};
        color     = specification{r,c}{5};
        caxisLim  = specification{r,c}{6};
        
        % surface plot
        axes(sub.AxesHandle{r,c})
        importFile = fullfile(baseDir, [baseName, '_', int2str(time),'.000000.txt']);
        data = importdata(importFile);
        headings = data.textdata;
        data = data.data;
        x = data(:,1);
        y = data(:,2);
        [X,Y] = meshgrid(min(x):.005:max(x), min(y):.005:max(y));
        in = data(:, column);
        F =  scatteredInterpolant(x,y,in,'natural','linear');
        out = F(X,Y);
        out(out < caxisLim(1)) = caxisLim(1);
        out(out > caxisLim(end)) = caxisLim(end);
        surface(X, Y, out, 'EdgeColor','non');
        
        % color limits
        if  (~isempty(caxisLim))
            caxis([caxisLim(1) caxisLim(end)]);
        end
        
        % colormap streching
        clim = get(gca,'CLim');
        if strcmp(color, 'cmap')
            set(gca,'CLim',newclim(BeginSlot1,EndSlot1,clim(1),...
                clim(2),CmLength))
        elseif strcmp(color, 'jet')
            set(gca,'CLim',newclim(BeginSlot2,EndSlot2,clim(1),...
                clim(2),CmLength))
        end
        
        % colorbar
        cbar = colorbar;
        axpos = get(gca, 'position');
        cpos = get(cbar, 'position');
        cpos(1) = axpos(1) + axpos(3) + 0.1;
        cpos(3) = 0.01;
        set(cbar, 'position', cpos)
        ylim(cbar,clim)
        
        % captions and settings
        axis(gca, 'equal')
        axis(gca, 'tight')
        title(gca, headings{column})
        xlabel('x-distance');
        ylabel('y-distance');
        box(gca, 'on')
        text(-0.2, 1.2, [char(97 + count),')'],'FontWeight','bold','FontSize',14)
        count = count + 1;
    end
end
% printing
set(gca, 'Layer', 'top')
set(gcf,'renderer','zbuffer');
set(gcf, 'paperpositionmode','auto')
print('-dmeta',[printName, '.emf']);

    function cm = cmap
        red = interp1([1, 110],[0, 1],1:110);
        green = [interp1([1, 55],[0, .8],1:55), interp1([55, 110],[.8, .15],55:110)];
        green(55) = [];
        blue = [interp1([1, 55],[.5, 1],1:55), interp1([55, 110],[1, 0],55:110)];
        blue(55) = [];
        cm = [red;green;blue]';
    end

    function CLim = newclim(BeginSlot,EndSlot,CDmin,CDmax,CmLength)
        % 				Convert slot number and range
        % 				to percent of colormap
        PBeginSlot    = (BeginSlot - 1) / (CmLength - 1);
        PEndSlot      = (EndSlot - 1) / (CmLength - 1);
        PCmRange      = PEndSlot - PBeginSlot;
        % 				Determine range and min and max
        % 				of new CLim values
        DataRange     = CDmax - CDmin;
        ClimRange     = DataRange / PCmRange;
        NewCmin       = CDmin - (PBeginSlot * ClimRange);
        NewCmax       = CDmax + (1 - PEndSlot) * ClimRange;
        CLim          = [NewCmin,NewCmax];
    end
end


%%
function SurfacePlotsAnimation(baseDir, baseName, plotCols)
close all;

% anim objects
% gifFileName = fullfile(baseDir, [baseName, '.gif']);
writerObj = VideoWriter(fullfile(baseDir, baseName),'MPEG-4');
open(writerObj);

% get all file names
files = dir(fullfile(baseDir,[baseName,'*.000000.txt']));
times = sort(str2double(strrep(strrep({files.name}, [baseName,'_'], ''), '.000000.txt', '')));
% times = [1 : 2 : 10]%100, 105 : 5 : 200, 220 : 20 : 5000, 5001 : 5050, 5055 : 5 : 6000];
files = cell(1, length(times));
for t = 1 : length(times)
    files{t} = fullfile(baseDir,[baseName, '_', int2str(times(t)), '.000000.txt']);
end

% find data range
[dataRange{1 : size(plotCols,1), 1 : size(plotCols,2)}] = deal([0,0]);
for t = 1 : length(files)
    imp = importdata(files{t});
    for r = 1 : size(plotCols,1)
        for c = 1 : size(plotCols,2)
            dataRange{r,c}(1) = min(dataRange{r,c}(1), min(imp.data(:, plotCols(r,c))));
            dataRange{r,c}(2) = max(dataRange{r,c}(2), max(imp.data(:, plotCols(r,c))));
        end
    end
end

% create subplots and figure
scrsz = get(0,'ScreenSize');
scrsz(4) = min(scrsz(4), 1088);
scrsz(3) = min(scrsz(3), 1920);
sub = WecSubplot('FigurePosition',[10 50  (scrsz(4)-140)*.825 (scrsz(4)-140)],...
    'RowNo', size(plotCols,1),...
    'ColNo', size(plotCols,2),...
    'TopBorder', 50,...
    'BottomBorder', 30,...
    'RightBorder', -5,...
    'LeftBorder', 35,...
    'VerticalSeparation', 50,...
    'HorizontalSeparation', 15);
set(gcf,'renderer','zbuffer','color','white');

% get mesh properties from last file
x = imp.data(:,1);
y = imp.data(:,2);
[X,Y] = meshgrid(min(x):.01:max(x), min(y):.01:max(y));

% set color bar and color range
for r = 1 : size(plotCols,1)
    for c = 1 : size(plotCols,2)
        axes(sub.AxesHandle{r,c})
        caxis(gca, dataRange{r,c});
        title(gca, imp.textdata{plotCols(r,c)})
        colo = colorbar;
        pos = get(gca, 'position');
        posC = get(colo, 'position');
        posC(1) = pos(1) + pos(3) + 0.02;
        posC(3) = 0.01;
        set(colo, 'position', posC)
        set(gca,'position',pos)
        box(gca, 'on')
        set(gca, 'Layer', 'top')
        axis(gca,[min(x) max(x) min(y) max(y)])
    end
end

% main SurfacePlotsAnimation loop
for t = 1 : length(times)
    imp = importdata(files{t});
    for r = 1 : size(plotCols,1)
        for c = 1 : size(plotCols,2)
            cla(sub.AxesHandle{r,c})
            in = imp.data(:, plotCols(r,c));
            F =  scatteredInterpolant(x,y,in,'linear','linear');
            out = F(X,Y);
            surface(X, Y, out,...
                'EdgeColor','none',...
                'Parent',sub.AxesHandle{r,c});
            %             tri = delaunay(x,y);
            %             trisurf(tri, x, y, in,...
            %                 'EdgeColor','none',...
            %                 'Parent',sub.AxesHandle{r,c});
        end
    end
    % set time indicator
    text(0.9,1.35,['Time: ',num2str(times(t))],...
        'units','normalized',...
        'FontWeight','bold',...
        'Parent', sub.AxesHandle{1,end});
    frame = getframe(gcf);
    writeVideo(writerObj,frame);
    %     im = frame2im(frame);
    %     [A,map] = rgb2ind(im,256);
    %     if t == 1;
    %         imwrite(A,map,gifFileName,'gif','LoopCount',Inf,'DelayTime',1);
    %     else
    %         imwrite(A,map,gifFileName,'gif','WriteMode','append','DelayTime',1);
    %     end
end
close(writerObj);
end

%%
function SurfacePlots(baseDir, baseName, time, plotCols)
close all;
scrsz = get(0,'ScreenSize');
sub = WecSubplot('FigurePosition',[10 50  (scrsz(4)-140)*.825 (scrsz(4)-140)],...
    'RowNo', size(plotCols,1),...
    'ColNo', size(plotCols,2),...
    'TopBorder', 50,...
    'BottomBorder', 30,...
    'RightBorder', -5,...
    'LeftBorder', 35,...
    'VerticalSeparation', 50,...
    'HorizontalSeparation', 15);
importFile = fullfile(baseDir, [baseName, '_', int2str(time),'.000000.txt']);
[~, fileName, ~] = fileparts(importFile);
set(sub.FigureHandle,'name',fileName);
data = importdata(importFile);
headings = data.textdata;
data = data.data;
x = data(:,1);
y = data(:,2);
[X,Y] = meshgrid(min(x):.005:max(x), min(y):.005:max(y));

for r = 1 : sub.RowNo
    for c = 1 : sub.ColNo
        axes(sub.AxesHandle{r,c})
        in = data(:, plotCols(r,c));
        F =  scatteredInterpolant(x,y,in,'natural','linear');
        out = F(X,Y);
        surface(X, Y, out, 'EdgeColor','none')
        title(gca, headings{plotCols(r,c)})
        colo = colorbar;
        pos = get(gca, 'position');
        posC = get(colo, 'position');
        posC(1) = pos(1) + pos(3) + 0.02;
        posC(3) = 0.01;
        set(colo, 'position', posC)
        set(gca,'position',pos)
        axis(gca, 'tight')
        box(gca, 'on')
        set(gca, 'Layer', 'top')
    end
end
set(gcf,'renderer','zbuffer');
set(gcf, 'paperpositionmode','auto')
[path, exportName, ~]  = fileparts(importFile);
print('-dpng',fullfile(path, [exportName, '.png']));
end

%%
function ObservationPointPlots(baseDir, baseName, plotCols)
obsPointNo = 2;
scrsz = get(0,'ScreenSize');

sub = WecSubplot('FigurePosition',[10    50   scrsz(3)-10   800],...
    'RowNo', obsPointNo,...
    'ColNo', length(plotCols),...
    'TopBorder', 40,...
    'BottomBorder', 80,...
    'RightBorder', 20,...
    'LeftBorder', 80,...
    'VerticalSeparation', 80,...
    'HorizontalSeparation', 80);

for r = 1 : obsPointNo
    importFile = fullfile(baseDir, [baseName, '_obsPoint', int2str(obsPointNo - r), '.txt']);
    data = importdata(importFile,'\t',1);
    headings = data.textdata;
    data = data.data;
    for c = 1 : length(plotCols)
        plot(sub.AxesHandle{r,c},data(:,1), data(:, plotCols{c}))
        legend(sub.AxesHandle{r,c}, headings{1, plotCols{c}},'location','northwest')
    end
end

% colored grid helper axes
for r = 1 : size(sub.AxesHandle,1)
    for c = 1 : size(sub.AxesHandle,2)
        grid(sub.AxesHandle{r,c},'on')
        subCopy{r,c} = sub.AxesHandle{r,c};
        box(sub.AxesHandle{r,c},'on')
        set(sub.AxesHandle{r,c},'Xcolor',[0.7 0.7 0.7]);
        set(sub.AxesHandle{r,c},'Ycolor',[0.7 0.7 0.7]);
        subCopy{r,c} = axes('color','none',...
            'position',get(sub.AxesHandle{r,c} ,'position'),...
            'xlim',get(sub.AxesHandle{r,c} ,'xlim'),...
            'ylim',get(sub.AxesHandle{r,c} ,'ylim'),...
            'box','on');
    end
end

title(subCopy{1,1}, 'Components')
title(subCopy{1,2}, 'Species')
title(subCopy{1,3}, 'Surfaces')
title(subCopy{1,4}, 'Equilibrium Phases')
title(subCopy{1,5}, 'Kinetics Phases')

xlabel(subCopy{2,1}, 'Time (d)')
xlabel(subCopy{2,2}, 'Time (d)')
xlabel(subCopy{2,3}, 'Time (d)')
xlabel(subCopy{2,4}, 'Time (d)')
xlabel(subCopy{2,5}, 'Time (d)')

ylabel(subCopy{1,1}, 'Fast velocity zone')
ylabel(subCopy{2,1}, 'Output zone')

set(gcf, 'paperpositionmode','auto')
set(gcf,'renderer','painters');
print('-dmeta',fullfile(baseDir, [baseName, '.emf']));
end

%%
function RICHY2DPlots(baseDir, baseName, time, plotCols)
for n = 1:2
    scrsz = get(0,'ScreenSize');
    sub = WecSubplot('FigurePosition',[10 50  (scrsz(4)-140)*1 (scrsz(4)-140)],...
        'RowNo', 4,...
        'ColNo', 2,...
        'TopBorder', 40,...
        'BottomBorder', 40,...
        'RightBorder', 10,...
        'LeftBorder', 60,...
        'VerticalSeparation', 80,...
        'HorizontalSeparation', 40);
    set(sub.FigureHandle,'name',['time = ', int2str(time), ' part ', int2str(n)]);
    importFile = fullfile(baseDir, [baseName, '_', int2str(time),'.000000.txt']);
    data = importdata(importFile);
    headings = data.textdata;
    data = data.data;
    x = data(:,1);
    y = data(:,2);
    [X,Y] = meshgrid(min(x):.01:max(x), min(y):.005:max(y));
    for r = 1 : sub.RowNo
        for c = 1 : sub.ColNo
            axes(sub.AxesHandle{r,c})
            ind = sub2ind([sub.ColNo, sub.RowNo], c, r);
            in = data(:, plotCols(n, ind));
            F =  scatteredInterpolant(x,y,in,'linear','linear');
            out = F(X,Y);
            surface(X, Y, out, 'EdgeColor','none')
            title(gca, headings{plotCols(n, ind)})
            %                 set(gca, 'clim', climits{t, n}{r, c});
            colo = colorbar;
            pos = get(gca, 'position');
            posC = get(colo, 'position');
            posC(1) = pos(1) + pos(3) + 0.02;
            posC(3) = 0.01;
            set(colo, 'position', posC)
            set(gca,'position',pos)
            axis(gca, 'tight')
            %             axis(gca, 'equal')
            box(gca, 'on')
            set(gca, 'Layer', 'top')
        end
    end
    set(gcf,'renderer','zbuffer');
    set(gcf, 'paperpositionmode','auto')
    [path, exportName, ~]  = fileparts(importFile);
    print('-dpng',fullfile(path, ['RICHY2DPlots_', exportName, '_', int2str(n), '.png']));
end
end

%%
function Profiles1D(baseDir, baseName, time, plotCols)
% close all;
scrsz = get(0,'ScreenSize');
sub = WecSubplot('FigurePosition',[10 50  (scrsz(4)-140)*.825 (scrsz(4)-140)],...
    'RowNo', size(plotCols,1),...
    'ColNo', size(plotCols,2),...
    'TopBorder', 50,...
    'BottomBorder', 30,...
    'RightBorder', 1,...
    'LeftBorder', 35,...
    'VerticalSeparation', 50,...
    'HorizontalSeparation', 50);
importFile = fullfile(baseDir, [baseName, '_', int2str(time),'.000000.txt']);
[~, fileName, ~] = fileparts(importFile);
set(sub.FigureHandle,'name',fileName);
data = importdata(importFile);
headings = data.textdata;
data = data.data;
x = data(:,1);
y = data(:,2);
for r = 1 : sub.RowNo
    for c = 1 : sub.ColNo
        axes(sub.AxesHandle{r,c})
        in = data(:, plotCols(r,c));
        plot(x,in)
        title(gca, headings{plotCols(r,c)})
        box(gca, 'on')
    end
end
set(gcf, 'paperpositionmode','auto')
[path, exportName, ~]  = fileparts(importFile);
print('-dmeta',fullfile(path, [exportName, '.emf']));
end