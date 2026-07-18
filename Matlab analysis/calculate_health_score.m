function [health_score, knock_score, combustion_score, trend_score, afr, lambda_filt] = ...
    calculate_health_score(lambda)
%CALCULATE_HEALTH_SCORE  Weighted engine health score from a lambda signal.
%
%   Extracted verbatim (logic unchanged) from the local function of the
%   same name inside "Analysis of working of device/Code.m", so it can be
%   called on its own and validated against the long-duration synthetic
%   scenarios produced by generate_synthetic_engine_data.m. This is the
%   ONLY algorithm in the repo that actually computes a health score from
%   raw sensor data (lambda) rather than having one authored/injected.
%
%   [health, knock, combustion, trend, afr] = calculate_health_score(lambda)
%
%   INPUT
%     lambda : Nx1 or 1xN vector of lambda (AFR/AFR_stoich) sensor readings
%
%   OUTPUT
%     health_score     : Nx1, 0-100 overall health score (weighted sum)
%     knock_score       : Nx1, 0-100, 45% weight  -> rolling-variance based
%     combustion_score  : Nx1, 0-100, 35% weight  -> mean deviation from lambda=1
%                          (NOTE: this is a single scalar broadcast to every
%                          sample in the ORIGINAL algorithm -- see the
%                          thesis addendum, Section 2.4, for why this is a
%                          structural limitation, not a bug in this port)
%     trend_score        : Nx1, 0-100, 20% weight  -> drift from baseline window
%     afr                 : Nx1, lambda converted to air-fuel ratio (14.7*lambda)

    WEIGHT_KNOCKING      = 0.45;
    WEIGHT_COMBUSTION    = 0.35;
    WEIGHT_TREND         = 0.20;
    KNOCK_SENSITIVITY    = 0.08;
    LAMBDA_TARGET        = 1.0;
    COMBUSTION_THRESHOLD = 0.12;

    lambda = lambda(:);                 % force column vector
    lambda_filt = movmean(lambda, 5);

    % ---- Convert to AFR (lambda_to_afr) ----
    afr = 14.7 * lambda_filt;

    % ---- 1. KNOCKING SCORE (45%) ----
    % High rolling variance = more knocking / instability
    lambda_variance = movvar(lambda_filt, 10);
    knock_score = 100 * max(0, 1 - lambda_variance / KNOCK_SENSITIVITY);

    % ---- 2. COMBUSTION QUALITY SCORE (35%) ----
    % Mean deviation from stoichiometric (lambda = 1.0) over the WHOLE
    % input -> single scalar, broadcast to every sample.
    lambda_deviation = abs(lambda_filt - LAMBDA_TARGET);
    combustion_quality = 100 * max(0, 1 - mean(lambda_deviation) / COMBUSTION_THRESHOLD);
    combustion_score = repmat(combustion_quality, length(lambda), 1);

    % ---- 3. TREND DEGRADATION SCORE (20%) ----
    % Compare a 50-sample rolling mean to a fixed baseline (first 20% of run)
    baseline_end = max(20, round(length(lambda) * 0.2));
    baseline = mean(lambda_filt(1:baseline_end));
    current_avg = movmean(lambda_filt, 50);
    trend_degradation = abs(current_avg - baseline);
    trend_score = 100 * max(0, 1 - trend_degradation * 10);   % x10 scale factor

    % ---- OVERALL HEALTH SCORE ----
    health_score = WEIGHT_KNOCKING   * knock_score + ...
                   WEIGHT_COMBUSTION * combustion_score + ...
                   WEIGHT_TREND      * trend_score;

    % ---- Clamp all outputs to [0, 100] ----
    health_score      = max(0, min(100, health_score));
    knock_score        = max(0, min(100, knock_score));
    combustion_score   = max(0, min(100, combustion_score));
    trend_score          = max(0, min(100, trend_score));
end
