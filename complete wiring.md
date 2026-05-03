
```text
┌─────────────────────────────────────┐
  BIKE              │           ESP32 DevKit              │
  BATTERY           │                                     │
    │          3.3V─┤─── OLED VCC                        │
    │               │─── OLED SDA ──────── GPIO21         │
   12V         GND─┤─── OLED GND                        │
    │               │─── OLED SCL ──────── GPIO22         │
    ▼               │                                     │
 LM2596             │─── SD VCC ────────── 3.3V           │
 12V→5V             │─── SD GND ────────── GND            │
    │               │─── SD SCK ────────── GPIO18         │
    5V              │─── SD MISO ───────── GPIO19         │
    │               │─── SD MOSI ───────── GPIO23         │
    ├──→ CJ125 VCC  │─── SD CS ─────────── GPIO4          │
    │               │                                     │
    ├──→ AMS1117    │─── CJ125 SCK ──────── GPIO18        │
         3.3V out   │─── CJ125 MISO ─────── GPIO19        │
                    │─── CJ125 MOSI ─────── GPIO23        │
  CJ125             │─── CJ125 CS ───────── GPIO5         │
    │               │─── CJ125 UR ───────── GPIO34        │
    ├── IP ─→ LSU PIN1    │─── CJ125 UA ───────── GPIO35  │
    ├── IM ─→ LSU PIN2    │                               │
    ├── HTRC→ LSU PIN3    │─── GREEN LED ──── GPIO25      │
    ├── GND ─→ LSU PIN4   │─── YELLOW LED ─── GPIO26      │
    ├── VS ─→ LSU PIN5    │─── RED LED ────── GPIO27      │
    └── IPE─→ LSU PIN6    │                               │
                    └─────────────────────────────────────┘