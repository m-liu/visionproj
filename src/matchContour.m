%generate a score of how well two edges match

%input: list of polygons described in tables

% Clockwise:
% Angle, distance_next, distance_prev, pos_x, pos_y
%
%
%
%
%

function [] = matchContour(polygons)
    %for each pair of polygons
	for polyi=1:size(polygons,1)
        for polyj=polyi:size(polygons,1)
            %for all vertices, look for complementary angles
            %TODO border angles should be 180 deg
            nvi = size(polygons(polyi), 1);
            nvj = size(polygons(polyj), 1);
            
            for vi=1:nvi
                for vj=1:nvj
                    anglesum = polygons(polyi).vertices(vi).angle + polygons(polyj).vertices(vj).angle
                    if (anglesum == 360)
                        
                    end
                    
                end
            end
            
            
        end
        
    end
    


end
