%GENERATE_INIT_DATA generate initial data including I,B,N,Nd,K

clear

disp('loading...');
I = im2double(imread('images/sculpture.jpg'));
% I = im2double(imread('onion.png'));

disp('generating blurred and noisy images...');
[k, B, N] = generate_blurimg(I,5,63,0,0.0025);  % used for the example in report
% [k, B, N] = generate_blurimg(I,9,37,0,0.0025);

disp('denoising noisy image...');
Nd = denoise(N);

disp('saving data...')
imwrite(B, 'images/blurred.jpg');
imwrite(N, 'images/noisy.jpg');
imwrite(Nd, 'images/denoised.jpg');

save init_data

disp('done')