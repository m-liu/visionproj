%% Test MatchContent Function

% Checks if the compatibility function found the actual neighbor with
% the highest probability.
cformRgbToLab = makecform('srgb2lab');
hits = 0;
total = 0;
partSize = 2;

for imageIndex = 1:10
    % Reading the image and converting to the LAB color scheme.
    image = imread('../img/lena.jpg');
    labImage = double(applycform(image, cformRgbToLab));

    image = double(image);
    imageSize = size(image);

    % Calculate a parts data
    rows = imageSize(1) / partSize;
    cols = imageSize(2) / partSize;
    numOfParts = rows * cols;
    partsCorrectOrder = 1:numOfParts;

    % Creating parts array that contain the puzzle parts
    labPartsArray =  zeros(partSize, partSize, 3, numOfParts);
    rgbPartsArray =  zeros(partSize, partSize, 3, numOfParts);

    % Splits the image into parts.
    cutImageToParts();

    % Initialize parts compatibility, unlike when solving the jigsaw
    % we will fill the entire partsCompVal matrix.
    partsCompVal = zeros(numOfParts,numOfParts,4);
    initializePartsCompatibility();
    for i = 1:numOfParts
        for j = i:numOfParts
            for l = 1:4
                if (i == j)
                    partsCompVal(i,j,l) = bitmax;
                else
                    if (l==1 || l==3)
                        partsCompVal(j,i,l) = partsCompVal(i, j, l+1);
                    else
                        partsCompVal(j,i,l) = partsCompVal(i, j, l-1);
                    end
                end
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
            if (i > 1) 
                hits = hits + wasCompatibilityFunctionCorrect(partsExpMat(i,j), partsExpMat(i-1,j), 3);
            end
            if (i<rows)
                hits = hits + wasCompatibilityFunctionCorrect(partsExpMat(i,j), partsExpMat(i+1,j), 4);
            end
            if (j > 1)
                hits = hits + wasCompatibilityFunctionCorrect(partsExpMat(i,j), partsExpMat(i,j-1), 1);
            end
            if (j<cols)
                hits = hits + wasCompatibilityFunctionCorrect(partsExpMat(i,j), partsExpMat(i,j+1), 2);
            end
        end
    end

    total = total + rows * (cols - 1) + (rows - 1) * cols;
end

% We count each connection (edge) twice.
accuracy = (hits / 2) / total;