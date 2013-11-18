function [row col] = coord2mat(coord, size)
%coord=[x y]
%mat = [row col]
%size = [height width channels]
    col = coord(1);
    row = size(1) - coord(2);
    %mat = [row col]
end