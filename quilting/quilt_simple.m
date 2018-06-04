function out = quilt_simple(sample, outsize, patchsize, overlap, tol)
    
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
        for k = 1:patchsize
            for l = 1:patchsize
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
        for k = 1:patchsize
            for l = 1:patchsize
                out(k,l+r*step,:) = sample(y0+k, x0+l, :);
            end
        end
    end
    out = permute(out, [2,1,3]);
    sample = permute(sample, [2,1,3]);
    
    for s = 1:fix((outsize-overlap)/step)-1
    for r = 1:fix((outsize-overlap)/step)-1%---(-overlap
        cost = ssd_patch(sample, out(1+s*step:patchsize+s*step, r*step+1:(r+1)*step+overlap,:), overlap, 0);
        [y,x] = choose_sample(cost((patchsize-1)/2+1:w-(patchsize-1)/2,(patchsize-1)/2+1:h-(patchsize-1)/2), tol);
        y0 = y-1;
        x0 = x-1;
        for k = 1:patchsize
            for l = 1:patchsize
                out(k+s*step,l+r*step,:) = sample(y0+k, x0+l, :);
            end
        end
    end
    end

    %{
    for r2 = 1:fix((outsize-overlap)/step)-1%---(-overlap
        cost = ssd_patch(sample, out(r2*step+1:(r2+1)*step+overlap, 1:patchsize,:), overlap, 2);
        [y,x] = choose_sample(cost((patchsize-1)/2+1:w-(patchsize-1)/2,(patchsize-1)/2+1:h-(patchsize-1)/2), tol);
        y0 = y-1;
        x0 = x-1;
        for k = 1:patchsize
            for l = 1:patchsize
                out(k+r2*step,l,:) = sample(y0+k, x0+l, :);
            end
        end
        imshow(out);
    end
    %}
    
    %for row = 1:fix(outsize/(patchsize-overlap))
    %    for col = 1:fix(outsize/(patchsize-overlap))
    %cost = ssd_patch(sample, out(patchsize-overlap+1:2*patchsize-overlap,1:patchsize,:), overlap);
    %[y,x] = choose_sample(cost, tol);
    %for k = 1:patchsize
    %        for l = 1:patchsize
    %            out(k,l,:) = sample(rx+k, ry+l, :);
    %        end
    %end
    %    end
    %end
end