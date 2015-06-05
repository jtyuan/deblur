function [ V ] = mat2vec( I )
% MAT2VEC transform I into vector form in the paper

[ h, w ] = size(I);

V = reshape(double(I), [h*w 1]);

end