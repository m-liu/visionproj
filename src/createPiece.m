function piece = createPiece( verts, im )
% creates a polygon struct based on vertices information

    numVerts = size(verts,1);
    %reorganize the list such that the top vertex is first
    %note: vertices are given in order, clockwise
    vertY = verts(:,2);
    ind = find(vertY==max(vertY));
    if (ind > 1)
        vertsTmp = verts(ind:end, :);
        vertsTmp = [vertsTmp; verts(1:ind-1,:)];
        verts = vertsTmp;
    end
    
    for i=1:numVerts
        if (i==1)
            vNext = verts(i+1,:) - verts(i,:);
            vPrev = verts(end,:) - verts(i,:);
        elseif (i==numVerts)
            vNext = verts(1,:) - verts(i,:);
            vPrev = verts(i-1,:) - verts(i,:);
        else
            vNext = verts(i+1,:) - verts(i,:);
            vPrev = verts(i-1,:) - verts(i,:);
        end
        dNext = norm( vNext );
        dPrev = norm( vPrev );
        
        %measure the counterclockwise angle between the prev and next vectors
        [thetaNext roNext] = cart2pol(vNext(1), vNext(2));
        [thetaPrev roPrev] = cart2pol(vPrev(1), vPrev(2));
        thetaNext = radtodeg(thetaNext);
        thetaPrev = radtodeg(thetaPrev);
        %next angle - prev angle
        angle = thetaNext - thetaPrev;
        if (angle < 0)
            angle = angle +360;
        end
        
        vertices(i) = struct('angle', angle, 'dNext', dNext, 'dPrev', dPrev, 'posX', verts(i,1), 'posY', verts(i,2));
        vertices(i)
    end
    
    %compute perimeter
    perimeter = 0;
    for i=1:size(vertices)
        perimeter = perimeter + vertices(i).dNext;
    end
    
    piece = struct ('vertices', vertices, 'perimeter', perimeter, 'im', im);


end

