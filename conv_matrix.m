function matrix = conv_matrix (wave,varargin);

if nargin == 1 
    matrix = rot90 ( gallery('circul',wave) , 2 );
else
    wave(cell2mat(varargin)) = 0;
    matrix = rot90 ( gallery('circul',wave) , 2 );
end