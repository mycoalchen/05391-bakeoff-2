import java.util.ArrayList;
import java.util.Collections;

//these are variables you should probably leave alone
int index = 0; //starts at zero-ith trial
float border = 0; //some padding from the sides of window, set later
int trialCount = 12; //this will be set higher for the bakeoff
int trialIndex = 0; //what trial are we on
int errorCount = 0;  //used to keep track of errors
float errorPenalty = 0.5f; //for every error, add this value to mean time
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false; //is the user done
boolean inTarget = false;

final int screenPPI = 72; //what is the DPI of the screen you are using
//you can test this by drawing a 72x72 pixel rectangle in code, and then confirming with a ruler it is 1x1 inch.

// opposing coordinates for square
float x1 = 500;
float y1 = 500;
float x2 = 600;
float y2 = 600;
float logoX;
float logoY;
float logoZ;
float targetD;
float logoRotation;
boolean dragging1 = false;
boolean dragging2 = false;
float dragRadius = 20;

private class Destination
{
  float x = 0;
  float y = 0;
  float rotation = 0;
  float z = 0;
}

ArrayList<Destination> destinations = new ArrayList<Destination>();

void setup() {
  size(1000, 800);
  rectMode(CENTER);
  textFont(createFont("Arial", inchToPix(.3f))); //sets the font to Arial that is 0.3" tall
  textAlign(CENTER);

  //don't change this!
  border = inchToPix(2f); //padding of 1.0 inches

  for (int i=0; i<trialCount; i++) //don't change this!
  {
    Destination d = new Destination();
    d.x = random(border, width-border); //set a random x with some padding
    d.y = random(border, height-border); //set a random y with some padding
    d.rotation = random(0, 360); //random rotation between 0 and 360
    int j = (int)random(20);
    d.z = ((j%12)+1)*inchToPix(.25f); //increasing size from .25 up to 3.0"
    destinations.add(d);
    println("created target with " + d.x + "," + d.y + "," + d.rotation + "," + d.z);
  }

  Collections.shuffle(destinations); // randomize the order of the button; don't change this.
}


void calcLogoParams() {
  logoX = (x1 + x2) / 2;
  logoY = (y1 + y2) / 2;
  float dx = x2 - x1;
  float dy = y2 - y1;
  logoZ = sqrt(dx*dx + dy*dy) / sqrt(2);
  logoRotation = atan2(dy, dx) - PI/4;
  targetD = max(15, logoZ - 10);
}


void draw() {

  background(40); //background is dark grey
  fill(200);
  noStroke();
 
  if (trialIndex < trialCount) {
    inTarget = checkForSuccess();
  }
  
  //shouldn't really modify this printout code unless there is a really good reason to
  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, inchToPix(.4f));
    text("User had " + errorCount + " error(s)", width/2, inchToPix(.4f)*2);
    text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per destination", width/2, inchToPix(.4f)*3);
    text("User took " + ((finishTime-startTime)/1000f/trialCount+(errorCount*errorPenalty)) + " sec per destination inc. penalty", width/2, inchToPix(.4f)*4);
    return;
  }

  //===========DRAW DESTINATION SQUARES=================
  for (int i=trialIndex; i<trialCount; i++) // reduces over time
  {
    pushMatrix();
    Destination d = destinations.get(i); //get destination trial
    translate(d.x, d.y); //center the drawing coordinates to the center of the destination trial
    rotate(radians(d.rotation)); //rotate around the origin of the destination trial
    noFill();
    strokeWeight(3f);
    if (trialIndex==i) {
      if (!inTarget) stroke(255, 0, 0, 192); //set color to semi translucent
      else stroke(0, 255, 0, 192);
    } else
      stroke(128, 128, 128, 128); //set color to semi translucent
    rect(0, 0, d.z, d.z);
    popMatrix();
  }

  //===========DRAW LOGO SQUARE=================
  if (dragging1) {
    float dx = mouseX - x1;
    float dy = mouseY - y1;
    x1 += dx;
    y1 += dy;
    x2 += dx;
    y2 += dy;
  }
  else if (dragging2) {
    x2 = mouseX;
    y2 = mouseY;
  }
  calcLogoParams();
  pushMatrix();
  translate(logoX, logoY); //translate draw center to the center oft he logo square
  println(logoZ);
  rotate(logoRotation); //rotate using the logo square as the origin
  noStroke();
  fill(60, 60, 192, 192);
  square(0, 0, logoZ);
  fill(0, 0, 0, 0);
  if (!inTarget) {
    stroke(30, 30, 30);
  } else {
    stroke(255, 255, 255);
  }
  circle(0, 0, targetD);
  popMatrix();
  // Make the translation dragger solid
  noStroke();
  fill(70, 70, 202, 202);
  circle(x1, y1, 20);
  // Make the scale/rotation dragger hollow
  stroke(140, 180, 255, 255);
  fill(0, 0, 0, 0);
  circle(x2, y2, 20);

  //===========DRAW EXAMPLE CONTROLS=================
  fill(255);
  scaffoldControlLogic(); //you are going to want to replace this
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchToPix(.6f));
  text("Drag the solid corner circle for translation and the empty corner circle for scale/rotation.", width/2, inchToPix(.9f));
  text("When you are on target, the inner circle will turn white. Click anywhere in the inner circle to submit.", width/2, inchToPix(1.2f));
}

//my example design for control, which is terrible
void scaffoldControlLogic()
{
  
}

void mousePressed()
{
  if (startTime == 0) //start time on the instant of the first user click
  {
    startTime = millis();
    println("time started!");
  }
  if (dist(logoX, logoY, mouseX, mouseY) > targetD/2 || !inTarget) {
    if (dist(mouseX, mouseY, x1, y1) < dragRadius) {
    dragging1 = true;
    }
    else if (dist(mouseX, mouseY, x2, y2) < dragRadius) {
      dragging2 = true;
    }
  }
}

void mouseReleased()
{
  dragging1 = false;
  dragging2 = false;
  //check to see if user clicked inside the "target" circle to submit
  if (dist(logoX, logoY, mouseX, mouseY)<targetD/2)
  {
    if (userDone==false && !inTarget)
      errorCount++;

    trialIndex++; //and move on to next trial

    if (trialIndex==trialCount && userDone==false)
    {
      userDone = true;
      finishTime = millis();
    }
  }
}

//probably shouldn't modify this, but email me if you want to for some good reason.
public boolean checkForSuccess()
{
  Destination d = destinations.get(trialIndex);	
  boolean closeDist = dist(d.x, d.y, logoX, logoY)<inchToPix(.05f); //has to be within +-0.05"
  boolean closeRotation = calculateDifferenceBetweenAngles(d.rotation, logoRotation*180/PI)<=5;
  boolean closeZ = abs(d.z - logoZ)<inchToPix(.1f); //has to be within +-0.1"	

  //println("Close Enough Distance: " + closeDist + " (logo X/Y = " + d.x + "/" + d.y + ", destination X/Y = " + logoX + "/" + logoY +")");
  //println("Close Enough Rotation: " + closeRotation + " (rot dist="+calculateDifferenceBetweenAngles(d.rotation, logoRotation)+")");
  //println("Close Enough Z: " +  closeZ + " (logo Z = " + d.z + ", destination Z = " + logoZ +")");
  //println("Close enough all: " + (closeDist && closeRotation && closeZ));

  return closeDist && closeRotation && closeZ;
}

//utility function I include to calc diference between two angles
double calculateDifferenceBetweenAngles(float a1, float a2)
{
  double diff=abs(a1-a2);
  diff%=90;
  if (diff>45)
    return 90-diff;
  else
    return diff;
}

//utility function to convert inches into pixels based on screen PPI
float inchToPix(float inch)
{
  return inch*screenPPI;
}
