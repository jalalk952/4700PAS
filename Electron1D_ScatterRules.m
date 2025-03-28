function Electron1D_ScatterRules()
    clf;
    set(0,'DefaultFigureWindowStyle','docked');
    set(0,'defaultaxesfontsize',20);
    set(0,'defaultaxesfontname','Times New Roman');
    set(0,'DefaultLineLineWidth',2);

    clear all; close all;

    dt = 1;
    nt = 1000;
    np = 100;

    q = 1.6e-19;
    % m = 9.1e-31;
    m=9.1e-17;
    E = 1e3;
    F = q * E;

    v = zeros(np, nt);
    x = zeros(np, nt);
    t = zeros(1, nt);
    AveV = zeros(1, nt);

    elastic = true;  % Toggle this for elastic rule

    for i = 2:nt
        t(i) = t(i-1) + dt;

        v(:, i) = v(:, i-1) + F/m * dt;
        x(:, i) = x(:, i-1) + v(:, i-1)*dt + F/m*dt^2/2;

        r = rand(np,1) < 0.05;
        if elastic
            v(r,i) = -0.25 * v(r, i-1);  % elastic rule
        else
            v(r,i) = 0; % reset to 0
        end

        AveV(i) = mean(v(:, i));

        subplot(3,1,1); plot(t(1:i), v(1,1:i), 'g'); hold on;
        plot(t(1:i), AveV(1:i), 'k'); hold off;
        xlabel('time'); ylabel('v');
        title(['Average v: ' num2str(AveV(i))]);

        subplot(3,1,2); plot(x(1,1:i), v(1,1:i), 'r'); hold on;
        plot(x(1,1:i), AveV(1:i), 'k'); hold off;
        xlabel('x'); ylabel('v');

        subplot(3,1,3); plot(t(1:i), x(1,1:i), 'b');
        xlabel('time'); ylabel('x');

        pause(0.01);
    end

    disp('Final Average V:');
    mean(v(:, end))
end
