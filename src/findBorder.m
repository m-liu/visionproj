function [pointslist] = findBorder(im)
    pointslist = [];
    
    imgray = rgb2gray(im);

    border = zeros(size(imgray));

    for i = 1:size(imgray, 1)
        for j = 1:size(imgray, 2)
            ret = isBorder(i,j);
            if ret == 1
                border(i,j) = 255;
                pointslist = [pointslist; i j;];
            end
        end
    end
    
    figure;
    imshow(border);
    
    function [ret] = isBorder(i,j)
        ret = 0;
        if imgray(i,j) < 254
            if i>1 && (imgray(i-1,j) > 253)
                ret = 1;
            end
            if i<size(imgray,1) && (imgray(i+1,j) > 253)
                ret = 1;
            end
            if j>1 && (imgray(i,j-1) > 253) 
                ret = 1;
            end
            if j<size(imgray,2) && (imgray(i,j+1) > 253)
                ret = 1;
            end
        end
    end
end