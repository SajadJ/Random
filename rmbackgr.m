function dbg = rmbackgr( d ) 
% 
%   RMBACKGR : Remove a global background trace from the GPR section 
%              passed in "d". The background trace is the average trace 
%              determined by adding all traces together and dividing by the 
%              number of traces.  
% 
%      Usage : dbg = rmbackgr( d ) 
%   
%      Input :   d, the input GPR section 
%     
%     Output : dbg, the reduced GPR section 
% 
%     Author : Andreas Tzanis, 
%              Department of Geophysics,  
%              University of Athens 
%              atzanis@geol.uoa.gr 
% 
% Copyright (C) 2005, Andreas Tzanis. All rights reserved. 
% 
%  This program is free software; you can redistribute it and/or modify 
%  it under the terms of the GNU General Public License as published by 
%  the Free Software Foundation; either version 2 of the License, or 
%  (at your option) any later version. 
% 
%  This program is distributed in the hope that it will be useful, 
%  but WITHOUT ANY WARRANTY; without even the implied warranty of 
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
%  GNU General Public License for more details. 
% 
%  You should have received a copy of the GNU General Public License 
%  along with this program; if not, write to the Free Software 
%  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA. 
% 
[m,n] = size( d ); 
backgr = mean( d' )'; 
dbg = d - backgr * ones( 1, n ); 
return 
