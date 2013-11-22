function [matchScore] = extractAndMatch(imi, imj, verti, verti2, vertj, vertj2)
%     figure;
%     imshow(imi);
%     hold on;
%     scatter(verti.posX,size(imi,1)-verti.posY,'bo');
%     scatter(verti2.posX,size(imi,1)-verti2.posY, 'bo');
%     
%     scatter(vertj.posX,size(imi,1)-vertj.posY,'go');
%     scatter(vertj2.posX,size(imi,1)-vertj2.posY, 'go');

    % calculate the difference vector between the given vertices
    vectori = [verti2.posX-verti.posX verti2.posY-verti.posY];
    vectorj = [vertj2.posX-vertj.posX vertj2.posY-vertj.posY];
    
    % convert into polar coordinates to get the angle with respect to 270
    % degrees (lining the edges vertically with the first vertex on top)
    [anglei,di] = cart2pol(vectori(1), vectori(2));
    [anglej,dj] = cart2pol(vectorj(1), vectorj(2));
    
    imiRotated = imrotate(imi, 270-radtodeg(anglei));
    imjRotated = imrotate(imj, 270-radtodeg(anglej));
    
    % map the vertices to new coordinates on the rotated images
    newVerti = mapCoord(verti.posX, verti.posY, size(imi), size(imiRotated), degtorad(270)-anglei);
    newVerti2 = mapCoord(verti2.posX, verti2.posY, size(imi), size(imiRotated), degtorad(270)-anglei);
    newVertj = mapCoord(vertj.posX, vertj.posY, size(imj), size(imjRotated), degtorad(270)-anglej);
    newVertj2 = mapCoord(vertj2.posX, vertj2.posY, size(imj), size(imjRotated), degtorad(270)-anglej);
    
    [newMatiX newMatiY] = coord2mat(floor(newVerti), size(imiRotated));
    [newMatiX2 newMatiY2] = coord2mat(floor(newVerti2), size(imiRotated));
    [newMatjX newMatjY] = coord2mat(floor(newVertj), size(imjRotated));
    [newMatjX2 newMatjY2] = coord2mat(floor(newVertj2), size(imjRotated));
    
    % check that the new difference vectors are vertical
    newVectori = floor(newVerti - newVerti2);
    newVectorj = floor(newVertj - newVertj2);
    %assert(newVectori(1) == 0.0 && newVectorj(1) == 0.0);
    
    % take the shorter of the two edges
    minEdge = min(newMatiX2-newMatiX,newMatjX2-newMatjX);
    
    extractedEdgei = zeros(minEdge, 3);
    extractedEdgej = zeros(minEdge, 3);
    
%     figure;
%     imshow(imiRotated);
%     hold on;
%     scatter(newVerti(1),size(imiRotated,1)-newVerti(2),'bo');
%     scatter(newVerti2(1),size(imiRotated,1)-newVerti2(2), 'bo');
%     
%     scatter(newVertj(1),size(imjRotated,1)-newVertj(2), 'go');
%     scatter(newVertj2(1),size(imjRotated,1)-newVertj2(2), 'go');
    
    for index=1:minEdge
        found = 1;
        for adj=1:5
            tempright = imiRotated(newMatiX+index-1,newMatiY+adj,:);            
            templeft = imiRotated(newMatiX+index-1,newMatiY-adj,:);
            temprightflat = reshape(tempright,1,3);
            templeftflat = reshape(templeft,1,3);
            if ~(tempright == 255)
                extractedEdgei(index,:) = temprightflat;
                break;
            elseif ~(templeft == 255)
                extractedEdgei(index,:) = templeftflat;
                break;
            end
            if adj == 5
                warning('MATLAB:NoValidPixel','No colored pixel found for imi at (%d,%d)', newMatiX, newMatiY+index-1);
                found = 0;
            end
        end
        if found == 1
            for adj=1:5
                tempright = imjRotated(newMatjX+index-1,newMatjY+adj,:);            
                templeft = imjRotated(newMatjX+index-1,newMatjY-adj,:);
                temprightflat = reshape(tempright,1,3);
                templeftflat = reshape(templeft,1,3);
                if ~(tempright == 255)
                    extractedEdgej(index,:) = temprightflat;
                    break;
                elseif ~(templeft == 255)
                    extractedEdgej(index,:) = templeftflat;
                    break;
                end
                if adj == 5
                    warning('MATLAB:NoValidPixel','No colored pixel found for imj at (%d,%d)', newMatjX, newMatjY+index-1);
                    extractedEdgei(index,:) = 0;
                end
            end
        end
    end
    
    matchScore = matchContent(extractedEdgei, extractedEdgej);
    
    % shift the edges against each other by 5 pixels up and down and
    % retrieve the minimum score (giving us some leniency with errors)
    for shift=1:5
        % shift edge j down first
        newEdgei = extractedEdgei(1+shift:end);
        newEdgej = extractedEdgej(1:end-shift);
        tempMatchScore = matchContent(newEdgei, newEdgej);
        if (tempMatchScore < matchScore)
            matchScore = tempMatchScore;
        end
        
        % shift edge i down after
        newEdgei = extractedEdgei(1:end-shift);
        newEdgej = extractedEdgej(1+shift:end);
        tempMatchScore = matchContent(newEdgei, newEdgej);
        if (tempMatchScore < matchScore)
            matchScore = tempMatchScore;
        end
    end
end

%% mapCoord
function newVert = mapCoord(x, y, size, newsize, rotateAngle)
% [xr,yr,xor,yor,theta] = rotateData(x,y,size(2)/2,size(1)/2,rotateAngle,'anticlockwise')
% newVert = [xr yr];

    center = [floor(size(2)/2) floor(size(1)/2)];
    newcenter = [floor(newsize(2)/2) floor(newsize(1)/2)];
    centerVector = [x-center(1) y-center(2)];
    [centerAngle,centerD] = cart2pol(centerVector(1), centerVector(2));
    [newCenterVector1,newCenterVector2] = pol2cart(centerAngle+rotateAngle, centerD);
    newVert = [newcenter(1)+newCenterVector1 newcenter(2)+newCenterVector2];
end