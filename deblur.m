function [ I, K ] = deblur( Nd, B, unikernel, deconvmode, verbose )
%DEBLUR Deblur image B
%
%   Nd          - Denoised image used by Yuan et al.
%   B           - Blurred imaged to deblur
%   unikernel   - true to estimate a uniform kernel for all channels
%   deconvmode  - deconvolution algorithm. it can be 'reg', 'lucy',
%                 'resRL', 'gcRL', 'detailedRL'
%   verbose     - display extra info if true
%

if nargin < 5
    verbose = true;
end
if nargin < 4
    deconvmode = 'gcRL';
end
if nargin < 3
    unikernel = true;
end


if isa(B, 'uint8')
    I = zeros(size(B), 'uint8');
elseif isa(B, 'uint16')
    I = zeros(size(B), 'uint16');
elseif isa(B, 'double')
    I = zeros(size(B), 'double');
end

[~, ~, d] = size(B);

if unikernel
    if d == 3
        gNd = rgb2gray(Nd);
        gB = rgb2gray(B);
    else
        gNd = Nd;
        gB = B;
    end
    
    % kernel estimation
    K = kernel_estimation(gNd, gB, 9, 5, 'l1ls', verbose);
    
    % deconvolution
    I = deconv(double(Nd), double(B), double(K), deconvmode, verbose);
else
    % calculate kernel for each channel
    K = zeros([9 9 d], 'double');
    
    % loop for every channel, same as unikernel if d == 1
    for i = 1:d
        K(:,:,i) = kernel_estimation(Nd(:,:,i), B(:,:,i), 9, 5, 'l1ls', verbose);
        I(:,:,i) = deconv(double(Nd), double(B(:,:,i)), double(K(:,:,i)), deconvmode, verbose);
    end
end

end
