% clear all
clearvars
clearvars -GLOBAL
close all
format shorte
set(0,'DefaultFigureWindowStyle','docked')

% ======================== CONSTANTS ========================
global C V Mun Mup Gv Dn Dp Bv Em DnM MunM DpM MupM np pp x xm n p
global Rho divFp divFn niSi TwoCarriers t EpiSi n0 p0 tauSi
global Coupled NetDoping l PlotYAxis PlotSS im map
global PlotCount doPlotImage

% Physical Constants
C.q_0 = 1.60217653e-19;  % Electron charge (Coulombs)
C.hb = 1.054571596e-34;  % Reduced Planck constant (J·s)
C.h = C.hb*2*pi;         % Planck constant (J·s)
C.m_0 = 9.10938215e-31;  % Electron mass (kg)
C.kb = 1.3806504e-23;    % Boltzmann constant (J/K)
C.eps_0 = 8.854187817e-12; % Vacuum permittivity (F/m)
C.Mun_0 = 1.2566370614e-6; % Vacuum permeability (H/m)
C.c = 299792458;         % Speed of light (m/s)

% ======================== MATERIAL PROPERTIES ========================
Temp = 300;  % Temperature in Kelvin
C.Vt = C.kb*Temp/C.q_0;  % Thermal voltage

% Silicon Properties
EpiSi = C.eps_0*11.68;   % Silicon permittivity
MunSi = 1400*1e-4;       % Electron mobility (m²/V·s)
DnSi = MunSi*C.kb*Temp/C.q_0; % Electron diffusion coefficient
MupSi = 450*1e-4;        % Hole mobility (m²/V·s)
DpSi = MunSi*C.kb*Temp/C.q_0; % Hole diffusion coefficient
tauSi = 1e-8;            % Carrier lifetime (s)
niSi = 1e10*1e6;         % Intrinsic carrier concentration (m⁻³)

% ======================== SIMULATION PARAMETERS ========================
JBC = 0; % Default no flow boundary condition
RVbc = 0; % Right-side boundary condition (Ground)
SecondSim = 0; % Run second simulation flag

PlotSS = 1;  % Enable steady-state plots
PlotFile = 'image.gif'; % File to save plots
PlotCount = 0;
doPlotImage = 0; % Disable image plotting

% ======================== SIMULATION SELECTION ========================
% Simulation = 'GaussianTwoCarRC'; % PA6
 Simulation = 'PNJctEqBias';


% Run appropriate parameter file based on selected simulation
if strcmp(Simulation,'GaussianTwoCar')
    eval('SetGaussian2CarParas');
elseif strcmp(Simulation,'GaussianTwoCarRC')
    eval('PA6');
elseif strcmp(Simulation,'GaussianTwoCarRCLinGrad')
    eval('SetGaussian2CarParasRCOnlyLinGrad');
elseif strcmp(Simulation,'GaussianSingle0V')
    eval('SetGaussian1CarParas0V');
elseif strcmp(Simulation,'GaussianSingle1V')
    eval('SetGaussian1CarParas1V');
elseif strcmp(Simulation,'ExpDoping')
    eval('SetExpDopingParas');
elseif strcmp(Simulation,'PNJct')
    eval('SetPNJctParas');
elseif strcmp(Simulation,'PNJctEq')
    eval('SetPNJctParasEqBC');
elseif strcmp(Simulation,'PNJctEqBias')
    eval('SetPNJctParasEqBCBias');
end

% ======================== FORMING POISSON EQUATION ========================
FormGv(nx,LVbc,RVbc); % Generate Poisson equation coefficients
[L,U] = lu(Gv); % LU decomposition for solving Poisson equation

% ======================== INITIALIZE MOBILITY & DIFFUSION ========================
Mun = ones(1,nx)*MunSi;  % Electron mobility profile
Dn = ones(1,nx)*DnSi;    % Electron diffusion coefficient
MunM(1:nx-1) = (Mun(1:nx-1) + Mun(2:nx))/2; % Electron mobility (averaged)
DnM(1:nx-1) = (Dn(1:nx-1) + Dn(2:nx))/2; % Electron diffusion (averaged)
n = zeros(1,nx); % Initialize electron concentration

Mup = ones(1,nx)*MupSi; % Hole mobility profile
Dp = ones(1,nx)*DnSi;   % Hole diffusion coefficient
MupM(1:nx-1) = (Mup(1:nx-1) + Mup(2:nx))/2; % Hole mobility (averaged)
DpM(1:nx-1) = (Dp(1:nx-1) + Dp(2:nx))/2; % Hole diffusion (averaged)
p = zeros(1,nx); % Initialize hole concentration

% ======================== INITIAL CARRIER DENSITY ========================
if TwoCarriers == 1
    ni = NetDoping >= 0;
    n0(ni) = (NetDoping(ni) + sqrt(NetDoping(ni).^2 + 4* niSi*niSi))/2;
    p0(ni)  = niSi^2./n0(ni);

    pi = ~ni;
    p0(pi) = (-NetDoping(pi) + sqrt(NetDoping(pi).^2 + 4* niSi*niSi))/2;
    n0(pi)  = niSi^2./p0(pi);
else
    n0  = NetDoping;
    p0 = zeros(1,nx);
end

% Add small disturbance
n0 = n0 + npDisturbance;
if TwoCarriers == 1
    p0 = p0 + npDisturbance;
end

% Initialize divergence terms
divFn = zeros(1,nx);
divFp = zeros(1,nx);

% ======================== CHARGE DENSITY & POISSON SOLUTION ========================
Rho = zeros(1,nx);
if (Coupled)
    Rho = C.q_0*(NetDoping - n0 + p0); % Charge density
    Rho(1) = 0; % Enforce BCs
    Rho(nx) = 0;
end

% Solve Poisson’s equation
V = U\(L\(-dx^2/EpiSi*Rho' + Bv'));
Em(1:nx-1) = -(V(2:nx) - V(1:nx-1))/dx; % Electric field
MaxEm = max(abs(Em)); % Max field
Maxn = max(n0); % Max carrier concentration

% ======================== TIME-STEP CALCULATION ========================
Ld = sqrt(EpiSi/(C.q_0*Maxn)); % Debye length
dxMax = Ld/5; % Mesh spacing limit

% Time step constraints
dtMax = min(dx^2/2/max(Dn),dx^2/2/max(Dp));
if MaxEm > 0
    dt = min([2*dx/MaxEm dtMax])/4;
else
    dt = dtMax/4;
end

t = 0; % Initialize time

% Set initial values for carriers
n = n0;
np = n0;
p = p0;
pp = p0;

% ======================== RUN SIMULATION ========================
PlotVals(nx,dx,'on',l,TStop,PlotYAxis);
SimulateFlow(TStop,nx,dx,dtMax,JBC,RC,U,L,PlDelt)

if SecondSim == 1
    FormGv(nx,LVbc2,RVbc); % Recalculate Poisson equation for second simulation
    [L,U] = lu(Gv);
    SimulateFlow(TStop2,nx,dx,dtMax,JBC,RC,U,L,PlDelt)
end

% ======================== IMAGE OUTPUT ========================
if doPlotImage
    imwrite(im,map,PlotFile,'DelayTime',0.2,'LoopCount',inf);
end

% ======================== FINAL PLOTTING ========================
PlotVals(nx,dx,'off',l,TStop,[]);
if doPlotImage
    f = getframe(fig2);
    [im,map] = rgb2ind(f.cdata,256,'nodither');
    filename = strcat('final-',PlotFile);
    imwrite(im,map,filename);
end



% Plot :
% V        - Electric potential (voltage) across the junction.
% E        - Electric field strength, peaking at the junction.
% Rho      - Charge density distribution.
% n        - Electron concentration.
% p        - Hole concentration.
% np - ni² - Carrier recombination/generation check.
% divFn    - Electron current continuity.
% divFp    - Hole current continuity.
% JnDiff / JnDrift - Electron diffusion vs. drift currents.
% JpDiff / JpDrift - Hole diffusion vs. drift currents.
% Jtot     - Total current density.
% Max n and p - Maximum carrier densities.




