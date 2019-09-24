ptc = pcread('../Final/quadratic/pc_9.ply');
% ptc = pcread('Gary.ply');
[V, score] = pca(ptc.Location);
score = double(score);
eps = 1e-3;
centroid = [mean(ptc.Location(:,1)), mean(ptc.Location(:,2)), mean(ptc.Location(:,3))];
v1 = V(:,1);
v2 = V(:,2);
d = dot(centroid, V(:,3));
plane = [V(:,3); d];

points = zeros(size(score));
for i = 1:length(ptc.Location)
    [x, y, z] = pc_project(ptc.Location(i,:), V(:,1), V(:,2), V(:,3), centroid);
    points(i,:) = [x,y,z];
end

