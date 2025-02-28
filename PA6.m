
% ======================== SIMULATION PARAMETERS ========================
Coupled = 1;       % Enable self-consistent solution of Poisson & carrier equations
TwoCarriers = 1;   % Simulate both electrons & holes
RC = 1;            % Include recombination effects
% ====================== EFFECTS OF FLAGS: Coupled, TwoCarriers, RC ======================
% Flag            | Effect When Enabled (1)             | Effect When Disabled (0)
% ---------------------------------------------------------------------------------------
% Coupled        | Solves Poisson + Drift-Diffusion    | Solves only Drift-Diffusion
% TwoCarriers    | Simulates both electrons & holes   | Only electrons (or holes)
% RC             | Includes recombination effects     | No recombination, carriers persist
% =======================================================================================


% ======================== GRID & DOMAIN ========================
nx = 201;          % Number of spatial points
l = 1e-6;         % Length of the domain (1 micron)
x = linspace(0, l, nx);  % Discretized spatial grid
dx = x(2) - x(1);        % Grid spacing
xm = x(1:nx-1) + 0.5*dx; % Midpoints for staggered grid




% ======================== DOPING PROFILE Constant ========================
% Nd = 1e16 * 1e6; % Constant doping density (converted from cm⁻³ to m⁻³)
% NetDoping = ones(1,nx).*Nd; % Uniform doping profile (commented out)

% % 2)d) i)======================== DOPING PROFILE (LINEAR GRADIENT) ========================
% Nd_min = 1e16 * 1e6;  % Minimum doping (converted from cm⁻³ to m⁻³)
% Nd_max = 20e16 * 1e6; % Maximum doping
% NetDoping = linspace(Nd_min, Nd_max, nx); % Linearly increasing doping profile
% % Current doping profile  const N d. VS (linear gradient 1e16-20e1)
%                             | Constant Doping       | Linear Gradient Doping
% -------------------------------------------------------------------
% Electric Field              | Uniform               | Varies, stronger at high-doping side
% Carrier Concentration (n,p) | Evenly distributed    | n increases with doping, p decreases
% Potential (V)               | Smooth                | Steeper gradient due to built-in field
% Current (J)                 | Diffusion-driven      | Drift becomes significant
% Disturbance Decay           | Symmetric             | Faster on low-doping side
% ===================================================================


% 2) d) ii) Exponential Doping Gradient from 1e16 to 20e16 cm⁻³
Nd_min = 1e16 * 1e6; % Minimum doping (1e16 cm^-3)
Nd_max = 20e16 * 1e6; % Maximum doping (20e16 cm^-3)
NetDoping = Nd_min * exp(log(Nd_max/Nd_min) * (x/l)); % Exponential increase
% ====================== EXPONENTIAL DOPING GRADIENT =======================
% Property                | Linear Doping        | Exponential Doping
% ------------------------------------------------------------------------
% Electric Field (E)      | Gradual change      | Stronger at high-doping
% Carrier Concentration   | Linearly varies    | Rapid increase near high-doping
% Potential (V)           | Moderate slope      | Steeper voltage drop
% Current (J)             | More uniform        | Higher drift near high doping
% Disturbance Decay       | Smooth & balanced   | Faster decay near high-doping
% ========================================================================





% Gaussian Disturbance in Doping Profile
x0 = l/2;         % Center of disturbance
nw = l/20;        % Width of Gaussian distribution

% npDisturbance = 1e16 * 1e6 * exp(-((x-x0)/nw).^2); % Gaussian-shaped carrier injection
  npDisturbance = 0;
% ========================= npDisturbance =========================
%                         | With npDisturbance   | Without npDisturbance
% -------------------------------------------------------------------------------
% Initial Carrier Dist.   | Peak due to injection | Smooth (doping only)
% Electric Field (E)      | Strong variations    | Only from doping gradient
% Current (J)             | Transient effects    | Steady-state drift current
% Potential (V)           | Fluctuations present | Smooth profile
% Time Evolution          | Dynamic behavior     | Immediate steady-state
% ===============================================================================



% ======================== BOUNDARY CONDITIONS ========================
LVbc = 0;  % Left voltage boundary condition (V)
RVbc = 0;  % Right voltage boundary condition (V)

% ======================== TIME PARAMETERS ========================
TStop = 14200000 * 1e-18; % Total simulation time (s)
PlDelt = 100000 * 1e-18;  % Time step between plots (s)

% ======================== PLOTTING PARAMETERS ========================
% PlotYAxis = {[-1e-15 2e-15] [-2e-9 2e-9] [-1.5e-12 1.5e-12]...
%     [1e22 2e22] [0 1e22] [0 20e43]...
%     [-20e33 15e33] [-2.5e34 2e34] [-1.1e8 1.1e8] ...
%     [-1e8 1e8] [-10e-3 10e-3] [0 2e22]}; % Axis scaling for different plots

doPlotImage = 0;       % Disable image saving
PlotFile = 'Gau2CarRC.gif'; % Filename for saved simulation images (if enabled)


 
