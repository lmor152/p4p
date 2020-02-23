function [obj] = mapping_obj(Phi, refL, refR, newL, newR, IntrinsicMatrix, RotationMatrix, TranslationMatrix,  plane, V, centroid, xgrid, ygrid, xyrange, d)
%     texture optimisation objective
%     
%     Arguments:
%         Phi {matrix} -- control point grid
%         refL {matrix} -- Left image to project
%         refR {matrix} -- Right image to project
%         newL {matrix} -- left image to compare
%         newR {matrix} -- Right image to compare
%         IntrinsicMatrix {cell} -- Intrinsic camera parameters for cameras
%         RotationMatrix {cell} -- Extrinsic Rotation matrix for cameras
%         TranslationMatrix {cell} -- Camera Translations
%         plane {array} -- PCAP plane
%         V {matrix} -- PCA principle vectors
%         centroid {array} -- PCAP centroid
%         xgrid {array} -- x knot vector
%         ygrid {array} -- y knot vector
%         xyrange {array} -- min x and y of point cloud
%         d {int} -- degree of basis (2 or 3)
%
%     Returns:
%         float -- obj
% 
%     Author: Gary Qian
%     Contact: Gary.Qian1998@gmail.com

    % reshape control grid
    Phi = reshape(Phi, length(xgrid)+d-1, length(ygrid)+d-1);
    % project left image to model
    [world_coord,ntex] = BackWardProjection(refL, plane, V, centroid, IntrinsicMatrix{1}, [0,0,0], ...
    [0,0,0], xgrid, ygrid, xyrange, Phi, d);
    % project model back to other camera and evaluate similarity score
    ssR = ForwardProject(newR, RotationMatrix{2}, IntrinsicMatrix{1}, TranslationMatrix{2}, world_coord, ntex);
    % project right image to model
    [world_coord1,ntex1] = BackWardProjection(refR, plane, V, centroid, IntrinsicMatrix{2}, RotationMatrix{2}, ...
    TranslationMatrix{2}, xgrid, ygrid, xyrange, Phi, d);
    % project textured model to left camera
    ssL = ForwardProject(newL, [0,0,0], IntrinsicMatrix{2}, [0,0,0], world_coord1, ntex1);
    % take average similarity
    obj = (ssR + ssL);
end
