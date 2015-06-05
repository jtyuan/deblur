function write_kernel( K, title )
%WRITE_KERNEL write kernel K in to an image file
%   Detailed explanation goes here

% change the range of K to make it visible to human eyes
K = K/max(K(:));

% and make it 10 times larger
K = imresize(K, 10, 'nearest');

% write the kernel to the disk
imwrite(K, ['images/kernel_', title, '.jpg']);

end

