

clear all

%vertices are an array of structs
for i=1:3
    vertices(i) = struct('angle', 0, 'dNext', 0, 'dPrev', 0, 'posX', 0, 'posY', 0)
end

%compute perimeter
perimeter = 0;
for i=1:size(vertices)
    perimeter = perimeter + vertices(i).dNext;
end

poly = struct ('vertices', vertices, 'perimeter', perimeter);

