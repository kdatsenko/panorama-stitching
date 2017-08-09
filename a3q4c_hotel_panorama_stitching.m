function out = a3q4c(num_trials)

k = 100; %limit on top matches for homography (to reduce outliers)
images = cell(1, 8);

images{1} = imread('hotel-07.png');
images{2} = imread('hotel-06.png');
images{3} = imread('hotel-05.png');
images{4} = imread('hotel-04.png');
images{5} = imread('hotel-03.png'); %central image
images{6} = imread('hotel-02.png');
images{7} = imread('hotel-01.png');
images{8} = imread('hotel-00.png');

homographies = cell(1, 8);
for i=1:8
    homographies{i} = eye(3);
end

for i=1:4 % --> from left to right
    H = ransac_homography(images{i}, images{i+1}, num_trials, k);
    for j=1:i
        homographies{j} = H * homographies{j}; 
    end
end
for i=8:-1:6 % <--- from right to left
    H = ransac_homography(images{i}, images{i-1}, num_trials, k);
    for j=8:-1:i
        homographies{j} = H * homographies{j}; 
    end
end

% Compute the size of the output panorama image
min_row = Inf;
min_col = Inf;
max_row = -Inf;
max_col = -Inf;

img_origins = zeros(8, 2); %row, col
% for each input image
for i=2:8
    cur_image = images{i};
    [rows,cols] = size(cur_image);
    
    % create a matrix with the homogenous coordinates of the four 
    % corners of the current image
    pt_matrix = zeros(3, 4); %each column is a corner point
    pt_matrix(:, 1) = [1,1,1];
    pt_matrix(:, 2) = [cols,1,1];
    pt_matrix(:, 3) = [1,rows,1];
    pt_matrix(:, 4) = [cols,rows,1];
    result = homographies{i}*pt_matrix;
    result(1,:) = result(1,:) ./ result(3,:); %space coordinates
    result(2,:) = result(2,:) ./ result(3,:);
    
    % Map each of the 4 corner's coordinates into the coordinate system of
    % the reference image
    min_row_i = Inf;
    min_col_i = Inf;
    for j=1:4        
        corner_pt = result(1:2, j);
        min_row_i = floor(min(min_row_i, corner_pt(2))); %y
        min_col_i = floor(min(min_col_i, corner_pt(1))); %x
    
        min_row = floor(min(min_row, corner_pt(2)));
        min_col = floor(min(min_col, corner_pt(1)));
        max_row = ceil(max(max_row, corner_pt(2)));
        max_col = ceil(max(max_col, corner_pt(1))); 
    end
    img_origins(i, :) = [min_row_i, min_col_i];
end

% Calculate output image size
panorama_height = max_row - min_row + 1;
panorama_width = max_col - min_col + 1;

% Initialize output image to black (0)
eps = 10; %resize in case of slight difference with imwarp
panorama_image = zeros(panorama_height + eps, panorama_width + eps);
for i=2:8 %plot each img
    clipped_warp = imwarp(images{i}, projective2d(homographies{i}'));
    r1 = img_origins(i, 1) - min_row + 1;
    c1 = img_origins(i, 2) - min_col + 1;
    r2 = r1 + size(clipped_warp, 1) - 1;
    c2 = c1 + size(clipped_warp, 2) - 1;
    warped_image = zeros(panorama_height + eps, panorama_width + eps);
    warped_image(r1:r2, c1:c2) = double(clipped_warp);
    overlap_fix = zeros(size(warped_image));
    overlap_fix(warped_image == 0) = 1;
    panorama_image = panorama_image .* overlap_fix;
    panorama_image = panorama_image + warped_image;
end

imshow(uint8(panorama_image));

