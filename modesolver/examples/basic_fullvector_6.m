% This example shows how to calculate and plot both the
% fundamental TE and TM eigenmodes of an example 3-layer ridge
% waveguide using the full-vector eigenmode solver.  

% Refractive indices:
n1 = 3.34;          % Lower cladding
n2 = 3.44;          % Core
n3 = 1.00;          % Upper cladding (air)

% Layer heights:
h1 = 2.0;           % Lower cladding
h2 = 1.3;           % Core thickness
h3 = 0.5;           % Upper cladding

% Horizontal dimensions:
rh = 1.1;           % Ridge height

%========== Removed 
%rw = 1.0;           % Ridge half-width



side = 1.5;         % Space on side

% Grid size:
dx = 0.0125;        % grid size (horizontal)
dy = 0.0125;        % grid size (vertical)

% make the mesh 8 times Less dense===========================
% dx = dx * 8;
% dy = dy * 8;


lambda = 1.55;      % vacuum wavelength
nmodes = 1;         % number of modes to compute


%============= Added 
n2_values = linspace(3.305, 3.44, 10);

neff_values = zeros(1, 10); % Store effective indices
rw = 0.5;
%============= Added 
for i = 1:10
    n2 = n2_values(i); % Update ridge index

    % Create waveguide mesh for the current n2
    [x, y, xc, yc, nx, ny, eps, edges] = waveguidemesh([n1, n2, n3], [h1, h2, h3], rh, rw, side, dx, dy);

    % Calculate the TE mode
    [Hx, Hy, neff] = wgmodes(lambda, n2, nmodes, dx, dy, eps, '000A');
    neff_values(i) = neff; % Store effective index

    % Plot the mode for this refractive index
    %subplot(2, 5, i); % Arrange plots in a 2x5 grid
    
    figure(i); % Create a new figure for each index


    subplot(122);
    contourmode(x, y, Hx); % Plot Hx for TE mode
    title(['n2 = ', num2str(n2, '%.3f')]); % Add title showing n2 value
    xlabel('x'); ylabel('y');
    for v = edges, line(v{:}); end

    %  Hy
    subplot(122); % Right subplot for Hy
    contourmode(x, y, Hy);
    title(['Hy for n2 = ', num2str(n2, '%.3f')]);
    xlabel('x'); ylabel('y');
    for v = edges, line(v{:}); end


end


% for i = 1:10
%     rw = rw_values(i); % Update ridge half-width
% 
%     % Create waveguide mesh for current ridge half-width
%     [x, y, xc, yc, nx, ny, eps, edges] = waveguidemesh([n1, n2, n3], [h1, h2, h3], rh, rw, side, dx, dy);
% 
%     % Calculate the TE mode
%     [Hx, Hy, neff] = wgmodes(lambda, n2, nmodes, dx, dy, eps, '000A');
%     neff_values(i) = neff; % Store effective index
% 
%     % Plot the mode for this ridge half-width
%     subplot(2, 5, i); % Arrange plots in a 2x5 grid
%     contourmode(x, y, Hx); % Plot Hx for TE mode
%     title(['rw = ', num2str(rw, '%.3f')]); % Add title showing rw value
%     xlabel('x'); ylabel('y');
%     for v = edges, line(v{:}); end
% end


% figure;
% plot(rw_values, neff_values, '-o', 'LineWidth', 1.5);
% xlabel('Ridge Half-Width (rw)');
% ylabel('Effective Index (neff)');
% title('Effective Index vs Ridge Half-Width');
% grid on;


%============= Added 
figure;
plot(n2_values, neff_values, '-o', 'LineWidth', 1.5);
xlabel('Ridge Refractive Index (n2)');
ylabel('Effective Index (neff)');
title('Effective Index vs Ridge Refractive Index');
grid on;



% First consider the fundamental TE mode:

% [Hx,Hy,neff] = wgmodes(lambda,n2,nmodes,dx,dy,eps,'000A');
% 
% fprintf(1,'neff = %.6f\n',neff);
%====== Original========================
% figure(1);
% subplot(121);
% contourmode(x,y,Hx);
% title('Hx (TE mode)'); xlabel('x'); ylabel('y'); 
% for v = edges, line(v{:}); end
% subplot(122);
% contourmode(x,y,Hy);
% title('Hy (TE mode)'); xlabel('x'); ylabel('y'); 
% for v = edges, line(v{:}); end
%=========================================


%====== Added Code ========================
%======== Removed=====================
% Updated plotting section TE mode
% for mode_num = 1:nmodes
%     fprintf(1, 'Mode %d, neff = %.6f\n', mode_num, neff(mode_num));
% 
%     figure(mode_num); % new figure for each mode
%     subplot(121);
%     contourmode(x, y, Hx(:, :, mode_num)); % Plot Hx for the current mode
%     title(['Hx (TE mode ', num2str(mode_num), ')']); xlabel('x'); ylabel('y');
%     for v = edges, line(v{:}); end
% 
%     subplot(122);
%     contourmode(x, y, Hy(:, :, mode_num)); % Plot Hy for the current mode
%     title(['Hy (TE mode ', num2str(mode_num), ')']); xlabel('x'); ylabel('y');
%     for v = edges, line(v{:}); end
% end


%================== Added 
fprintf(1, 'TE Mode, neff = %.6f\n', neff);

figure(1); % Single figure
subplot(121);
contourmode(x, y, Hx); % Plot Hx for TE mode
title('Hx (TE mode)'); xlabel('x'); ylabel('y');
for v = edges, line(v{:}); end

subplot(122);
contourmode(x, y, Hy); % Plot Hy for TE mode
title('Hy (TE mode)'); xlabel('x'); ylabel('y');
for v = edges, line(v{:}); end

% Plot Hy
subplot(122); % Right subplot for Hy
contourmode(x, y, Hy);
title(['Hy for n2 = ', num2str(n2, '%.3f')]);
xlabel('x'); ylabel('y');
for v = edges, line(v{:}); end



% Next consider the fundamental TM mode
% (same calculation, but with opposite symmetry)


% ========= Removed =================================
% TM mode calculation for 10 modes
% [Hx_TM, Hy_TM, neff_TM] = wgmodes(lambda, n2, nmodes, dx, dy, eps, '000S');
% 
% for mode_num = 1:nmodes
%     fprintf(1, 'TM Mode %d, neff = %.6f\n', mode_num, neff_TM(mode_num));
% 
%     % Plot each TM mode in a new figure
%     figure(nmodes + mode_num); % Avoid overlap with TE mode figures
%     subplot(121);
%     contourmode(x, y, Hx_TM(:, :, mode_num)); % Plot Hx for TM mode
%     title(['Hx (TM mode ', num2str(mode_num), ')']); xlabel('x'); ylabel('y');
%     for v = edges, line(v{:}); end
% 
%     subplot(122);
%     contourmode(x, y, Hy_TM(:, :, mode_num)); % Plot Hy for TM mode
%     title(['Hy (TM mode ', num2str(mode_num), ')']); xlabel('x'); ylabel('y');
%     for v = edges, line(v{:}); end
% end
