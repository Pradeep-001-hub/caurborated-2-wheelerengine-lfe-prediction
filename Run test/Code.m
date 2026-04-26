%% Unit Tests — Engine Life Prediction Suite
clc; clear; close all; addpath('../src');

passed = 0; failed = 0;

% Test 1: Sensor simulation output shape and ranges
try
    d = simulate_sensors(1000);
    assert(height(d) == 2000, 'Wrong row count');
    assert(all(d.lambda > 0.5 & d.lambda < 2.0), 'Lambda out of range');
    assert(all(d.health_index >= 0 & d.health_index <= 100), 'Health out of range');
    assert(all(d.RUL_hours >= 0), 'Negative RUL');
    fprintf('[PASS] Sensor simulation — shape and ranges\n'); passed=passed+1;
catch e
    fprintf('[FAIL] Sensor simulation: %s\n',e.message); failed=failed+1;
end

% Test 2: Health analysis returns valid final health
try
    d = simulate_sensors(1000);
    r = analyse_engine_health(d, false);
    assert(r.final_health >= 0 && r.final_health <= 100, 'Health out of bounds');
    fprintf('[PASS] Health analysis — final health value\n'); passed=passed+1;
catch e
    fprintf('[FAIL] Health analysis: %s\n',e.message); failed=failed+1;
end

% Test 3: RUL prediction R² > 0.85
try
    d = simulate_sensors(1000);
    r = predict_rul(d, false);
    assert(r.R2 > 0.85, sprintf('R²=%.4f below threshold', r.R2));
    fprintf('[PASS] RUL prediction — R²=%.4f\n', r.R2); passed=passed+1;
catch e
    fprintf('[FAIL] RUL prediction: %s\n',e.message); failed=failed+1;
end

% Test 4: Stages are 0,1,2,3 only
try
    d = simulate_sensors(1000);
    assert(all(ismember(d.stage, [0 1 2 3])), 'Invalid stage values');
    fprintf('[PASS] Stage classification — valid values\n'); passed=passed+1;
catch e
    fprintf('[FAIL] Stage classification: %s\n',e.message); failed=failed+1;
end

fprintf('\n----------------------------------\n');
fprintf(' Tests passed: %d / %d\n', passed, passed+failed);
if failed == 0, fprintf(' All tests passed!\n'); end
fprintf('----------------------------------\n');
