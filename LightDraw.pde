//Antti Tolppanen, 289795
//Drawing with light sensors, 

import processing.serial.*;

import cc.arduino.*;

Arduino arduino;

color off = color(4, 79, 111);
color on = color(84, 145, 158);
int num = 60;
int mx[] = new int[num];
int my[] = new int[num];
Table resultTable;
int Ycoord;
int Xcoord;
boolean pointerMode;

int initialPointerX, initialPointerY, pointerX, pointerY;

void setup() {
  pointerMode = false;
  resultTable = new Table();
  resultTable.addColumn("x");
  resultTable.addColumn("y");
  
  size(640, 360);
  noStroke();
  fill(255, 153); 
  // Prints out the available serial ports.
  for(int i=0; i < Arduino.list().length; i ++) {
    println(Arduino.list()[i]);
  }  
  arduino = new Arduino(this, "/dev/cu.usbmodem1411", 57600);
  println(arduino);
  initialPointerX = arduino.analogRead(0);
  initialPointerY = arduino.analogRead(1);
  pointerX = arduino.analogRead(0);
  pointerY = arduino.analogRead(1);
  println(pointerX);
  TableRow newRow = resultTable.addRow();
  newRow.setString("x", "Sensor Drawing");
  
  prepareExitHandler();
}

void draw() { 
  
  if (!pointerMode) { 
  Xcoord = arduino.analogRead(0) - initialPointerX;
  Ycoord = arduino.analogRead(1) - initialPointerY;
  //println(arduino.analogRead(0));
  }  
  else {
    Xcoord = mouseX;
    Ycoord = mouseY;
  }
  
  TableRow newRow = resultTable.addRow();
  newRow.setInt("x", Xcoord);
  newRow.setInt("y", Ycoord);
  
  background(Xcoord,Ycoord,50,Ycoord);
    
  int which = frameCount % num;
  mx[which] = Xcoord;
  my[which] = Ycoord;
  
  if(pointerMode) {
   for (int i = 0; i < num; i++) {
    // which+1 is the smallest (the oldest in the array)
    int index = (which+1 + i) % num;
    ellipse(mx[index], my[index], i, i);
    }
  }
 
}

void keyPressed() {
    if (keyCode == 32) {
      if (!pointerMode) {
        pointerMode = true;
        TableRow newRow = resultTable.addRow();
        newRow.setString("x", "Mouse Drawing");
      }
      else {
        pointerMode = false;
        TableRow newRow = resultTable.addRow();
        newRow.setString("x", "Sensors Drawing");
      }
    }
}


private void prepareExitHandler () {
Runtime.getRuntime().addShutdownHook(new Thread(new Runnable() {
public void run () {
   String fileName = hour() + ":" + minute() + "_drawingData.csv";
   saveTable(resultTable, fileName);
}
}));

}