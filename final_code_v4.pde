#include <DallasTemperature.h>
#include <NewOneWire.h>
#include <OneWire.h>

//pins for dallas temperature sensors
OneWire rightWire(8);  //to be modified
OneWire leftWire(4);  //to be modified

//pins for TEC control
int leftTEC = 10;  //to be modified
int rightTEC = 11;  //to be modified

//pins for fan control
int leftFan = 5;  //to be modified
int rightFan = 6;  //to be modified

//array to collect data from temp sensor
byte data[12] = {0,0,0,0,0,0,0,0,0,0,0,0};
byte addr[8] = {0,0,0,0,0,0,0,0};
byte present = 0;
    
//temperature reading declaration
int highB, lowB, TReading, signBit, Tc_100;
float whole, fract;

//data arrays to store temperature readings
float rightTemp[4] = {0, 0, 0, 0};
float leftTemp[4] = {0, 0, 0, 0};

//force sensor declaration
int leftFSR = A0;  //to be modified
int rightFSR = A1;  //to be modified
int fsrReading;

//pulse wave module control
int pulseVar = 0;

void setup()
{
  pinMode(leftTEC, OUTPUT);
  pinMode(rightTEC, OUTPUT);
  pinMode(leftFan, OUTPUT);
  pinMode(rightFan, OUTPUT);
  Serial.begin(9600);
}

void loop()
{
  //reset temp sensor search
  leftWire.reset_search();
  delay(250);

  //reiterate for all four Dallas sensors
  for (int i = 0; i < 4; i++)
  {
    //goes through each sensor and displays results
    switch (i)
    {
      case 0:
        leftTemp[0] = getLeftTemp();
        
//  Uncomment to display first left temperature reading
//      Serial.print("Left Temp 1: ");
//      Serial.println(leftTemp[0]);

        rightTemp[0] = getRightTemp();

//  Uncomment to display first right temperature reading
//      Serial.print("Right Temp 1: ");
//      Serial.println(leftTemp[0]);

        break;
   
      case 1:
        leftTemp[1] = getLeftTemp();

//  Uncomment to display second left temperature reading
//      Serial.print("Left Temp 2: ");
//      Serial.println(leftTemp[1]);

        rightTemp[1] = getRightTemp();

//  Uncomment to display second right temperature reading
//      Serial.print("Right Temp 2: ");
//      Serial.println(rightTemp[1]);

        break;     
  
      case 2:
        leftTemp[2] = getLeftTemp();

//  Uncomment to display third left temperature reading
//      Serial.print("Left Temp 3: ");
//      Serial.println(leftTemp[2]);        

        rightTemp[2] = getRightTemp();
        
//  Uncomment to display third right temperature reading
//      Serial.print("Right Temp 3: ");
//      Serial.println(rightTemp[2]);
        
        break;
  
      case 3: 
        leftTemp[3] = getLeftTemp();
        
//  Uncomment to display fourth left temperature reading
//      Serial.print("Left Temp 4: ");
//      Serial.println(leftTemp[3]);
        
        rightTemp[3] = getRightTemp();
        
//  Uncomment to display fourth right temperature reading
//      Serial.print("Right Temp 4: ");
//      Serial.println(rightTemp[3]);

        break;
    }
  }
    
  if (getPressure(leftFSR))
  {
    pulseVar = (leftTemp[2] * 3);  //Equation still in the works
    leftTECCtrl(pulseVar);
    leftFanCtrl(pulseVar);
  }
  
  if (getPressure(rightFSR))
  {
    pulseVar = (rightTemp[0] - 3) * (36.57);  //Equation still in the works
    rightTECCtrl(pulseVar);
    rightFanCtrl(pulseVar);
  }
    
}

//retrieves left temperature readings
float getLeftTemp()
{
  //retrieve address of four temp sensors on either side
  leftWire.search(addr);
    
  //left temp sensors
  leftWire.reset();
  leftWire.select(addr);
  leftWire.write(0x44, 1);
  delay(500);  //already sped up...could possibly go faster?
  present = leftWire.reset();
    
  leftWire.select(addr);
  leftWire.write(0xBE);
  
  for (int j = 0; j < 9; j++)          
  {
    data[j] = leftWire.read();
  }
     
  lowB = data[0];
  highB = data[1];
  TReading = (highB << 8) + lowB;
  signBit = TReading & 0x8000;  // test most sig bit
  
  if (signBit) // negative
  {
    TReading = (TReading ^ 0xffff) + 1; // 2's comp
  }
  Tc_100 = (6 * TReading) + TReading / 4;    // multiply by (100 * 0.0625) or 6.25

  whole = Tc_100 / 100.0;  // separate off the whole and fractional portions

 return (whole);
}

//retrieves right temperature readings
float getRightTemp()
{
  //retrieve address of four temp sensors on either side
  rightWire.search(addr);
    
  //right temp sensors
  rightWire.reset();
  rightWire.select(addr);
  rightWire.write(0x44, 1);
  delay(500);  //already sped up...could possibly go faster?
  present = rightWire.reset();
    
  rightWire.select(addr);
  rightWire.write(0xBE);
  
  for (int j = 0; j < 9; j++)          
  {
    data[j] = rightWire.read();
  }
     
  lowB = data[0];
  highB = data[1];
  TReading = (highB << 8) + lowB;
  signBit = TReading & 0x8000;  // test most sig bit
  
  if (signBit) // negative
  {
    TReading = (TReading ^ 0xffff) + 1; // 2's comp
  }
  
  Tc_100 = (6 * TReading) + TReading / 4;    // multiply by (100 * 0.0625) or 6.25

  whole = Tc_100 / 100.0;  // separate off the whole and fractional portions

  return (whole);
}

//tells whether pressure is applied
boolean getPressure(int Sensor)
{
  fsrReading = analogRead(Sensor);
  
  if (fsrReading != 0)
    return true;
  else
    return false;  
}

//controls the left fan
void leftFanCtrl(int pulse)
{
  analogWrite(leftFan, pulse + 10);
}

//controls the right fan
void rightFanCtrl(int pulse)
{
  analogWrite(rightFan, pulse + 10); 
}

//controls the right TEC
void rightTECCtrl(int pulse)
{
  analogWrite(rightTEC, pulse); 
}

//controls the left TEC
void leftTECCtrl(int pulse)
{
  analogWrite(leftTEC, pulse);
}

//controls the Vibrator
void getWarning()
{
  
}

//controls the LEDs
void showLED()
{
  
}
