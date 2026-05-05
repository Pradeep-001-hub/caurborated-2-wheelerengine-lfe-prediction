
Portable Lambda-Based Engine Diagnostic Device
SECTION 1: PROJECT OVERVIEW (COPYABLE)

PROJECT: Portable Engine Diagnostic Device (Lambda-Based)

OBJECTIVE:
To design a detachable handheld device that measures exhaust gas composition 
using a Bosch LSU 4.9 sensor and predicts engine health for carbureted 
2-wheelers.

WORKING PRINCIPLE:
Exhaust Gas → Lambda Sensor → CJ125 → ESP32 → Display + Storage

OUTPUT PARAMETERS:
- Lambda (λ)
- Air-Fuel Ratio (AFR)
- Engine Health Score
------
SECTION 2: BILL OF MATERIALS 

CORE COMPONENTS:
- ESP32 Development Board
- Bosch LSU 4.9 Wideband Oxygen Sensor
- CJ125 Lambda Controller IC / Module

POWER SYSTEM:
- 12V Battery OR Bike Battery Input
- Buck Converter (12V → 5V)
- Voltage Regulator (5V → 3.3V)

DISPLAY & INPUT:
- OLED Display (0.96", I2C, 128x64)
- Push Buttons (2x)

STORAGE:
- Micro SD Card Module

ANALOG COMPONENTS:
- Resistors: 1kΩ, 10kΩ
- Capacitors: 0.1µF, 10µF
- Optional: Op-Amp (LM358)

MECHANICAL:
- Metal Probe Pipe (Heat Resistant)
- Sensor Mount (Threaded Bung M18x1.5)
- Heat Resistant Wiring Sleeve
- Handheld Enclosure Box
------
SECTION 3: SENSOR MOUNTING 

SENSOR INSTALLATION METHOD:

- Use a metal probe pipe inserted into the silencer
- Mount LSU 4.9 sensor using M18x1.5 threaded bung
- Ensure sensor is NOT directly in exhaust blast

RECOMMENDED DISTANCE:
- 5 to 10 cm inside exhaust pipe

SAFETY:
- Avoid excessive heat exposure
- Use heat-resistant wiring
- Ensure airtight sealing to prevent air dilution
----
SECTION 4: HARDWARE CONNECTIONS 

CJ125 ↔ ESP32 (SPI):
- CS   → GPIO 5
- SCK  → GPIO 18
- MOSI → GPIO 23
- MISO → GPIO 19

CJ125 Analog Outputs:
- UN (Nernst Voltage) → GPIO 34 (ADC)
- IA (Pump Current)   → GPIO 35 (ADC)

OLED (I2C):
- SDA → GPIO 21
- SCL → GPIO 22

Buttons:
- HOLD  → GPIO 12
- RESET → GPIO 13

SD Card:
- CS → GPIO 15
-----
SECTION 5: POWER DESIGN

POWER ARCHITECTURE:

INPUT:
- 12V Battery (Portable) OR Bike Battery

STEP-DOWN:
- 12V → 5V (Buck Converter)
- 5V → 3.3V (Regulator for ESP32)

IMPORTANT:
- CJ125 Heater requires stable power
- Ensure proper grounding
- Add capacitors for noise filtering
-----
 SECTION 6: SENSOR WARMUP LOGIC 

WARMUP PROCESS:

1. Start Device
2. Activate Sensor Heater
3. Wait 90 seconds total:
   - First 30 sec → Preheat
   - Next 60 sec → Stabilization
4. Begin Measurement

NOTE:
Do NOT take readings before warmup completes.
----
SECTION 7: SOFTWARE FLOW
 

PROGRAM FLOW:

1. Initialize SPI, I2C, ADC
2. Initialize CJ125
3. Start Sensor Warmup
4. Read UN and IA values
5. Convert ADC → Voltage
6. Calculate Lambda (λ)
7. Convert λ → AFR
8. Compute Engine Health Score
9. Display Results on OLED
10. Save Data to SD Card
----
SECTION 8: LAMBDA & AFR CALCULATION (COPYABLE)

FORMULAS:

Lambda (λ) = Function of Pump Current (IA)

AFR = Lambda × 14.7

INTERPRETATION:
- λ = 1.0 → Ideal combustion
- λ < 1.0 → Rich mixture
- λ > 1.0 → Lean mixture
📟 🔹 SECTION 9: OLED DISPLAY FORMAT (COPYABLE)

DISPLAY SCREEN:

------------------------
λ: 1.02
AFR: 15.0

ENGINE: GOOD

STATUS: READY
------------------------
💾 🔹 SECTION 10: DATA LOGGING FORMAT (COPYABLE)

CSV FORMAT:

Time, Lambda, AFR, Health
12:01, 1.02, 15.0, 92%
12:02, 0.95, 13.9, 85%
 SECTION 11: TESTING PROCEDURE

TEST STEPS:

1. Mount probe in silencer
2. Start engine
3. Wait for warmup (90 sec)
4. Observe readings
----

EXPECTED:
- Idle → Slightly rich (λ < 1)
- Acceleration → Rich
- Steady → Near λ = 1
----
SECTION 12: FINAL DEVICE USAGE (COPYABLE)

USAGE METHOD:

1. Attach probe to silencer
2. Power ON device
3. Wait for warmup
4. Read values
5. Remove device after test
---
ADVANTAGE:
- Fully portable
- No permanent installation required
FINAL INSIGHT (IMPORTANT)

