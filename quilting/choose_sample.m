function [y,x] = choose_sample(cost, tol)
    minc = abs(min(cost(:)));
    [ys, xs] = find(cost<minc*(1+tol));
    k = length(ys);
    if k == 0
        disp(minc);
    end
    idx = ceil(k*rand());
    y = ys(idx);
    x = xs(idx);
end