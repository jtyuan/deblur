function [ k, B, N ] = generate_blurimg( I, len, theta, mean, variance )
%generateBlur generate Blur and Noisy image for the input image
%   
%   I        - the original image
%   len      - filter length
%   theta    - filter direction
%   mean     - mean for imnoise
%   variance - variance for imnoise
%

if nargin < 1
    error('usage: generateBlur image [len] [theta] [M] [V]');
end

if nargin < 2
    len = 8;
end

if nargin < 3
    theta = 0;
end

if nargin < 4
    mean = 0;
end

if nargin < 5
    variance = 0.0025;
end

k = fspecial('motion', len, theta); % used for the example in report
% k = fspecial('gaussian', [len len], 5);
%  k = random_kernel(len, len);

B = imfilter(I, k);

N = imnoise(I, 'gaussian', mean, variance); % used for the example in report

end

