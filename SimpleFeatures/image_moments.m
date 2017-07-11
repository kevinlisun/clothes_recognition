function Feat = image_moments(Img, para)

s = para.s;

w = fix(size(Img,2)/para.s(2));
h = fix(size(Img,1)/para.s(1));

Img = imresize(Img, [h*para.s(1),w*para.s(2)]);

Feat = [];

for i = 1:s(1)
    for j = 1:s(2)
        img = Img((i-1)*h+1:i*h, (j-1)*w+1:j*w);
        % Moments
        n20 = central_moments(2,0, img);
        n02 = central_moments(0,2, img);
        n11 = central_moments(1,1, img);
        n30 = central_moments(3,0, img);
        n12 = central_moments(1,2, img);
        n21 = central_moments(2,1, img);
        n03 = central_moments(0,3, img);
        
        M1= n20 + n02;
        M2 = (n20 - n02)^2 + 4 * n11^2;
        M3 = (n30 - 3 * n12)^2 + (3 * n21 - n03)^2;
        M4 = (n30 + n12)^2 + (n21 + n03)^2;
        M5 = (n30 - 3 * n12) * (n30 + n12) * ((n30 + n12)^2 - 3 * (n21 + n03)^2) + (3 * n21 - n03) * (n21 + n03) * (3 * (n30+n12)^2 - (n21+n03)^2);
        M6=(n20 - n02) * ((n30+n12)^2 - (n21 + n03)^2) + 4 * n11 * (n30 + n12) * (n21 + n03);
        M7=(3 * n21 - n03) * (n30 + n12) * ((n30 + n12)^2 - 3 * (n21 + n03)^2) - (n30 + 3 * n12) * (n21 + n03) * (3 * (n30 + n12)^2 - (n21 + n03)^2);
        M8 = n11 * ((n30 + n12)^2 - (n03 + n21)^2) - (n20 - n02) * (n30 + n12) * (n03 + n21);
        
        % Feature Vector
        feat=[M1, M2, M3, M4,  M5, M6, M7, M8];
        Feat = [Feat feat];
    end
end