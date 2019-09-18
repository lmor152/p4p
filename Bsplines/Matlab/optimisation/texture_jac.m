function [dx, dy] = texture_jac(est, origin, impoint, xgrid, ygrid, xyrange, Phi, d)
    z = evaluate_point(d, est(1), est(2), xgrid, ygrid, xyrange, Phi);
    [dfdx, dfdy] = spline_df(est(1), est(2), xgrid, ygrid, xyrange, Phi, d);
    denom = (origin(1) - est(1))^2 + (origin(2) - est(2))^2 + origin(3)^2;
    ex1 = 2*(est(1) - impoint(1));
    ex2 = 2*z*dfdx;
    numx1 = 2*(origin(1) - est(1))*((origin(1) - impoint(1))*(est(1) - impoint(1)) + (origin(2) - impoint(2))*(est(2) - impoint(2)) + origin(3)*z)^2;
    numx2 = 2*(origin(3)*dfdx + origin(1) - impoint(1))*((origin(1) - impoint(1))*(est(1) - impoint(1)) + (origin(2) - impoint(2))*(est(2) - impoint(2)) + origin(3)*z);
    dx = ex1 + ex2 - numx1/denom^2 - numx2/denom;
    ey1 = 2*(est(2) - impoint(2));
    ey2 = 2*z*dfdy;
    numy1 = 2*(origin(2) - est(2))*((origin(1) - impoint(1))*(est(1) - impoint(1)) + (origin(2) - impoint(2))*(est(2) - impoint(2)) + origin(3)*z)**2
    numy2 = 2*(origin(3)*dfdy + origin(2) - impoint(2))*((origin(1) - impoint(1))*(est(1) - impoint(1)) + (origin(2) - impoint(2))*(est(2) - impoint(2)) + origin(3)*z);
    dy = ey1 + ey2 - numy1/denom^2 - numy2/denom;
end

