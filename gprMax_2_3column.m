clc
clear

InputFileName = 'pipe_sand_cond1'; 
[Ez, dt, time, nx, nt, xT, yT, xR, yR] = gprmax_read(strcat(InputFileName,'.sca'));
x = (xR+xT)/2;

%% write to a txt file to be able to read in reflexw
OutFileName = strcat(InputFileName,'.txt');
file = fopen(OutFileName, 'w');
fprintf(file,'0\n');

for i = 1 : nx
    for j = 1 : nt
        fprintf(file,strcat(num2str(x(i)),'\t',num2str(time(j)*10^9),'\t',num2str(Ez(j,i)),'\n'));
    end
end
fclose(file);