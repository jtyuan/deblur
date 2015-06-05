%RUN_DEMO run through this project. 
%   input image is set in `generate_init_data` file

generate_init_data
write_kernel(k, 'true');

verbose = true;

% matlab builtin regularized filter
[Ireg, K] = deblur( Nd, B, true, 'reg', verbose );
write_kernel(K, 'estimated');
imwrite(Ireg, 'images/deblurred_reg.jpg');

% call deconv directly since we already have K

% matlab builtin Richardson-Lucy
Ilucy = deconv(double(Nd), double(B), double(K), 'lucy', verbose);
imwrite(Ilucy, 'images/deblurred_lucy.jpg');

% residual RL algorithm
Ir = deconv(double(Nd), double(B), double(K), 'resRL', verbose);
imwrite(Ir, 'images/deblurred_residual_RL.jpg');

% gain-controlled RL
Ig = deconv(double(Nd), double(B), double(K), 'gcRL', verbose);
imwrite(Ig, 'images/deblurred_gain_controlled_RL.jpg');

% gain-controlled Rl with detail
% no need to call deconv again, because we already have Ir and Ig
% Idetailed = deconv(double(Nd), double(B), double(K), 'detailedRL', verbose);
disp('Calculating Ibar with joint/cross bilateral filtering...');
Ibar = zeros(size(Ir), 'double');
[~, ~, d] = size(Ir);
for i = 1:d
    % joint/cross bilateral filtering
    Ibar(:,:,i) = jbfilter2(Ir(:,:,i), Ig(:,:,i), 5, [1.6, 0.08]);
end
Id = Ir - Ibar; % detail layer Id
imwrite(Id+0.8, 'images/detail_layer.jpg');
Idetailed = Ig + Id;    % final result
imwrite(Idetailed, 'images/deblurred_detail_RL.jpg');


disp('ALL CLEAR.')