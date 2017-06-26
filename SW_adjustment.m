clc
clear all
close all

sw_ini=dlmread('gaussian_4d_excit.txt');

%% initial dt
dx_ini = 0.01;
dy_ini = 0.01;
dz_ini = 0.01;

dt_initial = dt_gprmax(dx_ini,dy_ini,dz_ini);
%% final dt 
dx_final = 0.0025;
dy_final = 0.0025;
dz_final = 0.0025;

dt_final = dt_gprmax(dx_final,dy_final,dz_final);
%% adjusting the initial wavelet length
n_ini = length (sw_ini) ;
n_final = floor(( dt_initial/ dt_final)*length (sw_ini)) ;

sw_final = smooth(smooth(imresize(sw_ini, [n_final 1], 'nearest')));
sw_final = sw_final* (max(abs(sw_ini))/max(abs(sw_final)));
%% plot
plot(sw_ini);hold on
plot(sw_final); 

legend ('initial SW','correted SW')
title ('SW comparison')
ylabel('Normalized Amplitude')
xlabel ('Time (ns)')

%% write out the adjusted wavelet
outcome=fopen('adjusted_sw.txt','w');
outcome=fprintf(outcome,'%d\n',sw_final);
