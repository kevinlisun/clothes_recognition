function [errDists, errAngles] = compute_match_error(model, dataSample)

% load ground-truth vertices and make them going counter-clockwise
gtVerts = dataSample.verts;
if ~poly_pos_orient(gtVerts)
    gtVerts = gtVerts(:,model.VertSymmetry);
end

% load fitted vertices
pts = dataSample.simplePts;
fitVerts = pts(:,dataSample.fitVertInd);

% handle model symmetries
if numel(model.ModelSymmetry > 0)
    errStd = sum(sum((fitVerts - gtVerts).^2));
    errSym = sum(sum((fitVerts - gtVerts(:,model.ModelSymmetry)).^2));
    if errSym < errStd
        gtVerts = gtVerts(:,model.ModelSymmetry);
    end
end

% directions and distances of errors
errDirs = fitVerts - gtVerts;
errDists = sqrt(sum((errDirs).^2, 1));

gtVertsExt = [gtVerts(:,end), gtVerts, gtVerts(:,1)];
errAngles = zeros(1, model.NumVerts);

% compute relative angles of errors
for i = 1:model.NumVerts
    % direction of vertex corner and direction of error displacement
    vertDir = 2 * gtVertsExt(:,i+1) - gtVertsExt(:,i+2) - gtVertsExt(:,i);
    errDir = errDirs(:,i);
    
    % compute oriented angle in [-pi, +pi]
    errAngles(i) = oriented_angle(vertDir, errDir);
end

end
