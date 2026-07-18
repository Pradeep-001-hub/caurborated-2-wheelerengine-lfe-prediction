function data = generate_synthetic_engine_data(scenario, duration_hours, seed)
%GENERATE_SYNTHETIC_ENGINE_DATA  Generates realistic engine degradation scenarios
%
%   data = generate_synthetic_engine_data('healthy', 500)
%   data = generate_synthetic_engine_data('worn', 2000)
%   data = generate_synthetic_engine_data('critical', 3000)
%   data = generate_synthetic_engine_data('rich_fault', 1500)
%   data = generate_synthetic_engine_data('worn', 2000, 7)   % seed = 7
%
%   PATCH NOTE (vs. the original file in the repo):
%   The only change is the new optional 3rd argument `seed`, which is
%   forwarded to rng() instead of the hard-coded rng(42). This is what
%   lets noise_ci_analysis.m re-run the same degradation curve with many
%   independent sensor-noise realizations. Everything else is unchanged.
%
% SCENARIOS:
%   'healthy'      : New engine, stable operation (baseline)
%   'worn'         : Normal wear progression over 2000 hours
%   'critical'     : Progressive degradation to critical stage
%   'rich_fault'   : Sudden rich mixture fault (bad spark plug, carb issue)

if nargin < 2, duration_hours = 2000; end
if nargin < 1, scenario = 'worn'; end
if nargin < 3, seed = 42; end

fprintf('\n  Generating synthetic data: %s (%d hours, seed=%d)\n', scenario, duration_hours, seed);

% Time vector (sample every 10 minutes -> 6 samples/hour)
samples_per_hour = 6;
n_samples = duration_hours * samples_per_hour;
hours = linspace(0, duration_hours, n_samples)';

% Lambda, AFR, emissions, combustion efficiency
lambda = zeros(n_samples, 1);
afr = zeros(n_samples, 1);
co_ppm = zeros(n_samples, 1);
hc_ppm = zeros(n_samples, 1);
nox_ppm = zeros(n_samples, 1);
combustion_eff = zeros(n_samples, 1);
health_index = zeros(n_samples, 1);
rul_hours = zeros(n_samples, 1);
stage = zeros(n_samples, 1);

%% Base degradation curves (parametric)
% Normalized progress: 0 (new) -> 1 (critical/failure)
progress = hours / max(hours);

switch lower(scenario)

    case 'healthy'
        lambda_base = 1.0 + 0.01 * sin(2*pi*progress/0.5);
        afr_base = 14.7 + 0.2 * sin(2*pi*progress/0.3);
        combustion_eff_base = 95 + 2 * sin(2*pi*progress);
        co_ppm_base = 200 + 50 * sin(2*pi*progress);
        hc_ppm_base = 30 + 10 * sin(2*pi*progress);
        nox_ppm_base = 80 + 20 * sin(2*pi*progress);
        health_base = 100 - 5 * progress;

    case 'worn'
        lambda_base = 0.98 + 0.04 * progress + 0.015 * sin(4*pi*progress);
        afr_base = 14.7 + 0.8 * progress + 0.3 * sin(4*pi*progress);
        combustion_eff_base = 95 - 25 * progress.^1.5;
        co_ppm_base = 200 + 1000 * progress.^2;
        hc_ppm_base = 30 + 150 * progress.^1.8;
        nox_ppm_base = 80 + 120 * progress.^1.3;
        health_base = 100 - 10 * progress - 50 * progress.^2.5;

    case 'critical'
        lambda_base = 0.95 + 0.1 * progress + 0.04 * sin(8*pi*progress);
        afr_base = 14.7 + 1.5 * progress + 0.5 * sin(8*pi*progress);
        combustion_eff_base = 95 - 40 * progress.^1.2;
        co_ppm_base = 200 + 4000 * progress.^2.2;
        hc_ppm_base = 30 + 400 * progress.^2;
        nox_ppm_base = 80 + 250 * progress.^1.5;
        health_base = 100 - 15*progress - 80*progress.^2 - 5*progress.^3;

    case 'rich_fault'
        fault_hour = min(500, duration_hours / 2);
        fault_idx = find(hours >= fault_hour, 1);

        pre = progress(1:fault_idx) / (progress(fault_idx) + eps);
        lambda(1:fault_idx) = 0.98 + 0.02 * pre;
        afr(1:fault_idx) = 14.7 + 0.1 * pre;
        combustion_eff(1:fault_idx) = 95 - 5 * pre;
        co_ppm(1:fault_idx) = 200 + 100 * pre;
        hc_ppm(1:fault_idx) = 30 + 20 * pre;
        nox_ppm(1:fault_idx) = 80 + 30 * pre;
        health_index(1:fault_idx) = 100 - 3 * pre;

        post_progress = (progress(fault_idx+1:end) - progress(fault_idx)) / (1 - progress(fault_idx));
        lambda_base = [lambda(1:fault_idx); 0.75 + 0.08 * post_progress];
        afr_base = [afr(1:fault_idx); 11 + 2 * post_progress];
        combustion_eff_base = [combustion_eff(1:fault_idx); 75 - 40 * post_progress.^1.5];
        co_ppm_base = [co_ppm(1:fault_idx); 1500 + 3000 * post_progress.^2];
        hc_ppm_base = [hc_ppm(1:fault_idx); 80 + 300 * post_progress];
        nox_ppm_base = [nox_ppm(1:fault_idx); 150 + 100 * post_progress];
        health_base = [health_index(1:fault_idx); 95 - 70 * post_progress.^1.5];

end

if ~strcmp(lower(scenario), 'rich_fault')
    lambda = lambda_base;
    afr = afr_base;
    combustion_eff = combustion_eff_base;
    co_ppm = co_ppm_base;
    hc_ppm = hc_ppm_base;
    nox_ppm = nox_ppm_base;
    health_index = health_base;
end

%% Add realistic sensor noise
rng(seed);   % <-- PATCHED: was rng(42)
lambda = lambda + 0.008 * randn(n_samples, 1);
afr = afr + 0.3 * randn(n_samples, 1);
co_ppm = co_ppm + 80 * randn(n_samples, 1);
hc_ppm = hc_ppm + 12 * randn(n_samples, 1);
nox_ppm = nox_ppm + 15 * randn(n_samples, 1);
combustion_eff = combustion_eff + 2 * randn(n_samples, 1);

% Clamp to physical limits
lambda = max(0.7, min(1.3, lambda));
afr = max(10, min(18, afr));
co_ppm = max(0, co_ppm);
hc_ppm = max(0, hc_ppm);
nox_ppm = max(0, nox_ppm);
combustion_eff = max(40, min(100, combustion_eff));

%% Stage classification
for i = 1:n_samples
    if health_index(i) > 85
        stage(i) = 0; % NEW
    elseif health_index(i) > 60
        stage(i) = 1; % NORMAL WEAR
    elseif health_index(i) > 30
        stage(i) = 2; % ACCEL WEAR
    else
        stage(i) = 3; % CRITICAL
    end
end

%% RUL estimation (Remaining Useful Life)
health_rate = gradient(health_index, hours);
health_smooth = movmean(health_index, 50);
health_rate_smooth = gradient(health_smooth, hours);

rul_hours = zeros(n_samples, 1);
for i = 1:n_samples
    if health_rate_smooth(i) < -0.01
        rul_hours(i) = abs(health_smooth(i) / health_rate_smooth(i));
    else
        rul_hours(i) = 500; % default if degradation is negligible
    end
    rul_hours(i) = max(0, rul_hours(i));
end

%% Package as table
data = table(hours, lambda, afr, co_ppm, hc_ppm, nox_ppm, ...
             combustion_eff, health_index, stage, rul_hours, ...
             'VariableNames', {'hour', 'lambda', 'AFR', 'CO_ppm', 'HC_ppm', ...
                               'NOx_ppm', 'combustion_eff', 'health_index', ...
                               'stage', 'RUL_hours'});

fprintf('  Generated %d samples\n', n_samples);
fprintf('    Health range: %.1f -> %.1f\n', min(health_index), max(health_index));
fprintf('    Lambda range: %.2f -> %.2f\n', min(lambda), max(lambda));
fprintf('    CO range: %.0f -> %.0f ppm\n', min(co_ppm), max(co_ppm));

end
