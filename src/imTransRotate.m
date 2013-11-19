function [ imOut ] = imTransRotate( im, pt, angle )
%rotates an image about a given coordinate
%counterclockwise angle
    
    %make a new img 4x the size of the old one
    transNrows = 2*size(im,1);
    transNcols = 2*size(im,2);
    imTrans(1:transNrows, 1:transNcols, 1:3) = 255;
    imTrans = uint8(imTrans);
    imWhite(1:transNrows, 1:transNcols)=255;
    imWhite = uint8(imWhite);
    
    transX = size(im,2) - pt(1);
    transY = size(im,1) - pt(2);
    
    transRow = size(im,1) - transY;
    transCol = transX;
    transRowEnd = transRow+size(im,1)-1;
    transColEnd = transCol+size(im,2)-1;
    %[transRow transCol] = coord2mat([transX transY], [transNrows transNcols]);
    
    imTrans(transRow:transRowEnd, transCol:transColEnd, :) = im;
    
    
    imOut = imrotate(imTrans,angle);
    imMask = imrotate(imWhite,angle);
    
    %get rid of black border
    for i=1:size(imOut,1)
        for j=1:size(imOut,2)
            if(imMask(i,j)==0)
                imOut(i,j,:) = 255;
            end
        end
    end
    
    imshow(imOut);
 
end