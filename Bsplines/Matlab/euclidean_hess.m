function [hessian] = euclidean_hess(est,point, xgrid, ygrid, xyrange, Phi, d)
    z = evaluate_point(d, est(1), est(2), xgrid, ygrid, xyrange, Phi);
    [dfdx, dfdy] = spline_df(est(1), est(2), xgrid, ygrid, xyrange, Phi, d);
    [hess] = spline_ddf(est(1), est(2), xgrid, ygrid, xyrange, Phi, d);
    
    ddx2 = -2 * hess(1,1)*(point(3) - z) + 2*dfdx^2 + 2;
    ddy2 = -2 * hess(2,2)*(point(3) - z) + 2*dfdy^2 + 2;
    ddxy = -2 * hess(1,2)*(point(3) - z) + 2*dfdx*dfdy;
    hessian = [ddx2, ddxy; ddxy, ddy2];
end

