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




float heaterKp = 8.0f;      // starting point from published open-source implementations
float heaterKi = 0.003f;
float targetResistance = 3.5f; // ohms — approximate LSU 4.9 target at operating temp, verify against your sensor's datasheet
float integral = 0;

int heaterPID(float measuredVoltage, float measuredCurrent) {
  float measuredR = measuredVoltage / measuredCurrent;
  float error = targetResistance - measuredR;

  integral += error * heaterKi;
  integral = constrain(integral, 0, 255);

  float output = (error * heaterKp) + integral;
  return constrain((int)output, 0, 255);
}





if (!cj125Healthy()) {
  ledcWrite(HEATER_PWM_CHANNEL, 0);  // kill heater immediately on any CJ125 fault
}