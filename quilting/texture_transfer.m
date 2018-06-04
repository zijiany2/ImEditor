function out = texture_transfer(sample, target, patchsize, overlap, tol, alpha)
    targetMap = imfilter(rgb2gray(target),fspecial('gaussian',[15,15], 2));
    sampleMap = imfilter(rgb2gray(sample),fspecial('gaussian',[15,15], 2));
    [w0,h0] = size(targetMap);
    [w1,h1] = size(sampleMap);
    out = zeros(size(target));
    rowRange0 = 1:patchsize;
    colRange0 = 1:patchsize;
    costC = ssd_correspondance(sampleMap, targetMap(rowRange0, colRange0));
    patchHalfWidth = (patchsize-1)/2;
    rowRange1 = patchHalfWidth+1:w1-patchHalfWidth;
    colRange1 = patchHalfWidth+1:h1-patchHalfWidth;
    costC = costC(rowRange1, colRange1);
    [y,x] = choose_sample(costC, tol);
    out(rowRange0,colRange0,:) = sample(y:y+patchsize-1,x:x+patchsize-1,:);
    
    step = patchsize-overlap;
    rangeO = 1:overlap;
    rangeP = 1:patchsize;
    
    for r = 1:fix((h0-overlap)/step)-1
        costO = ssd_patch(sample, out(rowRange0, r*step+colRange0,:), overlap, 1);
        costC = ssd_correspondance(sampleMap, targetMap(rowRange0, r*step+colRange0));
        cost = alpha*costO+(1-alpha)*costC;
        cost = cost(rowRange1, colRange1);
        [y,x] = choose_sample(cost, tol);
        y0 = y-1;
        x0 = x-1;
        bndcost = overlap_diff(out(rangeP,r*step+rangeO,:), sample(y0+rangeP,x0+rangeO,:));
        mask = transpose(cut(transpose(bndcost)));
        for m = 1:3
                out(rangeP,r*step+rangeO,m) = mask.*sample(y0+rangeP,x0+rangeO, m)+(1-mask).*out(rangeP,r*step+rangeO,m);
        end
           for l = overlap+1:patchsize
                out(rangeP,l+r*step,:) = sample(y0+rangeP, x0+l, :);
           end    
    end
    
    for r = 1:fix((w0-overlap)/step)-1
        costO = ssd_patch(sample, out(r*step+rowRange0, colRange0,:), overlap, 2);
        costC = ssd_correspondance(sampleMap, targetMap(r*step+rowRange0, colRange0));
        cost = alpha*costO+(1-alpha)*costC;
        cost = cost(rowRange1, colRange1);
        [y,x] = choose_sample(cost, tol);
        y0 = y-1;
        x0 = x-1;
        bndcost = overlap_diff(out(r*step+rangeO,rangeP,:), sample(y0+rangeO,x0+rangeP,:));
        mask = cut(bndcost);
        for m = 1:3
                out(r*step+rangeO,rangeP,m) = mask.*sample(y0+rangeO,x0+rangeP, m)+(1-mask).*out(r*step+rangeO,rangeP,m);
        end
           for l = overlap+1:patchsize
                out(l+r*step,rangeP,:) = sample(y0+l, x0+rangeP, :);
           end    
    end
    
    for s = 1:fix((w0-overlap)/step)-1
    for r = 1:fix((h0-overlap)/step)-1
        costO = ssd_patch(sample, out(s*step+rowRange0, r*step+colRange0,:), overlap, 0);
        costC = ssd_correspondance(sampleMap, targetMap(s*step+rowRange0, r*step+colRange0));
        cost = alpha*costO+(1-alpha)*costC;
        cost = cost(rowRange1, colRange1);
        [y,x] = choose_sample(cost, tol);
        y0 = y-1;
        x0 = x-1;
        bndcost1 = overlap_diff(out(s*step+rangeP,r*step+rangeO,:), sample(y0+rangeP,x0+rangeO,:));
        mask1 = transpose(cut(transpose(bndcost1)));
        bndcost2 = overlap_diff(out(s*step+rangeO,r*step+rangeP,:), sample(y0+rangeO,x0+rangeP,:));
        mask2 = cut(bndcost2);
        m = ones(patchsize, patchsize);
        m(rangeO,:) = mask2;
        m(:,rangeO) = m(:,rangeO) & mask1;
        for n = 1:3
                out(rangeP+s*step,rangeP+r*step,n) = m.*sample(y0+rangeP, x0+rangeP, n)+(1-m).*out(s*step+rangeP,r*step+rangeP,n);
        end   
    end    
    end
    
end