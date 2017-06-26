%% code to calculate instantaneous phase, amplitude and frequency of a GPR signal
% Sajad Jazayeri, USF, Dec 2016
% Help from: https://www.mathworks.com/matlabcentral/answers/161198-instantaneous-frequency-using-hilbert
% https://www.mathworks.com/help/signal/ref/hilbert.html

clear all; close all; clc 

% decide if you are going to import gprmax data (.SCA), 3 column reflexw output (.ASC) or matlab (.mat) data 
prompt = {'Matlab file','3 column ASC file from reflex','gprMax ASCII file'};
dlg_title = 'DATA Input';
num_lines = 1;
defaultans = {'0','0','0'};
input = inputdlg(prompt,dlg_title,num_lines,defaultans); 
M_file = str2num(cell2mat((input(1))));
ASCII_reflex_file = str2num(cell2mat((input(2))));
ASCII_gprMax_file = str2num(cell2mat((input(3))));

%% READ DATA, mak uniform dataset regardless of the data kind
if M_file == 1 && ASCII_reflex_file == 0 && ASCII_gprMax_file == 0
    [filenameInput,filepathInput] = uigetfile({'*.mat'}, 'Select Input matlab File');
    load(strcat(filepathInput,filenameInput))
    
    % check the name logics
    test = exist('Ez');
    if test == 0 
        Ez = Ez_real;
    end
    
    

    elseif M_file == 0 && ASCII_reflex_file == 1 && ASCII_gprMax_file == 0
        [filenameInput,filepathInput] = uigetfile({'*.ASC'}, 'Select Input ASC File');
        data = dlmread(strcat(filepathInput,filenameInput));
        traces = 0;
        for i = 1 : length(data)
            if data(i,2) == 0
                traces=traces+1;
            end
        end
        n1trace = length(data)/traces;
        time_max = data(length(data),2);
        dt = time_max/(n1trace-1);
        time = 0:dt:time_max;
        x_max = data(length(data),1);
        x_min = data(1,1);
        dx = (x_max-x_min)/(traces-1);
        x = x_min:dx:x_max;

        for i = 1:traces
            for j = 1:n1trace
                Ez(j,i) = data(((i-1)*n1trace+j),3);
            end
        end

    elseif M_file == 0 && ASCII_reflex_file == 0 && ASCII_gprMax_file == 1
        [filenameInput,filepathInput] = uigetfile({'*.sca'}, 'Select gprMax Input File');
        data = fileread(strcat(filepathInput,filenameInput));
        
        traces = str2num(data(strfind(data,'#Number of Steps:')+17:strfind(data,'#Number of Steps:')+19));
        dx = str2num(data(strfind(data,'#dx:')+5:strfind(data,'#dx:')+11));
        tx_steps = str2num(data(strfind(data,'#tx_steps:')+11:strfind(data,'#tx_steps:')+13));

        tempT = fopen('tempT.txt','w');
        tempT = fprintf(tempT,data(strfind(data,'HY(A/m)')+11: size(data,2)));
        dataTrue = dlmread('tempT.txt'); fclose all; delete tempT.txt
        n = size(dataTrue,1);
        n1trace = n/traces;
        time = dataTrue(1:n1trace,1); 
        dt = time(2) - time(1); 

        prompt = {'X-min','dX','X-max'};
        dlg_title = 'X Input';
        num_lines = 1;
        defaultans = {'0','0','0'};
        Specifications = inputdlg(prompt,dlg_title,num_lines,defaultans); 

        if size(Specifications,1) == 0
        else
            x = str2num(cell2mat((Specifications(1)))):str2num(cell2mat((Specifications(2)))):str2num(cell2mat((Specifications(3))));

            for i=1:traces
                Ez(:,i)=dataTrue((i-1)*n1trace+1:(i*n1trace),2);
            end
        end 
        
end

try 
    fs = 1/(dt*10^-9); % sampling frequency
    %% 2D attribute analysis or 1D on just one trace?
    prompt = {'2D or 1D-single trace analysis (default 2D)'};
    dlg_title = '1/2D?';
    num_lines = 1;
    defaultans = {'2'};
    dimensionality = inputdlg(prompt,dlg_title,num_lines,defaultans); 
    dimensionality = str2num(cell2mat(dimensionality));

    if dimensionality == 2
            % 2D matrix of attributes
        for i = 1:traces
            % perform hilbert transform
            h = hilbert(Ez(:,i));
            A = abs(h);
            % calculating the INSTANTANEOUS FREQUENCY
            inst_phase = atan(angle(h));
            % calculating the INSTANTANEOUS FREQUENCY
            inst_freq = diff(unwrap(angle(h)))/((1/fs)*2*pi);
            inst_freq = cat(1,0, inst_freq);
            % make the attribute matrix
            ENV_A(:,i) = A;
            INS_PHASE(:,i) = inst_phase;
            INS_FREQ(:,i) = inst_freq;
            WEI_FREQ(:,i) = A .* inst_freq;
            PARAPHRASE(:,i) = cos(inst_phase);
        end

            figure
            subplot(3,2,1)
            imagesc(x,time,Ez); colormap hsv;ylabel('Data')
            subplot(3,2,2)
            imagesc(x,time,INS_FREQ);ylabel('Instantaneous Frequency')
            subplot(3,2,3)
            imagesc(x,time,ENV_A);ylabel('Instantaneous Amplitude')
            subplot(3,2,4)
            imagesc(x,time,INS_PHASE);ylabel('Instantaneous phase')
            subplot(3,2,5)
            imagesc(x,time, ENV_A.*INS_FREQ);ylabel('weighted frequency')
            subplot(3,2,6)
            imagesc(x,time, PARAPHRASE);ylabel('Instantaneous paraphrase (cos of ins phase)')

    elseif dimensionality == 1
        % which trace?
        prompt = {strcat('Which trace? less than ', num2str(traces))};
        dlg_title = 'Which trace? ';
        num_lines = 1;
        defaultans = {num2str(floor(traces/2))};
        desired_trace = inputdlg(prompt,dlg_title,num_lines,defaultans); 
        desired_trace = str2num(cell2mat(desired_trace));
        data = Ez(:,desired_trace);
        h=hilbert(data);
        A=abs(h);
        inst_phase=atan(angle(h));
        % calculating the INSTANTANEOUS FREQUENCY
        inst_freq = diff(unwrap(angle(h)))/((1/fs)*2*pi);
        inst_freq = cat(1,0, inst_freq);

        % plot all attributes
        figure
        subplot(5,1,1)
        plot(time*10^9,data); ylabel('signal');title('SIGNAL ATTRIBUTES')
        subplot(5,1,2)
        plot(time*10^9,A); ylabel('instant amplitude')
        subplot(5,1,3)
        plot(time*10^9,inst_freq/10^9);ylabel('instant freq')
        subplot(5,1,4)
        plot(time*10^9,inst_phase);ylabel('instant phase')
        subplot(5,1,5)
        plot(time*10^9,cos(inst_phase));ylabel('paraphrase');xlabel('time (ns)')

        % plot the hilbert transform of the signal, real and imaginary parts1
        figure
        plot(time,real(h),time,imag(h))
        legend('real','imaginary')
        title('hilbert Function')

        % Compute Welch estimates of the power spectral densities of the original sequence and the analytic signal. Divide the sequences into Hamming windowed nonoverlapping sections of length 256.
        figure
        pwelch([data;h],256,0,[],fs,'centered')
        legend('Original','hilbert')

        figure
        spectrogram(data,200,180,256,fs,'yaxis')
    end
catch fprintf('No input')
end