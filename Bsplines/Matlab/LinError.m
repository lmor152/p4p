function [RMSE,SSE] = LinError(d, points, xgrid, ygrid, Phi)
    xyrange = [min(points(:,1)), min(points(:,2))];
    pred = zeros(length(points), 1);
    for i = 1:length(points)
        pred(i) = evaluate_point(d, points(i,1), points(i,2), xgrid, ygrid, xyrange, Phi);
    end
    error = pred - points(:,3);
    RMSE = sqrt(mean(error.^2));
    SSE = sum(error.^2);
end