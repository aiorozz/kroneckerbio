function states = growStates(states, nx)

if nargin < 2
    nx = 0;
    if nargin < 1
        states = [];
    end
end

% Add more room in vector if necessary
current = numel(states);
add = nx - current;
if add > 0 || isempty(states)
    % Double length
    add = max(current,add);
    states = [states; struct('Name', cell(add,1), 'Compartment', cell(add,1), 'InitialValue', cell(add,1))];
end
