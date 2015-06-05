function [ A, DV, B ] = denoise_preprocess( N )
%DENOISE_PREPROCESS Preprocess noisy image N to calculate denoising parameters A, DV, B
%
%   N - noisy image
%


% gamma = [6, 5, 4, 3, 2, 1, 0.7, 0.5, 0.3, 0.1];

Avg = zeros(1,10,'double');
Std = zeros(1,10,'double');
Var = zeros(1,10,'double');

% generate serveral images that has different brightness with the original
% one
for i = 0:9
%     Ihsv = rgb2hsv(N);
%     Ihsv(:,:,3) = Ihsv(:,:,3) * gamma(i);
%     Irgb = hsv2rgb(Ihsv);
% %     imwrite(Irgb, ['tmp/',num2str(i),'.jpg']);
%     std2(Irgb)
%     Irgb = imread(['tmp/',num2str(i),'.jpg']);
%     max(max(Irgb))
%     Avg(i+1) = mean2(Irgb);
%     Std(i+1) = std2(double(Irgb));
%     Var(i+1) = Std(i+1)^2;
%     imwrite(I, ['tmp/',num2str(i),'.jpg']);
%     I = imadjust(N, [], [], gamma(i+1));


    % after several attempts, linear is best
    I = double(N) * (i*0.2 + 0.1);

    Avg(i+1) = mean2(I);
    Std(i+1) = std2(I);
    Var(i+1) = Std(i+1)^2;
end

% Yint seems to be something else if directly write the following line
% [slope, Yint] = polyfit(Avg,Var,1); 

result = polyfit(Avg,Var,1);

slope = result(1);
Yint = result(2);

A = slope;
DV = Var(1);
B = (DV - Yint) / A;

end