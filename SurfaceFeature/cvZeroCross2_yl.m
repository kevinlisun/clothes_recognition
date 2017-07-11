
function idx = cvZeroCross2_yl(I, thresh, direction)
% HOW TO FIND ZERO-CROSSING
% 
% See if there is a change in sign between the two opposite pixels on either
% side of the middle pixel. See in each of four directions. 
% If there is a change the point is set to 1. 
% If when neighbouring points are multiplied and its result is negative,
% then there must be a change in sign between these two points.
% If the change is also above the thereshold then set it as a zero crossing.
% 
% Let x,y be the coordinate in interest. 
% if (I(x-1,y) * I(x+1,y) < 0) { // if sign is different
%     if(abs(I(x-1,y)) + abs(I(x+1,y)) > thresh) {
%         zero crossing in horizontal direction
%     }
% } else if // vertical direction, and so on..
%
% Reference: http://homepages.inf.ed.ac.uk/rbf/HIPR2/zerocdemo.htm
% The above operations can be done smartly using 2D convolution. See codes. 
if ndims(I) >= 3
    error('The input must be a two dimensional array.');
end
if ~exist('thresh', 'var') || isempty(thresh)
    thresh = 0;
end
if ~exist('direction', 'var') || isempty(direction)
    % all directions
    idx = cvZeroCross2_yl(I, thresh, 'horizontal');
    idx = idx | cvZeroCross2_yl(I, thresh, 'vertical');
    idx = idx | cvZeroCross2_yl(I, thresh, '45');
    idx = idx | cvZeroCross2_yl(I, thresh, '135');
    return;
end


if strcmp(direction, 'horizontal')
    mask1 = [0  0  0;
            -1  0  1;
            0  0  0];
elseif strcmp(direction, 'vertical')
    mask1 = [0  -1  0;
            0  0  0 ;
            0  1  0];
elseif strcmp(direction, '135')
    mask1 = [-1  0 0;
            0  0 0;
            0  0 1];
elseif strcmp(direction, '45')
    mask1 = [0  0  1;
            0  0  0;
           -1  0  0];
end

% next pixel version
if strcmp(direction, 'horizontal')
    mask2 = [0  0  0;
            0  -1  1;
            0  0  0];
elseif strcmp(direction, 'vertical')
    mask2 = [0  0  0;
            0  -1  0 ;
            0  1  0];
elseif strcmp(direction, '135')
    mask2 = [0  0  0;
            0  -1 0;
            0  0  1];
elseif strcmp(direction, '45')
    mask2 = [0  0  0;
            0  -1  0;
            1  0  0];
end

%% check if there is a change in sign
s = sign(I);
t1 = conv2(s, mask1, 'same');
idx1 = (abs(t1) == 2);
t2=conv2(s, mask2, 'same');
idx2=(abs(t2) == 2);
idx=(abs(idx1+idx2)>0);
% To consider 0 for changes in sign, use (abs(t) > 0)

%% thresholding
if thresh > 0
     a1 = conv2(I, mask1, 'same');
    a2 = conv2(I, mask2, 'same');
    idx = idx & (abs(a1) > thresh);
    idx = idx & (abs(a2) > thresh);
end
 