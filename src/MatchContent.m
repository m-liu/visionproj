%% MatchContent
%  This function takes a pair of matrices, X and Y, each with dimension Kx3
%  then computes a match score based on the input. The equation is taken
%  from: http://people.csail.mit.edu/taegsang/Documents/JigsawSolver.pdf

function [score] = MatchContent(X, Y)

% Note this equation works with LAB space colors, that is the assumption

% dissimilarity based on sum of square differences
score = sum(sum(sum((X - Y).^2)));

% dissimilarity based on sum of square root differences
score = sum(sum(sum(sqrt(abs(X - Y)))));

% normalize score according to the size of the input array
% score = score/size(X,1);

end