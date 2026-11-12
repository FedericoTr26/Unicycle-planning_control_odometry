%RUN DIRECTLY THIS SCRIPT TO OBTAIN THE RESULT FROM SIMULINK (every time I
%run the eps' plot will be saved in the current folder)
clear
clc
close all

q_i = [0 0 0]';          
q_f = rand(1,3)';   
q_f = q_f / norm(q_f); % normalizzata a distanza unitaria

% devo mettere le condizioni iniziali e finali
x_i = q_i(1); 
y_i = q_i(2); 
theta_i = q_i(3);

x_f = q_f(1); 
y_f = q_f(2); 
theta_f = q_f(3);

%limiti
v_lim = 0.5;
w_lim = 2;

%coeff 
k=1;
alpha_x = k*cos(theta_f) - 3*x_f;
alpha_y = k*sin(theta_f) - 3*y_f;
beta_x  = k*cos(theta_i) + 3*x_i;
beta_y  = k*sin(theta_i) + 3*y_i;

% legge temporale cubica standard (s(t) = 3(t/T)^2 - 2(t/T)^3)
t_i = 0;
t_f = 1;            
t = t_i : 0.001 : t_f;
T = t_f - t_i;      % T = durata
tau=t/T;

s = 3*(tau).^2 - 2*(tau).^3;
sdot = (6/T)*(tau).*(1 - tau);  % derivata della legge cubica

%polinomi (percorso geometrico)
x_s = s.^3 * x_f - (s - 1).^3 .* x_i + alpha_x .* s.^2 .* (s - 1) + beta_x .* s .* (s - 1).^2;
y_s = s.^3 * y_f - (s - 1).^3 .* y_i + alpha_y .* s.^2 .* (s - 1) + beta_y .* s .* (s - 1).^2;

% derivate prime
dx_s = 3*s.^2 * x_f - 3*(s - 1).^2 .* x_i + alpha_x .* (2*s .* (s - 1) + s.^2) + beta_x  .* ((s - 1).^2 + 2*s .* (s - 1));
dy_s = 3*s.^2 * y_f - 3*(s - 1).^2 .* y_i + alpha_y .* (2*s .* (s - 1) + s.^2) + beta_y  .* ((s - 1).^2 + 2*s .* (s - 1));

thetas = atan2(dy_s, dx_s);

% derivate seconde
ddx_s = 6 .* s .* x_f - 6 .* (s - 1) .* x_i + alpha_x .* (2 .* (s - 1) + 4 .* s) + beta_x  .* (4 .* (s - 1) + 2 .* s);
ddy_s = 6 .* s .* y_f - 6 .* (s - 1) .* y_i + alpha_y .* (2 .* (s - 1) + 4 .* s) + beta_y  .* (4 .* (s - 1) + 2 .* s);

%velocità (temporali)
v_tilde = sqrt(dx_s.^2 + dy_s.^2);
w_tilde = (ddy_s .* dx_s - ddx_s .* dy_s) ./ (dx_s.^2 + dy_s.^2);
v = v_tilde .* sdot;
w = w_tilde .* sdot;


%% PLOTS
figure('Color', 'w', 'Renderer', 'painters', 'Position', [10 10 900 650])
subplot(2,1,1)
plot(t, v, 'LineWidth', 2, 'Color', [0 0 1]); hold on
yline(0.5, '--r', '$v_{\mathrm{lim}}$', 'Interpreter', 'latex');
y_max = max(v);
ylim([0, max(y_max, v_lim) * 1.05]); % aggiungo un 5% di margine visivo
title('Linear velocity $v(t)$ before scaling', 'Interpreter', 'latex')
ylabel('$v(t)\ [\mathrm{m}/\mathrm{s}]$', 'Interpreter', 'latex')
xlabel('$t\ [\mathrm{s}]$', 'Interpreter', 'latex')
grid on; set(gca, 'FontSize', 22, 'TickLabelInterpreter', 'latex')

subplot(2,1,2)
plot(t, w, 'LineWidth', 2, 'Color', [0 0 1]); hold on
yline(2, '--r', '$\omega_{\mathrm{lim}}$', 'Interpreter', 'latex');
ymax2=max(w);
ymin=min(w);
ylim([ymin,max(ymax2,w_lim)*1.05]);
% yl = ylim;
% ylim([yl(1), 3.5])
title('Angular velocity $\omega(t)$ before scaling', 'Interpreter', 'latex')
ylabel('$\omega(t)\ [\mathrm{rad}/\mathrm{s}]$', 'Interpreter', 'latex')
xlabel('$t\ [\mathrm{s}]$', 'Interpreter', 'latex')
grid on; set(gca, 'FontSize', 22, 'TickLabelInterpreter', 'latex')
print(gcf, '-depsc2', 'velocity_before_scaling')

figure('Color', 'w', 'Renderer', 'painters', 'Position', [10 10 900 650])
plot3(s, x_s, y_s, 'LineWidth', 2, 'Color', [0 0 1])
grid on
xlabel('$s$', 'Interpreter', 'latex')
ylabel('$x(s)\ [\mathrm{m}]$', 'Interpreter', 'latex')
zlabel('$y(s)\ [\mathrm{m}]$', 'Interpreter', 'latex')
title('3D path', 'Interpreter', 'latex')
set(gca, 'FontSize', 22, 'TickLabelInterpreter', 'latex')
print(gcf, '-depsc2', 'planned_path_plot3')

figure('Color', 'w', 'Renderer', 'painters', 'Position', [10 10 900 550])
plot(t, s, 'LineWidth', 2, 'Color', [0 0 1])
grid on
xlabel('$t\ [\mathrm{s}]$', 'Interpreter', 'latex')
ylabel('$s(t)$', 'Interpreter', 'latex')
title('Cubic time law $s(t)$', 'Interpreter', 'latex')
set(gca, 'FontSize', 22, 'TickLabelInterpreter', 'latex')
print(gcf, '-depsc2', 's_time_law')

figure('Color', 'w', 'Renderer', 'painters', 'Position', [10 10 900 650])
subplot(3,1,1)
plot(s, x_s, 'LineWidth', 2, 'Color', [0 0 1])
grid on
xlabel('$s$', 'Interpreter', 'latex')
ylabel('$x(s)\ [\mathrm{m}]$', 'Interpreter', 'latex')
title('Position $x(s)$ along the trajectory', 'Interpreter', 'latex')
set(gca, 'FontSize', 22, 'TickLabelInterpreter', 'latex')

subplot(3,1,2)
plot(s, y_s, 'LineWidth', 2, 'Color', [0 0 1])
grid on
xlabel('$s$', 'Interpreter', 'latex')
ylabel('$y(s)\ [\mathrm{m}]$', 'Interpreter', 'latex')
title('Position $y(s)$ along the trajectory', 'Interpreter', 'latex')
set(gca, 'FontSize', 22, 'TickLabelInterpreter', 'latex')

subplot(3,1,3)
plot(s, thetas, 'LineWidth', 2, 'Color', [0 0 1])
grid on
xlabel('$s$', 'Interpreter', 'latex')
ylabel('$\theta(s)\ [\mathrm{rad}]$', 'Interpreter', 'latex')
title('Orientation $\theta(s)$ along the trajectory', 'Interpreter', 'latex')
set(gca, 'FontSize', 22, 'TickLabelInterpreter', 'latex')
print(gcf, '-depsc2', 'x_y_theta_vs_s')

figure('Color', 'w', 'Renderer', 'painters', 'Position', [10 10 900 650])
subplot(2,2,1)
plot(s, dx_s, 'LineWidth', 2, 'Color', [0.2 0.2 0.2])
grid on
xlabel('$s$', 'Interpreter', 'latex')
ylabel('$x''(s)\ [\mathrm{m}]$', 'Interpreter', 'latex')
title('First derivative $x''(s)$', 'Interpreter', 'latex')
set(gca, 'FontSize', 22, 'TickLabelInterpreter', 'latex')

subplot(2,2,2)
plot(s, dy_s, 'LineWidth', 2, 'Color', [0.2 0.2 0.2])
grid on
xlabel('$s$', 'Interpreter', 'latex')
ylabel('$y''(s)\ [\mathrm{m}]$', 'Interpreter', 'latex')
title('First derivative $y''(s)$', 'Interpreter', 'latex')
set(gca, 'FontSize', 22, 'TickLabelInterpreter', 'latex')

subplot(2,2,3)
plot(s, ddx_s, 'LineWidth', 2, 'Color', [0.2 0.2 0.2])
grid on
xlabel('$s$', 'Interpreter', 'latex')
ylabel('$x''''(s)\ [\mathrm{m}]$', 'Interpreter', 'latex')
title('Second derivative $x''''(s)$', 'Interpreter', 'latex')
set(gca, 'FontSize', 22, 'TickLabelInterpreter', 'latex')

subplot(2,2,4)
plot(s, ddy_s, 'LineWidth', 2, 'Color', [0.2 0.2 0.2])
grid on
xlabel('$s$', 'Interpreter', 'latex')
ylabel('$y''''(s)\ [\mathrm{m}]$', 'Interpreter', 'latex')
title('Second derivative $y''''(s)$', 'Interpreter', 'latex')
set(gca, 'FontSize', 22, 'TickLabelInterpreter', 'latex')
print(gcf, '-depsc2', 'derivatives_vs_s')

% v_lim = 0.5;
% w_lim = 2;

v_max = max(abs(v));
w_max = max(abs(w));

% scaling_necessario = false;
% motivo = "";
% 
% if v_max > v_lim && w_max <= w_lim
%     %scaling_factor = v_max / v_lim;
%     scaling_factor = max([v_max / v_lim, w_max / w_lim]);
%     motivo = "solo v(t) supera il limite";
%     scaling_necessario = true;
% elseif v_max <= v_lim && w_max > w_lim
%     %scaling_factor = w_max / w_lim;
%     scaling_factor = max([v_max / v_lim, w_max / w_lim]);
%     motivo = "solo w(t) supera il limite";
%     scaling_necessario = true;
% elseif v_max > v_lim && w_max > w_lim
%     scaling_factor = max([v_max / v_lim, w_max / w_lim]);
%     motivo = "sia v(t) che w(t) superano il limite";
%     scaling_necessario = true;
% else
%     fprintf("Nessuno scaling necessario: limiti rispettati.\n");
% end

%così mi sembra meno ridondante
scaling_necessario = false;

if v_max > v_lim || w_max > w_lim
    scaling_necessario = true;

    ratio_v = v_max / v_lim;
    ratio_w = w_max / w_lim;
    scaling_factor = max([ratio_v, ratio_w]);

    if v_max > v_lim && w_max > w_lim
        motivo = "sia v(t) che w(t) superano il limite";
    elseif v_max > v_lim
        motivo = "solo v(t) supera il limite";
    else
        motivo = "solo w(t) supera il limite";
    end

else
    fprintf("Nessuno scaling necessario: limiti rispettati.\n");
end


if scaling_necessario
    T_new = T * scaling_factor;
    fprintf("Scaling necessario: %s\n", motivo);
    fprintf("T originale: %.3f s → Nuovo T: %.3f s\n", T, T_new);

    T = T_new;
    t = 0:0.001:T;
    tau = t / T;

    s = 3*(tau).^2 - 2*(tau).^3;
    sdot = (6/T)*(tau).*(1 - tau);

    x_s = s.^3 * x_f - (s - 1).^3 .* x_i + alpha_x .* s.^2 .* (s - 1) + beta_x .* s .* (s - 1).^2;
    y_s = s.^3 * y_f - (s - 1).^3 .* y_i + alpha_y .* s.^2 .* (s - 1) + beta_y .* s .* (s - 1).^2;

    dx_s = 3*s.^2 * x_f - 3*(s - 1).^2 .* x_i + alpha_x .* (2*s .* (s - 1) + s.^2) + beta_x .* ((s - 1).^2 + 2*s .* (s - 1));
    dy_s = 3*s.^2 * y_f - 3*(s - 1).^2 .* y_i + alpha_y .* (2*s .* (s - 1) + s.^2) + beta_y .* ((s - 1).^2 + 2*s .* (s - 1));

    ddx_s = 6*s*x_f - 6*(s - 1).*x_i + alpha_x .* (2*(s - 1) + 4*s) + beta_x .* (4*(s - 1) + 2*s);
    ddy_s = 6*s*y_f - 6*(s - 1).*y_i + alpha_y .* (2*(s - 1) + 4*s) + beta_y .* (4*(s - 1) + 2*s);

    thetas = atan2(dy_s, dx_s);

    v_tilde = sqrt(dx_s.^2 + dy_s.^2);
    w_tilde = (ddy_s .* dx_s - ddx_s .* dy_s) ./ (dx_s.^2 + dy_s.^2);

    v = v_tilde .* sdot;
    w = w_tilde .* sdot;

    figure('Color', 'w', 'Renderer', 'painters', 'Position', [10 10 900 650])
    subplot(2,1,1)
    plot(t, v, 'LineWidth', 2, 'Color', [0 0 1]); hold on
    yline(v_lim, '--r', '$v_{\mathrm{lim}}$', 'Interpreter', 'latex');
    ylim([0, 0.55]); 
    title('Linear velocity $v(t)$ after scaling', 'Interpreter', 'latex')
    ylabel('$v(t)\ [\mathrm{m}/\mathrm{s}]$', 'Interpreter', 'latex')
    xlabel('$t\ [\mathrm{s}]$', 'Interpreter', 'latex')
    grid on; set(gca, 'FontSize', 22, 'TickLabelInterpreter', 'latex')

    subplot(2,1,2)
    plot(t, w, 'LineWidth', 2, 'Color', [0 0 1]); hold on
    yline(w_lim, '--r', '$\omega_{\mathrm{lim}}$', 'Interpreter', 'latex'); 
    yline(-w_lim, '--r');
    yl = ylim;
    ylim([yl(1), 3.5])
    title('Angular velocity $\omega(t)$ after scaling', 'Interpreter', 'latex')
    ylabel('$\omega(t)\ [\mathrm{rad}/\mathrm{s}]$', 'Interpreter', 'latex')
    xlabel('$t\ [\mathrm{s}]$', 'Interpreter', 'latex')
    grid on; set(gca, 'FontSize', 22, 'TickLabelInterpreter', 'latex')

    print(gcf, '-depsc2', 'velocity_after_scaling')
end