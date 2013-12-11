%generate a score of how well two edges match

%input: list of polygons described in tables

% Clockwise:
% Angle, distance_next, distance_prev, pos_x, pos_y
%
%
%
%
%

function [newPolygons] = matchContour(polygons)
    %keep track of a score for all the pieces and each vertex
    % [1] = first polygon index; [2] = second polygon index
    % [3] = first polgyon vertex index; [4] second polgyon vertex index
    % [5] = contour match score
    scores = [];
    global angleErr; 
    angleErr = 5;
    dErr = 3
    
    %for each pair of polygons
	for polyi=1:size(polygons,2)
        for polyj=(polyi+1):size(polygons,2)
            %get perimeters
            periPolyi = polygons(polyi).perimeter;
            periPolyj = polygons(polyj).perimeter;
            %for all vertices, look for complementary angles
            %TODO border angles should be 180 deg
            nvi = size(polygons(polyi).vertices, 2);
            nvj = size(polygons(polyj).vertices, 2);
            
            imi = polygons(polyi).im;
            imj = polygons(polyj).im;
            
            for vi=1:nvi
                for vj=1:nvj
                    sc = 0; 
                    matchScore = inf;
                    verti = polygons(polyi).vertices(vi);
                    vertj = polygons(polyj).vertices(vj);
                    vertiNext = polygons(polyi).vertices(mod(vi,nvi)+1);
                    vertiPrev = polygons(polyi).vertices(mod(nvi+vi-2,nvi)+1);
                    vertjNext = polygons(polyj).vertices(mod(vj,nvj)+1);
                    vertjPrev = polygons(polyj).vertices(mod(nvj+vj-2,nvj)+1);
                    %check angles sum to 360
                    %TODO give an error threshold for approximation
                    anglesum = verti.angle + vertj.angle;
                    if (anglesum < 360+angleErr && anglesum > 360-angleErr)        
                       %extract edges for content matching
                       
                                             

                       %check distance between vertex and neighbour
                       % note: vertices are recorded clockwise
                       if ( approxEq(verti.dNext,vertj.dPrev, dErr) && approxEq(verti.dPrev,vertj.dNext,dErr) ) 
                           sc = 5;
                           %perimeter score. If the matching contour is more than 1/10 of the sum of perimeters of both polygons,
                           %add 2
                           if ( (verti.dNext + verti.dPrev) > (0.2 * (periPolyi+periPolyj)) )
                               sc = sc + 2;
                           end
                           
                           %content match score
                           matchScore = (extractAndMatch(imi, imj, verti, vertiNext, vertj, vertjPrev) + ...
                                            extractAndMatch(imi, imj, verti, vertiPrev, vertj, vertjNext)) / 2;
                           
                       elseif ( approxEq(verti.dNext, vertj.dPrev, dErr) )
                           sc = 1;
                           %perimeter score. If the matching contour is more than 1/20 of the sum of perimeters of both polygons,
                           %add 1
                           if ( verti.dNext > 0.1 * (periPolyi+periPolyj) )
                               sc = sc + 1;
                           end
                           
                           %content match score
                           matchScore = extractAndMatch(imi, imj, verti, vertiNext, vertj, vertjPrev);
                           
                       elseif ( approxEq(verti.dPrev, vertj.dNext, dErr) )
                           sc = 1;
                           %perimeter score. If the matching contour is more than 1/20 of the sum of perimeters of both polygons,
                           %add 1
                           if ( verti.dPrev > (0.1 * (periPolyi+periPolyj)) )
                               sc = sc + 1;
                           end
                           
                           %content match score
                           matchScore = extractAndMatch(imi, imj, verti, vertiPrev, vertj, vertjNext);
                       else 
                           %not a good match
                           %content match score
                           matchScore = (extractAndMatch(imi, imj, verti, vertiNext, vertj, vertjPrev) + ...
                                            extractAndMatch(imi, imj, verti, vertiPrev, vertj, vertjNext)) / 2;
                       end
                    else
                        %content match score
                        matchScore = extractAndMatch(imi, imj, verti, vertiPrev, vertj, vertjNext);
                    end
                    scores(end+1, :) = [polyi polyj vi vj sc -matchScore];
                end
            end 
        end
    end
        
    %TEST
    %random perm scores
    %perm = randperm(size(scores,1));
    %scores = scores(perm,:);
    
        %sort the scores and extract best score 
        scores = sortrows(scores, [5 6]);    
        %scores = sortrows(scores, 5);
        bestMatch = scores(end, :);
        
        %merge the two polygons that match on the angle
        newPoly = mergePolygons(polygons(bestMatch(1)), polygons(bestMatch(2)), bestMatch(3), bestMatch(4) )
        
        %remove the two polygons from the original set
        %add the new polygon
        polygons(bestMatch(1)) = newPoly;
        polygons(bestMatch(2)) = [];
        
        %return the new set
        newPolygons = polygons;

end

function res = approxEq (v1, v2, err)
    if ( abs(v1-v2) < err )
        res= 1;
    else
        res= 0;
    end
        
end
