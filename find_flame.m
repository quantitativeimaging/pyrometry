% Script to identify flame location

[filename, pathname] = uigetfile({'*.tif'},'Select input image',...
	'D:\EJR_OneDrive\OneDrive - University Of Cambridge\Projects\2017_2B_PYROMETRY\Sample_image_data\2017_10_13_sample\' );

imDat   = imread([pathname, filename]);

figure(2)
imshow(imDat)

imDatRed = imDat(:,:,1);
imDatGrn = imDat(:,:,2);
imDatBlu = imDat(:,:,3);

red_min = min(imDatRed(:));
red_max = max(imDatRed(:));

prompt = {'max_red val', 'min_red_val', 'red threshold'};
dlg_title = 'Please confirm red threshold';
num_lines = 1;
defaultans = {num2str(red_max),num2str(red_min),'60'};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);

red_threshold = str2num( answer{3} );

imThresholdedRed = imDatRed > red_threshold;

figure(3)
imagesc(imThresholdedRed)


%%%

imRatioRG = zeros(size(imDatRed));
imRatioRG = double(imDatRed)./double(imDatGrn);
imRatioRG( imThresholdedRed==0 ) = 0;

figure(4)
imagesc(imRatioRG)
colorbar
title('ratio of red:green pixel value')