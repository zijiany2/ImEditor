function cost = ssd_correspondance(sampleMap, patch)
    cost = imfilter(sampleMap.^2, ones(size(patch))) -2*imfilter(sampleMap, patch) + sum(sum(patch));
end