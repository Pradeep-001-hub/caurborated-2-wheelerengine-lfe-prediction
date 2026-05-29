# Engine Life Prediction Device Using Lambda Sensor and CJ125

## 1. Introduction

The **Engine Life Prediction Device** is an embedded intelligent diagnostic system designed to monitor engine combustion behavior, estimate engine health degradation, and predict Remaining Useful Life (RUL) using exhaust gas analysis.

The system uses a **Bosch Wideband Lambda Sensor** interfaced with the **CJ125 Wideband Lambda Controller IC** to measure accurate Air-Fuel Ratio (AFR) and oxygen concentration in real time.

The device continuously:

- Monitors combustion quality
- Processes sensor signals
- Logs operational data to an SD card
- Performs health estimation
- Predicts engine degradation trends

This project combines:

- Embedded Systems
- Signal Processing
- Machine Learning
- Predictive Maintenance
- Automotive Diagnostics
- Edge AI

### Main Objectives

- Real-time engine health monitoring
- Remaining useful life estimation
- Fault detection
- Combustion analysis
- Data logging for predictive analytics
- Low-cost intelligent diagnostics

---

# 2. Methodology

The system follows a complete real-time data acquisition and prediction pipeline.

## Step 1 — Exhaust Monitoring

A wideband lambda sensor is installed near the engine exhaust manifold to measure oxygen concentration and combustion efficiency.

Measured characteristics include:

- Air-Fuel Ratio (AFR)
- Lambda value
- Combustion stability
- Rich/Lean conditions
- Exhaust behavior

---

## Step 2 — CJ125 Signal Conditioning

The **CJ125 IC** acts as the interface between the lambda sensor and microcontroller.

Functions of CJ125:

- Heater control
- Pump current control
- Nernst cell regulation
- Signal amplification
- Sensor calibration support

The CJ125 converts raw lambda sensor behavior into measurable electrical outputs.

---

## Step 3 — Data Acquisition

A microcontroller such as:

- ESP32
- STM32
- Arduino

collects:

- Lambda readings
- AFR values
- Temperature data
- RPM
- Operating hours
- Pump current information

The signals are sampled continuously in real time.

---

## Step 4 — SD Card Logging

All sensor and prediction data are stored on an SD card for:

- Offline analysis
- Dataset generation
- Long-term monitoring
- Model training

Example logging format:

```csv
Timestamp,RPM,AFR,Lambda,Temperature,HealthScore
```

---

## Step 5 — Signal Processing

Sensor data undergoes preprocessing to improve reliability.

Processing techniques include:

- Moving average filtering
- Low-pass filtering
- Noise suppression
- Normalization
- Feature extraction

Processed data is then sent to the prediction model.

---

## Step 6 — Prediction

Machine learning algorithms analyze extracted features to estimate:

- Engine health condition
- Remaining Useful Life (RUL)
- Combustion abnormalities
- Wear progression

---

# 3. Dataset

The dataset contains engine operational parameters collected under different engine conditions.

## Dataset Parameters

| Parameter | Description |
|---|---|
| RPM | Engine rotational speed |
| AFR | Air-Fuel Ratio |
| Lambda | Oxygen ratio |
| Temperature | Exhaust temperature |
| Pump Current | CJ125 pump cell current |
| Voltage | Supply voltage |
| Runtime Hours | Engine operational duration |
| Health Label | Engine condition class |

---

## Dataset Categories

The dataset includes:

- Healthy conditions
- Rich combustion
- Lean combustion
- Misfire conditions
- High temperature operation
- Sensor drift scenarios
- Degraded engine conditions

---

## Data Sources

Possible data sources:

- Real engine testing
- Simulated engine models
- Public degradation datasets
- Laboratory experiments

---

# 4. Signal Processing

Signal processing improves measurement stability and prediction accuracy.

## Noise Reduction

Wideband lambda sensors are sensitive to:

- Ignition noise
- Exhaust turbulence
- Heater instability
- Electrical interference

Filtering methods reduce unwanted variations.

---

## Feature Extraction

Important extracted features include:

- Mean AFR
- Lambda variance
- Temperature fluctuation
- Moving RMS
- Combustion oscillation frequency
- Sensor response delay

These features represent combustion quality and degradation trends.

---

## Normalization

Features are normalized using:

- Min-Max Scaling
- Z-score normalization

This ensures stable machine learning performance.

---

# 5. Model Architecture

The prediction system uses machine learning algorithms for engine health estimation.

## Possible Models

### Linear Regression
Simple degradation trend estimation.

### Random Forest
Captures nonlinear engine behavior.

### XGBoost
Provides robust structured-data prediction.

### LSTM Neural Network
Suitable for time-series degradation analysis.

---

## Proposed System Architecture

```text
Lambda Sensor
      ↓
CJ125 Interface
      ↓
Microcontroller
      ↓
Signal Processing
      ↓
Feature Extraction
      ↓
ML Prediction Model
      ↓
Health Score & RUL
      ↓
SD Card Logging
```

---

# 6. Health Score Logic

The engine health score ranges from 0–100.

| Score Range | Engine Condition |
|---|---|
| 90–100 | Excellent |
| 75–89 | Healthy |
| 60–74 | Moderate Wear |
| 40–59 | Warning |
| Below 40 | Critical |

---

## Health Score Factors

The health score depends on:

- AFR stability
- Lambda fluctuation
- Exhaust temperature trends
- Combustion consistency
- Runtime degradation
- Sensor response behavior

---

## Example Health Formula

```math
Health Score =
100 - (w1·E_AFR + w2·E_T + w3·E_λ + w4·D_t)
```

Where:

- `E_AFR` = AFR deviation error
- `E_T` = Temperature instability
- `E_λ` = Lambda fluctuation
- `D_t` = Degradation over time
- `w1,w2,w3,w4` = Weight coefficients

---

# 7. Results

The developed system successfully demonstrates:

- Real-time combustion monitoring
- Continuous SD card data logging
- Embedded AI prediction
- Engine degradation tracking
- Remaining useful life estimation

---

## Observed Performance

| Metric | Performance |
|---|---|
| Sensor Stability | Good |
| Logging Reliability | High |
| Prediction Consistency | Stable |
| Fault Detection | Effective |
| Embedded Compatibility | Excellent |

---

## Key Achievements

- Real-time lambda monitoring
- Low-cost embedded implementation
- Predictive maintenance capability
- Scalable architecture
- AI-based health estimation

---

# 8. Validation

The system is validated under multiple engine operating conditions.

## Validation Methods

### Sensor Validation

Compared against calibrated AFR measurement systems.

### Model Validation Metrics

- RMSE
- MAE
- R² Score
- Prediction stability

### Real-Time Testing Conditions

- Idle operation
- High RPM
- Variable load
- Rich fuel mixture
- Lean fuel mixture

---

# 9. Limitations

Current limitations include:

- Sensor aging effects
- Exhaust temperature drift
- Limited dataset diversity
- Calibration dependency
- Embedded processing constraints
- Real-world variability challenges

---

# 10. Future Improvements

Several future enhancements can improve system capability.

## Advanced AI Models

- Transformer models
- Physics-informed neural networks
- Hybrid AI systems

---

## Additional Sensors

Future integration may include:

- Vibration sensors
- Knock sensors
- Pressure sensors
- Fuel flow sensors

---

## Cloud Integration

Possible future features:

- Cloud dashboard
- Remote monitoring
- OTA model updates
- Fleet analytics

---

## Edge AI Optimization

Future optimization methods:

- TinyML deployment
- Quantized neural networks
- Real-time inference acceleration

---

# Conclusion

This project demonstrates a scalable and intelligent approach for engine health monitoring using a lambda sensor and CJ125 interface IC.

By combining:

- Embedded systems
- Signal processing
- Machine learning
- Predictive analytics

the proposed device enables real-time engine diagnostics and Remaining Useful Life prediction.

The system provides a strong foundation for future research in:

- Smart automotive diagnostics
- Predictive maintenance
- Embedded AI systems
- Real-time combustion analytics
- Industrial monitoring systems



MIT License

Copyright (c) 2026 Koramutla Pradeep

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
