function [world_coord] = toWorld(texpoints, centroid, V)
    world_coord = zeros(size(texpoints));
    for i = 1:length(texpoints)
        world_coord(i,:) = centroid + (V(:,1)*texpoints(i,1) + V(:,2)*texpoints(i,2) + V(:,3)*texpoints(i,3))';  
    end
end

