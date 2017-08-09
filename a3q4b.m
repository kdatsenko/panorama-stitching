function out = a3q4b(num_trials)

k = 100; %limit on top matches for homography
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

figure
for i=1:8 %plot each img
    [x, y] = meshgrid(1:size(images{i},2), 1:size(images{i},1));
    % Reshare row and column coordinates to a flat list
    x = reshape(x,1,[]);
    y = reshape(y,1,[]);
    %homogenous untranformed coords
    untransf_img_coords(1,:) = x;
    untransf_img_coords(2,:) = y;
    untransf_img_coords(3,:) = ones(1,size(x,2));
    pan_img_homo = homographies{i} * untransf_img_coords;
    pan_x(1,:) = pan_img_homo(1,:) ./ pan_img_homo(3,:);
    pan_y(2,:) = pan_img_homo(2,:) ./ pan_img_homo(3,:);
    plot(pan_x, pan_y);
    hold on;
end



