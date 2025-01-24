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
rw = 1.0;           % Ridge half-width
side = 1.5;         % Space on side

% Grid size:
dx = 0.0125;        % grid size (horizontal)
dy = 0.0125;        % grid size (vertical)

lambda = 1.55;      % vacuum wavelength
nmodes = 10;         % number of modes to compute

[x,y,xc,yc,nx,ny,eps,edges] = waveguidemesh([n1,n2,n3],[h1,h2,h3], ...
                                            rh,rw,side,dx,dy); 

% First consider the fundamental TE mode:

[Hx,Hy,neff] = wgmodes(lambda,n2,nmodes,dx,dy,eps,'000A');

fprintf(1,'neff = %.6f\n',neff);
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
% Updated plotting section TE mode
for mode_num = 1:nmodes
    fprintf(1, 'Mode %d, neff = %.6f\n', mode_num, neff(mode_num));
    
    figure(mode_num); % new figure for each mode
    subplot(121);
    contourmode(x, y, Hx(:, :, mode_num)); % Plot Hx for the current mode
    title(['Hx (TE mode ', num2str(mode_num), ')']); xlabel('x'); ylabel('y');
    for v = edges, line(v{:}); end

    subplot(122);
    contourmode(x, y, Hy(:, :, mode_num)); % Plot Hy for the current mode
    title(['Hy (TE mode ', num2str(mode_num), ')']); xlabel('x'); ylabel('y');
    for v = edges, line(v{:}); end
end





% Next consider the fundamental TM mode
% (same calculation, but with opposite symmetry)

% TM mode calculation for 10 modes
[Hx_TM, Hy_TM, neff_TM] = wgmodes(lambda, n2, nmodes, dx, dy, eps, '000S');

for mode_num = 1:nmodes
    fprintf(1, 'TM Mode %d, neff = %.6f\n', mode_num, neff_TM(mode_num));
    
    % Plot each TM mode in a new figure
    figure(nmodes + mode_num); % Avoid overlap with TE mode figures
    subplot(121);
    contourmode(x, y, Hx_TM(:, :, mode_num)); % Plot Hx for TM mode
    title(['Hx (TM mode ', num2str(mode_num), ')']); xlabel('x'); ylabel('y');
    for v = edges, line(v{:}); end

    subplot(122);
    contourmode(x, y, Hy_TM(:, :, mode_num)); % Plot Hy for TM mode
    title(['Hy (TM mode ', num2str(mode_num), ')']); xlabel('x'); ylabel('y');
    for v = edges, line(v{:}); end
end
