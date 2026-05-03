
```text
BIKE BATTERY
  (+12V) ──────────────────── LM2596 INPUT (+)
  (GND)  ──────────────────── LM2596 INPUT (-)
                                    │
                              LM2596 OUTPUT
                              (adjust to 5V)
                                    │
              ┌─────────────────────┤
              │                     │
         CJ125 VCC (5V)      AMS1117 INPUT (5V)
         CJ125 GND                  │
                             AMS1117 OUTPUT (3.3V)
                                    │
                             ESP32 3.3V PIN
                             OLED VCC
                             SD MODULE VCC