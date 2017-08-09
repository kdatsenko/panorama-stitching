function [affine_with_inliers, highest_num_inliers, mean_SSD] = ...
    ransac_affine(ref_im, test_im, num_trials, k, visualize)

if nargin<4
    k = 100; %plot keypoint transform
end;

if nargin<5
    visualize = 0; %plot keypoint transform
end;

ref_img = single(ref_im);
test_img = single(test_im);
%compute the SIFT frames (keypoints) and descriptors
[f_ref,d_ref] = vl_sift(ref_img) ;
[f_test,d_test] = vl_sift(test_img) ;

[matches, scores] = vl_ubcmatch(d_ref, d_test, 1.5);

num_matches = size(matches, 2);
matches_joined = zeros(num_matches, 3);
matches_joined(:, 1) = scores';
matches_joined(:, 2:3) = matches';
scored_matches = sortrows(matches_joined);
matches_ref = scored_matches(:, 2);
matches_test = scored_matches(:, 3);

%[matches_ref, matches_test, num_matches] = a3_match_k(d_ref, d_test);

num_matches = size(matches, 2);
%top k matches
if num_matches > k
    num_matches = k; %limit on top matches
end

sample_size = 4;
threshold = 3;
highest_num_inliers = 0; %size of largest set of inliers
affine_with_inliers = 0;
best_inlier_set = 0;
mean_SSD = Inf;

if (num_matches < sample_size) %cannot do an affine, exit
    return;
end

for i=1:num_trials %set as input to the RANSAC algo.
    sample = randsample(num_matches, sample_size);
    
    %compute affine transf, get transf matrix
    sr = matches_ref(sample);
    st = matches_test(sample);
    affine_vect = affine_transf(f_ref, f_test, sr, st, sample_size);
    
    num_inliers = 0;
    inlier_set = zeros(1, num_matches);
    for j=1:num_matches
        %The matrix f has a column for each keypoint. 
        %A keypoint has center f(1:2)
        orig_point = f_ref(1:2, matches_ref(j));
        x = orig_point(1);
        y = orig_point(2);
        P_ref = [x, y, 0, 0, 1, 0; ...
                 0, 0, x, y, 0, 1;];
        Pt = P_ref*affine_vect; %compute transformed x', y'
        squared_diff = (Pt(1) - f_test(1, matches_test(j)))^2 + ...
                        (Pt(2) - f_test(2, matches_test(j)))^2;
        dist = sqrt(squared_diff);
        if (dist <= threshold)
            num_inliers = num_inliers + 1;
            inlier_set(num_inliers) = j;
        end
    end

    if highest_num_inliers < num_inliers
        highest_num_inliers = num_inliers;
        best_inlier_set = inlier_set(1:num_inliers);
    end 
end

if highest_num_inliers < 3
    return
end

%refit affine to best_inlier_set (outliers removed)
affine_with_inliers = affine_transf(f_ref, f_test, ...
                                    matches_ref(best_inlier_set), ...
                                    matches_test(best_inlier_set), ...
                                    highest_num_inliers);                         
%calculate mean SSD with refitted affine transformation                                
SSD = 0;                                
for j=1:num_matches
    orig_point = f_ref(1:2, matches_ref(j));
    x = orig_point(1);
    y = orig_point(2);
    P_ref = [x, y, 0, 0, 1, 0; ...
        0, 0, x, y, 0, 1;];
    Pt = P_ref*affine_with_inliers; %compute transformed x', y'
    squared_diff = (Pt(1) - f_test(1, matches_test(j)))^2 + ...
                   (Pt(2) - f_test(2, matches_test(j)))^2;
    SSD = SSD + sqrt(squared_diff); 
end   
mean_SSD = SSD / num_matches;

% SSD
% highest_num_inliers
%mean_SSD
%affine_with_inliers

if (visualize)
    colours = zeros(num_matches, 3);
    for c = 1:num_matches
        colours(c, :) = rand(1, 3);
    end
    % Plot images
    figure;
    imshow(test_im);
    for i=1:num_matches
        orig_point = f_ref(1:2, matches_ref(i));
        x = orig_point(1);
        y = orig_point(2);
        P_ref = [x, y, 0, 0, 1, 0; ...%top-left
            0, 0, x, y, 0, 1;];
        %compute transformed x', y'
        Pt = P_ref*affine_with_inliers;
        %Pt
        k = f_test(:, matches_test(i) );
        k(1:2) = Pt;
        h2 = vl_plotframe(k);
        set(h2,'color',colours(i, :),'linewidth',6) ;
        %h1 = vl_plotframe(f_ref(:, matches_ref(i) ));
        %set(h1,'color',colours(i, :),'linewidth',3) ;
    end
    %     figure;
    %     imshow(ref_im);
    %     for i=1:num_matches
    %
    %         h3 = vl_plotframe(f_ref(:, matches_ref(i) ));
    %         set(h3,'color',colours(i, :),'linewidth',6) ;
    %         %h1 = vl_plotframe(f_ref(:, matches_ref(i) ));
    %         %set(h1,'color',colours(i, :),'linewidth',3) ;
    %     end
    
    figure;
    imshow(test_im);
    for i=1:num_matches
        h1 = vl_plotframe(f_test(:, matches_test(i) ));
        %f_test(1:2, matches_test(i) )
        set(h1,'color',colours(i, :),'linewidth',6) ;
    end
    
end

end