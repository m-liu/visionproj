

clear all

%vertices are an array of structs
for i=1:3
    vertices(i) = struct('angle', 0, 'dNext', 0, 'dPrev', 0, 'posX', 0, 'posY', 0)
end

poly = struct ('vertices', vertices);

