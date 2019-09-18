function [x, y] = getLocal(world, v1, v2, centroid)
x = dot(world - centroid, v1);
y = dot(world - centroid, v2);
end
