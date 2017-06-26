function [smooth_list]=RunningAverage(list, WindowSize)
%SEK 9 24 03
%this algorithm comes from Matlab documentation
temp_list=filter(ones(1,WindowSize)/WindowSize,1,list);

%the rest is new code
%running average is shifted, need to shift back
smooth_list=[];
ishift = round(WindowSize/2);
for i=1:(length(temp_list)-ishift)
    smooth_list(i)=temp_list(i+ishift-1);
end

%deal with first points
for i=1:ishift
    smooth_list(i)=0.0;
    for is=1:(2*i-1)
        smooth_list(i)=smooth_list(i)+list(is);
    end
    smooth_list(i)=smooth_list(i)/(2*i-1);
end 

%deal with last points
il=length(list)+1;
for i=1:ishift
    smooth_list(il-i)=0.0;
    for is=1:(2*i-1)
        smooth_list(il-i)=smooth_list(il-i)+list(il-is);
    end
    smooth_list(il-i)=smooth_list(il-i)/(2*i-1);
end 
