function [d2, jac, hess] = texture_obj(est, origin, impoint, xgrid, ygrid, xyrange, Phi, d)
    z = evaluate_point(d, est(1), est(2), xgrid, ygrid, xyrange, Phi);
    normv1 = (est(1)-impoint(1))^2 +  (est(2)-impoint(2))^2 + z^2;
    num = ((origin(1) - impoint(1))*(est(1) - impoint(1)) + (origin(2) - impoint(2))*(est(2) - impoint(2)) + origin(3)*z)^2;
    denom = (origin(1) - impoint(1))^2 + (origin(2) - impoint(2))^2 + origin(3)^2;
    d2 = normv1 - num/denom;
    if nargout > 1
        [dx, dy] = texture_jac(est, origin, impoint, xgrid, ygrid, xyrange, Phi, d);
        jac = [dx, dy];
    end
    if nargout > 2
        hess = texture_hess(est, origin, impoint, xgrid, ygrid, xyrange, Phi, d);
    end
end

