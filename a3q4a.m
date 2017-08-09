function out = a3q4a(im1, im2, num_trials)

img1 = imread(im1);
img2 = imread(im2);

ransac_homography(img1, img2, num_trials, 100, 1);





















end