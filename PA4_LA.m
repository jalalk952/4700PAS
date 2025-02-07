% Set grid size
nx = 50;  % X points
ny = 50;  % Y points
ni = 3000; % Iterations

% Initialize voltage matrix
V = zeros(nx, ny);

% Iterative solver loop
for k = 1:ni
    for i = 1:nx  % Loop over X points
        for j = 1:ny  % Loop over Y points
            
            % Apply boundary conditions
            if j == 1
                 V(i,j) = V(i,j+1); % Top (insulating).
                % V(i,j) = 0;
            elseif j == ny
                  V(i,j) = V(i,j-1); % Bottom (insulating)
                 % V(i,j) = 0;
            else
                if i == 1
                    V(i,j) = 1; % Left boundary = 1V
                elseif i == nx
                    V(i,j) = 0; % Right boundary = 1V (was 0V, fixed)
                else
                    % Update voltage using the average of neighboring points
                    V(i,j) = (V(i+1,j) + V(i-1,j) + V(i,j+1) + V(i,j-1)) / 4;
                end
            end
        end
    end
    % Update visualization every 50 iterations
    if mod(k,50) == 0
        surf(V'); % 3D voltage plot
        xlabel('X-axis');
        ylabel('Y-axis');
        zlabel('Voltage (V)');
        title(['Voltage Distribution - Iteration ', num2str(k)]);
        shading interp;
        pause(0.05);
    end
end

% Compute Electric Field (E = ∇V)
[Ex, Ey] = gradient(V);

% Plot Electric Field Vectors
figure;
quiver(-Ey', -Ex', 0.5); % Shows direction & magnitude of E-field
xlabel('X-axis');
ylabel('Y-axis');
title('Electric Field Vectors');



%Dirichlet BC The voltage at the left side is 1V, no matter what
%Neumann BC: The voltage at the left side can change, but the slope (derivative) is 0