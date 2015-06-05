function [ dI ] = deconvglucy( Nd, dB, K, niter, alpha, verbose )
%DECONVGCLUCY Gain-controlled Richardson-Lucy algorithm
%
%   Nd      - denoised image
%   dB      - deltaB = B - Nd conv K (+ offset)
%   K       - kernel
%   niter   - # of iterations
%   alpha   - weight of the gain map
%   verbose - display more information if true
%

if nargin < 4
    % default = 0.2 in the paper
    alpha = 0.2;
end

if nargin < 5
    verbose = true;
end

if alpha > 0
    if verbose
        disp('Calculating Igain map...');
    end
    % calculate gain map according to Nd and param alpha
    Igain = compute_Igain_map(Nd, alpha);
    if verbose
        disp('Igain map ready.');
    end
else
    [ h, w, ~ ] = size(Nd);
    Igain = ones([ h w ], 'double');
end


dI = zeros(size(dB), 'double');
dnom = zeros(size(dB), 'double');
Khat = rot90(K, 2); % = flipud(fliplr(K));

[~, ~, d] = size(dB);

if verbose
    disp('Start iterating...');
end

for i = 1:niter
    dI = dI + 1;
    dI = max(dI, 0);
    
    % calculate the denominator in the equation
    for j = 1:d
        dnom(:,:,j) = fftconv2(dI(:,:,j), K); 
%         dnom(:,:,j) = conv2(dI(:,:,j), K, 'same');
    end
    
    tmp = dB./dnom;
    
    for j = 1:d
%         dI(:,:,j) = conv2(tmp(:,:,j), Khat, 'same') .* dI(:,:,j) - 1;
        dI(:,:,j) = fftconv2(tmp(:,:,j), Khat) .* dI(:,:,j) - 1;
        if i ~= niter
            dI(:,:,j) = Igain .* dI(:,:,j);
        end
    end
    dI = min(dI, 1);
end

end


