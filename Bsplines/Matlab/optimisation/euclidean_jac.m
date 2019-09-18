function [dx,dy] = euclidean_jac(est,point, xgrid, ygrid, xyrange, Phi, d)
    z = evaluate_point(d, est(1), est(2), xgrid, ygrid, xyrange, Phi);
    [dfdx, dfdy] = spline_df(est(1), est(2), xgrid, ygrid, xyrange, Phi, d);
    dx = -2*(point(1) - est(1)) - 2*dfdx*(point(3) - z);
    dy = -2*(point(2) - est(2)) - 2*dfdy*(point(3) - z);
end

