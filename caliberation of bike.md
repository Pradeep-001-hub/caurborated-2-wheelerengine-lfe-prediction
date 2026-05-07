============================================================
ENGINE HEALTH DEVICE – AUTO CALIBRATION PROCEDURE
============================================================

PHASE 0 — SYSTEM PREPARATION
------------------------------------------------------------
Conditions before calibration:
- Engine must be started and fully warmed up
- No throttle input for 2–3 minutes (idle stabilization)
- Sensor must be rigidly mounted (no loose vibration)
- Power supply must be stable (no voltage dips)

Reject calibration if:
- Engine is cold
- Sensor mounting is loose
- Electrical noise is high (starter / ignition spikes)

============================================================

PHASE 1 — IDLE BASELINE CAPTURE
------------------------------------------------------------
Goal: Learn stable engine idle signature

Conditions:
- Bike in neutral
- No throttle movement
- Engine fully warm
- Vehicle stationary

System records:
- baseLambdaIdle
- baseVibrationIdle
- baseNoiseVariance

Validation rule:
Only accept data if:
- vibration is low and stable
- lambda variance is minimal
- no spikes detected

If unstable → discard sample

============================================================

PHASE 2 — LIGHT REV CALIBRATION
------------------------------------------------------------
Goal: Capture controlled engine response behavior

Conditions:
- 2 to 3 gentle throttle blips
- Return to idle after each blip
- No aggressive acceleration

System learns:
- vibration spike profile
- lambda response delay
- transient engine behavior

Important rule:
Ignore data during:
- throttle transition phase
- sudden spike region

Only store:
- post-rev stabilization data

============================================================

PHASE 3 — REAL RIDING PROFILE LEARNING
------------------------------------------------------------
Goal: Capture real-world engine behavior

Conditions:
- Normal riding for 10–15 minutes
- Mixed speed (city riding)
- No aggressive racing behavior

System records:
- cruising vibration baseline
- load-dependent lambda variation
- real operating drift patterns

This becomes:
→ real-world reference model

============================================================

PHASE 4 — BASELINE MODEL GENERATION
------------------------------------------------------------
System computes weighted baseline:

FinalBaseline =
    60% Idle Data
    30% Riding Data
    10% Rev Response Smoothing

Outputs:
- baseLambda
- baseVibration
- baseNoiseProfile

============================================================

PHASE 5 — CONFIDENCE LOCK
------------------------------------------------------------
Condition:
If calibration stability is consistent over time

Then:
- Increase confidence score
- Reduce learning rate
- Freeze fast adaptation phase

Rule:
IF confidence > threshold:
    switch to slow drift correction mode

============================================================

PHASE 6 — CONTINUOUS SELF-ADAPTATION (RUN MODE)
------------------------------------------------------------
System behavior after calibration:

- Continuously updates baseline slowly
- Rejects sudden spikes and anomalies
- Compensates for engine wear over time
- Maintains long-term stability

Drift update rule:
- Very slow adjustment only (long-term changes)

============================================================

SAFETY & VALIDATION RULES
------------------------------------------------------------
DO NOT calibrate if:
- engine is cold
- vibration mounting is unstable
- throttle is being aggressively used
- electrical noise is high

ALWAYS ensure:
- idle stability first
- warm engine condition
- clean sensor signals

============================================================
END OF CALIBRATION PROCEDURE
============================================================