function [world_coord,ntex] = BackWardProjection(ref, plane, V, centroid, fx, R, T, xgrid, ygrid, xyrange, Phi, d)
%    project surface model to other camera 
%     
%     Arguments:
%         ref {matrix} -- image to project
%         plane {array} -- Rotation vector
%         V {matrix} -- PCAP principle vectors
%         centroid {array} -- Translation vector
%         fx {float} -- Focal length
%         R {array} -- Rotation vector
%         T {array} -- Translation vector
%         xgrid {array} -- knots in x direction
%         ygrid {array} -- knots in y direction
%         xyrange {array} -- min x, y
%         Phi {matrix} -- control grid
%         d {int} -- degree of basis (2 or 3)
%     
%     Returns:
%         world_coord -- points
%         ntex -- texture
%
%     Author: Gary Qian
%     Contact: Gary.Qian1998@gmail.com  

    % get rotaion matrix from vector
    rotationMatrix = rotationVectorToMatrix(R);
    % project image to PCAP
    [tex,points] = projection(ref, plane, V(:,1), V(:,2), centroid, ...
        fx(1,1),  fx(1,3), fx(2,3), fx(1,1)/ fx(2,2), rotationMatrix, T);
    % crop projection using control grid
    [texp, ntex] = first_crop(points, tex, xgrid, ygrid, xyrange);
    % convert origin to PCAP coordinate system
    origin = [dot(-T - centroid, V(:,1)), ...
            dot(-T - centroid, V(:,2)), ...
            dot(-T - centroid, V(:,3))];
    % project texture to model
    [texp] = texture_opt(Phi, texp, double(origin), texp, xgrid, ygrid, xyrange, d);
    % crop again
    %[texp, ntex] = second_crop(newX, ntex, xgrid, ygrid, xyrange);
    % evaluate z
    texZ = evaluate_pointvec(d,texp(:,1),texp(:,2),xgrid, ygrid, xyrange, Phi);
    texpoints = [texp, texZ];
    % convert to world coordinates
    [world_coord] = toWorld(texpoints, centroid, V);
    
end

