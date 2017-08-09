function out = a3q3b(num_iters, num_trials_ransac)

%downsize by half
ref_img = rgb2gray(imresize(imread('mugShot.jpg'), 0.5));

shredded_col = cell(1, 6);
shredded_col{1} = imread('cut01.png');
shredded_col{2} = imread('cut02.png');
shredded_col{3} = imread('cut03.png');
shredded_col{4} = imread('cut04.png');
shredded_col{5} = imread('cut05.png');
shredded_col{6} = imread('cut06.png');

shredded = cell(1, 6); %get grayscale
for i=1:6
    shredded{i} = imresize(shredded_col{i}, 0.5);
end

min_SSD_score = Inf;
pic = 0;

for i=1:num_iters
    sample = randsample(6, 6);
    permuted_segments = cell(1, 6);
    for j=1:6
        permuted_segments{j} = shredded{sample(j)};    
    end
    permuted_img = rgb2gray(cat(2, permuted_segments{:}));
    %only get SSD score for the top 50 matched features
    [~, ~, SSD_score] = ransac_affine(ref_img, permuted_img, num_trials_ransac, 50);
    if min_SSD_score > SSD_score
        min_SSD_score = SSD_score;
        pic = permuted_img;
    end 
end

imshow(pic);

% %per 'pair' row: meanSSD, index i, index j
% adjacent_pairs = zeros(30, 4);
% count = 1;
% for i=1:6
%     for j=1:6
%         if i == j
%             continue; %don't compare images w/ themselves
%         end
%         adjacent_pairs(count, 3) = i;
%         adjacent_pairs(count, 4) = j;
%         img_pair = rgb2gray(cat(2, shredded{i}, shredded{j}));
%         [~, n, SSD_score] = ransac_affine(ref_img, img_pair, num_trials_ransac);
%         %SSD_score
%         adjacent_pairs(count, 1) = SSD_score/1000;
%         adjacent_pairs(count, 2) = n;
%         count = count + 1;
%     end
% end
% 
% sorted_pairs = sortrows(adjacent_pairs);
% sorted_pairs


























end