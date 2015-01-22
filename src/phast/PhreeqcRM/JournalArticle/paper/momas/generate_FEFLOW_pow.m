close all
clear all

% generate time steps
steps = 0:5:6000;
steps = [steps, 0 : 1 : 100];
steps = [steps, 5000 : 1 : 5100];
steps = unique(steps)';

% generate time series with values
timeSeries = [steps, zeros(size(steps))];
timeSeries(timeSeries(:,1) == 5000,2) = -1;

% print time series to file
fid = fopen('ts.pow','w+');
fprintf(fid, '# 1\n');
fprintf(fid, '! p4f\n');
fprintf(fid, '! [type=Constant;option=linear;timeunit=d;unitclass=CARDINAL;userunit=]\n');
for n = 1 : size(timeSeries,1)
    fprintf(fid, ' %f %f\n', timeSeries(n,:));
end
fprintf(fid, 'END\n');
fprintf(fid, 'END\n');
fclose(fid);