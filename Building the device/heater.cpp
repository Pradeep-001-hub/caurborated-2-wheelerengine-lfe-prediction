#define HEATER_PWM_PIN     33
#define HEATER_PWM_CHANNEL 0
#define HEATER_PWM_FREQ    1000   // 1kHz — fine for resistive heating load
#define HEATER_PWM_RES     8      // 8-bit duty (0-255)

void heaterInit() {
  ledcSetup(HEATER_PWM_CHANNEL, HEATER_PWM_FREQ, HEATER_PWM_RES);
  ledcAttachPin(HEATER_PWM_PIN, HEATER_PWM_CHANNEL);
  ledcWrite(HEATER_PWM_CHANNEL, 0); // start OFF
}

void heaterUpdate(unsigned long elapsedMs) {
  unsigned long s = elapsedMs / 1000;
  int duty;

  if (s < 3) {
    duty = 51;                       // ~20% — gentle preheat, avoid thermal shock
  } else if (s < 15) {
    // linear ramp 20% -> 70% over 12 seconds
    duty = map(s, 3, 15, 51, 178);
  } else if (s < WARMUP_SECONDS) {
    duty = 200;                      // ~78% — approach steady operating point
  } else {
    duty = 190;                      // ~74% steady-state hold (tune this per your supply voltage)
  }

  ledcWrite(HEATER_PWM_CHANNEL, duty);
}