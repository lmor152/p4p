function [dPhi] = field_jac(point, xgrid, ygrid, xyrange, Phi, d)
    %Phi = reshape(Phi, length(xgrid)+d-1, length(ygrid)+d-1);
    minM = xyrange(1);
    minN = xyrange(2);
    dPhi = zeros(size(Phi));
    global est
    for ind = 1:length(point)
        [exmax, exmin, i] = find_gt(xgrid, est(ind,1) - minM);
        [eymax, eymin, j] = find_gt(ygrid, est(ind,2) - minN);
        s = (est(ind,1) - minM - exmin)/ (exmax - exmin);
        t = (est(ind,2) - minN - eymin)/ (eymax - eymin);
        z = evaluate_point(d, est(ind,1), est(ind,2), xgrid, ygrid, xyrange, Phi);
        e = (points(ind,3) - z);
        for k = 0:d
            for l = 0:d
                try
                    dPhi(i+k, j+l) = dPhi(i+k, j+l) - 2 * W(d,k,l,s,t)*e;
                catch
                    disp('out of range')
                end 
            end
        end
    end
end

