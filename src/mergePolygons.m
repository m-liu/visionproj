function [ polyMerged ] = mergePolygons( polyA, polyB, vA, vB )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    
%[xr,yr,xor,yor,theta] = rotateData(x,y,xo,yo,theta,direction)

pixA = polyA.im;
pixB = polyB.im;


%get coordinates
aX = polyA.vertices(vA).posX;
aY = polyA.vertices(vA).posY;
bX = polyB.vertices(vB).posX;
bY = polyB.vertices(vB).posY;

if (vA==1)
    vAprev = size(polyA.vertices,2);
else
    vAprev = vA-1;
end
aPrevX = polyA.vertices(vAprev).posX;
aPrevY = polyA.vertices(vAprev).posY;

if (vB==size(polyB.vertices,2))
    vBnext = 1;
else
    vBnext = vB+1;
end
bNextX = polyB.vertices(vBnext).posX;
bNextY = polyB.vertices(vBnext).posY;

%translate polyB according to the translate from vB to vA 
transX = aX - bX;
transY = aY - bY;

%rotate polyB about vB such that the edge aligns
%NOTE arbitrary choice of which edge to align right now: previous edge
aPrevEdgeVec = [aPrevX-aX, aPrevY-aY];
bNextEdgeVec = [bNextX-bX, bNextY-bY];
[aPrevTheta aRo] = cart2pol(aPrevEdgeVec(1), aPrevEdgeVec(2));
[bNextTheta bRo] = cart2pol(bNextEdgeVec(1), bNextEdgeVec(2));
if(aPrevTheta < 0)
    aPrevTheta = aPrevTheta + (2*pi);
end
if (bNextTheta < 0)
    bNextTheta = bNextTheta + (2*pi);
end
%clockwise rotation required to go from b to a
theta = bNextTheta - aPrevTheta;



pixBgray = rgb2gray(pixB);

%create a mapping table
src = [];
dest = [];
for i=1:size(pixB,1)
    for j=1:size(pixB,2)
        if (pixBgray(i,j) < 253)
            %convert to cartesian coordinates
            [x y] = mat2coord([i j], size(pixB));
            src(end+1, :) = [x y];
            %translate
            xNew = x + transX;
            yNew = y + transY;
            %rotate
            [xNew,yNew,xor,yor,trash] = rotateData(xNew,yNew,aX,aY,theta,'clockwise');
            dest(end+1, :) = [round(xNew) round(yNew)];
            
        end
    end
end


%create a new image canvas
%first put in polyA.im, but translate it so everything is positive after
%merging with polyB.im 
xmin = min(dest(:, 1));
ymin = min(dest(:, 2));

moveAx = 0;
moveAy = 0;
if (xmin < 1)
    moveAx = abs(xmin)+10; %give 10 pixels of leeway
    dest(:,1) = dest(:,1)+moveAx;
end

if (ymin < 1)
    moveAy = abs(ymin)+10;
    dest(:,2) = dest(:,2)+moveAy;
end

%find size of new canvas
width = max( size(pixA,2)+moveAx, max(dest(:,1)) ) + 10
height = max( size(pixA,1)+moveAy, max(dest(:,2)) ) + 10
imMerge(1:height, 1:width, 1:3) = 255; %initialize to white
imMerge = uint8(imMerge);

%fill with polyA pixels
for i=1:size(pixA,1)
    for j=1:size(pixA,2)
        [xA yA] = mat2coord([i j],size(pixA));
        xA = xA+moveAx;
        yA = yA+moveAy;
        [rowM colM] = coord2mat([xA yA], size(imMerge));
        imMerge(rowM, colM, :) = pixA(i, j, :);
    end
end

%translate coordinates of polyA's vertices
for i=1:size(polyA.vertices,2)
    polyA.vertices(i).posX = polyA.vertices(i).posX + moveAx;
    polyA.vertices(i).posY = polyA.vertices(i).posY + moveAy;
end

%fill with polyB pixels according to mapping table
for i=1:size(dest,1)
    %translate img such that vB is at center of the img
    
    %rotate img
    
    %translate again according to moveAx and transX
    
    %[rowM colM] = coord2mat(dest(i,:), size(imMerge));
    %[rowB colB] = coord2mat(src(i,:), size(pixB));
    %imMerge(rowM, colM, :) = pixB(rowB, colB, :);
end

%translate and rotate coordinates of polyB's vertices
for i=1:size(polyB.vertices,2)
    vxNew = polyB.vertices(i).posX + transX;
    vyNew = polyB.vertices(i).posY + transY;
    
    [vxNew,vyNew,xor,yor,trash] = rotateData(vxNew,vyNew,aX,aY,theta,'clockwise');
    vxNew = vxNew + moveAx;
    vyNew = vyNew + moveAy;
    
    polyB.vertices(i).posX = round(vxNew);
    polyB.vertices(i).posY = round(vyNew);
end



figure;
imshow(imMerge);

%generate new vertices data for merged polygon. First merge all vertices
verticesMerged = polyA.vertices( 1:vA );

%rotate the vertices list for polyB
verticesNew = polyB.vertices( vB+1 : end );
verticesNew = [verticesNew, polyB.vertices( 1:vB )];
verticesMerged = [ verticesMerged, verticesNew ];
verticesMerged = [ verticesMerged, polyA.vertices( vA+1 : end ) ];

%then delete/merge vertices
while (1) 
    found = 0;
    i=1;
    while (~found && i<size(verticesMerged,2))
        j=i+1;
        while (~found && j < size(verticesMerged,2))
            v1 = [verticesMerged(i).posX, verticesMerged(i).posY];
            v2 = [verticesMerged(j).posX, verticesMerged(j).posY];
            angsum = verticesMerged(i).angle + verticesMerged(j).angle;
            dist = 5;
            %delete vertices that add up to 360
            if ( inProximity(v1, v2, dist) && angsum < 365 && angsum > 355 )
                verticesMerged([i j]) = [];
                found=1;
            %merge vertices next to each other 
            elseif ( inProximity(v1, v2, dist) && j==i+1 )
                v1 = i;
                v2 = j;
                verticesMerged(v1).angle = verticesMerged(v1).angle + verticesMerged(v2).angle;
                verticesMerged(v1).dNext = verticesMerged(v2).dNext;
                verticesMerged(v1).posX = round(mean( [verticesMerged(v1).posX, verticesMerged(v2).posX] ));
                verticesMerged(v1).posY = round(mean( [verticesMerged(v1).posY, verticesMerged(v2).posY] ));
                verticesMerged(v2) = [];
                found=1;
            elseif ( inProximity(v1, v2, dist) )
                warning('vertices in the same location, but cant be merged');
            end
            j=j+1;
        end
        i=i+1;
    end
    if ( ~found )
        break;
    end
end

%compute perimeter
perimeter = 0;
for i=1:size(verticesMerged)
    perimeter = perimeter + verticesMerged(i).dNext;
end

%return new polygon
polyMerged = struct('vertices', verticesMerged, 'perimeter', perimeter, 'im', imMerge);


end



function res = inProximity(pt1, pt2, dist)
    if (norm(pt1-pt2) < dist)
        res = 1;
    else
        res = 0;
    end
end


            
            
