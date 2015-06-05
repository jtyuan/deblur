function [ km ] = mat2kmat( I, len )
% MAT2KMAT  Transform image I into Matrix-form in the paper
%  
%   I    - original image
%   len  - len of kernel
%

[ h, w ] = size(I);

km = zeros([w*h len^2], 'double');
ks = floor((len-1)/2);
kt = floor(len/2);

for i = 1:h
    for j = 1:w
        for p = -ks:kt
            for q = -ks:kt
                if i+p>0 && j+q>0 && i+p<=h && j+q<=w
                    km((i-1)*w+j, q+ks+1+(p+ks)*len) = I(i+p, j+q);
                else
                    km((i-1)*w+j, q+ks+1+(p+ks)*len) = 0;
                end
            end
        end
    end
end
end