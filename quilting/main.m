%{
sample = im2double(imread('proj2/square.png'));
%figure(1),imshow(sample);
%output = quilt_random(sample, 300, 60);
%figure(2),imshow(output);
%output2 = quilt_simple(sample, 319, 91, 15, 0.1);
output3 = quilt_cut(sample, 319, 91, 15, 0.1);
%imwrite(output,'proj2/square_rand.jpg');
%imwrite(output2,'proj2/square_simple.jpg');
imwrite(output3,'proj2/square_cut.jpg');
%figure(3),imshow(output);

source = im2double(imread('proj2/source3.png'));
target = im2double(imread('proj2/cartoon.jpg'));
%target = im2double(imread('feynman.tiff'));
transfer = texture_transfer(source, target, 11, 3, 0.1, 0.5);
figure(4),imshow(transfer);
imwrite(transfer,'proj2/transfer3.jpg');
%}
im = im2double(imread('proj2/hole_filling.png'));
out = fill_hole(im, 40, 19, 0.1); %31, 72.275
figure(5),imshow(out);
