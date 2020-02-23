function [world_coord] = toWorld(texpoints, centroid, V)
%     get world coordinates 
%     
%     Arguments:
%         texpoints {matrix} -- projected points
%         centroid {array} -- PCAP centroid
%         V {matrix} -- principle vectors
% 
%     Returns:
%         matrix -- texpoints in world coordinates
% 
%     Author: Gary Qian
%     Contact: Gary.Qian1998@gmail.com

    % initialise array
    world_coord = zeros(size(texpoints));
    % for every projected point
    for i = 1:length(texpoints)
        % convert to world coordinates 
        world_coord(i,:) = centroid + (V(:,1)*texpoints(i,1) + V(:,2)*texpoints(i,2) + V(:,3)*texpoints(i,3))';  
    end
end

