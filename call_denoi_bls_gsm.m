function [ out ] = call_denoi_bls_gsm( I, Nx, Ny, sig )
%CALL_DENOI_BLS_GSM A wrapper function to call bls_gsm denoise algorithm
%   
%   I       - input noisy image
%   Nx/Ny   - size of I
%   sig     - standard deviation

% Noise power spectral density
PS = ones(size(I));	% flat, i.e., white noise
seed = 0;               % random seed, not used

% Pyramidal representation parameters
Nsc = ceil(log2(min(Ny,Nx)) - 4);  % Number of scales (adapted to the image size)
% Nor = 3;				           % Number of orientations (for X-Y separable wavelets it can only be 3)
% repres1 = 'uw';                  % Type of pyramid (shift-invariant version of an orthogonal wavelet, in this case)
% repres2 = 'daub1';               % Type of wavelet (daubechies wavelet, order 2N, for 'daubN'; in this case, 'Haar')

% Model parameters (optimized: do not change them unless you are an advanced user with a deep understanding of the theory)
%blSize = [5 5]; 	% n x n coefficient neighborhood of spatial neighbors within the same subband
blSize = [3 3];	    % n x n coefficient neighborhood of spatial neighbors within the same subband
                    % (n must be odd): 
% parent = 0;
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
%                                    % and orientation as the central coefficient of the n x n neighborhood, but
%                                    % next coarser scale. Many times helps, but not always.
%tic;
out = denoi_BLS_GSM(I, sig, PS, blSize, parent, boundary, Nsc, Nor, covariance, optim, repres1, repres2, seed); 
%toc;
% im_d(im_d < B) = B;
% im_d = (im_d - B);

% Show the result
% figure(1)
% showIm(im, 'auto');title(['Raw image'])
% figure(2)
% showIm(im_d, 'auto');title(['Denoised Image'])
% imwrite(out, 'a-2.5-050-03gsm.tif','compression','none');
% size(out)
end

