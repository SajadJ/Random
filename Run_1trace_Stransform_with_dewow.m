% code to read .SCA file, apply dewow and do the S-transform

clc 
clear all
% close all

%% read data make an initial plot
[filenameInput,filepathInput]=uigetfile({'*.sca'}, 'Select Input File');
scaT=fileread(strcat(filepathInput,filenameInput));
traces=str2num(scaT(strfind(scaT,'#Number of Steps:')+17:strfind(scaT,'#Number of Steps:')+19));
dx=str2num(scaT(strfind(scaT,'#dx:')+5:strfind(scaT,'#dx:')+11));
tx_steps=str2num(scaT(strfind(scaT,'#tx_steps:')+11:strfind(scaT,'#tx_steps:')+13));

tempT=fopen('tempT.txt','w');
tempT=fprintf(tempT,scaT(strfind(scaT,'HY(A/m)')+11: size(scaT,2)));
dataTrue=dlmread('tempT.txt'); fclose all; delete tempT.txt
n = size(dataTrue,1);
n1trace=n/traces;
trace_data=dataTrue(:,2);
time=dataTrue(1:n1trace,1); 
n1trace=n/traces;
dt=time(2)-time(1); 

    prompt = {'dewow_window','f_min','f_max'};
    dlg_title = 'F T Input';
    num_lines = 1;
    defaultans = {'1','0','3000'};
    dewow_freq_info = inputdlg(prompt,dlg_title,num_lines,defaultans); 
    dewow_window = str2num(cell2mat((dewow_freq_info(1))));
    fmin = str2num(cell2mat((dewow_freq_info(2))));
    fmax = str2num(cell2mat((dewow_freq_info(3))));

% Apply dewow
Ndewow=floor(dewow_window/dt);
dewow_window_data=zeros(Ndewow,1);
x_dewowed=zeros(n1trace,1);


for i=1: n1trace-Ndewow
    dewow_window_data(:,1)=trace_data(i:i+Ndewow-1);
    mean_window=mean(dewow_window_data);
    x_dewowed(i:(i+Ndewow))=trace_data(i:(i+Ndewow))-mean_window;
end

%% plot a dewowed signal vs the original signal

plot(x_dewowed)
hold on
plot(trace_data,'r')
legend('dewowed','original')

%%
% t=time;
outfile='s_transform';

%Extract a trace to run S transform on
% x_position=0.25;
% [temp, x_pos_ele] = min(abs(x-x_position))

A_stransform=trace_data;%;x_dewowed

% x and t must be row vectors for stransform
% so convert if necessary
[nrow ncol] = size(A_stransform);
if nrow > ncol
    A_stransform = A_stransform';
end
t=time;
[nrow ncol] = size(t);
if nrow > ncol
    t = t';
end

x=A_stransform;
figure;
subplot(3,1,1);
plot (t,x);
ylabel('amplitude');
length(x)
n = 2^nextpow2(length(x));
[S,freq] = stransform(x,t,fmin,fmax,n);
xlim ([0 t(length(t))])
subplot(3,1,2);
  imagesc(t, freq, S); colormap (jet);
  ylabel('frequency (MHz)');
axis xy;

%normalize S-transform  so that peak value at each time i
Smax = max(S); %finds max of each column = max energy at each time
%divide by Smax, column by column

[nf nt] = size(S)
for i=1:nt;
    for j=1:nf
        Snorm(j,i)=S(j,i)/Smax(i);
    end
end

subplot(3,1,3);
  imagesc(t, freq, Snorm); colormap (jet);
axis xy;
xlabel('time (ns)');
ylabel('frequency (MHz)');
savefig('stransform.fig')
% save(outfile,'S','Snorm','x','t','freq')