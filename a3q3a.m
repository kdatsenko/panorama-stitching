function out = a3q3a(ref_im, im1, im2, num_trials, visualize)

if nargin<4
    num_trials = 5; %set a default number of trials
end;

if nargin<5
    visualize = 1; %yes, visualize the result
end;

% read images and grayscale
ref_img = rgb2gray(imread(ref_im));
img1_col = imread(im1);
affine1_img = rgb2gray(img1_col);
img2_col = imread(im2);
affine2_img = rgb2gray(img2_col);

% shredded_col = cell(1, 6);
% shredded_col{1} = imread('cut01.png');
% shredded_col{2} = imread('cut02.png');
% shredded_col{3} = imread('cut03.png');
% shredded_col{4} = imread('cut04.png');
% shredded_col{5} = imread('cut05.png');
% shredded_col{6} = imread('cut06.png');
% 
% sample = [1 5 2 3 4 6];%[2 4 3 6 1 5];%
%     permuted_segments = cell(1, 6);
%     for j=1:6
%         permuted_segments{j} = shredded_col{sample(j)};    
%     end
%     permuted_img = rgb2gray(cat(2, permuted_segments{:}));
%     
%imwrite(permuted_img, 'toy_couch.jpg');

%same number of trials for each
[affine_transf_1, ~, ssd1] = ransac_affine(ref_img, affine1_img, num_trials);
[affine_transf_2, ~, ssd2] = ransac_affine(ref_img, affine2_img, num_trials);

%minimal score is best (min mean SSD score)
if (ssd1 < ssd2)
    display_img = affine1_img;
    affine_transf = affine_transf_1;
else
    display_img = affine2_img;
    affine_transf = affine_transf_2;
end

if (visualize)
    %read the images in for visualization component
    [r, c, ~] = size(ref_img); %entire img will be mapped

    % fill in the rows of the P matrix where every 2 rows represent 
    % the x,y values of one of the four corners point of ref img
    P = [1, 1, 0, 0, 1, 0; ...%top-left 
        0, 0, 1, 1, 0, 1; ...  
        1, r, 0, 0, 1, 0; ...%bottom-left
        0, 0, 1, r, 0, 1; ...

        c, 1, 0, 0, 1, 0; ... %top-right
        0, 0, c, 1, 0, 1; ...
        c, r, 0, 0, 1, 0; ... %bottom-right
        0, 0, c, r, 0, 1;];

    points = P*affine_transf;

    % Plot lines for dvd
    imshow(display_img);
    hold on;
    line([points(1), points(3)],[points(2),points(4)],'Color','g', 'Linewidth', 2);
    line([points(5), points(7)],[points(6),points(8)],'Color','g', 'Linewidth', 2);
    line([points(1), points(5)],[points(2),points(6)],'Color','g', 'Linewidth', 2);
    line([points(3), points(7)],[points(4),points(8)],'Color','g', 'Linewidth', 2);
    hold off; 
         
end


end














