%TEST_DENOISE test denoising algorithm

I = im2double(imread('images/sculpture.jpg'));
[k, B, N] = generate_blurimg(I);
Nd = denoise(N(:,:,1));