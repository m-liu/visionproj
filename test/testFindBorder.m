% Test findBorder function

close all;
clear all;

% im = imread('../img/set2/1.bmp');
% pointsList = findBorder(im);
% im = imread('../img/set2/2.bmp');
% pointsList = findBorder(im);
% im = imread('../img/set2/3.bmp');
% pointsList = findBorder(im);

im = imread('../img/random.bmp');
figure;
imshow(rgb2gray(im));
pointsList = findBorder(im);