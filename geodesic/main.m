clear all
close all
warning off
clc

path(path, 'toolbox_fast_marching/');
path(path, 'toolbox_fast_marching/toolbox/');
path(path, 'toolbox_graph/');
path(path, 'toolbox_graph/off/');
path(path, 'meshes/');
path(path, 'toolbox_wavelet_meshes/');

% % load('/home/kevin/Desktop/reconstruction_tools_kevin/data/point_cloud_1_0.mat');
% % pcl = X3D(:,1:100:end);
% % pcl = pcl';
% % mesh = pointCloud2rawMesh(pcl);
% % 
% % vertex = mesh.vertices';
% % faces = mesh.triangles';

% read the 3D mesh
name = 'off/bunny'; % other choices includes 'skull' or 'bunny'
[vertex,faces] = read_mesh([name '.off']);



% % nsub = 1; % number of subdivision steps
% % options.sub_type = 'loop';
% % options.verb = 0;
% % [vertex,faces] = perform_mesh_subdivision(vertex0,faces0,nsub,options);

% select random sta功功rting points for the propagation
nverts = max(size(vertex)); % number of vertices
nstart = 1; % number of starting points
start_points = floor(rand(nstart,1)*nverts)+1;

% perform the front propagation, Q contains an approximate segementation
[D,S,Q] = perform_fast_marching_mesh(vertex, faces, start_points);

% display the result using the distance function
options.start_points = start_points;
plot_fast_marching_mesh(vertex,faces, D, [], options);

% extract precisely the voronoi regions, and display it
[Qexact,DQ, voronoi_edges] = compute_voronoi_mesh(vertex,faces, start_points, options);
options.voronoi_edges = voronoi_edges;
plot_fast_marching_mesh(vertex,faces, D, [], options);


% in order to extract a smooth path, one needs to use a gradient descent
nend = 1;
x = floor(rand(nend,1)*nverts)+1; % select random ending points for the geodesics
options.method = 'continuous';
paths = compute_geodesic_mesh(D, vertex, faces, x, options); 
plot_fast_marching_mesh(vertex,faces, Q, paths, options); 