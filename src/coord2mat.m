function [row col] = coord2mat(x, y, size)
    col = x;
    row = size(1) - y;
end