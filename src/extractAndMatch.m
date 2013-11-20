function [matchScore] = extractAndMatch(imi, imj, verti, verti2, vertj, vertj2)
    % calculate the difference vector between the given vertices
    vectori = [verti2.posX-verti.posX verti2.posY-verti.posY];
    vectorj = [vertj2.posX-vertj.posX vertj2.posY-vertj.posY];
    
    % convert into polar coordinates to get the angle with respect to 270
    % degrees (lining the edges vertically with the first vertex on top)
    [anglei,di] = cart2pol(vectori(1), vectori(2));
    [anglej,dj] = cart2pol(vectorj(1), vectorj(2));
    
    imiRotated = imrotate(imi, 270-anglei);
    imjRotated = imrotate(imj, 270-anglej);
    
    % map the vertices to new coordinates on the rotated images
    newVerti = mapCoord(verti.posX, verti.posY, size(imi), 270-anglei);
    newVerti2 = mapCoord(verti2.posX, verti2.posY, size(imi), 270-anglei);
    newVertj = mapCoord(vertj.posX, vertj.posY, size(imj), 270-anglej);
    newVertj2 = mapCoord(vertj2.posX, vertj2.posY, size(imj), 270-anglej);
    
    % check that the new difference vectors are vertical
    newVectori = newVerti - newVerti2;
    newVectorj = newVertj - newVertj2;
    assert(newVectori(1) == 0 && newVectorj(1) == 0);
    
    % take the shorter of the two edges
    minEdge = min(newVectori(2),newVectorj(2));
    
    extractedEdgei = zeros(minEdge, 3);
    extractedEdgej = zeros(minEdge, 3);
    for index=1:minEdge
        for adj=1:5
            if ~(imiRotated(newVerti(1)+adj,newVerti(2)+index-1,:) == 255)
                extractedEdgei(index) = imiRotated(newVerti(1)+adj,newVerti(2)+index-1,:);
                break;
            elseif ~(imiRotated(newVerti(1)-adj,newVerti(2)+index-1,:) == 255)
                extractedEdgei(index) = imiRotated(newVerti(1)-adj,newVerti(2)+index-1,:);
                break;
            end
            if adj == 10
                warning('No colored pixel found for imi at (%d,%d)', newVerti(1), newVerti(2)+index-1);
            end
        end
        for adj=1:5
            if ~(imjRotated(newVertj(1)+adj,newVertj(2)+index-1,:) == 255)
                extractedEdgej(index) = imjRotated(newVertj(1)+adj,newVertj(2)+index-1,:);
                break;
            elseif ~(imjRotated(newVertj(1)-adj,newVertj(2)+index-1,:) == 255)
                extractedEdgej(index) = imjRotated(newVertj(1)-adj,newVertj(2)+index-1,:);
                break;
            end
            if adj == 10
                warning('No colored pixel found for imj at (%d,%d)', newVertj(1), newVertj(2)+index-1);
            end
        end
    end
   
    matchScore = matchContent(extractedEdgei, extractedEdgej);
end

function newVert = mapCoord(x, y, size, rotateAngle)
    center = [floor(size(2)/2) floor(size(1)/2)];
    centerVector = [x-center(1) y-center(2)];
    [centerAngle,centerD] = cart2pol(centerVector(1), centerVector(2));
    newCenterVector = pol2cart(centerAngle+rotateAngle, centerD);
    newVert = [x+newCenterVector(1) y+newCenterVector(2)];
end