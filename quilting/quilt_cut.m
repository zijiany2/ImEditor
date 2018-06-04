function out = quilt_cut(sample, outsize, patchsize, overlap, tol)
    [w,h,d] = size(sample);
    out = zeros(outsize,outsize,d);
    rx = fix((w-patchsize)*rand());
    ry = fix((h-patchsize)*rand());
    for k = 1:patchsize
            for l = 1:patchsize
                out(k,l,:) = sample(rx+k, ry+l, :);
            end
    end
    step = patchsize-overlap;
    
    for r = 1:fix((outsize-overlap)/step)-1%---(-overlap
        cost = ssd_patch(sample, out(1:patchsize, r*step+1:(r+1)*step+overlap,:), overlap, 1);
        [y,x] = choose_sample(cost((patchsize-1)/2+1:w-(patchsize-1)/2,(patchsize-1)/2+1:h-(patchsize-1)/2), tol);
        y0 = y-1;
        x0 = x-1;
        bndcost = overlap_diff(out(1:patchsize,r*step+1:r*step+overlap,:), sample(y:y0+patchsize,x:x0+overlap,:));
        mask = transpose(cut(transpose(bndcost)));
        for m = 1:3
                out(1:patchsize,1+r*step:overlap+r*step,m) = mask.*sample(y0+1:y0+patchsize, x0+1:x0+overlap, m)+(1-mask).*out(1:patchsize,1+r*step:overlap+r*step,m);
        end
        for k = 1:patchsize
           for l = overlap+1:patchsize
                out(k,l+r*step,:) = sample(y0+k, x0+l, :);
            end
        end
    end
    
    out = permute(out, [2,1,3]);
    sample = permute(sample, [2,1,3]);

    for r = 1:fix((outsize-overlap)/step)-1%---(-overlap
        cost = ssd_patch(sample, out(1:patchsize, r*step+1:(r+1)*step+overlap,:), overlap, 1);
        [y,x] = choose_sample(cost((patchsize-1)/2+1:w-(patchsize-1)/2,(patchsize-1)/2+1:h-(patchsize-1)/2), tol);
        y0 = y-1;
        x0 = x-1;
        bndcost = overlap_diff(out(1:patchsize,r*step+1:r*step+overlap,:), sample(y:y0+patchsize,x:x0+overlap,:));
        mask = transpose(cut(transpose(bndcost)));
        for m = 1:3
                out(1:patchsize,1+r*step:overlap+r*step,m) = mask.*sample(y0+1:y0+patchsize, x0+1:x0+overlap, m)+(1-mask).*out(1:patchsize,1+r*step:overlap+r*step,m);
        end
        for k = 1:patchsize
           for l = overlap+1:patchsize
                out(k,l+r*step,:) = sample(y0+k, x0+l, :);
            end
        end
    end
    
    out = permute(out, [2,1,3]);
    sample = permute(sample, [2,1,3]);
    
    for s = 1:fix((outsize-overlap)/step)-1
    for r = 1:fix((outsize-overlap)/step)-1
        cost = ssd_patch(sample, out(1+s*step:patchsize+s*step, r*step+1:(r+1)*step+overlap,:), overlap, 0);
        [y,x] = choose_sample(cost((patchsize-1)/2+1:w-(patchsize-1)/2,(patchsize-1)/2+1:h-(patchsize-1)/2), tol);
        y0 = y-1;
        x0 = x-1;
        bndcost1 = overlap_diff(out(1+s*step:patchsize+s*step,r*step+1:r*step+overlap,:), sample(y:y0+patchsize,x:x0+overlap,:));
        mask1 = transpose(cut(transpose(bndcost1)));
        bndcost2 = overlap_diff(out(1+s*step:overlap+s*step,r*step+1:r*step+patchsize,:), sample(y:y0+overlap,x:x0+patchsize,:));
        mask2 = cut(bndcost2);
        m = ones(patchsize, patchsize);
        m(1:overlap,:) = mask2;
        m(:,1:overlap) = m(:,1:overlap) & mask1;
        %for k = 1:patchsize
            for n = 1:3
                out(1+s*step:patchsize+s*step,1+r*step:patchsize+r*step,n) = m.*sample(y0+1:y0+patchsize, x0+1:x0+patchsize, n)+(1-m).*out(1+s*step:patchsize+s*step,1+r*step:patchsize+r*step,n);
            end
        %end
        
    end
    end
end