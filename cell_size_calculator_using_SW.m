%% code to calculate the minimum required cell size for gprMax in order to prevent the numerical disperssion
% Sajad Jazayeri, USF, Jan 2017
% Help from: http://docs.gprmax.com/en/latest/gprmodelling.html#spatial-discretisation
clear all; close all; clc 

[filenameInput,filepathInput] = uigetfile({'*.txt'}, 'Select the Wavelet File');
SW = dlmread(strcat(filepathInput,filenameInput));

% import dt
prompt = {'dt(ns) = ?', 'or  cell_size =?'};
    dlg_title = 'dt ';
    num_lines = 1;
    defaultans = {'0', '0'};
    specs = inputdlg(prompt,dlg_title,num_lines,defaultans); 
    dt = str2num(cell2mat(specs(1)));
    dxy = str2num(cell2mat(specs(2)));
    
    if dt == 0 && dxy ==0
        return
    elseif dt == 0 && dxy ~= 0
        dt = 1/(0.3*sqrt(2/(dxy^2)));
    end

fs = 1/(dt*10^-9);

h=hilbert(SW);
figure(1)
pwelch([SW;h],64,0,[],fs,'centered')

figure(2)
spectrogram(SW,100,90,64,fs,'yaxis')
title('find the maximum of the frequency conetent')

% import soil perm and max f in the souce wavelet
prompt = {'max freq selected (GHZ)','soil perm'};
        dlg_title = 'INFO';
        num_lines = 1;
        defaultans = {'10','5'};
        Specifications = inputdlg(prompt,dlg_title,num_lines,defaultans); 
        
        soil_velocity = 0.3 / sqrt(str2num(cell2mat((Specifications(2)))));
        fmax = str2num(cell2mat((Specifications(1))));
        
        Lambda_min = soil_velocity / fmax;
        optimised_cell_size = Lambda_min / 10
        
        
        