function im_blend = poissonBlend(im_s, mask, im_background)
    [h,w] = size(mask);
    im2var = zeros(h,w);
    e = 0;
    for y = 1:h
        for x = 1:w
            if mask(y,x) == 1
                e = e + 1;
                im2var(y,x)= e;
            end
        end
    end
    
    
    sl = zeros(e,3);
    for k = 1:3
    cnt = 0;
    A = sparse([], [], [], 4*e, e, 8*e);
    b = zeros(4*e,1);
    for y = 1:h
        for x = 1:w
            if mask(y,x) == 1
                for y0 = [y-1, y+1]
                    for x0 = [x-1, x+1]
                        cnt = cnt + 1;
                        if mask(y0,x0) == 1
                            A(cnt, im2var(y,x)) = 1;
                            A(cnt, im2var(y0,x0)) = -1;
                            b(cnt) = im_s(y,x,k) - im_s(y0,x0,k);
                        else
                            A(cnt, im2var(y,x)) = 1;
                            b(cnt) = im_background(y0,x0,k) + im_s(y,x,k) - im_s(y0,x0,k);
                        end
                    end
                end 
            end
        end
    end
    sl(:,k) = A\b;
    end
    
    im_blend = zeros(size(im_background));
    for y = 1:h
        for x = 1:w
            if mask(y,x) == 1
                im_blend(y,x,:) = sl(im2var(y,x),:);
            else
                im_blend(y,x,:) = im_background(y,x,:);
            end
        end
    end
    
end