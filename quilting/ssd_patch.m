function cost = ssd_patch(sample, curpatch, overlap,option)
    %curpatch is the patch to be filled, size of patchsize^2
    %option1:horizontal only
    %option2:vertical only
    %figure(2),imshow(curpatch);
    squarsample = sample.^2;
    squarPatch = curpatch.^2;
    l = length(curpatch);
    mask = zeros(l,l);
    for i = 1:overlap
        for j = 1:length(curpatch)
            if option ~= 1
                mask(i,j) = 1;
            end
            if option ~= 2 
                mask(j,i) = 1; 
            end
        end
    end
    %figure(3),imagesc(mask);
    cost1 = imfilter(squarsample(:,:,1), mask) - 2* imfilter(sample(:,:,1), mask.*curpatch(:,:,1))+sum(sum(mask.*squarPatch(:,:,1)));
    cost2 = imfilter(squarsample(:,:,2), mask) - 2* imfilter(sample(:,:,2), mask.*curpatch(:,:,2))+sum(sum(mask.*squarPatch(:,:,2)));
    cost3 = imfilter(squarsample(:,:,3), mask) - 2* imfilter(sample(:,:,3), mask.*curpatch(:,:,3))+sum(sum(mask.*squarPatch(:,:,3)));
    cost = cost1 + cost2 + cost3;
    %%debugging
    
        disp([min(min(cost)),option]);
    
end