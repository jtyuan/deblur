%--------------------------------------------------------------------------
% Son Hua, NUS
% 2010-05-25
%
% Special matrix representating an image that provides fast convolution
% operation via the mtimes operator *
% 
% This class is used for kernel estimation only.
% Kernel estimation equation: I \corr I \conv K = I \corr B
%
%                                   Modified by Tianyuan Jiang 2015-06-02
%--------------------------------------------------------------------------
classdef MatrixConvolve < handle
    properties
        I = [];
        sizeK = 0;
        transpose = 0;
    end
    
    methods
        function obj = MatrixConvolve(I, sizeK)
            obj.I = I;            
            obj.sizeK = sizeK;
        end
        
        function r = ctranspose(obj)
            r = MatrixConvolve(obj.I, obj.sizeK);
            r.transpose = xor(obj.transpose, 1);
        end
        
        function r = mtimes(M, k)
            % M is a MatrixConvolve object
            [h, w] = size(M.I);
            
            % perform convolution between I and K
            if M.transpose == 0
                kh = floor(sqrt(size(k, 1)));
                kw = kh;
                kernel = reshape(k, [kh kw]);
                
                rad = floor(kh * 0.5);
                exI = expand_image_zero(M.I, rad);
                imgFFT = fft2(exI);
                kerFFT = psf2otf(kernel, size(exI));
                exout = real(ifft2(imgFFT.*kerFFT));
                
                out = exout(rad + 1 : h + rad, rad + 1 : w + rad);   
                r = reshape(out, [h*w 1]);
            else
                % the input for A' has the same size as I
                kh = M.sizeK;
                kw = kh;
                kernel = reshape(k, [h w]);
                %
                % Correct correlation formula for kernel estimation: 
                % I \corr K
                % Note that for image deconvolution, the correlation is K \corr I.
                %
                J = rot90(M.I,2);
                fI = fft2(J);
                fK = psf2otf(kernel, size(J));
                out = real(ifft2(fI .* fK));
                
                %imshow(out, []); drawnow;                
                % crop the center part            
                r_start = ceil((h - kh + 1) / 2); % the center patch corresponds to kernel update part
                c_start = ceil((w - kw + 1) / 2);
                r_end = r_start + kh - 1;
                c_end = c_start + kw - 1;
                out = out(r_start : r_end, c_start : c_end);

                r = reshape(out, [kh^2 1]);

            end
        end
    end
end

% expand a image with a specified radius
function expanded_img = expand_image_zero(img, rad)
    [h, w, d] = size(img);
    h_ex = h + 2*rad;
    w_ex = w + 2*rad;

    expanded_img = zeros(h_ex, w_ex, d);
    expanded_img(rad + 1 : h + rad, rad + 1 : w + rad, :) = img(:, :, :);
end