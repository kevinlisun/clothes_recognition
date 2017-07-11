function plot_gmm(Prior, Mean, Cov, color)

% number of GMM components
k = size(Mean, 2);

% plot 3D ellipse for each component
for i = 1:k
    color_i = Prior(i)^0.2 * color;
    plot_ellipsoid(Mean(:,i), Cov(:,:,i), color_i);
end

end
