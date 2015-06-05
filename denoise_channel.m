function [ Nd ] = denoise_channel( N, A, DV, B, method_ )
%DENOISE_CHANNEL Channel wise denoise
%
%   N   - noisy image
%   A   - Slope of Avg-Var curve
%   DV  - Dark Variance (stddev of the first (dark) image sample)
%   B   - (DV - Y_intercept) / A
%
%   method_  - denoising method. it can be either 'blsgsm' or 'fastnlm'
%

imch = double(N);

method = 'fastnlm';

if nargin == 5
    method = method_;
end

% A = 0;
% Calculate noise
if A == 0
    % Slope == 0, so the overall stddev == that of the fisrt point
    sig = DV;
    [Ny,Nx] = size(imch);
else
    % the following method is provided by the CMU modification of the
    % original denoise algorithm. But no significant different in the
    % (my test) results.
    gaussian = [
        [0.0001 0.0006 0.0022 0.0054 0.0093 0.0111 0.0093 0.0054 0.0022 0.0006 0.0001] 
        [0.0006 0.0032 0.0111 0.0273 0.0469 0.0561 0.0469 0.0273 0.0111 0.0032 0.0006] 
        [0.0022 0.0111 0.0392 0.0963 0.1653 0.1979 0.1653 0.0963 0.0392 0.0111 0.0022] 
        [0.0054 0.0273 0.0963 0.2369 0.4066 0.4868 0.4066 0.2369 0.0963 0.0273 0.0054]
        [0.0093 0.0469 0.1653 0.4066 0.6977 0.8353 0.6977 0.4066 0.1653 0.0469 0.0093]
        [0.0111 0.0561 0.1979 0.4868 0.8353 1.0000 0.8353 0.4868 0.1979 0.0561 0.0111]
        [0.0093 0.0469 0.1653 0.4066 0.6977 0.8353 0.6977 0.4066 0.1653 0.0469 0.0093]
        [0.0054 0.0273 0.0963 0.2369 0.4066 0.4868 0.4066 0.2369 0.0963 0.0273 0.0054]
        [0.0022 0.0111 0.0392 0.0963 0.1653 0.1979 0.1653 0.0963 0.0392 0.0111 0.0022]
        [0.0006 0.0032 0.0111 0.0273 0.0469 0.0561 0.0469 0.0273 0.0111 0.0032 0.0006]
        [0.0001 0.0006 0.0022 0.0054 0.0093 0.0111 0.0093 0.0054 0.0022 0.0006 0.0001]
    ];
    gaussian = gaussian/sum(sum(gaussian));
%     sig = conv2(imch,gaussian,'same') - B;
    sig = fftconv2(imch, gaussian) - B;
    sig(sig < 0) = 0;
    sig = sig * A + DV;
    sig = sqrt(sig);
    [Nys,Nxs] = size(imch);
    [Ny,Nx] = size(sig);
    Nys = (Nys - Ny) / 2 + 1;
    Nxs = (Nxs - Nx) / 2 + 1;
    imch = imch(Nys:Nys + Ny - 1, Nxs:Nxs + Nx - 1);
end

if strcmp(method, 'fastnlm')
    im_d = FAST_NLM_II(imch, 7, 15, sig);
elseif strcmp(method, 'blsgsm')
    im_d = call_denoi_bls_gsm(imch, Nx, Ny, sig);
end

if isa(N, 'uint8')
    Nd = uint8(im_d);
elseif isa(N, 'uint16')
    Nd = uint16(im_d);
elseif isa(N, 'double')
    Nd = double(im_d);
end
end

