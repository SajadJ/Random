% function to calculate the time interval between the readings in gprMax3D

function [dt] = dt_gprmax(dx,dy,dz)

c = 3e8;
switch nargin 
    case 2
        dt = 1/(c*sqrt(1/(dx^2)+1/(dy^2)));
    case 3 
        dt = 1/(c*sqrt(1/(dx^2)+1/(dy^2)+1/(dz^2)));
end
dt

