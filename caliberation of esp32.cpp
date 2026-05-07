#include <Arduino.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>

#define LAMBDA_PIN 34
#define VIB_PIN 32

#define OLED_SDA 21
#define OLED_SCL 22
#define OLED_ADDR 0x3C

Adafruit_SSD1306 display(128, 64, &Wire, -1);

enum BikeMode { IDLE, REV, RIDE };
BikeMode mode = IDLE;

float baseLambda = 1.0;
float baseVib = 0.0;

float confidence = 0;

#define BUF 10
float lbuf[BUF];
int li = 0;

#define VBUF 64
float vbuf[VBUF];
int vi = 0;

float lastLambda = 1.0;

float readLambda() {
  int r = analogRead(LAMBDA_PIN);
  float v = (r / 4095.0) * 3.3;
  return constrain(1.0 + (v - 1.5) * 0.25, 0.7, 1.3);
}

float readVib() {
  int r = analogRead(VIB_PIN);
  return (r / 4095.0) * 3.3;
}

float filterLambda(float x) {
  lbuf[li++] = x;
  if (li >= BUF) li = 0;

  float s = 0;
  for (int i = 0; i < BUF; i++) s += lbuf[i];
  return s / BUF;
}

void addVib(float v) {
  vbuf[vi++] = v;
  if (vi >= VBUF) vi = 0;
}

float vibEnergy() {
  float e = 0;
  for (int i = 1; i < VBUF; i++) {
    float d = vbuf[i] - vbuf[i - 1];
    e += d * d;
  }
  return e / VBUF;
}

float lambdaVar() {
  float m = 0;
  for (int i = 0; i < BUF; i++) m += lbuf[i];
  m /= BUF;

  float v = 0;
  for (int i = 0; i < BUF; i++) {
    float d = lbuf[i] - m;
    v += d * d;
  }
  return v / BUF;
}

float roc(float l) {
  float r = abs(l - lastLambda);
  lastLambda = l;
  return r;
}

BikeMode detectMode(float ve, float lv, float r) {

  if (ve < 0.2 && lv < 0.01) return IDLE;
  if (ve > 0.5 || r > 0.05) return REV;
  return RIDE;
}

BikeMode stableMode(BikeMode m) {

  static BikeMode last = IDLE;
  static int c = 0;

  if (m == last) c++;
  else c = 0;

  if (c > 5) last = m;

  return last;
}

bool learningAllowed(float ve, float lv, BikeMode m) {
  return (m == IDLE && ve < 0.2 && lv < 0.01);
}

void autoCalibrate(float l, float v, bool allow) {

  if (allow) {

    baseLambda = baseLambda * 0.995 + l * 0.005;
    baseVib = baseVib * 0.995 + v * 0.005;

    confidence += 1;
  } else {
    confidence -= 2;
  }

  confidence = constrain(confidence, 0, 1000);
}

void driftCorrection(float l, float v) {
  if (confidence > 300) {
    baseLambda = baseLambda * 0.999 + l * 0.001;
    baseVib = baseVib * 0.999 + v * 0.001;
  }
}

float health(float l, float v) {

  float le = abs(l - baseLambda);
  float ve = abs(v - baseVib);

  float h = 100 - (le * 120) - (ve * 80);

  if (mode == REV) h *= 0.8;
  if (mode == IDLE) h *= 1.05;

  return constrain(h, 0, 100);
}

void show(float l, float h) {

  display.clearDisplay();
  display.setTextSize(1);

  display.setCursor(0,0);
  display.print("MODE:");
  if (mode == IDLE) display.print("IDLE");
  if (mode == REV) display.print("REV");
  if (mode == RIDE) display.print("RIDE");

  display.setCursor(0,15);
  display.print("Lambda:");
  display.print(l, 3);

  display.setCursor(0,30);
  display.print("Health:");
  display.print(h, 1);

  display.setCursor(0,45);
  display.print("Conf:");
  display.print(confidence);

  display.display();
}

void setup() {
  Serial.begin(115200);

  Wire.begin(OLED_SDA, OLED_SCL);
  display.begin(SSD1306_SWITCHCAPVCC, OLED_ADDR);

  display.clearDisplay();
  display.display();
}

void loop() {

  float rawL = readLambda();
  float l = filterLambda(rawL);

  float v = readVib();
  addVib(v);

  float ve = vibEnergy();
  float lv = lambdaVar();
  float r = roc(l);

  mode = stableMode(detectMode(ve, lv, r));

  bool allow = learningAllowed(ve, lv, mode);

  autoCalibrate(l, v, allow);
  driftCorrection(l, v);

  float h = health(l, v);

  show(l, h);

  delay(100);
}