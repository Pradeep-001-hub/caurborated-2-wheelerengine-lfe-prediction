NORMAL ENGINE (Idle, stoichiometric):
  Lambda: 0.98 - 1.02 (±0.02 variation)
  AFR: 14.5 - 15.0
  Voltage: 1.45 - 1.55V (from CJ125)
  Health Score: 95-100
  Variance: < 0.01

RICH MIXTURE:
  Lambda: 0.85 - 0.95
  AFR: 12.5 - 14.0
  Voltage: 1.0 - 1.3V
  Health Score: 70-85 (combustion penalty)
  Variance: 0.01-0.03

LEAN MIXTURE:
  Lambda: 1.05 - 1.15
  AFR: 15.4 - 16.9
  Voltage: 1.7 - 1.9V
  Health Score: 75-85 (combustion penalty)
  Variance: 0.01-0.03

KNOCKING (Rapid oscillations):
  Lambda: 0.9 - 1.1 (oscillating)
  AFR: 13.2 - 16.2 (oscillating)
  Voltage: 1.2 - 1.8V (rapid changes)
  Health Score: 40-60 (knock penalty applied)
  Variance: > 0.08 (knock detected)

FOULED ENGINE (Degraded):
  Lambda: 1.05 - 1.12 (lean drift)
  AFR: 15.4 - 16.5
  Voltage: 1.65 - 1.85V
  Health Score: 50-70 (trend degradation)
  Variance: 0.02-0.05 (higher instability)