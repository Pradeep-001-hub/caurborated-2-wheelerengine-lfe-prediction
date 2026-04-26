function data = simulate_sensors(engine_hours)
%SIMULATE_SENSORS  Simulates Lambda/O2 sensor readings over engine lifespan.
%
%  Degradation stages:
%    Stage 0 — New engine        (0–25% life)
%    Stage 1 — Normal wear       (25–50%)
%    Stage 2 — Accelerated wear  (50–75%)
%    Stage 3 — Critical / EOL   (75–100%)
%
%  Returns a table with columns:
%    hour, life_pct, lambda, sensor_voltage, AFR,
%    combustion_eff, CO_ppm, HC_ppm, NOx_ppm,
%    health_index, RUL_hours, stage

if nargin < 1, engine_hours = 5000; end

STOICH_AFR   = 14.7;
LAMBDA_IDEAL = 1.0;
N_POINTS     = 2000;
rng(42);

hours = linspace(0, engine_hours, N_POINTS)';

% Preallocate
lambda        = zeros(N_POINTS, 1);
sensor_voltage= zeros(N_POINTS, 1);
AFR           = zeros(N_POINTS, 1);
combustion_eff= zeros(N_POINTS, 1);
CO_ppm        = zeros(N_POINTS, 1);
HC_ppm        = zeros(N_POINTS, 1);
NOx_ppm       = zeros(N_POINTS, 1);
health_index  = zeros(N_POINTS, 1);
RUL_hours     = zeros(N_POINTS, 1);
stage         = zeros(N_POINTS, 1);

for i = 1:N_POINTS
    hour     = hours(i);
    life_pct = hour / engine_hours;

    % Degradation model per stage
    if life_pct < 0.25
        drift = 0.0;       noise = 0.005;
        co_b  = 500  + 200  * life_pct/0.25;
        hc_b  = 50   + 20   * life_pct/0.25;
        nox_b = 80   + 30   * life_pct/0.25;
        stg   = 0;
    elseif life_pct < 0.50
        t = (life_pct-0.25)/0.25;
        drift = 0.02*t;    noise = 0.012;
        co_b  = 700  + 800  * t;
        hc_b  = 70   + 80   * t;
        nox_b = 110  + 90   * t;
        stg   = 1;
    elseif life_pct < 0.75
        t = (life_pct-0.50)/0.25;
        drift = 0.02 + 0.06*t;  noise = 0.025;
        co_b  = 1500 + 2000 * t;
        hc_b  = 150  + 200  * t;
        nox_b = 200  + 300  * t;
        stg   = 2;
    else
        t = (life_pct-0.75)/0.25;
        drift = 0.08 + 0.15*t;  noise = 0.05;
        co_b  = 3500 + 4000 * t;
        hc_b  = 350  + 400  * t;
        nox_b = 500  + 600  * t;
        stg   = 3;
    end

    % Lambda sensor (Nernst cell sigmoid response)
    lam = LAMBDA_IDEAL + drift + randn()*noise;
    Vout = 0.9 / (1 + exp(15*(lam - 1.0)));

    % Derived quantities
    afr_val  = lam * STOICH_AFR;
    eff      = max(0, min(100, 98.5 - 25*abs(lam-1.0) - 0.008*life_pct*100));
    co_val   = max(0, co_b  + randn()*co_b*0.05);
    hc_val   = max(0, hc_b  + randn()*hc_b*0.05);
    nox_val  = max(0, nox_b + randn()*nox_b*0.05);
    hi       = max(0, 100 - life_pct*100 - 10*drift^2*100 - co_val/1000);

    lambda(i)         = lam;
    sensor_voltage(i) = Vout;
    AFR(i)            = afr_val;
    combustion_eff(i) = eff;
    CO_ppm(i)         = co_val;
    HC_ppm(i)         = hc_val;
    NOx_ppm(i)        = nox_val;
    health_index(i)   = min(100, hi);
    RUL_hours(i)      = max(0, engine_hours - hour);
    stage(i)          = stg;
end

life_pct_col = hours / engine_hours * 100;

data = table(hours, life_pct_col, lambda, sensor_voltage, AFR, ...
             combustion_eff, CO_ppm, HC_ppm, NOx_ppm, ...
             health_index, RUL_hours, stage, ...
             'VariableNames', {'hour','life_pct','lambda','sensor_voltage', ...
             'AFR','combustion_eff','CO_ppm','HC_ppm','NOx_ppm', ...
             'health_index','RUL_hours','stage'});

% Save to CSV
if ~exist('data','dir'), mkdir('data'); end
writetable(data, 'data/sensor_data.csv');
fprintf('  Saved → data/sensor_data.csv\n');
end
