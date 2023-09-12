function J = medianFilter3(I) 
%#codegen

[Jmin3x3,Jmed3x3,Jmax3x3,~]                 = hdl.npufun(@myMedianKernel,[3 3],I); 
[Jmin5x5,Jmed5x5,Jmax5x5,~]                 = hdl.npufun(@myMedianKernel,[5 5],I); 
[Jmin7x7,Jmed7x7,Jmax7x7,~]                 = hdl.npufun(@myMedianKernel,[7 7],I); 
[Jmin9x9,Jmed9x9,Jmax9x9,JnewCenterData9x9] = hdl.npufun(@myMedianKernel,[9 9],I); 


J = hdl.npufun(@get_new_pixel, [1 1], Jmin3x3,Jmed3x3,Jmax3x3, ...
    Jmin5x5,Jmed5x5,Jmax5x5, ...
    Jmin7x7,Jmed7x7,Jmax7x7, ...
    Jmin9x9,Jmed9x9,Jmax9x9,JnewCenterData9x9 ...
    );

end



function [min,med,max,newCenterData] = myMedianKernel(mat)

[nrows, ncols] = size(mat);
prevCenterData = mat(ceil(nrows/2), ceil(ncols/2));
[min, med, max] = sortAndComputeMinMaxMedian(mat(:)');
newCenterData = get_center_data(min,med,max,prevCenterData);

end


function [new_data] = get_center_data(min,med,max,center_data)
if center_data == min || center_data == max
    new_data = med;
else 
    new_data = center_data;
end
end


function new_pixel  = get_new_pixel(min3, med3, max3, ...
                                    min5, med5, max5, ...
                                    min7, med7, max7, ...
                                    min9, med9, max9, ...
                                    center_data)



if (med3 > min3 || med3 < max3)
    new_pixel = get_center_data(min3, med3, max3,center_data);
elseif (med5 > min5 || med5 < max5)
    new_pixel = get_center_data(min5, med5, max5,center_data);
elseif (med7 > min7 || med7 < max7)
   new_pixel = get_center_data(min7, med7, max7,center_data);
else
   new_pixel = get_center_data(min9, med9, max9,center_data);
end
end
