%% VALIDATE_HEALTH_ALGORITHM
%
% This is the script your repo was missing: it actually runs your firmware
% health-scoring algorithm (calculate_health_score.m) on the lambda signal
% from your own official long-duration scenarios (generate_synthetic_
% engine_data.m) and compares the result to the injected ground-truth
% health curve. run_all_scenarios.m never did this -- it only re-plotted
% the ground-truth curve.
%
% REQUIRES (same folder or MATLAB path):
%   generate_synthetic_engine_data.m   (patched version with seed arg, included)
%   calculate_health_score.m           (included)
%
% OUTPUTS (written to ./results/):
%   fig1_<scenario>_pred_vs_truth.png   x4  (one per scenario)
%   fig2_error_summary.png
%   validation_results.csv

clear; clc; close all;
if ~exist('results', 'dir'), mkdir('results'); end

scenarios = {'healthy', 'worn', 'critical', 'rich_fault'};
durations = [500, 2000, 3000, 1500];

n = numel(scenarios);
MAE  = zeros(n,1);
RMSE = zeros(n,1);
R    = zeros(n,1);

fprintf('\n%-12s %8s %8s %8s %8s\n', 'Scenario', 'Dur(h)', 'MAE', 'RMSE', 'r');
fprintf('%s\n', repmat('-', 1, 50));

for k = 1:n
    name = scenarios{k};
    dur  = durations(k);

    data = generate_synthetic_engine_data(name, dur);

    [pred, knock_s, comb_s, trend_s] = calculate_health_score(data.lambda);
    truth = data.health_index;

    err = pred - truth;
    MAE(k)  = mean(abs(err));
    RMSE(k) = sqrt(mean(err.^2));
    Rmat    = corrcoef(pred, truth);
    R(k)    = Rmat(1,2);

    fprintf('%-12s %8d %8.2f %8.2f %8.3f\n', name, dur, MAE(k), RMSE(k), R(k));

    %% ---- Comparison plot: predicted vs. ground truth ----
    fig = figure('Position', [100 100 900 420], 'Color', 'w');
    plot(data.hour, truth, 'Color', [0.16 0.49 0.25], 'LineWidth', 1.8); hold on;
    plot(data.hour, pred,  'Color', [0.75 0.16 0.16], 'LineWidth', 1.2);
    yline(30, 'k--', 'Critical threshold (30)', 'LabelHorizontalAlignment', 'left');
    xlabel('Engine hours');
    ylabel('Health score (0-100)');
    title(sprintf('Scenario: %s (%d h) -- predicted vs. ground truth', name, dur), ...
          'Interpreter', 'none');
    legend('Ground-truth health (simulation label)', ...
           'calculate\_health\_score() output (actual firmware algorithm)', ...
           'Location', 'best');
    grid on;
    ylim([0 105]);
    saveas(fig, fullfile('results', sprintf('fig1_%s_pred_vs_truth.png', name)));
end

%% ---- Summary bar chart: MAE / RMSE / r by scenario ----
fig2 = figure('Position', [100 100 800 420], 'Color', 'w');
b = bar([MAE RMSE]);
b(1).FaceColor = [0.16 0.50 0.73];
b(2).FaceColor = [0.90 0.49 0.13];
set(gca, 'XTickLabel', scenarios);
ylabel('Error (health-score points, 0-100 scale)');
title('Prediction error of calculate\_health\_score() vs. ground truth, by scenario');
legend('MAE', 'RMSE', 'Location', 'northwest');
grid on;
for k = 1:n
    text(k, max(MAE(k), RMSE(k)) + 1.5, sprintf('r=%+.2f', R(k)), ...
         'HorizontalAlignment', 'center', 'FontSize', 9);
end
saveas(fig2, fullfile('results', 'fig2_error_summary.png'));

%% ---- Save results table (use this table directly in your thesis) ----
T = table(scenarios', durations', MAE, RMSE, R, ...
    'VariableNames', {'Scenario', 'Duration_hours', 'MAE', 'RMSE', 'PearsonR'});
writetable(T, fullfile('results', 'validation_results.csv'));

fprintf('\nSaved 4 comparison plots + fig2_error_summary.png + validation_results.csv to results/\n');
fprintf('Use validation_results.csv directly as your "Quantitative Validation" table.\n');
