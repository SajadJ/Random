function [Ez, dt, time, nx, nt, xT, yT, xR, yR] = gprmax_read(FileName,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this code reads ASCII gprMax2D input files. the FileName should be the output
% file of gprMax2D and the options are 'save' and 'plot'. 
%
% If you want to just read data, run:
% [Ez, dt, time, nx, nt, xT, yT, xR, yR] = gprmax_read('test.sca');
%
% If you want to read data and plot it, run:
% [Ez, dt, time, nx, nt, xT, yT, xR, yR] = gprmax_read('test.sca','plot');
%
% If you want to read data and save it as a *.mat file, run:
% [Ez, dt, time, nx, nt, xT, yT, xR, yR] = gprmax_read('test.sca','save');
%
% If you want to read data, plot and save it as a *.mat file, run either:
% [Ez, dt, time, nx, nt, xT, yT, xR, yR] = gprmax_read('test.sca','plot','save');
% [Ez, dt, time, nx, nt, xT, yT, xR, yR] = gprmax_read('test.sca','save','plot');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% developed by Sajad Jazayeri, USF 27 Oct 2017 %%%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

lines = dataread('file', FileName, '%s', 'delimiter', '\n');

% find number of traces 
nx = 7;   % line number in *.sca file
nx = reshape(str2double(strsplit(sprintf(lines{nx},' '),' ')),[],4); nx = nx (4); 

% find number of elements of each trace
nt = 3;   % line number in *.sca file
nt = reshape(str2double(strsplit(sprintf(lines{nt},' '),' ')),[],2); nt = nt (2); 

% find dt and time 
dt = 6;   % line number in *.sca file
dt = reshape(str2double(strsplit(sprintf(lines{dt},' '),' ')),[],3); dt = dt (2); 
time = 0 : dt : ( nt - 1 ) * dt;

% find cell sizes in x and y direction and Tx and Rx steps
dx = 4;   % line number in *.sca file
dx = reshape(str2double(strsplit(sprintf(lines{dx},' '),' ')),[],3); dx = dx (2); 
dy = 5;   % line number in *.sca file
dy = reshape(str2double(strsplit(sprintf(lines{dy},' '),' ')),[],3); dy = dy (2);
txstep = 17;   % line number in *.sca file
txstep = reshape(str2double(strsplit(sprintf(lines{txstep},' '),' ')),[],5); txstep = txstep (2:3);
rxstep = 17;   % line number in *.sca file
rxstep = reshape(str2double(strsplit(sprintf(lines{rxstep},' '),' ')),[],5); rxstep = rxstep (2:3);

% find first location of transmitter 
Tini = 12;
Tini = reshape(str2double(strsplit(sprintf(lines{Tini},' '),' ')),[],7); 
xT = linspace((Tini (4) * dx),((nx - 1) * txstep (1) * dx + Tini (4) * dx),nx);
yT = linspace((Tini (5) * dy),((nx - 1) * txstep (2) * dy + Tini (5) * dy),nx);

% find first location of receiver 
Rini = 16;
Rini = reshape(str2double(strsplit(sprintf(lines{Rini},' '),' ')),[],5); 
xR = linspace((Rini (2) * dx),((nx - 1) * rxstep (1) * dx + Rini (2) * dx),nx);
yR = linspace((Rini (3) * dy),((nx - 1) * rxstep (2) * dy + Rini (3) * dy),nx);


% read the data 
noheaderData = lines(21 : length(lines));
% noheaderData = reshape(str2double(strsplit(sprintf(lines{noheaderData},' '),' ')),[],4);
temp = regexp(noheaderData, '\s+', 'split');
data = str2double(vertcat(temp{:})); data (:,5) = [];

% extract Ez 
Ez = reshape (data (:,2),nt,nx);
 
% optional plot and save 
if nargin == 2
    if char(varargin(1))=='plot' 
        imagesc ((xR+xT)/2, time, Ez)
        title('Synthetic GPR data');xlabel('X(m)');ylabel('Time (s)')
    elseif char(varargin(1))=='save' 
        save(strcat(FileName(1:end-4),'.mat'),'Ez', 'dt', 'time', 'nx', ...
            'nt', 'xT', 'yT', 'xR', 'yR')
    end
end
if nargin > 2
    imagesc ((xR+xT)/2, time, Ez)
    title('Synthetic GPR data');xlabel('X(m)');ylabel('Time (s)')
    save(strcat(FileName(1:end-4),'.mat'),'Ez', 'dt', 'time', 'nx', ...
            'nt', 'xT', 'yT', 'xR', 'yR')
end