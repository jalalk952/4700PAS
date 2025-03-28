function Electron1D()
    Nsteps = 200;
    dt = 1e-14; % time step
    q = 1.6e-19; m = 9.1e-31; E = 1e3; % charge, mass, electric field

    % x = zeros(1, Nsteps); % position
    % v = zeros(1, Nsteps); % velocity

    Np = 100; % number of electrons
x = zeros(Np, Nsteps);
v = zeros(Np, Nsteps);


    a = (q * E) / m; % constant acceleration
% 
%     for i = 2:Nsteps
%         % v(i) = v(i-1) + a * dt;
% %======Added
% Pscatter = 0.05; % 5% chance of scattering
% 
% if rand < Pscatter
%     v(i) = 0; % scatter: reset velocity to zero
% else
%     v(i) = v(i-1) + a * dt; % regular update
% end
% 
%         x(i) = x(i-1) + v(i) * dt;
%     end
% %==================
Pscatter = 0.05;

for i = 2:Nsteps
    for n = 1:Np
        if rand < Pscatter
            v(n, i) = 0;
        else
            v(n, i) = v(n, i-1) + a * dt;
        end
        x(n, i) = x(n, i-1) + v(n, i) * dt;
    end
end

    % for i = 1:Nsteps
    %     subplot(2,1,1);
    %     plot(x(1:i), 'b'); ylabel('Position'); hold on;
    %     plot(i, x(i), 'ro'); hold off;
    % 
    %     subplot(2,1,2);
    %     plot(v(1:i), 'r'); ylabel('Velocity'); hold on;
    %     plot(i, v(i), 'bo'); hold off;
    % 
    %     % sgtitle('Electron Motion (No Scattering)');
    %     sgtitle(['Electron Motion | Drift Velocity = ' num2str(driftV, '%.2e') ' m/s']);
    % 
    % 
    %     pause(0.01);
    % end
    driftV = mean(v(:, end));

    for i = 1:Nsteps
    subplot(2,1,1);
    plot(x(:, i), '.'); ylabel('Position');

    subplot(2,1,2);
    plot(v(:, i), '.'); ylabel('Velocity');

    sgtitle(['Electron Motion | Drift Velocity = ' num2str(driftV, '%.2e') ' m/s']);
    pause(0.01);
end

end



% driftV = mean(v);


