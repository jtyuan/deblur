function [ out ] = fftconv2(I, K)
%FFTCONV2 conv2 realised with FFT, boundary situation is considered

[h, w] = size(I);
[kh, ~] = size(K);

% expand I
rad = floor(kh * 0.5);
I = I([ones(1, rad), 1:h, h*ones(1, rad)], [ones(1, rad), 1:w, w*ones(1, rad)]);

% fft convolution
iFFT = fft2(I);
kFFT = psf2otf(K, size(I));
out = real(ifft2(iFFT.*kFFT));

% tailor a region of h*w as the result
out = out(rad + 1 : h + rad, rad + 1 : w + rad);

end
