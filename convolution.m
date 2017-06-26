% by sajad 2017

function [y] = myconv( x,h )
    m=length(x); 
    n=length(h); 
    x=[x,zeros(1,n)]; 
    h=[h,zeros(1,m)]; 
    for i=1:n+m-1 
        y(i)=0; 
        for j=1:m 
            if(i-j+1>0) 
                y(i)=y(i)+x(j)*h(i-j+1); 
            end 
        end 
    end