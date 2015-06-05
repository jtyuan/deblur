function [ k ] = random_kernel( kh, kw )
%RANDOM_KERNEL Generate a random kernel

k = rand(kh, kw);

% normalize the kernel
k = k/sum(k(:));

end

