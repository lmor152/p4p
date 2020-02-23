function [dPhi] = field_jac(est, point, xgrid, ygrid, xyrange, Phi, d)
%     calculate field jacobian
%     
%     Arguments:
%         est {array} -- initial guess of (x',y')
%         point {array} -- data point (x,y,z)
%         xgrid {array} -- knots in the x direction
%         ygrid {array} -- knots in the y direction
%         xyrange {array} -- min x,y of point cloud
%         Phi {matrix} -- control lattice
%         d {int} -- Basis degree (2 or 3)
%     
%     Returns:
%         array - jacobian of control grid
%
%     Author: Gary Qian
%     Contact: Gary.Qian1998@gmail.com

    % reshape control grid
    Phi = reshape(Phi, length(xgrid)+d-1, length(ygrid)+d-1);
    % get min x,y
    minM = xyrange(1);
    minN = xyrange(2);
    % initialise derivative of control grid
    dPhi = zeros(size(Phi));
    
    % for each point in cloud
    for ind = 1:length(point)
        % evaluate min, max, and index of ensemble corresponding to each point
        [exmax, exmin, i] = find_gt(xgrid, est(ind,1) - minM);
        [eymax, eymin, j] = find_gt(ygrid, est(ind,2) - minN);
        % get local coordinates
        s = (est(ind,1) - minM - exmin)/ (exmax - exmin);
        t = (est(ind,2) - minN - eymin)/ (eymax - eymin);
        % evaluate z for each point
        z = evaluate_point(d, est(ind,1), est(ind,2), xgrid, ygrid, xyrange, Phi);
        % calculate e
        e = (point(ind, 3) - z);
        for k = 0:d
            for l = 0:d
                try
                    % evaluate derivative of control grid
                    dPhi(i+k, j+l) = dPhi(i+k, j+l) - 2 * W(d,k,l,s,t)*e;
                catch
                end 
            end
        end
    end
end

