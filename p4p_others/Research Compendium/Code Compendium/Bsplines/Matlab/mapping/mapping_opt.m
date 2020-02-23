function [x,F] = mapping_opt(Phi, refL, refR, newL, newR, IntrinsicMatrix, RotationMatrix, TranslationMatrix,plane, V, centroid, xgrid, ygrid, xyrange, d, maxit)
%     optimisation using texture method
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
%         maxit {int} -- maximum interations for optimisation
% 
%     Returns:
%         float -- x
%         float -- y
% 
%     Author: Gary Qian
%     Contact: Gary.Qian1998@gmail.com

    % set optimisation options
    options = optimoptions('fminunc','Algorithm','quasi-newton', 'display', 'iter',...
     'MaxIterations', maxit);  
    % run texture optimisation
    [x,F] = fminunc(@(Phi)mapping_obj(Phi, refL, refR, newL, newR,...
                                  IntrinsicMatrix, RotationMatrix, TranslationMatrix,  ...
                                  plane, V, centroid, xgrid, ygrid, xyrange, d), ...
                                  Phi(:), options);
end

