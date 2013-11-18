function [sortedList] = findBorder(im)
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
    
   % figure;
   % imshow(border);
    
    % need to sort the pointslist in clockwise order
    % 1 represents 'up' neighbor of the pixel, 2 = 'up-right', 3 = 'right'
    % and so on... until 'up-left' = 8
    numPoints = size(pointslist,1);
    sortedList = [];
    index = 0;
    
    curPixel = pointslist(1,:);
    curDirection = 3; % start with right pixel
    
    while 1
        [index, relation] = findBorderNeighbor(curPixel, curDirection);
        if size(sortedList, 1) > numPoints
            print test
        end
        if index == 0
            curPixel = sortedList(end,:);
            curDirection = mod(curDirection + 3, 8) + 1;
        elseif index == 1
            sortedList = [sortedList; curPixel];
            break
        else
            sortedList = [sortedList; curPixel];
            curDirection = mod(relation + 4, 8) + 1;
            curPixel = pointslist(index,:);
            pointslist(index,:) = [];
        end
    end
    
    function [index, relation] = findBorderNeighbor(pixel, startDirection)
        direction = startDirection;
        counter = 0;
        while counter < 8
            index = 0;
            switch direction
                case 1
                    [~,index] = ismember([pixel(1)-1 pixel(2)], pointslist, 'rows');
                case 2
                    [~,index] = ismember([pixel(1)-1 pixel(2)+1], pointslist, 'rows');
                case 3
                    [~,index] = ismember([pixel(1) pixel(2)+1], pointslist, 'rows');
                case 4
                    [~,index] = ismember([pixel(1)+1 pixel(2)+1], pointslist, 'rows');
                case 5
                    [~,index] = ismember([pixel(1)+1 pixel(2)], pointslist, 'rows');
                case 6
                    [~,index] = ismember([pixel(1)+1 pixel(2)-1], pointslist, 'rows');
                case 7
                    [~,index] = ismember([pixel(1) pixel(2)-1], pointslist, 'rows');
                case 8
                    [~,index] = ismember([pixel(1)-1 pixel(2)-1], pointslist, 'rows');
            end
            if index ~= 0
                relation = direction;
                break
            else
                direction = mod(direction, 8) + 1;
            end
            counter = counter + 1;
        end
        
        if index == 0
            relation = 0;
        end
    end
    
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