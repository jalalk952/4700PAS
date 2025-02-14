clear; clc;
nx = 50; % Number of grid points in x-direction
ny = 50; % Number of grid points in y-direction
N = nx * ny; % Total number of nodes

%viii. Change nx and ny so they are not equal. What occurs?
%=========== Modified
% nx = 60; % Change nx to be different from ny
% ny = 40; 
% N = nx * ny;  
% The modes stretch in the longer direction.
% The eigenvalues change, since the spatial resolution is different
%===========



G = sparse(N, N); % Initialize sparse matrix G

% Apply boundary conditions (BCs)
for i = 1:nx
    for j = 1:ny
        m = j + (i - 1) * ny; % Mapping (i,j) -> m
        
        if i == 1 || i == nx || j == 1 || j == ny  % Boundary nodes
            G(m, m) = 1; % Set diagonal to 1
        else
            % Bulk node finite difference equation
            mxp = j + ((i + 1) - 1) * ny; % (i+1, j)
            mxm = j + ((i - 1) - 1) * ny; % (i-1, j)
            myp = (j + 1) + (i - 1) * ny; % (i, j+1)
            mym = (j - 1) + (i - 1) * ny; % (i, j-1)

            %G(m, m) = -2;   % Center coefficient
            % Lowers the effective index in the region
            % Modes concentrate in the modified area
            % Simulates a lower refractive index
            % Analogous to a weaker potential well in quantum mechanics

            if i > 10 && i < 20 && j > 10 && j < 20
                G(m, m) = -2; % Change diagonal value inside region
            else
                G(m, m) = -4; % Default diagonal value
            end
            G(m, mxp) = 1;  % Right neighbor
            G(m, mxm) = 1;  % Left neighbor
            G(m, myp) = 1;  % Top neighbor
            G(m, mym) = 1;  % Bottom neighbor
        end
    end
end

% Plot the sparsity pattern of G
figure;
spy(G);
title('Sparsity Pattern of G');


% ======== Single figures 
% % Compute the 9 smallest eigenvalues and eigenvectors
% [E, D] = eigs(G, 9, 'SM'); 
% 
% % Step (vi): Plot eigenvalues
% figure;
% plot(diag(D), 'o', 'MarkerFaceColor', 'b');
% title('Eigenvalues of G');
% xlabel('Index');
% ylabel('Eigenvalue');
% 
% % Step (vii): Plot eigenvectors as 2D mode shapes
% for k = 1:9
%     modeShape = reshape(E(:, k), ny, nx); % Reshape eigenvector into (nx, ny) grid
% 
%     figure;
%     surf(modeShape);
%     shading interp;
%     title(['Mode ', num2str(k)]);
%     xlabel('x');
%     ylabel('y');
%     zlabel('Amplitude');
% end


% Compute the 9 smallest eigenvalues and eigenvectors
[E, D] = eigs(G, 9, 'SM'); 

% Step (vi): Plot eigenvalues
figure;
plot(diag(D), 'o', 'MarkerFaceColor', 'b');
title('Eigenvalues of G');
xlabel('Index');
ylabel('Eigenvalue');

% Step (vii): Plot all 9 eigenvectors in a single figure
figure;
for k = 1:9
    modeShape = reshape(E(:, k), ny, nx); % Reshape eigenvector into (nx, ny) grid
    
    subplot(3, 3, k); % Arrange in 3x3 grid
    surf(modeShape);
    shading interp;
    title(['Mode ', num2str(k)]);
    xlabel('x');
    ylabel('y');
    zlabel('Amplitude');
end
sgtitle('All 9 Mode Shapes');
