clc; clear; close all;

%% Task 2: Generate Data
% Given diode parameters
Is = 0.01e-12;   % Forward bias saturation current (A)
Ib = 0.1e-12;    % Breakdown saturation current (A)
Vb = 1.3;        % Breakdown voltage (V)
Gp = 0.1;        % Parasitic parallel conductance (S)

% Define voltage range
V = linspace(-1.95, 0.7, 200); % Voltage from -1.95V to 0.7V with 200 steps

% Compute ideal diode current with noise
I = Is * (exp(1.2 * V / 0.025) - 1) + Gp * V - Ib * (exp(-1.2 * (V + Vb) / 0.025) - 1);
I = I .* (1 + 0.2 * randn(size(I))); % Add 20% random noise

%% Task 3: Polynomial Fitting
% Fit a 4th and 8th order polynomial to the noisy data
poly4_coeffs = polyfit(V, I, 4);
poly8_coeffs = polyfit(V, I, 8);

% Evaluate polynomial fits
I_poly4 = polyval(poly4_coeffs, V);
I_poly8 = polyval(poly8_coeffs, V);

%% Task 4: Nonlinear Curve Fitting
% Define nonlinear diode equation model
fo = fittype('A.*(exp(1.2*x/25e-3)-1) + B.*x - C.*(exp(1.2*(-(x+D))/25e-3)-1)', ...
    'independent', 'x', 'coefficients', {'A', 'B', 'C', 'D'});

% Fit all parameters A, B, C, D
fit1 = fit(V', I', fo, 'StartPoint', [Is, Gp, Ib, Vb]);

% Fit with B fixed
fit2 = fit(V', I', fo, 'StartPoint', [Is, Gp, Ib, Vb], ...
    'Lower', [-Inf, Gp, -Inf, -Inf], 'Upper', [Inf, Gp, Inf, Inf]);

% Fit with D fixed
fit3 = fit(V', I', fo, 'StartPoint', [Is, Gp, Ib, Vb], ...
    'Lower', [-Inf, -Inf, -Inf, Vb], 'Upper', [Inf, Inf, Inf, Vb]);

% Generate fitted curves
I_fit1 = fit1(V);
I_fit2 = fit2(V);
I_fit3 = fit3(V);

%% Task 5: Neural Network Fitting
% Define inputs and targets
inputs = V';
targets = I';

% Create and configure neural network
hiddenLayerSize = 10;
net = fitnet(hiddenLayerSize);
net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 15/100;

% Train the network
[net, ~] = train(net, inputs, targets);

% Predict using trained network
I_nn = net(inputs);

%% Task 6: Gaussian Process Regression (GPR) Fitting
% Train GPR model
gprModel = fitrgp(V', I');

% Predict current using GPR model
[I_rgp, I_rgp_std] = predict(gprModel, V');

% Compute confidence intervals
I_rgp_upper = I_rgp + 2 * I_rgp_std;
I_rgp_lower = I_rgp - 2 * I_rgp_std;

%% Plot all results
figure;

% Polynomial Fit - Linear Scale
subplot(4,2,1);
plot(V, I, 'b-', 'LineWidth', 1.5); hold on;
plot(V, I_poly4, 'r--', 'LineWidth', 1.5);
plot(V, I_poly8, 'g:', 'LineWidth', 2);
xlabel('V'); ylabel('I');
title('Polynomial Fit');
legend('Data', '4th Order', '8th Order');

% Polynomial Fit - Log Scale
subplot(4,2,2);
semilogy(V, abs(I), 'b-', 'LineWidth', 1.5); hold on;
semilogy(V, abs(I_poly4), 'r--', 'LineWidth', 1.5);
semilogy(V, abs(I_poly8), 'g:', 'LineWidth', 2);
xlabel('V'); ylabel('abs(I)');
title('Polynomial Fit (Log Scale)');
legend('Data', '4th Order', '8th Order');

% Nonlinear Fit - Linear Scale
subplot(4,2,3);
plot(V, I, 'b-', 'LineWidth', 1.5); hold on;
plot(V, I_fit1, 'r--', 'LineWidth', 1.5);
plot(V, I_fit2, 'g:', 'LineWidth', 2);
plot(V, I_fit3, 'm-.', 'LineWidth', 1.5);
xlabel('V'); ylabel('I');
title('Nonlinear Fit');
legend('Data', 'Fit1', 'Fit2', 'Fit3');

% Nonlinear Fit - Log Scale
subplot(4,2,4);
semilogy(V, abs(I), 'b-', 'LineWidth', 1.5); hold on;
semilogy(V, abs(I_fit1), 'r--', 'LineWidth', 1.5);
semilogy(V, abs(I_fit2), 'g:', 'LineWidth', 2);
semilogy(V, abs(I_fit3), 'm-.', 'LineWidth', 1.5);
xlabel('V'); ylabel('abs(I)');
title('Nonlinear Fit (Log Scale)');
legend('Data', 'Fit1', 'Fit2', 'Fit3');

% Neural Network Fit - Linear Scale
subplot(4,2,5);
plot(V, I, 'b-', 'LineWidth', 1.5); hold on;
plot(V, I_nn, 'r--', 'LineWidth', 1.5);
xlabel('V'); ylabel('I');
title('Neural Network Fit');
legend('Data', 'NN Fit');

% Neural Network Fit - Log Scale
subplot(4,2,6);
semilogy(V, abs(I), 'b-', 'LineWidth', 1.5); hold on;
semilogy(V, abs(I_nn), 'r--', 'LineWidth', 1.5);
xlabel('V'); ylabel('abs(I)');
title('Neural Network Fit (Log Scale)');
legend('Data', 'NN Fit');

% GPR Fit - Linear Scale
subplot(4,2,7);
plot(V, I, 'b-', 'LineWidth', 1.5); hold on;
plot(V, I_rgp, 'r--', 'LineWidth', 1.5);
plot(V, I_rgp_upper, 'g:', 'LineWidth', 2);
plot(V, I_rgp_lower, 'm-.', 'LineWidth', 1);
xlabel('V'); ylabel('I');
title('GPR Fit');
legend('Data', 'GPR Mean', 'GPR Upper', 'GPR Lower');

% GPR Fit - Log Scale
subplot(4,2,8);
semilogy(V, abs(I), 'b-', 'LineWidth', 1.5); hold on;
semilogy(V, abs(I_rgp), 'r--', 'LineWidth', 1.5);
semilogy(V, abs(I_rgp_upper), 'g:', 'LineWidth', 2);
semilogy(V, abs(I_rgp_lower), 'm-.', 'LineWidth', 1);
xlabel('V'); ylabel('abs(I)');
title('GPR Fit (Log Scale)');
legend('Data', 'GPR Mean', 'GPR Upper', 'GPR Lower');

sgtitle('Diode Curve Fitting Results');

plotbrowser
