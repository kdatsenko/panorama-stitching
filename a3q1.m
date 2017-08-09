function out = a3q1()

im = imread('shoe.jpg');
%im = rgb2gray(shoe_img_col);

%annotate_pts of 5-dollar-bill
imshow(im);
disp('click on the four corners of the bill. Double click the last point');
disp('upper-left start, go clockwise');
[x,y] = getpts();
close all;

%annotate_pts of shoe
imshow(im);
disp('click at least 3 points for height&width of shoe. Double click the last point');
disp('start at far right corner of shoe, annote 2 more points clockwise');
[shoe_x,shoe_y] = getpts();
close all;

% display the image and picked points
figure('position', [100,100,size(im,2)*0.3,size(im,1)*0.3]);
subplot('position', [0,0,1,1]);
imshow(im);
hold on;
plot([x(:); x(1)],[y(:); y(1)],'-o','linewidth',2,'color', [1,0.1,0.1], 'Markersize',10,'markeredgecolor',[0,0,0],'markerfacecolor',[0.5,0.0,1])
plot([shoe_x(:); shoe_x(1)],[shoe_y(:); shoe_y(1)],'-o','linewidth',2,'color', [1,0.1,0.1], 'Markersize',10,'markeredgecolor',[0,0,0],'markerfacecolor',[0.5,0.0,1])

h = 15.240;
w = 6.985;

x2 = [1, w, w, 1]';
y2 = [1, 1, h, h]';

%The U and X arguments are each 4-by-2 and define the corners 
%of input and output quadrilaterals.
%compute homography from homo-bill to real life bill
tform = maketform('projective',[x,y],[x2,y2]);

% warp the shoe points according to homography
[X, Y] = tformfwd(tform, shoe_x, shoe_y);

shoe_width = sqrt((X(3) - X(4))^2 + (Y(3) - Y(4))^2)
shoe_length = sqrt((X(2) - X(3))^2 + (Y(2) - Y(3))^2)


% Display the 5 dollar bill
% h = 15240;
% w = 6985;
% 
% x2 = [1, w, w, 1]';
% y2 = [1, 1, h, h]';
% [imrec] = imtransform(im, tform, 'bicubic',...
%     'xdata', [1,max(x2)],...
%     'ydata', [1,max(y2)],...
%     'size', [round(max(y2)), round(max(x2))],...
%     'fill', 0);
% figure('position', [150,150,size(imrec,2)*0.6,size(imrec,1)*0.6]);
% subplot('position', [0,0,1,1]);
% imshow(imrec)







