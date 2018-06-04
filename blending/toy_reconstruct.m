function out = toy_reconstruct(s)
    [r,c] = size(s);
    im2var = zeros(r, c); 
    im2var(1:r*c) = 1:r*c;
    
    A = sparse([],[],[],2*r*c-r-c+1, r*c,2*(2*r*c-r-c+1));
    b = zeros(2*r*c-r-c+1,1);
    e = 0;
    for y = 1:r
        for x = 1:c-1
        e = e + 1;
        A(e, im2var(y,x+1))=1; 
        A(e, im2var(y,x))=-1; 
        b(e) = s(y,x+1)-s(y,x); 
        end
    end
    
    for y = 1:r-1
        for x = 1:c
        e = e + 1;
        A(e, im2var(y+1,x))=1; 
        A(e, im2var(y,x))=-1; 
        b(e) = s(y+1,x)-s(y,x); 
        end
    end
    
    e=e+1; 
    A(e, im2var(1,1))=1; 
    b(e)=s(1,1); 
    
    v = A\b;
    out = zeros(r,c);
    for y = 1:r
        for x = 1:c
        out(y,x) =  v(im2var(y,x));
        end
    end
end