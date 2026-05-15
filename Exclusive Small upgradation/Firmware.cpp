// ============================================================
// ADVANCED AI ENGINE HEALTH MONITOR
// ESP32 + CJ125 + LSU 4.9 + OLED + SD + AI Diagnostics
// ============================================================

#include <Arduino.h>
#include <SPI.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <SD.h>
#include <EEPROM.h>

// ============================================================
// PIN DEFINITIONS
// ============================================================

#define CJ125_CSN_PIN     5
#define CJ125_SCK_PIN     18
#define CJ125_MOSI_PIN    23
#define CJ125_MISO_PIN    19
#define CJ125_UN_PIN      34
#define CJ125_IA_PIN      35

#define OLED_SDA          21
#define OLED_SCL          22
#define OLED_ADDRESS      0x3C

#define BTN_HOLD          12
#define BTN_RESET         13

#define SD_CS_PIN         15

// ============================================================
// CONSTANTS
// ============================================================

#define STOICH_AFR        14.7f
#define LAMBDA_TARGET     1.0f
#define LAMBDA_RICH       0.90f
#define LAMBDA_LEAN       1.10f

#define WARMUP_SECONDS    90

#define GRAPH_POINTS      128
#define HISTORY_SIZE      100
#define BUFFER_SIZE       20

#define EEPROM_SIZE       512
#define EEPROM_ADDR       0

// ============================================================
// OLED
// ============================================================

Adafruit_SSD1306 display(128, 64, &Wire, -1);

// ============================================================
// DISPLAY PAGES
// ============================================================

enum DisplayPage {
  PAGE_MAIN,
  PAGE_STATS,
  PAGE_GRAPH,
  PAGE_OSC,
  PAGE_MISFIRE,
  PAGE_CATALYST,
  PAGE_RUL,
  PAGE_AI
};

DisplayPage currentPage = PAGE_MAIN;

// ============================================================
// GLOBAL VARIABLES
// ============================================================

float lambdaValue = 1.0;
float afrValue = 14.7;

float healthScore = 100;
float fuelEfficiency = 100;
float catalystEfficiency = 90;
float misfireProbability = 0;
float oscillationFrequency = 0;
float rulPercent = 100;
float aiAnomalyScore = 0;

float baselineLambda = 1.0;

float sessionMinAFR = 99;
float sessionMaxAFR = 0;
float sessionAvgAFR = 0;

unsigned long startMs = 0;
unsigned long lastLogMs = 0;

float lambdaHistory[HISTORY_SIZE];
int historyIndex = 0;

float graphData[GRAPH_POINTS];
int graphIndex = 0;

float lambdaBuffer[BUFFER_SIZE];
int bufferIndex = 0;

bool baselineSet = false;

// ============================================================
// SPI COMMUNICATION
// ============================================================

uint16_t cj125Send(uint16_t data) {
  digitalWrite(CJ125_CSN_PIN, LOW);
  delayMicroseconds(5);
  uint16_t result = SPI.transfer16(data);
  digitalWrite(CJ125_CSN_PIN, HIGH);
  return result;
}

void cj125Init() {
  cj125Send(0x2800);
  delay(100);
}

bool cj125Healthy() {
  uint16_t diag = cj125Send(0x6C00);
  return ((diag & 0xFF) == 0x28);
}

// ============================================================
// SENSOR READING
// ============================================================

float calcLambda() {

  int rawIA = analogRead(CJ125_IA_PIN);

  float vIA = (rawIA / 4095.0f) * 3.3f;

  float Ip_mA = (vIA - 1.5f) / 0.1f;

  float lambda = 1.0f + (Ip_mA * 0.015f);

  lambda = constrain(lambda, 0.65f, 1.60f);

  return lambda;
}

// ============================================================
// HISTORY UPDATE
// ============================================================

void updateHistory(float lambda) {

  lambdaHistory[historyIndex] = lambda;
  historyIndex++;

  if (historyIndex >= HISTORY_SIZE)
    historyIndex = 0;

  graphData[graphIndex] = lambda;
  graphIndex++;

  if (graphIndex >= GRAPH_POINTS)
    graphIndex = 0;

  lambdaBuffer[bufferIndex] = lambda;
  bufferIndex++;

  if (bufferIndex >= BUFFER_SIZE)
    bufferIndex = 0;
}

// ============================================================
// VARIANCE
// ============================================================

float calcVariance(float* data, int size) {

  float mean = 0;

  for (int i = 0; i < size; i++)
    mean += data[i];

  mean /= size;

  float variance = 0;

  for (int i = 0; i < size; i++) {
    variance += pow(data[i] - mean, 2);
  }

  variance /= size;

  return variance;
}

// ============================================================
// HEALTH SCORE
// ============================================================

float calcHealthScore() {

  float variance = calcVariance(lambdaBuffer, BUFFER_SIZE);

  float combustion = 100 - abs(lambdaValue - 1.0) * 250;

  float trend = 100 - abs(lambdaValue - baselineLambda) * 200;

  float oscillation = 100 - variance * 4000;

  combustion = constrain(combustion, 0, 100);
  trend = constrain(trend, 0, 100);
  oscillation = constrain(oscillation, 0, 100);

  float score =
    (0.45 * oscillation) +
    (0.35 * combustion) +
    (0.20 * trend);

  return constrain(score, 0, 100);
}

// ============================================================
// FUEL EFFICIENCY
// ============================================================

float calcFuelEfficiency() {

  float dev = abs(lambdaValue - 1.0);

  float eff = 100 - (dev * 220);

  return constrain(eff, 0, 100);
}

// ============================================================
// OSCILLATION FREQUENCY
// ============================================================

float calcOscillationFrequency() {

  int crossings = 0;

  for (int i = 1; i < BUFFER_SIZE; i++) {

    if ((lambdaBuffer[i - 1] < 1.0 &&
         lambdaBuffer[i] > 1.0) ||

        (lambdaBuffer[i - 1] > 1.0 &&
         lambdaBuffer[i] < 1.0)) {

      crossings++;
    }
  }

  return crossings / 2.0;
}

// ============================================================
// MISFIRE DETECTION
// ============================================================

float calcMisfireProbability() {

  float variance = calcVariance(lambdaBuffer, BUFFER_SIZE);

  float prob = variance * 3000;

  if (abs(lambdaValue - 1.0) > 0.18)
    prob += 25;

  return constrain(prob, 0, 100);
}

// ============================================================
// CATALYST EFFICIENCY
// ============================================================

float calcCatalystEfficiency() {

  float variance = calcVariance(lambdaBuffer, BUFFER_SIZE);

  float eff = 100 - (variance * 2500);

  return constrain(eff, 0, 100);
}

// ============================================================
// RUL ESTIMATION
// ============================================================

float calcRUL() {

  float degradation = 100 - healthScore;

  float rul = 100 - degradation * 1.2;

  return constrain(rul, 0, 100);
}

// ============================================================
// AI ANOMALY SCORE
// ============================================================

float calcAIAnomaly() {

  float score = 0;

  score += abs(lambdaValue - 1.0) * 180;

  score += calcVariance(lambdaBuffer, BUFFER_SIZE) * 4000;

  score += misfireProbability * 0.3;

  return constrain(score, 0, 100);
}

// ============================================================
// EEPROM
// ============================================================

void saveBaseline(float val) {

  EEPROM.begin(EEPROM_SIZE);
  EEPROM.put(EEPROM_ADDR, val);
  EEPROM.commit();
  EEPROM.end();
}

void loadBaseline() {

  EEPROM.begin(EEPROM_SIZE);
  EEPROM.get(EEPROM_ADDR, baselineLambda);
  EEPROM.end();

  if (baselineLambda > 0.6 &&
      baselineLambda < 1.4) {

    baselineSet = true;
  }
}

// ============================================================
// SD CARD
// ============================================================

File logFile;

void initSD() {

  if (!SD.begin(SD_CS_PIN)) {
    Serial.println("SD failed");
    return;
  }

  logFile = SD.open("/engine.csv", FILE_WRITE);

  if (logFile) {
    logFile.println(
      "time,lambda,afr,health,misfire,rul,ai");
  }
}

void logData() {

  if (!logFile)
    return;

  unsigned long t =
    (millis() - startMs) / 1000;

  logFile.print(t);
  logFile.print(",");

  logFile.print(lambdaValue, 3);
  logFile.print(",");

  logFile.print(afrValue, 2);
  logFile.print(",");

  logFile.print(healthScore, 1);
  logFile.print(",");

  logFile.print(misfireProbability, 1);
  logFile.print(",");

  logFile.print(rulPercent, 1);
  logFile.print(",");

  logFile.println(aiAnomalyScore, 1);

  logFile.flush();
}

// ============================================================
// DISPLAY PAGES
// ============================================================

void drawHeader(const char* title) {

  display.clearDisplay();

  display.setTextSize(1);
  display.setCursor(0, 0);

  display.println(title);

  display.drawLine(0, 10, 127, 10, WHITE);
}

void showMainPage() {

  drawHeader("ENGINE HEALTH");

  display.setCursor(0, 15);
  display.print("L:");
  display.print(lambdaValue, 3);

  display.setCursor(75, 15);
  display.print("AFR:");
  display.print(afrValue, 1);

  display.setCursor(0, 30);

  if (lambdaValue < LAMBDA_RICH)
    display.print("RICH");

  else if (lambdaValue > LAMBDA_LEAN)
    display.print("LEAN");

  else
    display.print("OK");

  display.setCursor(0, 50);
  display.print("H:");
  display.print((int)healthScore);
  display.print("%");

  display.setCursor(70, 50);
  display.print("FE:");
  display.print((int)fuelEfficiency);

  display.display();
}

void showStatsPage() {

  drawHeader("STATISTICS");

  display.setCursor(0, 15);
  display.print("AVG AFR:");
  display.print(sessionAvgAFR, 1);

  display.setCursor(0, 28);
  display.print("MIN:");
  display.print(sessionMinAFR, 1);

  display.setCursor(65, 28);
  display.print("MAX:");
  display.print(sessionMaxAFR, 1);

  unsigned long runtime =
    (millis() - startMs) / 1000;

  display.setCursor(0, 45);
  display.print("RUN:");
  display.print(runtime);
  display.print("s");

  display.display();
}

void showGraphPage() {

  drawHeader("TREND GRAPH");

  for (int x = 0; x < 127; x++) {

    int idx = (graphIndex + x) % GRAPH_POINTS;

    int y = map(
      graphData[idx] * 100,
      65,
      160,
      63,
      15
    );

    display.drawPixel(x, y, WHITE);
  }

  display.display();
}

void showOscPage() {

  drawHeader("OSCILLATION");

  display.setCursor(0, 20);
  display.print("Freq:");
  display.print(oscillationFrequency, 1);
  display.print("Hz");

  float var =
    calcVariance(lambdaBuffer, BUFFER_SIZE);

  display.setCursor(0, 35);
  display.print("Var:");
  display.print(var, 4);

  display.display();
}

void showMisfirePage() {

  drawHeader("MISFIRE");

  display.setCursor(0, 20);

  display.print("Probability:");

  display.setCursor(0, 35);

  display.print((int)misfireProbability);
  display.print("%");

  display.display();
}

void showCatalystPage() {

  drawHeader("CATALYST");

  display.setCursor(0, 25);

  display.print("Efficiency:");

  display.setCursor(0, 40);

  display.print((int)catalystEfficiency);
  display.print("%");

  display.display();
}

void showRULPage() {

  drawHeader("RUL ESTIMATE");

  display.setCursor(0, 25);

  display.print("Life:");

  display.setCursor(50, 25);

  display.print((int)rulPercent);

  display.print("%");

  display.display();
}

void showAIPage() {

  drawHeader("AI ANALYSIS");

  display.setCursor(0, 20);

  display.print("Anomaly:");

  display.setCursor(0, 35);

  display.print((int)aiAnomalyScore);

  display.print("%");

  display.display();
}

// ============================================================
// PAGE HANDLER
// ============================================================

void showCurrentPage() {

  switch (currentPage) {

    case PAGE_MAIN:
      showMainPage();
      break;

    case PAGE_STATS:
      showStatsPage();
      break;

    case PAGE_GRAPH:
      showGraphPage();
      break;

    case PAGE_OSC:
      showOscPage();
      break;

    case PAGE_MISFIRE:
      showMisfirePage();
      break;

    case PAGE_CATALYST:
      showCatalystPage();
      break;

    case PAGE_RUL:
      showRULPage();
      break;

    case PAGE_AI:
      showAIPage();
      break;
  }
}

// ============================================================
// SETUP
// ============================================================

void setup() {

  Serial.begin(115200);

  pinMode(BTN_HOLD, INPUT_PULLUP);
  pinMode(BTN_RESET, INPUT_PULLUP);

  SPI.begin(
    CJ125_SCK_PIN,
    CJ125_MISO_PIN,
    CJ125_MOSI_PIN
  );

  pinMode(CJ125_CSN_PIN, OUTPUT);

  digitalWrite(CJ125_CSN_PIN, HIGH);

  analogReadResolution(12);

  Wire.begin(OLED_SDA, OLED_SCL);

  display.begin(
    SSD1306_SWITCHCAPVCC,
    OLED_ADDRESS
  );

  display.clearDisplay();
  display.display();

  cj125Init();

  loadBaseline();

  initSD();

  startMs = millis();
}

// ============================================================
// LOOP
// ============================================================

void loop() {

  unsigned long elapsed =
    (millis() - startMs) / 1000;

  // Warmup
  if (elapsed < WARMUP_SECONDS) {

    display.clearDisplay();

    display.setTextSize(2);

    display.setCursor(15, 20);

    display.println("WARMUP");

    display.setTextSize(1);

    display.setCursor(35, 50);

    display.print(
      WARMUP_SECONDS - elapsed
    );

    display.print("s");

    display.display();

    delay(500);

    return;
  }

  // Sensor health
  if (!cj125Healthy()) {

    display.clearDisplay();

    display.setCursor(10, 20);

    display.println("CJ125 ERROR");

    display.display();

    delay(1000);

    return;
  }

  // Read lambda
  lambdaValue = calcLambda();

  afrValue = lambdaValue * STOICH_AFR;

  // Update history
  updateHistory(lambdaValue);

  // Baseline
  if (!baselineSet) {

    baselineLambda = lambdaValue;

    saveBaseline(baselineLambda);

    baselineSet = true;
  }

  // Calculations
  healthScore =
    calcHealthScore();

  fuelEfficiency =
    calcFuelEfficiency();

  oscillationFrequency =
    calcOscillationFrequency();

  misfireProbability =
    calcMisfireProbability();

  catalystEfficiency =
    calcCatalystEfficiency();

  rulPercent =
    calcRUL();

  aiAnomalyScore =
    calcAIAnomaly();

  // Session stats
  sessionMinAFR =
    min(sessionMinAFR, afrValue);

  sessionMaxAFR =
    max(sessionMaxAFR, afrValue);

  sessionAvgAFR =
    (sessionAvgAFR + afrValue) / 2.0;

  // Button: next page
  if (digitalRead(BTN_HOLD) == LOW) {

    currentPage =
      (DisplayPage)((currentPage + 1) % 8);

    delay(300);
  }

  // Reset stats
  if (digitalRead(BTN_RESET) == LOW) {

    sessionMinAFR = 99;
    sessionMaxAFR = 0;
    sessionAvgAFR = 0;

    delay(300);
  }

  // Show page
  showCurrentPage();

  // SD logging
  if (millis() - lastLogMs > 2000) {

    logData();

    lastLogMs = millis();
  }

  delay(150);
}
