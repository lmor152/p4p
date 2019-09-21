function [Z] = evaluate_pointvec(d,x,y,xgrid, ygrid, xyrange, Phi)
    Z = zeros(length(x),1);
    for i = 1:length(x)
        Z(i) = evaluate_point(d, x(i), y(i), xgrid, ygrid, xyrange, Phi);
    end
end
