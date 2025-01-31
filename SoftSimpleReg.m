winstyle = 'docked';
% winstyle = 'normal';

set(0,'DefaultFigureWindowStyle',winstyle)
set(0,'defaultaxesfontsize',18)
set(0,'defaultaxesfontname','Times New Roman')
% set(0,'defaultfigurecolor',[1 1 1])

% clear VARIABLES;
clear
global spatialFactor;
global c_eps_0 c_mu_0 c_c c_eta_0
global simulationStopTimes;
global AsymForcing
global dels
global SurfHxLeft SurfHyLeft SurfEzLeft SurfHxRight SurfHyRight SurfEzRight



dels = 0.75;
spatialFactor = 1;

c_c = 299792458;                  % speed of light
c_eps_0 = 8.8542149e-12;          % vacuum permittivity
c_mu_0 = 1.2566370614e-6;         % vacuum permeability
c_eta_0 = sqrt(c_mu_0/c_eps_0);


tSim = 200e-15
f = 230e12; 
% %------------------------------- Added code 
% trying excitation frequencies 
%f = 150e12; % Lower frequency  
%f = 300e12; % Higher frequency  



lambda = c_c/f;

xMax{1} = 20e-6;
nx{1} = 200;
ny{1} = 0.75*nx{1};


Reg.n = 1;

mu{1} = ones(nx{1},ny{1})*c_mu_0;



epi{1} = ones(nx{1},ny{1})*c_eps_0;
% epi is the relative permittivity


%----------INCLUSION
%-------------------------------- commented line 
% this line adds the INCLUSION
%epi{1}(125:150,55:95)= c_eps_0*11.3;


% %------------------------------- Added code part 4
% for i = 100:20:160  % Create a periodic grating
%     epi{1}(i:i+10, 55:95) = c_eps_0 * 11.3;
% end
% %------------------------ Added End

% %------------------------------- Added code part 5
% % Create a circular scattering object
% [xGrid, yGrid] = meshgrid(1:nx{1}, 1:ny{1});
% centerX = nx{1}/2; centerY = ny{1}/2; radius = 30;
% 
% mask = (xGrid - centerX).^2 + (yGrid - centerY).^2 <= radius^2;
% epi{1}(mask) = c_eps_0 * 11.3; % High permittivity scatterer
% %------------------------- Added End

% % Create a single high-permittivity block (scatterer)
% epi{1}(120:140, 60:90) = c_eps_0 * 11.3; 

% Create two separate high-permittivity blocks
% epi{1}(100:120, 50:70) = c_eps_0 * 11.3;  
% epi{1}(150:170, 80:100) = c_eps_0 * 11.3;  


% Initialize permittivity matrix
epi{1} = ones(nx{1}, ny{1}) * c_eps_0; % Default permittivity
% Define circle parameters
centerX = nx{1}/2;  
centerY = ny{1}/2;  
radius = 20;  
% Generate grid
[xGrid, yGrid] = meshgrid(1:nx{1}, 1:ny{1});  
% Apply high permittivity inside the circle
mask = (xGrid - centerX).^2 + (yGrid - centerY).^2 <= radius^2;  
epi{1}(mask) = c_eps_0 * 11.3;















sigma{1} = zeros(nx{1},ny{1});
sigmaH{1} = zeros(nx{1},ny{1});

dx = xMax{1}/nx{1};
dt = 0.25*dx/c_c;
nSteps = round(tSim/dt*2);
yMax = ny{1}*dx;
nsteps_lamda = lambda/dx

movie = 1;
Plot.off = 0;
Plot.pl = 0;
Plot.ori = '13';
Plot.N = 100;
%Plot.MaxEz = 1.1;
Plot.MaxEz = 4;
Plot.MaxH = Plot.MaxEz/c_eta_0;
Plot.pv = [0 0 90];
Plot.reglim = [0 xMax{1} 0 yMax];

% %------------------------------- OLD source
% bc{1}.NumS = 1;
% bc{1}.s(1).xpos = nx{1}/(4) + 1; % nx{1}, the number of grid points in the x-direction
% bc{1}.s(1).type = 'ss';
% bc{1}.s(1).fct = @PlaneWaveBC;

% % %------------------------------- Added code Part 5 b
bc{1}.NumS = 2;  %  using two sources

% first source 
bc{1}.s(1).xpos = nx{1}/4 + 1;  
bc{1}.s(1).type = 'ss';  
bc{1}.s(1).fct = @PlaneWaveBC;  

% second source 
bc{1}.s(2).xpos = 3*nx{1}/4;  
bc{1}.s(2).type = 'ss';  
bc{1}.s(2).fct = @PlaneWaveBC;  
% % %------------------------------- Added End




% mag = -1/c_eta_0;
%mag = 1;
mag = 3;
%phi = 0;
phi = 0;
omega = f*2*pi;
betap = 0;
t0 = 30e-15;% this changes the Start of the pulse 
s = 0;
y0 = yMax/2;
sty = 1.5*lambda;

mag2 = 3;
%phi = 0;
phi2 = 0;
omega2 = f*pi;
betap2 = 0;
t02 = 30e-15;
s2 = 0;
y02 = yMax/2;
sty2 = 1.5*lambda;

%st = 15e-15;% changes the width of the pulse (sin wave decays)
% %------------------------------- Added code
st = -0.05; % Adjust pulse shape for better interaction with the grating
%-------------------------------- Added End




% Second source

bc{1}.s(1).paras = {mag,phi,omega,betap,t0,st,s,y0,sty,'s'};
st2 = st; % 
bc{1}.s(2).paras = {mag2,phi2,omega2,betap2,t02,st2,s2,y02,sty2,'s'};


Plot.y0 = round(y0/dx);
Plot.y02 = round(y02/dx);

bc{1}.xm.type = 'a';
bc{1}.xp.type = 'a';
bc{1}.ym.type = 'a';
bc{1}.yp.type = 'a';

pml.width = 20 * spatialFactor;
pml.m = 3.5;

Reg.n  = 1;
Reg.xoff{1} = 0;
Reg.yoff{1} = 0;

RunYeeReg


% 3. Basic Simulation:
   
    %(a) Open SoftSimpleReg.m and run the le.
    %---------------------------------------------------------------------- 
   
    %(b) What is it simulating?
    % Simulates EM wave propagation using Yee Cell FDTD Finite-Difference Time-Domain

    % A Gaussian pulse travels, scatters, and transmits through a high permittivit inclusion 
    % causing wavelength reduction and reflection and diffraction
    %----------------------------------------------------------------------
    
    %(c) Have a look at SoftSimpleReg and explore what it is doing and add comments to the code.
        % i. Find the code that adds the inclusion . Comment it out. Did that work?
        %------------ commented line 
        % this line adds the inclusion
        %epi{1}(125:150,55:95)= c_eps_0*11.3;
        % removing this line code removes inclusion and wave propagates without
        % scattering
        %----------------------------------------------------------------------
       
        %   ii. What is the bc structure used for?
        % bc structure defines boundaries and source parameters.
        %----------------------------------------------------------------------
        
        % iii. bc 1 .s(1) is setting up what? 
        % bc{1}.s(1).xpos sets the source position.
        %Play with paramaters to see what they do?

        %bc{1}.s(1).xpos = nx{1}/3 + 1; % Move source closer to the left
        %t0 = 50e-15; % Start pulse later
        %st = 30e-15; % Make pulse wider
        %bc{1}.s(1).type = 'p'; % Use a plane wave source; ss is soft source
        %----------------------------------------------------------------------
       
        % iv. bc 1 .xm/xp/ym/yp are used for what? 
        %set boundary conditions on all edges.
        % Try setting bc1.xp.type = e what happened?
        % Modify boundary condition on the right
%--------------------------------------------------------------------------

%4. Geometric Changes:
    % (a) Create a grating by adding more inclusions.
        % for i = 100:20:160  % Create a periodic grating
        %     epi{1}(i:i+10, 55:95) = c_eps_0 * 11.3;
        % end
        
    % (b) Simulate the grating. 
         % You might finnd it useful to set the st paramater to-0.05. 
         % What did that do?
         %st = -0.05; % Adjust pulse shape for better interaction with the grating
         %st controls the width and shape of the Gaussian pulse used as the excitation source

     % (c) Try varying the frequency of the excitation.
         %f = 150e12; % Low freq. more transmission, weaker diffraction (spreads out)
         %f = 300e12; % High freq. more reflection & diffraction.
%--------------------------------------------------------------------------

% 5. Be creative:
     % (a) Create an interesting structure for scattering.

     % (b) Add multiple sources.


% 2 source are added 
% Remove the inclusion
