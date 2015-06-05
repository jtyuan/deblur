% Read the file "ReadMe.txt" for more details about this demo
% Javier Portilla, Universidad de Granada, Spain
% Last time modified: 14/5/2004

clear

% Enter noise parameters
B = 4860.840;
A = 36.418;                 % sigma^2 = A * (I - B) + DV
DV = 212;

% Read image
im = imread('a-2.5-050-03.tif');
im = double(im);        % convert it to double

% Calculate noise
if A == 0
    sig = DV;
    [Ny,Nx] = size(im);
else
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
    sig = conv2(im,gaussian,'valid') - B;
    sig(sig < 0) = 0;
    sig = sig * A + DV;
    sig = sqrt(sig);
    [Nys,Nxs] = size(im);
    [Ny,Nx] = size(sig);
    Nys = (Nys - Ny) / 2 + 1;
    Nxs = (Nxs - Nx) / 2 + 1;
    im = im(Nys:Nys + Ny - 1, Nxs:Nxs + Nx - 1);
end

% Noise power spectral density
PS = ones(size(im));	% flat, i.e., white noise
seed = 0;               % random seed, not used

% Pyramidal representation parameters
Nsc = ceil(log2(min(Ny,Nx)) - 4);   % Number of scales (adapted to the image size)

% Model parameters (optimized: do not change them unless you are an advanced user with a deep understanding of the theory)
%blSize = [5 5]; 	% n x n coefficient neighborhood of spatial neighbors within the same subband
blSize = [3 3];	    % n x n coefficient neighborhood of spatial neighbors within the same subband
                    % (n must be odd): 
boundary = 1;		% Boundary mirror extension, to avoid boundary artifacts 
covariance = 1;     % Full covariance matrix (1) or only diagonal elements (0).
optim = 1;          % Bayes Least Squares solution (1), or MAP-Wiener solution in two steps (0)

% Uncomment the following 4 code lines for reproducing the results in our IEEE Trans. on Im. Proc., Nov. 2003 paper
% This configuration is slower than the previous one, but it gives slightly better results (SNR)
% on average for the test images "lena", "barbara", and "boats" used in the cited article.

Nor = 8;				           % Number of orientations (for X-Y separable wavelets it can only be 3)
repres1 = 'fs';                    % Full Steerable Pyramid, 5 scales for 512x512
repres2 = '';                      % Dummy parameter when using repres1 = 'fs'   
parent = 1;             		   % including or not (1/0) in the neighborhood a coefficient from the same spatial location
                                   % and orientation as the central coefficient of the n x n neighborhood, but
                                   % next coarser scale. Many times helps, but not always.

% Call the denoising function
tic; im_d = denoi_BLS_GSM(im, sig, PS, blSize, parent, boundary, Nsc, Nor, covariance, optim, repres1, repres2, seed); toc
im_d(im_d < B) = B;
im_d = (im_d - B);

% Show the result
figure(1)
showIm(im, 'auto');title(['Raw image'])
figure(2)
showIm(im_d, 'auto');title(['Denoised Image'])
out = uint16(im_d);
imwrite(out, 'a-2.5-050-03gsm.tif','compression','none');
