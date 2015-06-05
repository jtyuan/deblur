function [ Nd ] = denoise( N )
%DENOISE Denoise noisy image N
%   
%   N - noisy image
%

if isa(N, 'uint8')
    Nd = zeros(size(N), 'uint8');
elseif isa(N, 'uint16')
    Nd = zeros(size(N), 'uint16');
elseif isa(N, 'double')
    Nd = zeros(size(N), 'double');
end

[~, ~, d] = size(N);

for i = 1:d
    [A, DV, B] = denoise_preprocess(N(:,:,i)*255);

    % let A be 0, simply use DV as sigma
    A = 0;
    
    % channel wise denoise
    Nd(:,:,i) = denoise_channel(N(:,:,i)*255, A, DV, B, 'fastnlm'); 
end

Nd = Nd/255;

end


