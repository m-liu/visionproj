function [x y] = mat2coord(row, col, size)
    x = col;
    y = size(1) - row;
end