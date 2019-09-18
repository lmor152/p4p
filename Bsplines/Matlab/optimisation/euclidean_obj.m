function [obj, jac] = euclidean_obj(est, point, xgrid, ygrid, xyrange, Phi, d)
    z = evaluate_point(d, est(1), est(2), xgrid, ygrid, xyrange, Phi);
    obj = (point(1) - est(1))^2 + (point(2) - est(2))^2 + (point(3) - z)^2;
    if nargout > 1
        [jacx, jacy] = euclidean_jac(est, point, xgrid, ygrid, xyrange, Phi, d); 
        jac = [jacx, jacy];
    end
end
