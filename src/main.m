%main function

close all 
clear variables

directory = 'img/set3/';
inputImgs = dir( strcat(directory, '*.bmp') );

if ( size(inputImgs,1) < 1 )
    error('image inputs not found');
end

for imInd=1:size(inputImgs)
    
    %read input image
    im = imread( strcat(directory, inputImgs(imInd).name) );
    figure
    imshow(im); hold on;
    
    %get all the contour pixels
    contour = findBorder(im);

    %convert contour pixels to coordinates
    for i=1:size(contour,1)
        [contour(i,1) contour(i,2)] = mat2coord(contour(i,:), size(im));
    end
%     figure;
%     plot(contour(:,1), contour(:,2));
%     axis([0 size(im,2) 0 size(im,1)]);


    %run DP to generate simplified polygons
    [list_pts,verts]= douglas_peucker(contour, 5)
    
    %delete the last vertex because it's redundant (DP can't run on a
    %closed loop)
    verts(end,:)=[];    

    %figure;
    vertsPlot = verts;
    vertsPlot(end+1,:) = verts(1,:); %make a loop for plotting purposes
    scatter(vertsPlot(:,1), size(im,1)-vertsPlot(:,2), 'bo'); hold on;
    plot(vertsPlot(:,1), size(im,1)-vertsPlot(:,2), 'b-');
    axis([0 size(im,2) 0 size(im,1)]);
    
    %generate struct describing each piece
    %a 'piece' struct is defined as:
    %   'vertices', 'perimeter', 'im'
    % where vertices structs are:
    %   'angle', 'dNext', 'dPrev', 'posX', 'posY'
    pieces(imInd) = createPiece( verts, im );

end

while (size(pieces,2) > 1)
    pieces = matchContour(pieces);
end




