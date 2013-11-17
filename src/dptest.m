close all 
clear all
%list = [5 5; 10 50; 13 80; 15 10; 12 20; 18 30; 19 40;]
list = [10 10; 13 50; 58 50; 50 30; 60 10]
 figure;
plot(list(:,1), list(:,2));
axis([0 100 0 100]);

%get the vertices
[list_pts,verts]= douglas_peucker(list, 5)

 figure;
plot(verts(:,1), verts(:,2));
axis([0 100 0 100]);

numVerts = size(verts,1);
for i=1:numVerts
    if (i==1)
        vNext = verts(i+1,:) - verts(i,:);
        vPrev = verts(end,:) - verts(i,:);
    elseif (i==numVerts)
        vNext = verts(1,:) - verts(i,:);
        vPrev = verts(i-1,:) - verts(i,:);
    else
        vNext = verts(i+1,:) - verts(i,:);
        vPrev = verts(i-1,:) - verts(i,:);
    end
    dNext = norm( vNext );
    dPrev = norm( vPrev );
    
    angle = acos ( dot(vNext, vPrev) / (dNext * dPrev) );
    angle = radtodeg(angle)
    vertices(i) = struct('angle', angle, 'dNext', dNext, 'dPrev', dPrev, 'posX', verts(i,1), 'posY', verts(i,2));
end

%compute perimeter
perimeter = 0;
for i=1:size(vertices)
    perimeter = perimeter + vertices(i).dNext;
end

poly = struct ('vertices', vertices, 'perimeter', perimeter);

%generate the table vertices

