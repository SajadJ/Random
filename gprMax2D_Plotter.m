%%% this code plots the ASCII format output of gprMax
%%% change the name of the input file in nameT. and x range.
%%% By: Sajad S. Jazayeri, USF 2015
%%% modified in Dec 2016

clc 
clear all
close all
[filenameInput,filepathInput]=uigetfile({'*.sca'}, 'Select Input File');
scaT=fileread(strcat(filepathInput,filenameInput));


traces=str2num(scaT(strfind(scaT,'#Number of Steps:')+17:strfind(scaT,'#Number of Steps:')+20));
dx=str2num(scaT(strfind(scaT,'#dx:')+5:strfind(scaT,'#dx:')+11));
tx_steps=str2num(scaT(strfind(scaT,'#tx_steps:')+11:strfind(scaT,'#tx_steps:')+13));

tempT=fopen('tempT.txt','w');
tempT=fprintf(tempT,scaT(strfind(scaT,'HY(A/m)')+11: size(scaT,2)));
dataTrue=dlmread('tempT.txt'); fclose all; delete tempT.txt
n=size(dataTrue,1);
ndata1trace=n/traces;

time=dataTrue(1:ndata1trace,1); 
dt=time(2)-time(1); 

prompt = {'X-min','dX','X-max','Save *.mat file (0/1)','Save ASCII file, 3 columns: x, time, Ez (0/1)'};
dlg_title = 'X Input';
num_lines = 1;
defaultans = {'0','0.01','1', '0','0'};
Specifications = inputdlg(prompt,dlg_title,num_lines,defaultans); 
save_mat_file = str2num(cell2mat((Specifications(4))));
three_column_export = str2num(cell2mat((Specifications(5))));


if size(Specifications,1) == 0
else
    x = str2num(cell2mat((Specifications(1)))):str2num(cell2mat((Specifications(2)))):str2num(cell2mat((Specifications(3))));

    for i=1:traces
        Ez(:,i)=dataTrue((i-1)*ndata1trace+1:(i*ndata1trace),2);
    end

    imagesc(x,time,Ez)

    title('GPR B-scan Synthetic model')
    legend Ez
    xlabel('Distance (m)')
    ylabel('Time (ns)')
    c = colorbar;
    % c.Label.String = 'Ez(v/m)';
    set(get(c,'title'),'string','Ez(v/m)');
    colormap gray

    % save *.mat file
    if save_mat_file == 1
        [outputfile,outputpath] = uiputfile('.mat','Save file name');
        if outputfile ==0
        else
            save(strcat(outputpath,outputfile))
        end
    end

    % export the data as a 3 column data file, x, time and amplitude
    if three_column_export == 1
        [outputfile,outputpath] = uiputfile('.txt','Save file name');

        if outputfile ==0
        else
            ascii_file = fopen(strcat(outputpath,outputfile), 'w');
            fprintf(ascii_file,'0 \n')
            for i=1:traces
                for j=1:ndata1trace
                    fprintf(ascii_file, strcat(num2str(x(i)),'\t',num2str(time(j)),'\t',num2str(Ez(j,i)),'\n'));

                end
            end
        end
    end
end


