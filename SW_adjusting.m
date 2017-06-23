clc
clear all
close all


[filenameInput,filepathInput] = uigetfile({'*.txt'}, 'Select the Wavelet File');
initial_SW = dlmread(strcat(filepathInput,filenameInput));

% calculate the overal SW time and make an initiary plot of SW
prompt = {'Current dxy = ?'};
    dlg_title = 'dxy ';
    num_lines = 1;
    defaultans = {'0'};
    specs = inputdlg(prompt,dlg_title,num_lines,defaultans); 
    dxy = str2num(cell2mat(specs(1))); 
    dt = 1/(0.3*sqrt(2/(dxy^2)));
    time = 0: dt :(length(initial_SW)-1)*dt;
plot(time,initial_SW)

% how much to expand/shorten the trace?
prompt = {'total length of the wanted trace = ?', 'The expansion length constant = ?'};
    dlg_title = 'dxy ';
    num_lines = 1;
    defaultans = {'0', '0'};
    specs = inputdlg(prompt,dlg_title,num_lines,defaultans); 
    T = str2num(cell2mat(specs(1)));
    alfa = str2num(cell2mat(specs(2)));
    
    if T == 0 && alfa ==0
        break
    elseif alfa == 0 && T ~= 0
        alfa  = ceil(T / time(end));
    end
    
    
%% normalize the SWs
%initial_SW=initial_SW/max(abs(initial_SW));

%% time definement
final_length = length(initial_SW) * alfa;
%% adjusting the initial
adjusted_SW = zeros(final_length,1);
adjusted_SW(1) = initial_SW(1);
for i = 1 : (final_length/alfa)
    adjusted_SW(alfa*i) = initial_SW(i);
end

adjusted_SW(adjusted_SW==0) = NaN;
adjusted_SW = inpaint_nans(adjusted_SW);

new_time = 0: dt : (length(adjusted_SW)-1)*dt;
figure
subplot(211)
plot(time,initial_SW)
subplot(212)
plot(new_time, adjusted_SW)

output=fopen('SW_adjusted.txt','w') % output
for i=1: length(adjusted_SW)
        line=strcat(num2str(adjusted_SW(i)),'\n');
        fprintf(output,line);
end
fclose all
