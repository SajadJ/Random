function o = normalize(i,varargin)
% function that normalized the input file
% Sajad Jazayeri Feb 2018

if nargin == 1;
    theme = 'global';
else
    theme = 'locall';
end

[nx ny] = size (i);

if nx == 1 | ny == 1 | theme == 'locall' 
    o = i ./ max(abs(i));
else
    o = i / max(max(abs(i)));
end

    
    
    