function sol = integrateSteadystateSys(m, con, opts)

% Constants
nx = m.nx;

% Construct system
[der, jac, eve] = constructSystem();

% Initial conditions
if opts.UseModelSeeds
    s = m.s;
else
    s = con.s;
end

ic = m.dx0ds * s + m.x0c;

% Input
if opts.UseModelInputs
    u = m.u;
    q = m.q;
else
    u = con.u;
    q = con.q;
end

% Integrate x over time
sol = accumulateOdeFwd(der, jac, 0, inf, ic, u, con.Discontinuities, 1:nx, opts.RelTol, opts.AbsTol(1:nx), [], eve, [], 1);
sol.u = u;
sol.C1 = m.C1;
sol.C2 = m.C2;
sol.c  = m.c;
sol.k = m.k;
sol.s = s;
sol.q = q;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% The system for integrating x %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [der, jac, eve] = constructSystem()
        f    = m.f;
        dfdx = m.dfdx;
        
        der = @derivative;
        jac = @jacobian;
        eve = @events;
        
        % Derivative of x with respect to time
        function val = derivative(t, x, u)
            u   = u(-1);
            val = f(t, x, u);
        end
        
        % Jacobian of x derivative
        function val = jacobian(t, x, u)
            u   = u(-1);
            val = dfdx(t, x, u);
        end
        
        % Steady-state event
        function [value, isTerminal, direction] = events(t, x, u)
            u = u(-1);

            % Absolute change
            absDiff = con.tF * f(-1, x, u); % Change over an entire simulation
            
            % Relative change
            relDiff = absDiff ./ x;
            
            % Either absolute change or relative change must be less than
            % the tolerance for all species
            value = max(min(abs(absDiff) - opts.AbsTol(1:nx), abs(relDiff) - opts.RelTol));
            if value < 0
                value = 0;
            end
            
            % Always end and only care about drops below the threshold
            isTerminal = true;
            direction = -1;
        end
    end
end
