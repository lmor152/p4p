function [newX] = texture_opt(Phi, est, origin, impoint, xgrid, ygrid, xyrange, d)
%     Projection optimisation
%     
%     Arguments:
%         Phi {matrix} -- control lattice (model parameters) 
%         est {array} -- initial guess of (x',y')
%         origin {array} -- transformed origin
%         impoint {array} -- (x, y)
%         xgrid {array} -- knots in the x direction
%         ygrid {array} -- knots in the y direction
%         xyrange {array} -- min x and y of point cloud
%         d {[2,3]} -- degree of basis (2 or 3)
% 
%     Returns:
%         float -- evaluate basis at the local coordinates using the kth basis
% 
%     Author: Gary Qian
%     Contact: Gary.Qian1998@gmail.com

    % initialise
    newX = zeros(size(est(:,1:2)));
    errors = zeros(length(est),1);
    
    % set option
    options = optimoptions('fminunc','Algorithm','trust-region', 'SpecifyObjectiveGradient', true, 'display', 'off');
    % parallel for each pixel projection
    parfor i = 1:length(est)
        % run optimisation
        [x,F] = fminunc(@(x)texture_obj(x, origin, impoint(i,:), xgrid, ygrid, xyrange, Phi, d), est(i,:), options);
        newX(i,:) = x;
        errors(i) = F;
    end
end

