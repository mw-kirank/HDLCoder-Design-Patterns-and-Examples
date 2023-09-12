I = imread('mlhdlc_img_pattern_noisy.png');
J = I;

%   Copyright 2011-2019 The MathWorks, Inc.

smax = 9;
[nrows, ncols] = size(I);
ll = ceil(smax/2);
ul = floor(smax/2);

for ii=1:ncols-smax
    for jj=1:nrows-smax
        
        c_idx = ii;                    
        c_data = double(I(jj:jj+smax-1, ii));            
                
        [pixel_val, pixel_valid] = mlhdlc_median_filter(c_data, c_idx);
        
        if pixel_valid
            J(jj, ii) = pixel_val;
        end
    end
end

h = figure;
set( h, 'Name', [ mfilename, '_plot' ] );
subplot( 1, 2, 1 );
imshow( I, [  ] );
subplot( 1, 2, 2 );
imshow( J, [  ] );


