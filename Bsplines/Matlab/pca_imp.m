z = [phi1(:), phi2(:), phi3(:), phi4(:), phi5(:)].';
centroid = repmat(mean(z),1,numel(phi1));
[V, score] = pca(z);

newscore = score + centroid;

newphi1 = reshape(V(:,1), size(phi1));

[X, Y] = meshgrid(ceil(min(pp(:,1))):floor(max(pp(:,1))), ...
    ceil(min(pp(:,2))):floor(max(pp(:,2))));

figure
Z = evaluateSurface(d,X,Y,xgrid, ygrid, xyrange, newphi1);
s = surf(X,Y,Z);
daspect([1 1 1])