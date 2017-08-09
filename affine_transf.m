% Solve for the affine transformation between features using top k correspondences
function out = affine_transf(f_im1, f_im2, ind1, ind2, ks)

% We assume we are using more than 3 keypoints, 
% so we will use the Moore-Penrose psudeo inverse a = (P^T*P)^-1 * P^T*P'

P = zeros(2*ks, 6);
P_prime = zeros(2*ks, 1);

for i = 1:ks
    P(2*(i-1) + 1, :) = [f_im1(1, ind1(i)), f_im1(2, ind1(i)), 0, 0, 1, 0];
    P(2*(i-1) + 2, :) = [0, 0, f_im1(1, ind1(i)), f_im1(2, ind1(i)), 0, 1];
    
    P_prime(2*(i-1) + 1) = f_im2(1, ind2(i));
    P_prime(2*(i-1) + 2) = f_im2(2, ind2(i));
end

%Only use matrix operators (*, ^T, ^-1 (i.e. inv() in matlab)
%Do not use pinv, fsolve, maketform, mrdivide, mldivide, 
%or the \ or / operators.

moore_penrose_inv = pinv(P);
out = moore_penrose_inv*P_prime;

end