close all;

imi = imread('img/lennacrop.bmp');
imj = imi;

verti = struct('posX', 256, 'posY', 256);
verti2 = struct('posX', 10, 'posY', 10);
vertj = struct('posX', 258, 'posY', 256);
vertj2 = struct('posX', 12, 'posY', 10);

score = extractAndMatch(imi,imj,verti,verti2,vertj,vertj2)