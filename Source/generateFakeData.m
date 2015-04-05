function [obj, data] = generateFakeData(m, con, outputs, lintimes, errorFunc, nonNegMeasurements, populate, seed, opts)
%function [obj, data] = generateFakeData(m, con, outputs, lintimes, errorFunc, nonNegMeasurements, populate, seed, opts)

if nargin < 9
    opts = [];
    if nargin < 8
        seed = [];
        if nargin < 7
            populate = [];
            if nargin < 6
                nonNegMeasurements = [];
            end
        end
    end
end

if isempty(nonNegMeasurements)
    nonNegMeasurements = true;
end
if isempty(populate)
    populate = true;
end

% Constants
ny = length(outputs);
nt = length(lintimes);

% Generate lists
outputList = vec(repmat(vec(outputs), 1,nt));
timesList = vec(repmat(vec(lintimes)', ny,1));
measurements = zeros(ny*nt,1);

% Do simulation if requested
if populate
    % Apply random stream
    if ~isempty(seed)
        rng_state = rng;
        rng(seed);
    end
    
    % Generate simulation
    sim = SimulateSelect(m,con,lintimes,opts);
    
    % Extract outputs
    measurements = vec(sim.y(lookup(outputs,1:size(sim.y,1)),:));
    
    for i = 1:ny
        for j = 1:nt
            ind = sub2ind([ny,nt], i, j);
            
            sd = errorFunc(timesList(ind), outputList(ind), measurements(ind));
            measurements(ind) = measurements(ind) + sd*randn;
        end
    end
    
    % Reset random stream
    if ~isempty(seed)
        rng(rng_state);
    end
end

if nonNegMeasurements
    if populate
        obj = objectiveWeightedSumOfSquaresNonNeg(outputList, timesList, errorFunc, measurements);
    else
        obj = objectiveWeightedSumOfSquaresNonNeg(outputList, timesList, errorFunc);
    end
else
    if populate
        obj = objectiveWeightedSumOfSquares(outputList, timesList, errorFunc, measurements);
    else
        obj = objectiveWeightedSumOfSquares(outputList, timesList, errorFunc);
    end
end

if nargout >= 2
    data.Outputs            = outputs;
    data.Times              = lintimes;
    data.OutputList         = outputList;
    data.TimesList          = timesList;
    data.ErrorFunction      = errorFunc;
    data.Measurements       = measurements;
end

end