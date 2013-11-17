close all 
clear all
%list = [5 5; 10 50; 13 80; 15 10; 12 20; 18 30; 19 40;]
%list = [10 10; 13 50; 58 50; 50 30; 60 10]

im = imread('img/random.bmp');
list = findBorder(im)
 figure;
plot(list(:,1), list(:,2));
axis([0 1000 0 1000]);

%get the vertices
[list_pts,verts]= douglas_peucker(list, 10)

 figure;
plot(verts(:,1), verts(:,2));
axis([0 1000 0 1000]);

