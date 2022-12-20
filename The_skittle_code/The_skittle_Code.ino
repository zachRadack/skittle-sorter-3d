#include <Wire.h>
#include "Adafruit_TCS34725.h"
#include <Adafruit_MotorShield.h>
#include <Servo.h>

// Create the motor shield object with the default I2C address
Adafruit_MotorShield AFMS = Adafruit_MotorShield();
// Or, create it with a different I2C address (say for stacking)
// Adafruit_MotorShield AFMS = Adafruit_MotorShield(0x61);

// Connect a stepper motor with 200 steps per revolution (1.8 degree)
// to motor port #2 (M3 and M4)
Adafruit_StepperMotor *myMotor = AFMS.getStepper(200, 2);

Adafruit_TCS34725 tcs = Adafruit_TCS34725(TCS34725_INTEGRATIONTIME_2_4MS, TCS34725_GAIN_1X);

Servo arm_bottom_right;
Servo arm_top;
Servo arm_bottom_left;

const int buttonToggle_input = 7;   
const int arm_bottom_right_input = 11;
const int arm_top_input = 10;
const int arm_bottom_left_input = 9;

const int skittle_test_list [] = {5,4,5,3,2,5,1};
int skittle_order =0;


/*
 * Global colour sensing variables
 */

#define NUM_COLORS  7

// Skittle colours to indices
#define COL_RED     0
#define COL_GREEN   1
#define COL_ORANGE  2
#define COL_YELLOW  3
#define COL_PURPLE  4
#define COL_NOTHING 5
#define COL_NOTHING2 6

// Names for colours
#define COLNAME_RED     "RED"
#define COLNAME_GREEN   "GREEN"
#define COLNAME_ORANGE  "ORANGE"
#define COLNAME_YELLOW  "YELLOW"
#define COLNAME_PURPLE  "PURPLE"
#define COLNAME_NOTHING "NOTHING"
#define COLNAME_NOTHING2 "NOTHING2"

// RGB channels in the array
#define CHANNEL_R   0
#define CHANNEL_G   1
#define CHANNEL_B   2

// Training colours (populate these manually, but these vectors must be of unit length (i.e. length 1))
float trainingColors[3][NUM_COLORS];    // 3(rgb) x NUM_COLORS.

// Last read colour
float rNorm = 0.0f;
float gNorm = 0.0f;
float bNorm = 0.0f;
float hue = 0.0f;
float saturation = 0.0f;
float brightness = 0.0f;

// Last classified class
int lastClass = -1;
float lastCosine = 0;


// most receantly detected skittle
char next_skittle = "";
unsigned long next_skittle_time = millis();
// oldest skittle
char old_skittle = "";
unsigned long old_skittle_time = millis();



// time from detection which after this point the thing should be starting the process of moving the motors to make the new path
const int milli_delay_time_till_fall = 110;

// this was created because purple often does not get detected so this is a vain attempt that keeps the sorter at purple meaning if it misses purple
// it will still fall into purple
bool i_hate_purple_toggle = false;
unsigned long milli_tracker_purple_hatered= millis();
const int milli_delay_time_to_fall = 290;

/*
 * Colour sensing
 */
void initializeTrainingColors() {
  // Skittle: red
  trainingColors[CHANNEL_R][COL_RED] = 0.778;
  trainingColors[CHANNEL_G][COL_RED] = 0.444;
  trainingColors[CHANNEL_B][COL_RED] = 0.444;

  // Skittle: orange
  trainingColors[CHANNEL_R][COL_ORANGE] = 0.832;
  trainingColors[CHANNEL_G][COL_ORANGE] = 0.444;
  trainingColors[CHANNEL_B][COL_ORANGE] = 0.333;

  // Skittle: green
  trainingColors[CHANNEL_R][COL_GREEN] = 0.504;
  trainingColors[CHANNEL_G][COL_GREEN] = 0.755;
  trainingColors[CHANNEL_B][COL_GREEN] = 0.420;

  // Skittle: yellow
  trainingColors[CHANNEL_R][COL_YELLOW] = 0.755;
  trainingColors[CHANNEL_G][COL_YELLOW] = 0.577;
  trainingColors[CHANNEL_B][COL_YELLOW] = 0.311;

  // Skittle: purple
  trainingColors[CHANNEL_R][COL_PURPLE] = 0.615;
  trainingColors[CHANNEL_G][COL_PURPLE] = 0.615;
  trainingColors[CHANNEL_B][COL_PURPLE] = 0.492;

  // Nothing
  trainingColors[CHANNEL_R][COL_NOTHING] = 0.577;
  trainingColors[CHANNEL_G][COL_NOTHING] = 0.577;
  trainingColors[CHANNEL_B][COL_NOTHING] = 0.577;

  // Nothing (this is when its over the board)
  trainingColors[CHANNEL_R][COL_NOTHING2] = 0.492;
  trainingColors[CHANNEL_G][COL_NOTHING2] = 0.615;
  trainingColors[CHANNEL_B][COL_NOTHING2] = 0.615;
}


void getNormalizedColor() {
  uint16_t r, g, b, c, colorTemp, lux;  
  tcs.getRawData(&r, &g, &b, &c);

  float lenVec = sqrt((float)r*(float)r + (float)g*(float)g + (float)b*(float)b);

  // Note: the Arduino only has 2k of RAM, so rNorm/gNorm/bNorm are global variables. 
  rNorm = (float)r/lenVec;
  gNorm = (float)g/lenVec;
  bNorm = (float)b/lenVec;

  // Also convert to HSB:
  RGBtoHSV(rNorm, gNorm, bNorm, &hue, &saturation, &brightness);
}


int getColorClass() {
  float distances[NUM_COLORS] = {0.0f};

  // Step 1: Compute the cosine similarity between the query vector and all the training colours. 
  for (int i=0; i<NUM_COLORS; i++) {
    // For normalized (unit length) vectors, the cosine similarity is the same as the dot product of the two vectors.
    float cosineSimilarity = rNorm*trainingColors[CHANNEL_R][i] + gNorm*trainingColors[CHANNEL_G][i] + bNorm*trainingColors[CHANNEL_B][i];
    distances[i] = cosineSimilarity;

    // DEBUG: Output cosines
    //Serial.print("   C"); Serial.print(i); Serial.print(": "); Serial.println(cosineSimilarity, 3);
  }

  // Step 2: Find the vector with the highest cosine (meaning, the closest to the training color)
  float maxVal = distances[0];
  int maxIdx = 0;
  for (int i=0; i<NUM_COLORS; i++) {
    if (distances[i] > maxVal) {
      if ((i!=4)){
      maxVal = distances[i];
      maxIdx = i;
      }else if ((saturation>.19)){
          maxVal = distances[i];
          maxIdx = i;
      }
    }
  }

  // Step 3: Return the index of the minimum color
  lastCosine = maxVal;
  lastClass = maxIdx;
  return maxIdx;
}


// Convert from colour index to colour name.
void printColourName(int colIdx) {  
  switch (colIdx) {
    case COL_RED:
      Serial.print(COLNAME_RED);
      break;
    case COL_GREEN:
      Serial.print(COLNAME_GREEN);
      break;
    case COL_ORANGE:
      Serial.print(COLNAME_ORANGE);
      break;
    case COL_YELLOW:
      Serial.print(COLNAME_YELLOW);
      break;
    case COL_PURPLE:
      Serial.print(COLNAME_PURPLE);
      break;
    case COL_NOTHING:
      Serial.print(COLNAME_NOTHING);
      break;
    case COL_NOTHING2:
      Serial.print(COLNAME_NOTHING);
      break;
    default:
    Serial.print(colIdx);
      Serial.print(" ERROR");
      break;
  }
}


// essential for the skittle path, this chooses the motors that path towards where skittles go
void color_path_choser(){
  if(old_skittle!=COL_PURPLE){
  i_hate_purple_toggle=true;
  milli_tracker_purple_hatered = millis();
  }

  switch (old_skittle){
      case COL_RED:
      Serial.print(COLNAME_RED);
      red_path();
      break;
    case COL_GREEN:
      Serial.print(COLNAME_GREEN);
      green_path();
      break;
    case COL_ORANGE:
      Serial.print(COLNAME_ORANGE);
      orange_path();
      break;
    case COL_YELLOW:
      Serial.print(COLNAME_YELLOW);
      yellow_path();
      break;
    case COL_PURPLE:
      Serial.print(COLNAME_PURPLE);
      purple_path();
      break;
    case COL_NOTHING:
      Serial.print(COLNAME_NOTHING);
      break;
    case COL_NOTHING2:
      Serial.print(COLNAME_NOTHING);
      break;
    default:
      Serial.print("ERROR");
      break;
    }
}



/*
 * Colour converstion
 */

// RGB to HSV.  From https://www.cs.rit.edu/~ncs/color/t_convert.html . 
void RGBtoHSV( float r, float g, float b, float *h, float *s, float *v ) {  
  float minVal = min(min(r, g), b);
  float maxVal = max(max(r, g), b);
  *v = maxVal;       // v
  float delta = maxVal - minVal;
  if( maxVal != 0 )
    *s = delta / maxVal;   // s
  else {
    // r = g = b = 0    // s = 0, v is undefined 
    *s = 0;
    *h = -1;
    return;
  }
  if( r == maxVal )
    *h = ( g - b ) / delta;   // between yellow & magenta
  else if( g == maxVal )
    *h = 2 + ( b - r ) / delta; // between cyan & yellow
  else
    *h = 4 + ( r - g ) / delta; // between magenta & cyan
  *h *= 60;       // degrees
  if( *h < 0 )
    *h += 360;
}

void top_arm(int direction){

  if (direction== 0){
    arm_top.write(53);

  }else if (direction== 1){
    arm_top.write(90);
  }else{
    arm_top.write(130);

  }
}

void right_arm_setter(int direction){

  if (direction== 0){
    arm_bottom_right.write(90);

  }else{
    arm_bottom_right.write(40);
  }
}

// bottom left arm setter
void left_arm_setter(int direction){
  if (direction== 0){
    arm_bottom_left.write(100);

  }else{
    arm_bottom_left.write(170);
  }
}

void red_path(){
    top_arm(0);
    left_arm_setter(0);
}
void orange_path(){
    top_arm(0);
    left_arm_setter(1);
}
void purple_path(){
    top_arm(1);
}
void green_path(){
    top_arm(2);
    right_arm_setter(1);
}
void yellow_path(){
    top_arm(2);
    right_arm_setter(0);
}
void setup() {
  Serial.begin(115200);
  color_setup();
  motorsetup();

  next_skittle = COL_NOTHING;

  armsetup();
}
void loop() {
  getNormalizedColor();
  int colClass = getColorClass();
  
  if (i_hate_purple_toggle==true){
    if(millis()-milli_delay_time_to_fall>=milli_tracker_purple_hatered){
      //resets the thing to be in the dead center where purple should go because all me and my homies hate purple
      i_hate_purple_toggle= false;
      Serial.print(COLNAME_PURPLE);
      purple_path();
    }
  }
  
  

  //colorprint(colClass); 
  colors_motorized_operations(colClass);
  myMotor->step(2, FORWARD, DOUBLE);
  
  //Serial.println(next_skittle_time); 
  //delay(100000);
}



void colors_motorized_operations(int colClass){
// main heart beat that brings everything together.
    change_skittle_path();
      
    new_skittle_time(colClass);
   
}

void new_skittle_time(int colClass){
  // this gets the new skittle if it counts and removes the old one
  //if(((millis()-next_skittle_time)/ 2)== 0){
  //Serial.println(millis()-next_skittle_time); 
  //Serial.println("ZZZZZZZZZZ");
  //}
  // 
if ((millis()-next_skittle_time >= milli_delay_time_till_fall*.8)){
      
      int averager_list[3];

      if(colClass>=COL_NOTHING){
      // nothin does not break the system

        //colorprint(colClass);

      }else{
       // while(1);
       // this checks the skittle repeatedly at mutliple spots
        myMotor->step(5, BACKWARD, DOUBLE);
        for (int i=0; i<=3; i++) {
        getNormalizedColor();
        colClass = getColorClass();
        Serial.print(i);
        Serial.println("+++++++++++");
        colorprint(colClass);     
        debug_cosine();
        
        
        myMotor->step(1, FORWARD, DOUBLE);
        averager_list[i] = colClass;

        delay(25);
        }
        colClass = mostFrequent(averager_list,3);
        old_skittle_time = next_skittle_time;
        next_skittle_time = millis();
        myMotor->step(1, FORWARD, DOUBLE);
        delay(15);
      }
      new_skittle__old_skittle_shifter(colClass);
  }
  
}


void new_skittle__old_skittle_shifter(int colClass){


      old_skittle = next_skittle;
      next_skittle = colClass;
      
}

void debug_cosine(){
  float distances[NUM_COLORS] = {0.0f};

for (int i=0; i<NUM_COLORS; i++) {
    // For normalized (unit length) vectors, the cosine similarity is the same as the dot product of the two vectors.
    float cosineSimilarity = rNorm*trainingColors[CHANNEL_R][i] + gNorm*trainingColors[CHANNEL_G][i] + bNorm*trainingColors[CHANNEL_B][i];
    distances[i] = cosineSimilarity;

    // DEBUG: Output cosines
    Serial.print("   C"); Serial.print(i); Serial.print(": "); Serial.println(cosineSimilarity, 3);
  }


}
void change_skittle_path(){
  // this will deal with timing out when the bottom skittle sorter should change the pathing and calls in the handler
  //Serial.println(millis()-old_skittle_time);
    if ((millis()-old_skittle_time >= milli_delay_time_till_fall)&& (old_skittle<COL_NOTHING)){
      //Serial.println(millis()-old_skittle_time);
      //while(true);
      
      Serial.println("bbbbbbbbbbbbbbbb");
      color_path_choser();
    
    }

}


//  DEBUG TOOL: Output colour 
void colorprint(int colClass){
  Serial.print("R: "); Serial.print(rNorm, 3); Serial.print("  ");
  Serial.print("G: "); Serial.print(gNorm, 3); Serial.print("  ");
  Serial.print("B: "); Serial.print(bNorm, 3); Serial.print("  ");  
  Serial.print("H: "); Serial.print(hue, 3); Serial.print("  ");
  Serial.print("S: "); Serial.print(saturation, 3); Serial.print("  ");
  Serial.print("B: "); Serial.print(brightness, 3); Serial.print("  ");
  
  printColourName(colClass);  
  Serial.print(" (cos: "); Serial.print(lastCosine); Serial.print(") color: ");printColourName(colClass);
  Serial.println("=========");


}

// Populate array of training colours for classification. 
void color_setup(){
  initializeTrainingColors();
  
  if (tcs.begin()) {
    Serial.println("Found sensor");
  } else {
    Serial.println("No TCS34725 found ... check your connections");
    while (1);
  }
}

// This sets up the main motor
void motorsetup(){
  while (!Serial);
  Serial.println("Stepper test!");

  if (!AFMS.begin()) {         // create with the default frequency 1.6KHz
  // if (!AFMS.begin(1000)) {  // OR with a different frequency, say 1KHz
    Serial.println("Could not find Motor Shield. Check wiring.");
    while (1);
  }
  Serial.println("Motor Shield found.");

  myMotor->setSpeed(15);  // 10 rpm

}
void armsetup(){

  arm_bottom_right.attach(arm_bottom_right_input);
  arm_bottom_left.attach(arm_bottom_left_input);
  arm_top.attach(arm_top_input);
  
  arm_bottom_right.write(90);
  arm_bottom_left.write(100);
  arm_top.write(90);


  delay(600);
}



int mostFrequent(int* arr, int n_num)
{
    // code here
    int maxcount = 0;
    int element_having_max_freq;
    for (int i = 0; i < n_num; i++) {
        int count = 0;
        Serial.print(arr[i]);
        Serial.print("++++");
        Serial.println(arr[i]>=COL_NOTHING);
        if(arr[i]<COL_NOTHING){
        for (int j = 0; j < n_num; j++) {
          
            if (arr[i] == arr[j])
                count++;
        }}
 
        if (count > maxcount) {
            maxcount = count;
            element_having_max_freq = arr[i];
        }
    }
 
    return element_having_max_freq;
}
 