function [ I ] = deconv( Nd, B, K, mode, verbose )
%DECONVOLUTION Deconvolve B with K in given mode
%
%   Nd      - denoised image, only used  for resRL, gcRL and detailedRL, if u
%             use lucy or reg, simply passing [] is ok.
%   B       - blurred image
%   K       - blur kernel
%   mode    - deconvolution mode, can be 'reg', 'lucy', 'resRL', 'gcRL' and
%             'detailedRL'. The former two are matlab builtin algorithm, the
%             latter 3 are implemented according to the paper
%   verbose - display more information
%

if nargin < 5
    verbose = true;
end

if nargin < 4
    mode = 'lucy';
end

if verbose
    disp('Start deconvolution...');
end

niter = 20;
alpha = 0.2;    % alpha controls the influence of the gain map
winr  = 5;
sig_d = 1.6;
sig_r = 0.08;

I = zeros(size(Nd));

switch mode
    case 'reg'  % matlab builtin regularized filter
        I = deconvreg(B, K);
    case 'lucy' % matlab builtin Richardson-Lucy algorithm
        I = deconvlucy(B, K, niter);
    case 'resRL'% residual RL algorithm
        NdK = zeros(size(B), 'double');
        [~, ~, d] = size(B);
        for i = 1:d
            NdK(:,:,i) = fftconv2(Nd(:,:,i), K);
%             NdK(:,:,i) = conv2(Nd(:,:,i), K, 'same');
        end
        dB = B - NdK + 1;
        dI = deconvglucy(Nd, dB, K, niter, 0, verbose);
%         dI = deconvlucy(dB, K, niter, 0) - 1; % matlab builtin RL
        I = Nd + dI;
    case 'gcRL' % gain-controlled RL
        NdK = zeros(size(B), 'double');
        [~, ~, d] = size(B);
        for i = 1:d
            NdK(:,:,i) = fftconv2(Nd(:,:,i), K);%conv2(Nd(:,:,i), K, 'same');
        end
        dB = B - NdK + 1; % add 1 as offset
        dI = deconvglucy(Nd, dB, K, niter, alpha, verbose);
        I = Nd + dI;
    case 'detailedRL' % gain-controlled Rl with detail
        if verbose
            disp('Calculating residual-RL result Ir...');
        end
        Ir = deconv(Nd, B, K, 'resRL', true);%deconvlucy(B, K, niter);
        if verbose
            disp('Calculating gain-controlled RL result Ig...');
        end
        Ig = deconv(Nd, B, K, 'gcRL', true);
        if verbose
            disp('Calculating Ibar with joint/cross bilateral filtering...');
        end
        Ibar = zeros(size(Ir), 'double');
        [~, ~, d] = size(Ir);
        for i = 1:d
            % joint/cross bilateral filtering
            Ibar(:,:,i) = jbfilter2(Ir(:,:,i), Ig(:,:,i), winr, [sig_d, sig_r]);
        end
        
        Id = Ir - Ibar; % detail layer Id
        if verbose
            imwrite(Id+0.8, 'images/detail_layer.jpg');
        end
        I = Ig + Id;    % final result
    otherwise
        fprintf('Unimplemented deconvolution method: %s\n', mode);
end

% normalize the range of output image I
I = min(max(I, 0), 1);

if verbose
    disp('Deconvolution complete...');
end

    
end

