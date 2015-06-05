%TEST_MATRIX_VECTOR_MUL test image to matrix transformation, and
%multiplication afterwards

A = [1 2 3 4; 4 5 6 7; 7 8 9 10; 10 11 12 13];
B = [4 3 2 1; 7 6 5 4; 10 9 8 7; 13 12 11 10];

mul1 = A'*B;

B = reshape(B, [16 1]);
len = 3;

[h w] = size(A);

km = zeros([w*h len^2], 'double');
ks = floor((len-1)/2);
kt = floor(len/2);

for i = 1:h
    for j = 1:w
        for p = -ks:kt
            for q = -ks:kt
                if i+p>0 && j+q>0 && i+p<=h && j+q<=w
                    km((i-1)*w+j, q+ks+1+(p+ks)*len) = A(i+p, j+q);
                else
                    km((i-1)*w+j, q+ks+1+(p+ks)*len) = 0;
                end
            end
        end
    end
end

A = km;
mul2 = A'*B;
mul2 = reshape(mul2, [3 3]);
