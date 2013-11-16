%% Test MatchContent Function
function [accuracy] =  testMatchContent()
    % Checks if the compatibility function found the actual neighbor with
    % the highest probability.
    cformRgbToLab = makecform('srgb2lab');
    hits = 0;
    total = 0;
    partSize = 256;

    for imageIndex = 1:10
        % Reading the image and converting to the LAB color scheme.
        image = imread('../img/lenn1.png');
        labImage = double(applycform(image, cformRgbToLab));

        image = double(image);
        imageSize = size(image);

        % Calculate a parts data
        % rows = imageSize(1) / partSize;
        % only vertical strips for now;
        rows = 1;
        cols = imageSize(2) / partSize;
        numOfParts = rows * cols;

        % Creating parts array that contain the puzzle parts
        labPartsArray =  zeros(512, partSize, 3, numOfParts);
        rgbPartsArray =  zeros(512, partSize, 3, numOfParts);

        % Splits the image into parts.
        cutImageToParts();

        % Initialize parts compatibility, unlike when solving the jigsaw
        % we will fill the entire partsCompVal matrix.
        partsCompVal = zeros(numOfParts,numOfParts);
        
        % Populate the partsCompVal matrix
        for i = 1:numOfParts
            for j = 1:numOfParts
                if (i == j)
                    partsCompVal(i,j) = bitmax;
                else
                    partsCompVal(i,j) = calcCompatibility(i, j);
                end
            end
        end

        % Creating the expected result matrix so we will be able to
        % know a parts neighbors.
        partsExpMat = zeros(rows,cols);
        for i = 1:rows
            for j = 1:cols
                partsExpMat(i,j) = (i - 1) * cols + j;
            end
        end

        % Going over the connections
        for i = 1:rows
            for j = 1:cols
                if (j > 1)
                    hits = hits + compCorrect(partsExpMat(i,j-1), partsExpMat(i,j));
                end
                if (j<cols)
                    hits = hits + compCorrect(partsExpMat(i,j), partsExpMat(i,j+1));
                end
            end
        end

        total = total + rows * (cols - 1) + (rows - 1) * cols;
    end

    % We count each connection (edge) twice.
    accuracy = (hits / 2) / total;
    
    % Cuts the images into parts.
    function cutImageToParts()
        for index = 1 : numOfParts
            rowStartIndex = 1;
            rowEndIndex = 512;
            colStartIndex = mod(index - 1, cols)  * partSize + 1;
            colEndIndex = colStartIndex + (partSize -  1);
            labPartsArray(:,:,:, index) = labImage(rowStartIndex :rowEndIndex, colStartIndex :colEndIndex, :);
            rgbPartsArray(:,:,:, index) = image(rowStartIndex :rowEndIndex, colStartIndex :colEndIndex, :);
        end
    end
    
    % Calculate compatibility between 2 pieces
    function [compVal] = calcCompatibility(i, j)
        firstPart = labPartsArray(:,:,:, i);
        secondPart = labPartsArray(:,:,:, j);
        
        firstVec = firstPart(:,partSize,:);
        secondVec = secondPart(:,1,:);
        
        compVal = MatchContent(firstVec, secondVec);
    end

    % Checks if the compatibility function found the actual neighbor with
    % the highest probability to be the given part's neighbor 
    function [hit] = compCorrect(part, actualNeighbor)
        hit = 0;
        partsVec = partsCompVal(part,:);
        minNdxVec = find(partsVec==min(partsVec));
        
        if ((length(minNdxVec) == 1) && minNdxVec == actualNeighbor)
            hit = 1;
        end
    end
end

