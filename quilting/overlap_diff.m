function cost = overlap_diff(old, new)
    [h,w,~] = size(old);
    cost = zeros(h,w);
    for k =1:3
        cost = cost + (old(:,:,k) - new(:,:,k)).^2;
    end
end