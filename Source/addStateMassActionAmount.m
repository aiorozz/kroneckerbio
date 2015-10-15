function m = addStateMassActionAmount(m, name, compartment, ic)
%AddState Add a state species to a KroneckerBio model
%
%   m = AddState(m, name, compartment, seed)
%
%   Inputs
%   m: [ model struct scalar ]
%       The model to which the state will be added
%   name: [ string ]
%       A name for the state. This is the name by which reactions will
%       refer to it.
%   compartment: [ string ]
%       The name of the compartment to which it will be added
%   ic: [ string | nonnegative scalar | cell vector of strings
%           | cell matrix {0} ]
%       This is the name of the seed that will control the initial value of
%       this state. If it is an empty string, then no seed will control it,
%       and it will always have an initial condition of 0. If a number is
%       given, this will be the initial condition of the state, which will
%       not have an associated parameter.
%
%   Outputs
%   m: [ model struct scalar ]
%       The model with the new state added.

% (c) 2015 David R Hagen & Bruce Tidor
% This work is released under the MIT license.

% Clean-up inputs
if nargin < 4
    ic = [];
end

% Increment counter
nx = m.nx + 1;
m.nx = nx;
m.States = growStates(m.States, nx);

% Add item
m.States(nx).Name         = fixSpeciesName(name);
m.States(nx).Compartment  = fixCompartmentName(compartment);
m.States(nx).InitialValue = fixStateICMassAction(ic);

m.Ready = false;
