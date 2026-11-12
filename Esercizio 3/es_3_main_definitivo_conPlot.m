%RUN DIRECTLY THIS SCRIPT TO OBTAIN THE RESULT FROM SIMULINK (every time I
%run the eps' plot will be saved in the current folder)
clear; clc; close all;

%% Parametri generali
alpha = 3;
omega = alpha + 1;
T = 4 * pi / omega;
dt = 0.001;
t = 0:dt:T;

%% Selezione traiettoria
caso = 2;  % 1 per r = 3, 2 per r = 30  %%%%%CAMBIARE QUI
r = [3, 30];
r = r(caso);

%% Generazione traiettoria
theta = omega * t;
x = r * cos(theta) ./ (1 + sin(theta).^2);
y = r * cos(theta) .* sin(theta) ./ (1 + sin(theta).^2);

dx = gradient(x, dt);
dy = gradient(y, dt);
ddx = gradient(dx, dt);
ddy = gradient(dy, dt);

theta_d = atan2(dy, dx);
v_d = sqrt(dx.^2 + dy.^2);
omega_d = (ddy .* dx - ddx .* dy) ./ (dx.^2 + dy.^2);


x_ts = timeseries(x', t');
y_ts = timeseries(y', t');
theta_ts = timeseries(theta_d', t');
v_d_ts = timeseries(v_d', t');
omega_d_ts = timeseries(omega_d', t');

x0 = x(1) + (rand - 0.5);
y0 = y(1) + (rand - 0.5);
theta0 = theta_d(1) + 0.2 * (rand - 0.5);
initial_state = [x0; y0; theta0];

save(['bern_ts_r', num2str(r), '.mat'], ...
    'x_ts', 'y_ts', 'theta_ts', 'v_d_ts', 'omega_d_ts', 'initial_state');

%% Simulazioni
out_lin = sim("es_3_model_linear.slx");
out_nonlin = sim("es_3_model_almost_nonlinear.slx");

fields = {'x', 'y', 'theta'};
labels = {'$x(t)$ [m]', '$y(t)$ [m]', '$\theta(t)$ [rad]'};
file_suffixes = {'x', 'y', 'theta'};

for i = 1:length(fields)
    field = fields{i};
    ts_ref = eval([field '_ts']);

    if strcmp(field, 'theta')
        sim_field = 'theta_w_sim';
    else
        sim_field = [field '_sim'];
    end

    %% --- TRACKING LINEAR ---
    figure('Color', 'w', 'Renderer', 'painters', 'Position', [10 10 900 350]);
    plot(ts_ref.Time, ts_ref.Data, '--', 'LineWidth', 2, 'Color', [0.2 0.2 0.2]); hold on;
    plot(out_lin.(sim_field).Time, out_lin.(sim_field).Data, '-', 'LineWidth', 2, 'Color', [0.5 0.5 0.5]);
    xlabel('$t$ [s]', 'Interpreter', 'latex');
    ylabel(labels{i}, 'Interpreter', 'latex');
    legend({'Reference', 'Linear'}, 'Interpreter', 'latex', 'Location', 'best');
    set(gca, 'FontSize', 22, 'TickLabelInterpreter', 'latex');
    grid on; box on;
    xlim([t(1), t(end)]);
    print(gcf, '-depsc2', [file_suffixes{i} '_tracking_linear_r' num2str(r) '.eps']);

    %% --- TRACKING NONLINEAR ---
    figure('Color', 'w', 'Renderer', 'painters', 'Position', [10 10 900 350]);
    plot(ts_ref.Time, ts_ref.Data, '--', 'LineWidth', 2, 'Color', [0.2 0.2 0.2]); hold on;
    plot(out_nonlin.(sim_field).Time, out_nonlin.(sim_field).Data, '-', 'LineWidth', 2, 'Color', [0.5 0.5 0.5]);
    xlabel('$t$ [s]', 'Interpreter', 'latex');
    ylabel(labels{i}, 'Interpreter', 'latex');
    legend({'Reference', 'Almost Nonlinear'}, 'Interpreter', 'latex', 'Location', 'best');
    set(gca, 'FontSize', 22, 'TickLabelInterpreter', 'latex');
    grid on; box on;
    xlim([t(1), t(end)]);
    print(gcf, '-depsc2', [file_suffixes{i} '_tracking_nonlin_r' num2str(r) '.eps']);

    %% --- ERROR LINEAR ---
    figure('Color', 'w', 'Renderer', 'painters', 'Position', [10 10 900 450]);
    e_field = ['e_' file_suffixes{i}];
    plot(out_lin.(e_field).Time, out_lin.(e_field).Data, '-', 'LineWidth', 2, 'Color', [0 0 1]);
    xlabel('$t$ [s]', 'Interpreter', 'latex');
    % Inserisco unità di misura sull'asse delle ordinate
    if strcmp(field, 'theta')
        ylabel(['$e_{' file_suffixes{i} '}(t)$ [rad]'], 'Interpreter', 'latex');
    else
        ylabel(['$e_{' file_suffixes{i} '}(t)$ [m]'], 'Interpreter', 'latex');
    end
    title(['Tracking error (Linear) - ', field], 'Interpreter', 'latex');
    legend({['$e_{' file_suffixes{i} '}(t)$']}, 'Interpreter', 'latex', 'Location', 'best');
    set(gca, 'FontSize', 22, 'TickLabelInterpreter', 'latex');
    grid on; box on;
    xlim([t(1), t(end)]);
    print(gcf, '-depsc2', ['error_' file_suffixes{i} '_linear_r' num2str(r) '.eps']);

    %% --- ERROR NONLINEAR ---
    figure('Color', 'w', 'Renderer', 'painters', 'Position', [10 10 900 450]);
    plot(out_nonlin.(e_field).Time, out_nonlin.(e_field).Data, '-', 'LineWidth', 2, 'Color', [0 0 1]);
    xlabel('$t$ [s]', 'Interpreter', 'latex');
    if strcmp(field, 'theta')
        ylabel(['$e_{' file_suffixes{i} '}(t)$ [rad]'], 'Interpreter', 'latex');
    else
        ylabel(['$e_{' file_suffixes{i} '}(t)$ [m]'], 'Interpreter', 'latex');
    end
    title(['Tracking error (Nonlinear) - ', field], 'Interpreter', 'latex');
    legend({['$e_{' file_suffixes{i} '}(t)$']}, 'Interpreter', 'latex', 'Location', 'best');
    set(gca, 'FontSize', 22, 'TickLabelInterpreter', 'latex');
    grid on; box on;
    xlim([t(1), t(end)]);
    print(gcf, '-depsc2', ['error_' file_suffixes{i} '_nonlin_r' num2str(r) '.eps']);
end
%% --- Trajectory comparison: Reference vs Linear ---
figure('Color','w','Renderer','painters','Position',[10 10 900 500]);
plot(x_ts.Data, y_ts.Data,'--','LineWidth',2,'Color',[0.2 0.2 0.2]); hold on;
plot(out_lin.x_sim.Data, out_lin.y_sim.Data,'-','LineWidth',2,'Color',[1 0 0]);
xlabel('$x(t)$ [m]','Interpreter','latex');
ylabel('$y(t)$ [m]','Interpreter','latex');
hleg = legend({'Reference','Linear'}, ...
              'Interpreter','latex', ...
              'Location','west', ...       % center‑left inside the axes
              'Box','on');                % or 'off' if you prefer no box
set(hleg,'Orientation','vertical');
title(['Trajectory - Linear controller, r = ',num2str(r)],'Interpreter','latex', 'FontWeight', 'normal');
%title(['Trajectory – Linear controller, r = ',num2str(r)],'Interpreter','latex', 'FontWeight', 'normal');
axis equal; grid on;
set(gca,'FontSize',22,'TickLabelInterpreter','latex');
print(gcf,'-depsc2',['trajectory_linear_r' num2str(r) '.eps']);


%% --- Trajectory comparison: Reference vs Nonlinear ---
figure('Color','w','Renderer','painters','Position',[10 10 900 500]);
plot(x_ts.Data, y_ts.Data,'--','LineWidth',2,'Color',[0.2 0.2 0.2]); hold on;
plot(out_nonlin.x_sim.Data, out_nonlin.y_sim.Data,'-','LineWidth',2,'Color',[1 0 0]);
xlabel('$x(t)$ [m]','Interpreter','latex');
ylabel('$y(t)$ [m]','Interpreter','latex');
hleg = legend({'Reference','Almost Nonlinear'}, ...
              'Interpreter','latex', ...
              'Location','west', ...
              'Box','on');
set(hleg,'Orientation','vertical');
title(['Trajectory - Almost Nonlinear, r = ',num2str(r)],'Interpreter','latex','FontWeight', 'normal');
%title(['Trajectory – Almost Nonlinear, r = ',num2str(r)],'Interpreter','latex','FontWeight', 'normal');
axis equal; grid on;
set(gca,'FontSize',22,'TickLabelInterpreter','latex');
print(gcf,'-depsc2',['trajectory_nonlin_r' num2str(r) '.eps']);

