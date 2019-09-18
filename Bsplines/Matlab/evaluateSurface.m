function [Z] = evaluateSurface(d,X,Y,xgrid, ygrid, xyrange, Phi)
    Z = zeros(size(X));
    for i = 1:size(Z,1)
        for j = 1:size(Z,2)
            Z(i,j) = evaluate_point(d, X(i,j), Y(i,j), xgrid, ygrid, xyrange, Phi);
        end
    end
end