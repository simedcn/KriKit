function [ExpectedImprovement]=calcExpectedImprovement(obj,varargin)
% [ExpectedImprovement]=calcExpectedImprovement(obj,KrigingObjectIndex,pointsOfInterest)
%
% Input:
% - KrigingObjectIndex ... indicates the which Kriging Objective is
%                          considered [1X1]
% - pointsOfInterest ... maxtrix containting the points of interest
%                        [nPointsXnInputVar] 
%
% Output:
% - ExpectedImprovement ... vector containing the expected improvment value
%                           associated with input points given in
%                           "pointsOfInterest" [nPointsX1]
%
% You can set: -
%
% You can get: -
%
% For further optional settings and more details about the calculation of
% expected improvement see "calcExpectedImprovementMainPart()"
%
% Note: For more information about how to introduces fuzzy inequality
% constraints for the output see documentation for
% "modExpImprByOutputConstr". For fuzzy constraints the probability is
% calculated that these constraints hold. If fuzzy constraints are
% available than the modified expected improvement value is a compormise
% between achieving high improvement and not violating the constraints.
% This should be prefered for Markov Chain Monte Charlo Design of
% Experiment instead of hard constraints.
% 
% Copyright 2014-2016: Lars Freier, Eric von Lieres
% See the license note at the end of the file.

% Initialization
KrigingObjectIndex = varargin{1};
pointsOfInterest = varargin{2};

if isempty(pointsOfInterest)
    ExpectedImprovement = [];
    return
end

inputWasTransposed = false;
if size(pointsOfInterest,1)==obj.KrigingObjects{KrigingObjectIndex}.getnInputVar &&...
   size(pointsOfInterest,2)~=obj.KrigingObjects{KrigingObjectIndex}.getnInputVar
        pointsOfInterest = pointsOfInterest';
        inputWasTransposed = true;
end


%% Make Prediction
prediction = obj.KrigingObjects{KrigingObjectIndex}.prediction(pointsOfInterest);
prediction(:,1) = -obj.MinMax(KrigingObjectIndex)*prediction(:,1);

%% Actual Calculation of the Expected improvement
if length(varargin)>2
    checkPoint = varargin{3};
    [ExpectedImprovement] = calcExpectedImprovementMainPart(obj,KrigingObjectIndex,prediction,checkPoint);
else
    [ExpectedImprovement] = calcExpectedImprovementMainPart(obj,KrigingObjectIndex,prediction);
end

% Final Output
if inputWasTransposed
    ExpectedImprovement = ExpectedImprovement';
end

% Include Inequality constraint distribution into final expected
% improvement
if isprop(obj,'InequalityConstraintOutputDistribution')&&~isempty(obj.getInequalityConstraintOutputDistribution)
    predictionProto = -obj.MinMax(KrigingObjectIndex)*prediction(:,1);
    ExpectedImprovement = obj.modExpImprByOutputConstr(ExpectedImprovement,predictionProto,prediction(:,2));
end

end
% =============================================================================
%  KriKit - Kriging toolKit
%  
%  Copyright 2014-2016: Lars Freier(1), Eric von Lieres(1)
%                                      
%    (1)Forschungszentrum Juelich GmbH, IBG-1, Juelich, Germany.
%  
%  All rights reserved. This program and the accompanying materials
%  are made available under the terms of the GNU Public License v3.0 (or, at
%  your option, any later version) which accompanies this distribution, and
%  is available at http://www.gnu.org/licenses/gpl.html
% =============================================================================
