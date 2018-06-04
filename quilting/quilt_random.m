function output = quilt_random(sample, outsize, patchsize)
[w,h,d] = size(sample);
output = zeros(outsize,outsize,d);
for i = 1:fix(outsize/patchsize)
    for j = 1:fix(outsize/patchsize)
        rx = fix((w-patchsize)*rand());
        ry = fix((h-patchsize)*rand());
        for k = 1:patchsize
            for l = 1:patchsize
                output((i-1)*patchsize+k,(j-1)*patchsize+l,:) = sample(rx+k, ry+l, :);
            end
        end
    end
end
end
