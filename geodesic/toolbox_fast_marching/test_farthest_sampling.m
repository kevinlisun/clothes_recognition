% test for farthest point sampling

n = 400;

name = 'bump';
name = 'map';
name = 'stephanodiscusniagarae';
name = 'cavern';
name = 'gaussian';
name = 'road2';
name = 'binary';
name = 'constant';
name = 'mountain';

rep = ['results/farthest-sampling/' name '/'];
if exist(rep)~=7
    mkdir(rep);
end

[M,W] = load_potential_map(name, n);


if strcmp(name, 'binary')
    W = rescale(W,0.5,1); M = W;
    M(1) = min(M(:))-.3; M(2) = max(M(:))+.3;
end

warning off;
imwrite(rescale(M), [rep 'name-metric.png'], 'png');
warning on;

k = 40;
W1 = W;
W1 = perform_image_extension(W,n+2*k, '2side');

% plot sampling location
ms = 20; lw = 3;
i = 0;
for nbr_landmarks = [1 2 3 4 5 10 20 40 100 300]
    i = i+1;
    disp('Perform farthest point sampling');
    landmark = [1;1];
    landmark = farthest_point_sampling( W, landmark, nbr_landmarks-1 );
    
    % compute the associated triangulation
    landmark1 = landmark;
    landmark1 = landmark+k;
    [D,Z,Q] = perform_fast_marching_2d(W1, landmark1);
    D = D(k+1:n+k,k+1:n+k);
    faces = compute_voronoi_triangulation(Q,landmark);
    edges = compute_edges(faces');
    
    sel = randperm(nbr_landmarks);
    Q = Q(k+1:n+k,k+1:n+k);
    Q = sel(Q);
    clf; 
    hold on;
    imageplot(Q'); 
    plot(landmark(1,:), landmark(2,:), 'r.', 'MarkerSize', ms);
    colormap jet(256);
    hold off;
    saveas(gcf, [rep name '-voronoi-' num2string_fixeddigit(nbr_landmarks,3) '.png'], 'png');
    
    % display sampling + distance
    D = perform_histogram_equalization(D,linspace(0,1,n^2));   
    clf;
    hold on;
    imageplot(D');
    plot(landmark(1,:), landmark(2,:), 'r.', 'MarkerSize', ms);
    hold off;
    colormap jet(256);
    saveas(gcf, [rep name '-sampling-' num2string_fixeddigit(nbr_landmarks,3) '.png'], 'png');
    
    % display triangulation
    clf;
    hold on;
    imageplot(M');
    if not(isempty(edges))
        h = plot_edges(edges, landmark, 'b');
        set(h, 'LineWidth',lw);
    end
    plot(landmark(1,:), landmark(2,:), 'r.', 'MarkerSize', ms);
    hold off;
    axis tight; axis image; axis off;
    colormap gray(256);
    saveas(gcf, [rep name '-triangulation-' num2string_fixeddigit(nbr_landmarks,3) '.png'], 'png');
end