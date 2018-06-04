function out = fill_hole(im, thre, pitchSize, tol)
    lab_im = rgb2lab(im);
    imlab = lab_im(:,:,1)+lab_im(:,:,2)+lab_im(:,:,3);
    figure(4),imagesc(imlab);
    imgray = rgb2gray(im);
    [h1,w1] = size(imgray);
    disp(min(min(imgray)));
    conf = logical(imlab > thre)*1.0;
    %figure(), imagesc(conf), saveas(gcf,strcat('conf00.jpg'));
    halfWidth = (pitchSize-1)/2;
    count = 0;
    while(1)
    isBlank = logical(conf==0);
    isFill = ~isBlank;
    
    rowRange1 = halfWidth+1:h1-halfWidth;
    colRange1 = 175:w1-halfWidth;
   
    
    flt = ones(pitchSize, pitchSize)/pitchSize^2;
    curr_conf = imfilter(conf, flt);
    mask = isBlank.*curr_conf;
    maxconf = max(mask(:));
    [y,x] = find(mask == maxconf);
    y0 = y(1) - halfWidth - 1;
    x0 = x(1) - halfWidth - 1;
    pRange = 1:pitchSize;
    
    cost = zeros(size(imgray));
    for m = 1:3
        ssd =  imfilter(im(:,:,m).^2, isFill(y0+pRange,x0+pRange)*1.0)...
            - 2*imfilter(im(:,:,m), im(y0+pRange,x0+pRange,m)) ...
            + sum(sum(im(y0+pRange,x0+pRange,m).^2));
        cost = cost +ssd;
        
    end
    cost = cost + isBlank*9e6;
    [yc,xc] = choose_sample(cost(rowRange1, colRange1), tol);
    yc =yc-1; xc = xc+174-halfWidth-1;
    for m = 1:3
    %im(y0+pRange,x0+pRange,m) = im(yc+pRange, xc+pRange, m).*isBlank(y0+pRange,x0+pRange) ...
     %   + im(y0+pRange,x0+pRange,m).*isFill(y0+pRange,x0+pRange);
     im(y0+pRange,x0+pRange,m) = im(yc+pRange, xc+pRange, m);
    end
    
    conf(y0+pRange,x0+pRange) = maxconf*isBlank(y0+pRange,x0+pRange) ...
        + conf(y0+pRange,x0+pRange).*isFill(y0+pRange,x0+pRange);
    
    count = count +1;
    if (rem(count,12)==0)
        imwrite(im,strcat('process',int2str(count),'.jpg'));
        %figure(), imagesc(conf), saveas(gcf,strcat('conf',int2str(count),'.jpg'));
    end
    if min(min(conf)) > 0
        imwrite(im,strcat('processend.jpg'));
        %figure(), imagesc(conf), saveas(gcf,strcat('confend.jpg'));
        break;
    end
    end
    out = im;
end