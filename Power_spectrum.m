%% code to make power Spectrum of a GPR signal
% Sajad Jazayeri, USF, Nov 2016
% got help from : https://www.mathworks.com/help/signal/ug/power-spectral-density-estimates-using-fft.html?requestedDomain=www.mathworks.com

clear all; close all; clc 

% decide if you are going to import gprmax data (.SCA), 3 column reflexw output (.ASC) or matlab (.mat) data 
prompt = {'Matlab file','3 column ASC file from reflex','gprMax v2 ASCII file','gprMax v3 ASCII file'};
dlg_title = 'DATA Input';
num_lines = 1;
defaultans = {'0','0','0','0'};
input = inputdlg(prompt,dlg_title,num_lines,defaultans); 
MAT_file = str2num(cell2mat((input(1))));
ASCII_reflex_file = str2num(cell2mat((input(2))));
ASCII_gprMax_v2_file = str2num(cell2mat((input(3))));
ASCII_gprMax_v3_file = str2num(cell2mat((input(4))));

if ASCII_gprMax_v3_file == 1
    % read data make an initial plot
    [filenameInput,filepathInput] = uigetfile({'*.sca'}, 'Select the data File');
    data = dlmread(strcat(filepathInput,filenameInput));

    % define sampling frequency and time intervals 
    prompt = {'Total time (ns)','Antenna frequency (MHz)'};
        dlg_title = 'INFO';
        num_lines = 1;
        defaultans = {'50','800'};
        Specifications = inputdlg(prompt,dlg_title,num_lines,defaultans); 

        time_total = (str2num(cell2mat((Specifications(1)))))*(10^-9);  % in s
        f_antenna = (str2num(cell2mat((Specifications(2)))))*(10^6);    % in Hz
    
    dt = time_total/(length(data)-1);
    fs = 1/dt;                             % in Hz
    t = 0:dt:(length(data)-1)*dt;

    % obtain trace length
    n1trace = length(data);

    % get fast fourier transform
    xdft = fft(data);
    xdft = xdft(1:n1trace/2+1);

    % calculate power spectrum
    psdx = (1/(fs*n1trace)) * abs(xdft).^2;
    psdx(2:end-1) = 2 * psdx(2:end-1);

    % calculate frequencies for the spectrum
    frequency = 0: fs/length(data) : fs/2;

    % plot the frequency spectrum
    figure 
    subplot(3,1,1)
    plot(frequency, abs(xdft))
    xlim([0 15*f_antenna])
    grid on 
    title ('Frequency Spectrum')
    xlabel ('Frequency (Hz)')
    ylabel ('Amplitude')

    % plot the power spectrum 
    subplot(3,1,2)
    plot(frequency, 10*log10(psdx))
    xlim([0 5*f_antenna])
    grid on 
    title ('Power Spectrum')
    xlabel ('Frequency (Hz)')
    ylabel ('Power/Frequency (dB/Hz)')

    % plot the power spectrum with no limit for freq range: 0-fs
    subplot(3,1,3)
    plot(frequency, 10*log10(psdx))
    xlim([0 fs/2])
    grid on 
    title ('Power Spectrum')
    xlabel ('Frequency (Hz)')
    ylabel ('Power/Frequency (dB/Hz)')
end
    
if ASCII_gprMax_v2_file == 1
    % read data make an initial plot
    [filenameInput,filepathInput]=uigetfile({'*.sca'}, 'Select Input File');
    scaT=fileread(strcat(filepathInput,filenameInput));
    
    traces=str2num(scaT(strfind(scaT,'#Number of Steps:')+17:strfind(scaT,'#Number of Steps:')+19));
    dx=str2num(scaT(strfind(scaT,'#dx:')+5:strfind(scaT,'#dx:')+11));
    tx_steps=str2num(scaT(strfind(scaT,'#tx_steps:')+11:strfind(scaT,'#tx_steps:')+13));

    tempT=fopen('tempT.txt','w');
    tempT=fprintf(tempT,scaT(strfind(scaT,'HY(A/m)')+11: size(scaT,2)));
    dataTrue=dlmread('tempT.txt'); fclose all; delete tempT.txt
    n=size(dataTrue,1);
    n1trace=n/traces;
    time=dataTrue(1:n1trace,1); 
    dt=time(2)-time(1); dt = dt * (10^-9);
    for i=1:traces
        Ez(:,i)=dataTrue((i-1)*n1trace+1:(i*n1trace),2);
    end

    if traces > 1
       prompt = {strcat('Which trace? less than ', num2str(traces))};
        dlg_title = 'Which trace? ';
        num_lines = 1;
        defaultans = {num2str(floor(traces/2))};
        desired_trace = inputdlg(prompt,dlg_title,num_lines,defaultans); 
        desired_trace = str2num(cell2mat(desired_trace));
        data = Ez (:,desired_trace);
    else
        data = Ez;
    end
    
        prompt = {'Antenna Frequency (MHz)?'};
        dlg_title = 'Antenna Frequency';
        num_lines = 1;
        defaultans = {num2str(floor(traces/2))};
        f_antenna = inputdlg(prompt,dlg_title,num_lines,defaultans); 
        f_antenna = (str2num(cell2mat((f_antenna))))*(10^6);    % in Hz
    
    fs = 1/dt;                             % in Hz
    t = time*10^-9;

    % get fast fourier transform
    xdft = fft(data);
    xdft = xdft(1:n1trace/2+1);

    % calculate power spectrum
    psdx = (1/(fs*n1trace)) * abs(xdft).^2;
    psdx(2:end-1) = 2 * psdx(2:end-1);

    % calculate frequencies for the spectrum
    frequency = 0: fs/length(data) : fs/2;

    % plot the frequency spectrum
    figure 
    subplot(3,1,1)
    plot(frequency, abs(xdft))
    xlim([0 5*f_antenna])
    grid on 
    title ('Frequency Spectrum')
    xlabel ('Frequency (Hz)')
    ylabel ('Amplitude')

    % plot the power spectrum 
    subplot(3,1,2)
    plot(frequency, 10*log10(psdx))
    xlim([0 5*f_antenna])
    grid on 
    title ('Power Spectrum')
    xlabel ('Frequency (Hz)')
    ylabel ('Power/Frequency (dB/Hz)')

    % plot the power spectrum with no limit for freq range: 0-fs
    subplot(3,1,3)
    plot(frequency, 10*log10(psdx))
    xlim([0 fs/2])
    grid on 
    title ('Power Spectrum')
    xlabel ('Frequency (Hz)')
    ylabel ('Power/Frequency (dB/Hz)')
end

if MAT_file == 1
    [filenameInput,filepathInput] = uigetfile({'*.mat'}, 'Select the data File');
    load(strcat(filepathInput,filenameInput));
    
    Ez = Ez_real;
    n = traces;
    n1trace = ndata1trace;

    if traces > 1
       prompt = {strcat('Which trace? less than ', num2str(traces))};
        dlg_title = 'Which trace? ';
        num_lines = 1;
        defaultans = {num2str(floor(traces/2))};
        desired_trace = inputdlg(prompt,dlg_title,num_lines,defaultans); 
        desired_trace = str2num(cell2mat(desired_trace));
        data = Ez (:,desired_trace);
    else
        data = Ez;
    end
    
        prompt = {'Antenna Frequency (MHz)?'};
        dlg_title = 'Antenna Frequency';
        num_lines = 1;
        defaultans = {num2str(floor(traces/2))};
        f_antenna = inputdlg(prompt,dlg_title,num_lines,defaultans); 
        f_antenna = (str2num(cell2mat((f_antenna))))*(10^6);    % in Hz
    
    fs = 1/dt;                             % in Hz
    t = time*10^-9;

    % get fast fourier transform
    xdft = fft(data);
    xdft = xdft(1:n1trace/2+1);

    % calculate power spectrum
    psdx = (1/(fs*n1trace)) * abs(xdft).^2;
    psdx(2:end-1) = 2 * psdx(2:end-1);

    % calculate frequencies for the spectrum
    frequency = 0: fs/length(data) : fs/2;

    % plot the frequency spectrum
    figure 
    subplot(3,1,1)
    plot(frequency, abs(xdft))
    xlim([0 5*f_antenna])
    grid on 
    title ('Frequency Spectrum')
    xlabel ('Frequency (Hz)')
    ylabel ('Amplitude')

    % plot the power spectrum 
    subplot(3,1,2)
    plot(frequency, 10*log10(psdx))
    xlim([0 5*f_antenna])
    grid on 
    title ('Power Spectrum')
    xlabel ('Frequency (Hz)')
    ylabel ('Power/Frequency (dB/Hz)')

    % plot the power spectrum with no limit for freq range: 0-fs
    subplot(3,1,3)
    plot(frequency, 10*log10(psdx))
    xlim([0 fs/2])
    grid on 
    title ('Power Spectrum')
    xlabel ('Frequency (Hz)')
    ylabel ('Power/Frequency (dB/Hz)')
end