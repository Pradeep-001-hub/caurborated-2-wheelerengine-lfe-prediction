# Engine Health Prediction Device for Carbureted Two-Wheelers

## Summary

Modern vehicles benefit from sophisticated on-board diagnostic systems that monitor engine health in real-time. However, carbureted two-wheelers—which comprise millions of vehicles globally in developing regions—lack such monitoring capabilities. This paper presents a compact, portable, retrofit engine health prediction device that analyzes exhaust gas composition using a wideband lambda sensor to detect engine degradation, knocking events, and combustion quality without requiring OBD-II access or engine RPM data.

## Statement of Need

Carbureted two-wheelers (motorcycles, scooters, mopeds) represent a significant portion of global vehicles, particularly in Asia and Africa. Unlike modern fuel-injected engines with embedded diagnostics, carbureted engines provide no warning of health degradation, poor combustion, or impending mechanical failure. This lack of visibility forces owners to rely on reactive maintenance—waiting for catastrophic failure before intervention.

Engine knock, valve wear, spark plug degradation, and fuel delivery problems manifest as anomalies in exhaust gas composition long before mechanical failure occurs. A low-cost, standalone monitoring device that can be retrofitted to existing carbureted vehicles would enable:

- **Predictive Maintenance:** Detect engine problems before catastrophic failure
- **Fuel Efficiency Optimization:** Real-time feedback on combustion quality
- **Emission Monitoring:** Track exhaust gas parameters for regulatory compliance
- **Owner Empowerment:** Mechanics and enthusiasts gain visibility into engine state

## Implementation

The device consists of three core components:

**Hardware:** An ESP32 microcontroller paired with a Bosch LSU 4.9 wideband oxygen sensor measures exhaust lambda (air-fuel ratio) in real-time. A buck converter steps down 12V vehicle power to 5V logic levels. An OLED display provides real-time feedback, and an SD card module logs historical data for trend analysis. A modular enclosure makes the device portable and retrofit-compatible.

**Firmware:** Two-file Arduino firmware (config.h + main.ino) implements:
- Adaptive lambda sensor calibration independent of engine RPM
- Weighted health scoring algorithm analyzing combustion stability, knock indicators, and baseline deviation
- EEPROM-based baseline persistence across power cycles
- SD card logging with timestamp and parameter aggregation
- Real-time OLED visualization of health metrics

**Control Algorithm:** The system establishes a baseline health profile during initial operation, then monitors deviation from baseline as an indicator of engine degradation. Knock detection is inferred from rapid transients in exhaust composition. Health scores integrate multiple parameters: combustion consistency (lambda variance), knock event frequency, and deviation from established baseline.

## Key Features

- **No OBD Dependency:** Works on carbureted engines without diagnostic port
- **Standalone Operation:** Battery-backed OLED display functions independently
- **Compact & Portable:** 3D-printed enclosure fits vehicle toolkits
- **Low Cost:** Total BOM ~$65 USD; no licensing fees
- **Historical Logging:** SD card storage enables trend analysis and diagnostics
- **Adaptive Calibration:** Self-learning baseline reduces manual tuning

## Target Users

- Two-wheeler mechanics and service centers
- Automotive enthusiasts and DIY technicians
- Researchers in engine diagnostics and combustion monitoring
- Fleet operators managing carbureted vehicle fleets

## Validation

Initial prototype validation on test vehicles demonstrates feasible sensor integration, stable lambda measurement acquisition, and real-time health scoring with reasonable computational overhead on ESP32.

## Repository Contents

- **firmware/:** Arduino sketches for ESP32 (config.h, main.ino)
- **hardware/:** CAD models, schematic, BOM for laser-cut and 3D-printed components
- **docs/:** Installation, calibration, and usage guides
- **validation/:** Sample logs and test data from prototype vehicles

## Future Work

Planned extensions include Bluetooth connectivity for smartphone visualization, ML-based knock detection algorithms, and expanded sensor fusion (temperature, pressure) for enhanced diagnostics.

## Acknowledgments

Development was enabled by open-source tools including Arduino, ESP-IDF, and the broader embedded systems community.
