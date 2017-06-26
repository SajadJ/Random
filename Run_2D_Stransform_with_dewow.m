% code to read .SCA file, apply dewow and do the S-transform

clc 
clear all
% close all

%% read data make an initial plot

prompt = {'Matlab data (*.mat), 0 or 1','ASCII 3 column data, 0 or 1 '};
dlg_title = 'DATA Input';
num_lines = 1;
defaultans = {'0','0'};
input_kind = inputdlg(prompt,dlg_title,num_lines,defaultans);
M_file = str2num(cell2mat((input_kind(1))));
ASCII_file = str2num(cell2mat((input_kind(2))));

if M_file == 1

    [filenameInput,filepathInput]=uigetfile({'*.mat'}, 'Select Input File');
    load(strcat(filepathInput,filenameInput))

    prompt = {'dewow_window','f_min','f_max'};
    dlg_title = 'F T Input';
    num_lines = 1;
    defaultans = {' ','0','3000'};
    dewow_freq_info = inputdlg(prompt,dlg_title,num_lines,defaultans); 

    if exist('migHF') == 1
        dewow_window = '';
    else
        dewow_window = str2num(cell2mat((dewow_freq_info(1))));
    end   

    fmin = str2num(cell2mat((dewow_freq_info(2))));
    fmax = str2num(cell2mat((dewow_freq_info(3))));

    if isempty(dewow_window) == 1
        Ndewow = 0;
        dewow_window_data = 0;
        x_dewowed = 0;
    else
        Ndewow=floor(dewow_window/dt);
        dewow_window_data=zeros(Ndewow,1);
        x_dewowed=zeros( ndata1trace ,1);
    end
    if exist('Ez') == 0
        Ez = Ez_real ;
    end
    for S_trace=1:traces

        if exist('migHF') == 1
            trace_data = migHF(:,S_trace);
        else
            trace_data = Ez(:,S_trace);
        end

        for i = 1 : ndata1trace-Ndewow
            dewow_window_data=trace_data(i:i+Ndewow-1);

            if isempty(dewow_window) == 1
                mean_window = 0;
            else
                mean_window=mean(dewow_window_data);
            end

            Ez_dewowed(i:(i+Ndewow))=trace_data(i:(i+Ndewow))-mean_window;
        end

        outfile='s_transform';

        A_stransform = trace_data;
        [nrow ncol] = size(A_stransform);
        if nrow > ncol
            A_stransform = A_stransform';
        end
        [nrow ncol] = size(time);
        if nrow > ncol
            time = time';
        end

        n = 2^nextpow2(length(A_stransform));
        [S,freq] = stransform(A_stransform,time,fmin,fmax,n);
        Smax(:,S_trace) = max(S)'; 

    end
    %% plot the output

    prompt = {'title','X_min','X_max','Time_min','Time_max', 'Frequency_min', 'Frequency_max'};
    dlg_title = 'F T Input';
    num_lines = 2;
    defaultans = {'S transform of GPR data on a pipe, 500 MHz', ...
        num2str(x(1)),num2str(x(end)),num2str(time(1)),num2str(round(time(end))) ...
        ,num2str(min(min(S))),num2str(max(max(S)))};
    plotting_info = inputdlg(prompt,dlg_title,num_lines,defaultans); 

    imagesc ( x,time,Smax); colormap jet; colorbar; 
    title(plotting_info(1))
    xlabel('X (m)')
    ylabel('Time (ns)')
    xlim([str2num(cell2mat((plotting_info(2)))) str2num(cell2mat((plotting_info(3))))])
    ylim([str2num(cell2mat((plotting_info(4)))) str2num(cell2mat((plotting_info(5))))])
    caxis([floor(str2num(cell2mat((plotting_info(6))))) str2num(cell2mat((plotting_info(7))))])    

elseif ASCII_file == 1
    [filenameInput,filepathInput] = uigetfile({'*.ASC'}, 'Select Input File');
    data = dlmread(strcat(filepathInput,filenameInput));
    
    traces=0;
    for i=1:length(data)
        if data(i,2)==0
            traces=traces+1;
        else
        end
    end
    ndata1trace = length(data)/traces;
    time_max = data(length(data),2);
    dt = time_max/(ndata1trace-1);
    time = 0:dt:time_max;
    x_max = data(length(data),1);
    x_min = data(1,1);
    dx = (x_max-x_min)/(traces-1);
    x = x_min:dx:x_max;
    
    for i=1:traces
        for j=1:ndata1trace
            Ez(j,i)=data(((i-1)*ndata1trace+j),3);
        end
    end
    
    
    prompt = {'f_min','f_max'};
    dlg_title = 'Frequency Input';
    num_lines = 1;
    defaultans = {'0','3000'};
    freq_info = inputdlg(prompt,dlg_title,num_lines,defaultans); 
    fmin = str2num(cell2mat((freq_info(1))));
    fmax = str2num(cell2mat((freq_info(2))));

    for S_trace=1:traces
        
        A_stransform = Ez(:,S_trace);
        outfile='s_transform';
        [nrow ncol] = size(A_stransform);
        if nrow > ncol
            A_stransform = A_stransform';
        end
        [nrow ncol] = size(time);
        if nrow > ncol
            time = time';
        end

        n = 2^nextpow2(length(A_stransform));
        [S,freq] = stransform(A_stransform,time,fmin,fmax,n);
        Smax(:,S_trace) = max(S)'; 

    end
    %% plot the output

    prompt = {'title','X_min','X_max','Time_min','Time_max', 'Frequency_min', 'Frequency_max'};
    dlg_title = 'F T Input';
    num_lines = 2;
    defaultans = {'S transform of migrated GPR data on a pipe, 500 MHz', ...
        num2str(x(1)),num2str(x(end)),num2str(time(1)),num2str(round(time(end))) ...
        ,num2str(min(min(S))),num2str(max(max(S)))};
    plotting_info = inputdlg(prompt,dlg_title,num_lines,defaultans); 

    imagesc ( x,time,Smax); colormap jet; colorbar; 
    title(plotting_info(1))
    xlabel('X (m)')
    ylabel('Time (ns)')
    xlim([str2num(cell2mat((plotting_info(2)))) str2num(cell2mat((plotting_info(3))))])
    ylim([str2num(cell2mat((plotting_info(4)))) str2num(cell2mat((plotting_info(5))))])
    caxis([floor(str2num(cell2mat((plotting_info(6))))) str2num(cell2mat((plotting_info(7))))])    

    
end

