function plot_dashboard(data, save_fig)
%PLOT_DASHBOARD  Engine life monitoring dashboard.

if nargin < 2, save_fig = false; end

stage_colors = [0.18 0.80 0.44; 0.95 0.77 0.06; 0.90 0.49 0.13; 0.91 0.30 0.24];
stage_labels = {'NEW','NORMAL WEAR','ACCEL. WEAR','CRITICAL'};

latest = data(end,:);
stg    = latest.stage + 1;   % 1-indexed

fig = figure('Name','Engine Dashboard','Position',[50 50 1400 800], ...
             'Color',[0.10 0.10 0.14]);

%% Status banner
ax0 = subplot('Position',[0.02 0.88 0.96 0.08]);
patch([0 1 1 0],[0 0 1 1], stage_colors(stg,:), 'Parent',ax0);
text(0.5, 0.5, sprintf('ENGINE STATUS:  %s   |   Health: %.1f%%   |   RUL: %.0f hrs', ...
     stage_labels{stg}, latest.health_index, latest.RUL_hours), ...
     'Units','normalized','HorizontalAlignment','center', ...
     'FontSize',14,'FontWeight','bold','Color','w','Parent',ax0);
axis(ax0,'off');

%% KPI tiles
kpi = {
    'Lambda (λ)',       latest.lambda,         0.8,  1.2,  'λ';
    'Air-Fuel Ratio',   latest.AFR,            10,   18,   'AFR';
    'Comb. Efficiency', latest.combustion_eff, 60,   100,  '%';
    'CO Level',         latest.CO_ppm,         0,    5000, 'ppm';
};

for k = 1:4
    ax = subplot('Position', [0.02+(k-1)*0.245, 0.60, 0.22, 0.25]);
    set(ax,'Color',[0.13 0.13 0.18]);
    val  = kpi{k,2}; vmin = kpi{k,3}; vmax = kpi{k,4};
    pct  = min(1, max(0, (val-vmin)/(vmax-vmin)));
    col  = [pct, 1-pct, 0.2];   % green → red

    % Semicircle gauge
    th = linspace(pi, 0, 200);
    plot(ax, cos(th), sin(th), 'Color',[0.3 0.3 0.3], 'LineWidth', 10); hold(ax,'on');
    th_f = linspace(pi, pi - pct*pi, 200);
    plot(ax, cos(th_f), sin(th_f), 'Color', col, 'LineWidth', 10);
    text(ax, 0, -0.1, sprintf('%.2f', val),  'HorizontalAlignment','center', ...
         'FontSize',18,'FontWeight','bold','Color','w');
    text(ax, 0, -0.45, kpi{k,5}, 'HorizontalAlignment','center','FontSize',10,'Color',[0.7 0.7 0.7]);
    text(ax, 0,  0.7,  kpi{k,1}, 'HorizontalAlignment','center','FontSize',10,'FontWeight','bold','Color','w');
    xlim(ax,[-1.3 1.3]); ylim(ax,[-0.7 1.1]); axis(ax,'off');
end

%% Health trend
ax_h = subplot('Position',[0.02 0.08 0.46 0.45]);
set(ax_h,'Color',[0.13 0.13 0.18],'XColor','w','YColor','w');
plot(ax_h, data.hour, data.health_index, 'Color',[0.5 0.5 0.5], 'LineWidth',0.8); hold(ax_h,'on');
plot(ax_h, data.hour, movmean(data.health_index,50), 'Color',[0.18 0.80 0.44], 'LineWidth',2);
yline(ax_h, 30,'r--','LineWidth',1);
xlabel(ax_h,'Hours','Color','w'); ylabel(ax_h,'Health Index','Color','w');
title(ax_h,'Health Index Over Life','Color','w'); grid(ax_h,'on');
ax_h.GridColor = [0.3 0.3 0.3];

%% Emissions trend
ax_e = subplot('Position',[0.52 0.08 0.46 0.45]);
set(ax_e,'Color',[0.13 0.13 0.18],'XColor','w','YColor','w');
plot(ax_e, data.hour, data.CO_ppm,  'r',  'LineWidth',1,'DisplayName','CO');  hold(ax_e,'on');
plot(ax_e, data.hour, data.HC_ppm,  'Color',[1 0.6 0],'LineWidth',1,'DisplayName','HC');
plot(ax_e, data.hour, data.NOx_ppm, 'm',  'LineWidth',1,'DisplayName','NOx');
xlabel(ax_e,'Hours','Color','w'); ylabel(ax_e,'[ppm]','Color','w');
title(ax_e,'Exhaust Emissions','Color','w');
legend(ax_e,'TextColor','w','Color',[0.2 0.2 0.2],'FontSize',8);
grid(ax_e,'on'); ax_e.GridColor = [0.3 0.3 0.3];

if save_fig
    if ~exist('results','dir'), mkdir('results'); end
    saveas(fig,'results/dashboard.png');
    fprintf('  Dashboard saved → results/dashboard.png\n');
end
end
