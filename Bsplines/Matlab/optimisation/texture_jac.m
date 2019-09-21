function [tex_dx, tex_dy] = texture_jac(est, origin, impoint, xgrid, ygrid, xyrange, Phi, d)
    z = evaluate_point(d, est(1), est(2), xgrid, ygrid, xyrange, Phi);
    [dx, dy] = spline_df(est(1), est(2), xgrid, ygrid, xyrange, Phi, d);
    
    xterm1 = 2*(est(1) - impoint(1)) + 2*z*dx;
    xterm2 = 2*((origin(1) - impoint(1)) + origin(3)*dx);
    xterm3 = ((origin(1)-impoint(1))*(est(1)-impoint(1)) + (origin(2)-impoint(2))*(est(2)-impoint(2)) + origin(3)*z);
    denom = (origin(1)-impoint(1))^2 + (origin(2)-impoint(2))^2 + origin(3)^2;
    tex_dx = xterm1 - xterm2*xterm3/denom;

    yterm1 = 2*(est(2) - impoint(2)) + 2*z*dy;
    yterm2 = 2*((origin(2) - impoint(2)) + origin(3)*dy);
    yterm3 = ((origin(1)-impoint(1))*(est(1)-impoint(1)) + (origin(2)-impoint(2))*(est(2)-impoint(2)) + origin(3)*z);
    tex_dy = yterm1 - yterm2*yterm3/denom;    
end

