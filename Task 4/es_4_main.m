%RUN DIRECTLY THIS SCRIPT TO OBTAIN THE RESULT FROM SIMULINK (every time I
%run the eps' plot will be saved in the current folder)
clear
clc
close all

alpha=3;
q_i=[alpha+1  1  pi/4]';
Ts=0.001;

out=sim("es_4_model.slx");

% Estrazione dati
t = out.x_sim.Time;
x_real = out.x_sim.Data;
y_real = out.y_sim.Data;
theta_real = out.theta_sim.Data;

x_odo = out.x_k.Data(:);
y_odo = out.y_k.Data(:);
theta_odo = out.theta_k.Data(:);

% Calcolo errori
e_x = x_real - x_odo;
e_y = y_real - y_odo;
e_theta = theta_real - theta_odo;

%% Plot separati degli errori
figure('Color','w','Renderer','painters','Position',[10 10 1000 600]);

subplot(3,1,1);
plot(t, e_x, '-', 'LineWidth', 2, 'Color', [0 0 1]); grid on;
ylabel('$e_x(t)$ [m]', 'Interpreter', 'latex');
title('Errors', 'Interpreter', 'latex', 'FontWeight', 'normal');
set(gca,'FontSize',22,'TickLabelInterpreter','latex');

subplot(3,1,2);
plot(t, e_y, '-', 'LineWidth', 2, 'Color', [0 0 1]); grid on;
ylabel('$e_y(t)$ [m]', 'Interpreter', 'latex');
set(gca,'FontSize',22,'TickLabelInterpreter','latex');

subplot(3,1,3);
plot(t, e_theta, '-', 'LineWidth', 2, 'Color', [0 0 1]); grid on;
xlabel('$t$ [s]', 'Interpreter', 'latex');
ylabel('$e_\theta(t)$ [rad]', 'Interpreter', 'latex');
set(gca,'FontSize',22,'TickLabelInterpreter','latex');

print(gcf,'-depsc2','errori_localizzazione.eps');

%% 1. Traiettoria reale vs stimata
figure('Color','w','Renderer','painters','Position',[10 10 1000 600]);

plot(x_odo, y_odo, '-', 'LineWidth', 2, 'Color', [1 0 0]); hold on;
plot(x_real, y_real, '--', 'LineWidth', 2, 'Color', [0 0 1]);
% xlim([-0.5 4.5]);
% ylim([-1.2 5]);
xlabel('$x(t)$ [m]', 'Interpreter', 'latex');
ylabel('$y(t)$ [m]', 'Interpreter', 'latex');

hleg = legend({'Odometry', 'Real'}, 'Interpreter', 'latex', 'Location', 'northwest', 'Box', 'on');
set(hleg, 'Orientation', 'vertical');

title('Real vs Estimated Trajectory', 'Interpreter', 'latex', 'FontWeight', 'normal');
axis equal; grid on;
set(gca, 'FontSize', 22, 'TickLabelInterpreter', 'latex');
print(gcf, '-depsc2', 'trajectory_vs_odometry.eps');



figure('Color','w','Position',[100 100 900 500]);

subplot(3,1,1);
plot(out.rho.Time, out.rho.Data, 'LineWidth', 2);
ylabel('$\rho(t)$ [m]', 'Interpreter', 'latex');
title('Polar Coordinates - Posture Regulation', 'Interpreter', 'latex');
grid on;

subplot(3,1,2);
plot(out.gamma.Time, out.gamma.Data, 'LineWidth', 2);
ylabel('$\gamma(t)$ [rad]', 'Interpreter', 'latex');
grid on;

subplot(3,1,3);
plot(out.delta.Time, out.delta.Data, 'LineWidth', 2);
xlabel('$t$ [s]', 'Interpreter', 'latex');
ylabel('$\delta(t)$ [rad]', 'Interpreter', 'latex');
grid on;
set(findall(gcf,'-property','FontSize'),'FontSize',22);
set(findall(gcf,'-property','TickLabelInterpreter'), 'TickLabelInterpreter','latex');
print(gcf, '-depsc2', 'polar_coordinates.eps');



% Plot
figure('Color','w','Renderer','painters','Position',[10 10 900 500]);

subplot(3,1,1);
plot(t, x_real, 'LineWidth', 2, 'Color', [0 0.4470 0.7410]); grid on;
ylabel('$x(t)$ [m]', 'Interpreter', 'latex');
title('State evolution over time', 'Interpreter', 'latex', 'FontWeight', 'normal');
set(gca, 'FontSize', 22, 'TickLabelInterpreter', 'latex');

subplot(3,1,2);
plot(t, y_real, 'LineWidth', 2, 'Color', [0.8500 0.3250 0.0980]); grid on;
ylabel('$y(t)$ [m]', 'Interpreter', 'latex');
set(gca, 'FontSize', 22, 'TickLabelInterpreter', 'latex');

subplot(3,1,3);
plot(t, theta_real, 'LineWidth', 2, 'Color', [0.2 0.2 0.2]); grid on;
xlabel('$t$ [s]', 'Interpreter', 'latex');
ylabel('$\theta(t)$ [rad]', 'Interpreter', 'latex');
set(gca, 'FontSize', 22, 'TickLabelInterpreter', 'latex');

print(gcf, '-depsc2', 'state_evolution.eps');



%% Velocity profiles from simulation (real inputs to unicycle)
figure('Color','w','Renderer','painters','Position',[10 10 900 500]);

subplot(2,1,1);
plot(out.v_sim.Time, out.v_sim.Data, 'LineWidth', 2, 'Color', [0 0.4470 0.7410]); grid on;
ylabel('$v(t)$ [m/s]', 'Interpreter', 'latex');
title('Input Velocities', 'Interpreter', 'latex', 'FontWeight', 'normal');
set(gca, 'FontSize', 22, 'TickLabelInterpreter', 'latex');

subplot(2,1,2);
plot(out.w_sim.Time, out.w_sim.Data, 'LineWidth', 2, 'Color', [0.8500 0.3250 0.0980]); grid on;
xlabel('$t$ [s]', 'Interpreter', 'latex');
ylabel('$\omega(t)$ [rad/s]', 'Interpreter', 'latex');
set(gca, 'FontSize', 22, 'TickLabelInterpreter', 'latex');

print(gcf, '-depsc2', 'input_velocities.eps');
