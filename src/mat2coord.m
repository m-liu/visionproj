
function [x y] = mat2coord(mat, size)

%coord=[x y]
%mat = [row col]
%size = [height width channels]

    x = mat(2);
    y = size(1) - mat(1);
    %coord = [x y];
end