function plt (data,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% developed by Sajad Jazayeri, Sep 2019 %%%%%%%%%%%%%%%%%%%%%
% code to plot time series, either data or data against time and distance

% data: matrix of the data to be plotted, rows time, columns distance
% x: distance
% time: time in ns
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% hint: input should be like either of these: 
% % plt(data,time,x)
% or
% % plt(data,x,time)
% or 
% % plt(data)
% the sequence after data is not important as far as size of time and x
% differs

img = figure
colormap gray;
set(0,'DefaultTextInterpreter','latex')
set(gca,'TickLabelInterpreter','latex','FontSize', 10)
if nargin == 1
    % plot the data just
    imagesc(data); 
    ylabel('Time (node)')
    xlabel('Distance (node)')
else
    
    try
        % find which variable after data is distance and which is time
        temp = varargin{1,1};
        if size(data,1) == length(temp)
            time = varargin{1,1};
            x = varargin{1,2};
        else
            time = varargin{1,2};
            x = varargin{1,1};
        end
        % make time units ns if not already
        if time(2) < 10^-9
            time = time * 10^9;
        end
        % plot Ez vs time and distance
        imagesc(x,time,data); 
        ylabel('Time (ns)')
        xlabel('Distance (m)')
    catch 
        print('check your inputs again!')
        close(img)
    end
end