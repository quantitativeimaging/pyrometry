% test_Abel_transform
% Inverse Abel transforms a 2D (YZ) flame image to obtain cross section 
% of red and green luminance.
%
% Notes
% 1. Assumptions: 
%    - Orthographic (telecentric) image acquisition
%    - Flame is axisymmetric
%    - Flame centreline is vertical (add rotation if not)
%    - Flame centreline y-position can be user-defined
%    - The transform just uses one side of the flame image (it should be
%    mirror symmetric)
% 
% Instructions:
%
% 1. Run this script. 
% 2. Select file to process
% 3. Specify region for transform, including centreline position
%
% Questions to think about and check
% 1. What is the effect of smoothing the raw data?
% 2. Why not use both sides of the (symmetric) flame for better estimation
% 3. Why are some complex numbers produced (co-ordinate offset?)

% INPUT: Specify file to process
[filename, pathname] = uigetfile({'*.tif'},'Select input image',...
	'D:\EJR_OneDrive\OneDrive - University Of Cambridge\Projects\2017_2B_PYROMETRY\Sample_image_data\2017_10_13_sample\' );

imDat   = imread([pathname, filename]);
  figure(2)
  imshow(imDat)
imDatRed = double( imDat(:,:,1) );
imDatGrn = double( imDat(:,:,2) );
imDatBlu = double( imDat(:,:,3) );

% INPUT: Specify the location of the flame and centre line position
% Dimesions are pixel positions 
centre_position = 419; % In raw data before differentation
edge_position   = 560;
first_row       = 710;
last_row        = 740;
smoothing       = 5;
threshold_red   = 0.1; % To segment 'good' regions of bright-enough flame
threshold_grn   = 0.1;
rg_caxis_low    = 0;
rg_caxis_high   = 2.0;

% Prompt user to confirm parameters
prompt = {'Y (horizontal) position of centreline', ...
	        'Y (horizontal) position beyond flame edge', ...
					'first row to process', ...
					'last row to process', ...
					'amount of smoothing', ...
					'Red threshold', ...
					'Green threshold' ...
					'Red-green ratio scale (low)' ...
					'Red-green ratio scale (high)' };
dlg_title = 'Please confirm red threshold';
num_lines = 1;
defaultans = {num2str(centre_position),num2str(edge_position),...
	            num2str(first_row),num2str(last_row),...
							num2str(smoothing), ...
							num2str(threshold_red), num2str(threshold_grn ), ... 
							num2str(rg_caxis_low ), num2str(rg_caxis_high ) };
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);

centre_position = str2double( answer{1} );
edge_position   = str2double( answer{2} );
first_row       = str2double( answer{3} );
last_row        = str2double( answer{4} );
smoothing       = str2double( answer{5} );
threshold_red   = str2double( answer{6} );
threshold_grn   = str2double( answer{7} );
rg_caxis_low    = str2double( answer{8} );
rg_caxis_high   = str2double( answer{9} );

% Create empty images to store the result of the inverse Abel transform
imResultRed = zeros(last_row - first_row + 1, edge_position - centre_position +1);
imResultGrn = zeros(last_row - first_row + 1, edge_position - centre_position +1);


% 2. PROCESS IMAGE DATA ONE LINE AT A TIME
for lpZ = first_row:last_row

F_row_red = double( imDatRed(lpZ,:) );
F_row_grn = double( imDatGrn(lpZ,:) );
figure(11)
plot(F_row_red, 'r', 'lineWidth', 2)
hold on
  plot(F_row_grn, 'g', 'lineWidth', 2)
hold off
title('single row pixel values')
legend('red pixel value', 'green pixel value')
drawnow

F_row_red_smoothed = smooth(F_row_red, smoothing);
F_row_grn_smoothed = smooth(F_row_grn, smoothing);

diff_red = diff(F_row_red_smoothed);
diff_grn = diff(F_row_grn_smoothed);
%my_slope_smoothed = smooth(my_slope,25)
figure(12)
plot(diff_red ,'r')
hold on
  plot(diff_grn ,'g')
hold off
title('derivative of smoothed F row')

y_data   = 0:(edge_position - centre_position) + 0.5;
dF_by_dy_red = diff_red(centre_position:edge_position);
dF_by_dy_grn = diff_grn(centre_position:edge_position);

figure(13)
plot(y_data, dF_by_dy_red)

r_data = y_data;
f_r_red    = zeros(size(r_data));
f_r_grn    = zeros(size(r_data));

for lp = 1:length(r_data-1)
	f_r_red(lp) = (-1/pi)* sum(  dF_by_dy_red(lp+1:end)*1 ./ sqrt( (y_data(lp+1:end)).^2 - (r_data(lp)).^2 )' );
	f_r_grn(lp) = (-1/pi)* sum(  dF_by_dy_grn(lp+1:end)*1 ./ sqrt( (y_data(lp+1:end)).^2 - (r_data(lp)).^2 )' );
end

figure(14)
plot(r_data, f_r_red, 'r')
hold on
  plot(r_data, f_r_grn, 'g')
hold off
xlabel('r')
ylabel('f_r (brightness at radial value')
title('Flame brightness in red channel versus radius, one z-position')
set(gca, 'fontSize', 14)

imResultRed(lpZ-first_row + 1,:) = f_r_red;
imResultGrn(lpZ-first_row + 1,:) = f_r_grn;
end

% 3. OUTPUT
% Quantify and visualise the reconstructed image data
hi_value_red = max( max(real(imResultRed(:))) );
hi_value_grn = max( max(real(imResultGrn(:))) );
hi_value     = max( hi_value_red, hi_value_grn );

figure(15)
recon_red = zeros([size(imResultRed) ,3]);
recon_red(:,:,1) = real(imResultRed)./max(real(imResultRed(:)));
imagesc(recon_red)
title('Flame red luminance (radius, z)')
set(gca, 'fontSize', 14)
xlabel('radial position / pixels')
ylabel('Z-position / pixels')

figure(16)
recon_grn = zeros([size(imResultGrn) ,3]);
recon_grn(:,:,2) = real(imResultGrn)./max(real(imResultGrn(:)));
imagesc(recon_grn)
title('Flame green luminance (radius, z)')
set(gca, 'fontSize', 14)
xlabel('radial position / pixels')
ylabel('Z-position / pixels')

reconRGB = zeros([size(imResultRed) ,3]);
reconRGB(:,:,1) = real(imResultRed)/hi_value;
reconRGB(:,:,2) = real(imResultGrn)/hi_value;

recon_R = real(imResultRed); % Main problem for R-G ratio is masking...
recon_G = real(imResultGrn);
% recon_R(recon_R <= hi_value/20) = 1;
% recon_G(recon_G <= hi_value/20) = 1;
recon_RG_ratio = zeros(size(recon_R));
recon_Good = (recon_R > threshold_red * hi_value_red) & ...
	           (recon_G > threshold_grn * hi_value_grn);
recon_RG_ratio(recon_Good) = recon_R(recon_Good) ./ recon_G(recon_Good);

figure(17)
imagesc(reconRGB)
title('Red+green reconstruction of (radius, z)')
set(gca, 'fontSize', 14)
xlabel('radial position / pixels')
ylabel('Z-position / pixels')

figure(18)
imagesc(imDat(first_row:last_row, centre_position:edge_position, :))
title('Raw flame image (y, z)')
set(gca, 'fontSize', 14)
xlabel('y-position / pixels')
ylabel('Z-position / pixels')

figure(19)
imagesc(recon_RG_ratio)
title('Reconstructed red/green ratio (r, z), dark areas masked')
set(gca, 'fontSize', 14)
xlabel('radial position / pixels')
ylabel('Z-position / pixels')
colorbar
caxis([rg_caxis_low rg_caxis_high])
my_cmap = colormap();
axis equal
ylim([1 size(recon_RG_ratio,1)])

% Make a RGB (0-1, 0-1, 0-1 mode) color version for visualisation
% With the regions of low flame brightness set to black
recon_RG_ratio_ind = ceil(size(my_cmap,1)* ( recon_RG_ratio - rg_caxis_low)./ (rg_caxis_high-rg_caxis_low) );
recon_RG_ratio_ind(recon_RG_ratio_ind>size(my_cmap,1)) = size(my_cmap,1); % Truncate values above top of colormap
recon_RG_ratio_ind(recon_RG_ratio_ind<1) = 1; % Truncate low values. For doubles, 1 is the first colormap entry. 
recon_RG_ratio_rgb = ind2rgb(recon_RG_ratio_ind - rg_caxis_low, my_cmap);
for lp = 1:3
	myChannel = recon_RG_ratio_rgb(:,:,lp);
  myChannel(not(recon_Good) ) = 0;
	recon_RG_ratio_rgb(:,:,lp) = myChannel;
end

figure(20)
imagesc(recon_RG_ratio_rgb)
title('f_{red}(r,z) / f_{green}(r,z), dim regions = black')
set(gca, 'fontSize', 14)
xlabel('radius, r / pixels')
ylabel('height, z / pixels')
colorbar
caxis([rg_caxis_low rg_caxis_high])
axis equal
ylim([1 size(recon_RG_ratio_rgb,1)])

