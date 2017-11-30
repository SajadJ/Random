function [Ez, dt, time, nx, nt, xT, yT, xR, yR] = gpr_read(FileName,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this code reads ASCII gprMax2D/gprMax2D/reflexW input files. the FileName should be the output
% file of either gprmax2d/3d/reflexw and the options are 'save' and 'plot'. 
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
%%%%%%%%%%%%%%%%%%% Updated by Sajad Jazayeri, USF 22 Nov 2017 %%%%%%%%%%%%%%%%%%
%%% update: code now reads automatically 3D data and reflex output data as well%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

lines = dataread('file', FileName, '%s', 'delimiter', '\n');

% check to see if data if from gprmax2D gprmax3d or exported from reflex
line1 = char(reshape(strsplit(sprintf(lines{1},' '),' '),[],3));

if line1(1,1:10) == '#GprMax2D,' | line1(1,1:10) == '#gprMax2D,'  %gprMax2D file
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
    rxstep = 18;   % line number in *.sca file
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
            title('Synthetic 2D GPR data');xlabel('X(m)');ylabel('Time (s)')
        elseif char(varargin(1))=='save' 
            save(strcat(FileName(1:end-4),'.mat'),'Ez', 'dt', 'time', 'nx', ...
                'nt', 'xT', 'yT', 'xR', 'yR')
        end
    end
    if nargin > 2
        imagesc ((xR+xT)/2, time, Ez)
        title('Synthetic 2D GPR data');xlabel('X(m)');ylabel('Time (s)')
        save(strcat(FileName(1:end-4),'.mat'),'Ez', 'dt', 'time', 'nx', ...
                'nt', 'xT', 'yT', 'xR', 'yR')
    end

elseif line1(1,1:10) == '#gprMax3D,'  %gprMax3D file
    
    % find number of traces 
    nx = 8;   % line number in *.sca file
    nx = reshape(str2double(strsplit(sprintf(lines{nx},' '),' ')),[],4); nx = nx (4); 

    % find number of elements of each trace
    nt = 3;   % line number in *.sca file
    nt = reshape(str2double(strsplit(sprintf(lines{nt},' '),' ')),[],2); nt = nt (2); 

    % find dt and time 
    dt = 7;   % line number in *.sca file
    dt = reshape(str2double(strsplit(sprintf(lines{dt},' '),' ')),[],3); dt = dt (2); 
    time = 0 : dt : ( nt - 1 ) * dt;

    % find cell sizes in x and y direction and Tx and Rx steps
    dx = 4;   % line number in *.sca file
    dx = reshape(str2double(strsplit(sprintf(lines{dx},' '),' ')),[],3); dx = dx (2); 
    dy = 5;   % line number in *.sca file
    dy = reshape(str2double(strsplit(sprintf(lines{dy},' '),' ')),[],3); dy = dy (2);
    dz = 6;   % line number in *.sca file
    dz = reshape(str2double(strsplit(sprintf(lines{dz},' '),' ')),[],3); dz = dz (2);
    txstep = 19;   % line number in *.sca file
    txstep = reshape(str2double(strsplit(sprintf(lines{txstep},' '),' ')),[],6); txstep = txstep (2:4);
    rxstep = 20;   % line number in *.sca file
    rxstep = reshape(str2double(strsplit(sprintf(lines{rxstep},' '),' ')),[],6); rxstep = rxstep (2:4);

    % find first location of transmitter 
    Tini = 14;
    Tini = reshape(str2double(strsplit(sprintf(lines{Tini},' '),' ')),[],8); 
    xT = linspace((Tini (4) * dx),((nx - 1) * txstep (1) * dx + Tini (4) * dx),nx);
    yT = linspace((Tini (5) * dy),((nx - 1) * txstep (2) * dy + Tini (5) * dy),nx);
    zT = linspace((Tini (6) * dz),((nx - 1) * txstep (3) * dz + Tini (6) * dz),nx);

    % find first location of receiver 
    Rini = 18;
    Rini = reshape(str2double(strsplit(sprintf(lines{Rini},' '),' ')),[],6); 
    xR = linspace((Rini (2) * dx),((nx - 1) * rxstep (1) * dx + Rini (2) * dx),nx);
    yR = linspace((Rini (3) * dy),((nx - 1) * rxstep (2) * dy + Rini (3) * dy),nx);
    zR = linspace((Rini (4) * dz),((nx - 1) * rxstep (3) * dy + Rini (4) * dz),nx);


    % read the data 
    noheaderData = lines(23 : length(lines));
    % noheaderData = reshape(str2double(strsplit(sprintf(lines{noheaderData},' '),' ')),[],4);
    temp = regexp(noheaderData, '\s+', 'split');
    data = str2double(vertcat(temp{:})); data (:,11) = [];

    % extract Ez 
    Ez = reshape (data (:,4),nt,nx);
    
    % optional plot and save 
    if nargin == 2
        if char(varargin(1))=='plot' 
            imagesc ((xR+xT)/2, time, Ez)
            title('Synthetic 3D GPR data');xlabel('X(m)');ylabel('Time (s)')
        elseif char(varargin(1))=='save' 
            save(strcat(FileName(1:end-4),'.mat'),'Ez', 'dt', 'time', 'nx', ...
                'nt', 'xT', 'yT', 'xR', 'yR')
        end
    end
    if nargin > 2
        imagesc ((xR+xT)/2, time, Ez)
        title('Synthetic 3D GPR data');xlabel('X(m)');ylabel('Time (s)')
        save(strcat(FileName(1:end-4),'.mat'),'Ez', 'dt', 'time', 'nx', ...
                'nt', 'xT', 'yT', 'xR', 'yR')
    end

else    %Reflex output file

    data = dlmread(FileName);
    nx = 0;
    
    for i = 1 : length(data)
        if data(i,2) == 0
            nx = nx + 1;
        end
    end
    
    nt = length(data)/nx;
    time_max = data(length(data),2) * 10^-9;
    dt = time_max/(nt - 1);
    time = 0 : dt : time_max;
    x_max = data(length(data),1);
    x_min = data(1,1);
    dx = ( x_max - x_min ) / (nx - 1);
    xT = x_min : dx : x_max;
    yT = 0; % not readable from reflex fils!!!!
    xR = xT;% not readable from reflex fils!!!!
    yR = 0; % not readable from reflex fils!!!!

    for i = 1 : nx
        for j = 1 : nt
            Ez(j,i) = data(((i-1)*nt+j),3);
        end
    end
    
    if nargin == 2
        if char(varargin(1))=='plot' 
            imagesc ((xR+xT)/2, time, Ez)
            title('GPR data from reflexw');xlabel('X(m)');ylabel('Time (s)')
        elseif char(varargin(1))=='save' 
            save(strcat(FileName(1:end-4),'.mat'),'Ez', 'dt', 'time', 'nx', ...
                'nt', 'xT', 'yT', 'xR', 'yR')
        end
    end
    if nargin > 2
        imagesc ((xR+xT)/2, time, Ez)
        title('GPR data from reflexw');xlabel('X(m)');ylabel('Time (s)')
        save(strcat(FileName(1:end-4),'.mat'),'Ez', 'dt', 'time', 'nx', ...
                'nt', 'xT', 'yT', 'xR', 'yR')
    end
    
end


 
