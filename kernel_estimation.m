function [ K ] = kernel_estimation( I, B, len, lambda, method, verbose)
%KERNEL_ESTIMATION Get an estimated kernel based on benoised and blurred image
%   Solve a l1-regularized least squares problem to get the kernel
%
%   I       - is actually Nd as approxiamation
%   B       - blurred image
%   len     - kernel size; default: 64
%   lambda  _ estimation parameter mentioned in the paper: default: 25
%   method  - 
%   verbose - true to enable debug output
%
%   including a toolbox from Standford to the l1-ls problem (in 
%       l1_ls_matlab directory, https://github.com/cvxgrp/l1_ls)
%


if verbose
    disp('Starting kernel estimation...');
end

niter = 50;

if nargin < 3
    len = 5;
end

if nargin < 4
    lambda = 1;
end

if nargin < 5
    method = 'l1ls';
end

if nargin < 6
    verbose = true;
end

if strcmp(method, 'l1ls')
    % Transform image I into matrix A that is suitable for l1ls problem
    A = MatrixConvolve(I, len);
    At = A';
    b = mat2vec(B);
    rel_tol = 0.001;
    [K, ~] = l1_ls_nonneg(A, At, numel(I), len^2, b, lambda^2, rel_tol, ~verbose);
%     K = sqrt(K);
elseif strcmp(method, 'landweber')
    % initialize K to dirac delta function
    K = zeros([len^2 1]);
    K(floor((len^2+1)/2)) = 1;

    A = mat2kmat(I, len);
    At = A';
    b = mat2vec(B);
    AtA = At * A;
    Atb = At * b;
    lambda2 = lambda^2;
    E = eye(len^2);
    for i = 1:niter
        K = K + beta * (Atb - (AtA + lambda2*E)*K);
        K(K<0) = 0;
        K = K / sum(K(:));
    end
else
    K = [];
    disp('Unimplemented method.');
    return;
end
K = reshape(K, [len len]);

% normalize estimated kernel
K = K / sum(K(:));

if verbose
    disp('Kernel estimation complete...');
end

end




