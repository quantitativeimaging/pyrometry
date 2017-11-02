% Script to evaluate image scale, with user input

[filename, pathname] = uigetfile({'*.tif'},'Select input image',...
	'D:\EJR_OneDrive\OneDrive - University Of Cambridge\Projects\2017_2B_PYROMETRY\Sample_image_data\2017_10_13_sample\' );

imDat   = imread([pathname, filename]);

figure(1)
imshow(imDat)

myRectangle = getrect;

xmin = myRectangle(1);
ymin = myRectangle(2);
width = myRectangle(3);
height = myRectangle(4);

figure(1)
hold on
  scatter(xmin, ymin, 'rx')
	scatter(xmin, ymin+height, 'bo')
	scatter(xmin+width, ymin, 'y+')
hold off

prompt = {'xmin (pixels)','ymin (pixels)','width (pixels)','height (pixels)','width (mm)','height (mm)'};
dlg_title = 'Please confirm rectangle size';
num_lines = 1;
defaultans = {num2str(xmin),num2str(ymin),num2str(width),num2str(height),'0','0'};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);

xmin_user   = str2num(answer{1});
ymin_user   = str2num(answer{2});
width_user  = str2num(answer{3});
height_user = str2num(answer{4});
width_mm    = str2num(answer{5});
height_mm   = str2num(answer{6});

% Calculate pixels_per_mm_vert, and pixels_per_mm_horz
pixels_per_mm_horz = width_user / width_mm
pixels_per_mm_vert = height_user / height_mm

