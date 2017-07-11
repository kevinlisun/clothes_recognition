function plot_ellipsoid(mean, Cov, color)

[U, D] = eig(Cov);
A = U * sqrtm(D);
b = mean;

nTheta = 8;
nPhi = 8;

nSamples = nTheta * nPhi;
x = zeros(3, nSamples);

sample = 1;
for t = 1 : nTheta;
    for p = 1 : nPhi;
        theta = 2 * pi * (t / nTheta);
        phi = pi * ((p / nPhi) - 0.5);
        
        x(1,sample) = cos(phi) * cos(theta);
        x(2,sample) = cos(phi) * sin(theta);
        x(3,sample) = sin(phi);
        sample = sample + 1;
    end
end

y = A * x + b * ones(1, nSamples);

for sample = 1:nSamples
    y0(:,1) = y(:, sample);
    y1(:,1) = y(:, mod(sample,nSamples)+1);
    y2(:,1) = y(:, mod(sample+nPhi-1,nSamples)+1);
    
    l1 = [y0'; y1'];
    l2 = [y0'; y2'];
    
    if (mod(sample, nPhi) ~= 0)
        line(l1(:,1), l1(:,2), l1(:,3), 'color', color);
    end
    line(l2(:,1), l2(:,2), l2(:,3), 'color', color);
end
