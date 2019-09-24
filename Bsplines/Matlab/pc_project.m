function [x, y, z] = pc_project(world, v1, v2, v3, centroid)
x = dot(world - centroid, v1);
y = dot(world - centroid, v2);
z = dot(world - centroid, v3);
end
