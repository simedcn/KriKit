function [] = plotInterpolation_23D(obj,varargin)
% []=plotInterpolation_23D(KrigingObjectIndex,dimensionInterpolation,plotExpectedImprovement,plotContour)
%
% Creates a 2D or 3D plot using the interpolation data and information
% generated by "calcMutualInterpolation_23D()"
%
% Input: 
% KrigingObjectIndex ... index of Kriging Object(s) used when
%                        "calcMutualInterpolation_23D()" was called
% dimensionInterpolation ... decision if 2D or 3D interpolation shall be
%                            created. dimensionInterpolation has to be
%                            consistent with the call of
%                            "calcMutualInterpolation_23D()" 
% plotExpectedImprovement ... if true, expected improvement at
%                             interpolation points is plotted. For further
%                             details about expected improvement see
%                             "calcExpectedImprovement()". 
%                             Note: plotExpectedImprovement cannot be
%                             combined with mutual interpolation
% plotContour   ... if true, contour plot is created instead of a mesh
%                   plot. In case of plotting the Kriging prediction, the
%                   confidence intervals are ignored
%
%
% You can set:
% - ShowBounds ... If true, the confidence interval is displayed. Width of
%                  confidence interval depends on value of
%                  "WidthConfidenceInterval"
% - WidthConfidenceInterval ... width of the confidence interval:
%   KrigingPrediction +(-) WidthConfidenceInterval*KrigingStandardDeviation
% - ShowData ... If true, provided data points are visualized in the plot
% - SuppressFigure ... If true, figure is hidden
% - ColormapToolbox ... colormap used for plots. By default, reverse winter
%                       colormap
%
% You can get: -
%
% Copyright 2014-2016: Lars Freier, Eric von Lieres
% See the license note at the end of the file.


%% Initialization    
KrigingObjectIndex = varargin{1};
dimensionInterpolation = varargin{2};
if length(varargin)>2&&~isempty(varargin{3})
    plotExpectedImprovement = varargin{3};
else
    plotExpectedImprovement = false;
end
if length(varargin)>3&&~isempty(varargin{4})
    plotContour = varargin{4};
else
    plotContour = false;
end

% In case of mutual Kriging interpolation, the prediction of all
% objects is saved redundant, such that only the first index should
% be used
KrigingObjectIndex = obj.checkKrigingIndizes(KrigingObjectIndex);
KrigingObjectIndexArray = KrigingObjectIndex;
KrigingObjectIndex = KrigingObjectIndexArray(1);

% Get data and rescale if neccesary
[prediction,LB,UB] = scaleData(dimensionInterpolation);

% Create empty figure
if obj.SuppressFigure==1
    figure('Visible','off')
else
    figure()
end
hold on

% Calculate Epxetected improvement if needed
if plotExpectedImprovement
    [expImprovement] = calcExpImprovementForPlot();
else
    expImprovement = [];
end
%%  Actual Plotting

% Plot Kriging estimation
[AccuracyTemp] = plotKrigingEstimation(dimensionInterpolation,expImprovement);

% Plot lower and upper bound 
if ~plotExpectedImprovement&&~plotContour
    plotConfidenceTube(dimensionInterpolation);
end

% Plot provided Data
if obj.ShowData==true
    plotDataAndMarkOutliers(dimensionInterpolation,KrigingObjectIndexArray);
end

% Finale Adjustments
obj.labelPlots_23D(KrigingObjectIndex,dimensionInterpolation,plotExpectedImprovement,plotContour)
alpha(obj.AlphaValue)

% Set Colormap
colormap(gcf,obj.ColormapToolbox);
grid on

%% Nested Functions
% -------------------------------------------------------------------------
function [expImprovement] = calcExpImprovementForPlot()
    % Get data and rescale if neccesary
    switch dimensionInterpolation
        case 2
            prediction = obj.KrigingPrediction_Interpolation2D{KrigingObjectIndex,1};
%             prediction(:,1) = -obj.MinMax(KrigingObjectIndex)*prediction(:,1);
%             expImprovement = obj.calcExpectedImprovement(KrigingObjectIndex,obj.KrigingPrediction_Interpolation2D{KrigingObjectIndex,2});
%             expImprovement = obj.calcExpectedImprovementMainPart(KrigingObjectIndex,prediction);
        case 3
            prediction = obj.KrigingPrediction_Interpolation3D{KrigingObjectIndex,1};
            
%             expImprovement = obj.calcExpectedImprovement(KrigingObjectIndex,obj.KrigingPrediction_Interpolation3D{KrigingObjectIndex,2});
        otherwise
            error('plotInterpolation_23D is only possible for 2D and 3D interpolation')
    end
    prediction(:,1) = -obj.MinMax(KrigingObjectIndex)*prediction(:,1);
    expImprovement = calcExpectedImprovementMainPart(obj,KrigingObjectIndex,prediction);
    
end
% -------------------------------------------------------------------------
function [prediction,LB,UB] = scaleData(dimensionInterpolation)
    % Get data and rescale if neccesary
    switch dimensionInterpolation
        case 2
            prediction = obj.KrigingPrediction_Interpolation2D{KrigingObjectIndex,1}(:,1);
            LB = prediction-obj.WidthConfidenceInterval*obj.KrigingPrediction_Interpolation2D{KrigingObjectIndex,1}(:,2);
            UB = prediction+obj.WidthConfidenceInterval*obj.KrigingPrediction_Interpolation2D{KrigingObjectIndex,1}(:,2);
        case 3
            prediction = obj.KrigingPrediction_Interpolation3D{KrigingObjectIndex,1}(:,1);
            LB = prediction-obj.WidthConfidenceInterval*obj.KrigingPrediction_Interpolation3D{KrigingObjectIndex,1}(:,2);
            UB = prediction+obj.WidthConfidenceInterval*obj.KrigingPrediction_Interpolation3D{KrigingObjectIndex,1}(:,2);
        otherwise
                error('Plotting function is only allowed for 2D and 3D interpolation')
    end
end
% -------------------------------------------------------------------------
function [AccuracyTemp] = plotKrigingEstimation(dimensionInterpolation,expImprovement)
    
    
    switch dimensionInterpolation
        case 2
            % Number of data
            AccuracyTemp = sqrt(length(obj.KrigingPrediction_Interpolation2D{KrigingObjectIndex,1}(:,1)));
            inputIndices = obj.KrigingPrediction_Interpolation2D{KrigingObjectIndex,3};
            
            % Plot actual prediction
            if plotExpectedImprovement
                plot(obj.KrigingPrediction_Interpolation2D{KrigingObjectIndex,2}(:,inputIndices),...
                     expImprovement,'k','LineWidth',2);
            else
                plot(obj.KrigingPrediction_Interpolation2D{KrigingObjectIndex,2}(:,inputIndices),...
                     prediction,'k','LineWidth',2);
            end
            % Plot lower and upper bound
        case 3
            % Number of data
            AccuracyTemp = sqrt(length(obj.KrigingPrediction_Interpolation3D{KrigingObjectIndex,1}(:,1)));
            inputIndices = obj.KrigingPrediction_Interpolation3D{KrigingObjectIndex,3};
            
            % Plot actual prediction
            if plotExpectedImprovement
                output = expImprovement;
            else
                output = prediction;
            end
            
            if plotContour
                contourf(unique(obj.KrigingPrediction_Interpolation3D{KrigingObjectIndex,2}(:,inputIndices(1))),...
                         unique(obj.KrigingPrediction_Interpolation3D{KrigingObjectIndex,2}(:,inputIndices(2))),...
                         reshape(output,AccuracyTemp,AccuracyTemp)')
            else
                surf(unique(obj.KrigingPrediction_Interpolation3D{KrigingObjectIndex,2}(:,inputIndices(1))),...
                         unique(obj.KrigingPrediction_Interpolation3D{KrigingObjectIndex,2}(:,inputIndices(2))),...
                         reshape(output,AccuracyTemp,AccuracyTemp)')
            end
        otherwise
                error('Plotting function is only allowed for 2D and 3D interpolation')
    end
end
% -------------------------------------------------------------------------
function [] = plotConfidenceTube(dimensionInterpolation)
    % Plot lower and upper bound 
    if obj.ShowBounds==1
        switch dimensionInterpolation
            case 2
                % LB
                 plot(obj.KrigingPrediction_Interpolation2D{KrigingObjectIndex,2}(:,obj.KrigingPrediction_Interpolation2D{KrigingObjectIndex,3}),...
                     LB,'-.','Color',[0.3 0.3 0.3]);

                 % UB
                 plot(obj.KrigingPrediction_Interpolation2D{KrigingObjectIndex,2}(:,obj.KrigingPrediction_Interpolation2D{KrigingObjectIndex,3}),...
                     UB,'-.','Color',[0.3 0.3 0.3]);
            case 3
                % LB
                 surf(unique(obj.KrigingPrediction_Interpolation3D{KrigingObjectIndex,2}(:,obj.KrigingPrediction_Interpolation3D{KrigingObjectIndex,3}(1))),...
                 unique(obj.KrigingPrediction_Interpolation3D{KrigingObjectIndex,2}(:,obj.KrigingPrediction_Interpolation3D{KrigingObjectIndex,3}(2))),...
                 reshape(LB,AccuracyTemp,AccuracyTemp)')

                 % UB
                 surf(unique(obj.KrigingPrediction_Interpolation3D{KrigingObjectIndex,2}(:,obj.KrigingPrediction_Interpolation3D{KrigingObjectIndex,3}(1))),...
                 unique(obj.KrigingPrediction_Interpolation3D{KrigingObjectIndex,2}(:,obj.KrigingPrediction_Interpolation3D{KrigingObjectIndex,3}(2))),...
                 reshape(UB,AccuracyTemp,AccuracyTemp)')
            otherwise
                    error('Plotting function is only allowed for 2D and 3D interpolation')
        end
    end
end
% -------------------------------------------------------------------------
function [] = plotDataAndMarkOutliers(dimensionInterpolation,KrigingObjectIndexArray)
    for iKrigingObject=KrigingObjectIndexArray'
        [Data,dataShown,OutlierShown]=obj.determineRelevantDataPointsForPlot(iKrigingObject,dimensionInterpolation);
        % Copy Output Data
        OutputData = obj.KrigingObjects{iKrigingObject}.getOutputData;

        if plotExpectedImprovement
            evaluationValuesData = obj.calcExpectedImprovement(iKrigingObject,Data(dataShown,:));
            evaluationValuesOutliers = obj.calcExpectedImprovement(iKrigingObject,Data(OutlierShown,:));
        else
            evaluationValuesData = OutputData(dataShown);
            evaluationValuesOutliers = OutputData(OutlierShown);
        end
                
        switch dimensionInterpolation
            case 2
                plot(Data(dataShown,obj.KrigingPrediction_Interpolation2D{iKrigingObject,3}),...
                evaluationValuesData,...
                'ko','MarkerFaceColor',[255/255 102/255 0/255]);

                plot(Data(OutlierShown,obj.KrigingPrediction_Interpolation2D{iKrigingObject,3}),...
                evaluationValuesOutliers,...
                'ko','MarkerFaceColor','k');
            case 3
                inputData = [Data(dataShown,obj.KrigingPrediction_Interpolation3D{iKrigingObject,3}(1)),...
                        Data(dataShown,obj.KrigingPrediction_Interpolation3D{iKrigingObject,3}(2))];
                inputOutlier = [Data(OutlierShown,obj.KrigingPrediction_Interpolation3D{iKrigingObject,3}(1)),...
                    Data(OutlierShown,obj.KrigingPrediction_Interpolation3D{iKrigingObject,3}(2))];
                if plotContour
                    plot(inputData(:,1),inputData(:,2),...
                        'ko','MarkerFaceColor',[255/255 102/255 0/255]);

                    plot(inputOutlier(:,1),inputOutlier(:,2),...
                        'ko','MarkerFaceColor','k');
                else
                    plot3(inputData(:,1),inputData(:,2),...
                        evaluationValuesData,...
                        'ko','MarkerFaceColor',[255/255 102/255 0/255]);

                    plot3(inputOutlier(:,1),inputOutlier(:,2),...
                        evaluationValuesOutliers,...
                        'ko','MarkerFaceColor','k');
                end
            otherwise
                error('Plotting function is only allowed for 2D and 3D interpolation')
        end
    end
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
