//Musical Deep Space Interaction With TUIO  //<>//
//By : Michael Lachower
import processing.core.*;
import ddf.minim.*;
import TUIO.*;
import beads.*;
import java.util.Arrays; 
import java.util.ArrayList;
import java.awt.*;
import java.util.ConcurrentModificationException;

public enum Beat { 
  Beat_1_1, Beat_1_2, Beat_1_4, Beat_1_8, Beat_1_16, Beat_1_32, Beat_1_32_2, Beat_1_32_3, 
    Beat_3_1, Beat_3_2, Beat_3_3, Beat_3_4, Beat_3_5
};

  public enum TrackRepate { 
  All, OnlyFirst, EverySecond
};



// print console debug messages
boolean debugLog = false; 

// declare a TuioProcessing client
TuioProcessing tuioClient;

/// Screen Size for draw calculation has to be kept updated
int screenWid = 1600;
int screenHigh = 1000;
// these are some helper variables which are used
// to create scalable graphical feedback
float object_size = 60;
float table_size = 760;
float scale_factor = 1;
PFont font;
/// Note Images
PImage endImg, noteImg, noteImgA, noteImgB, noteImgC, noteImgD, noteImgE, noteImgF, noteImgG;

/// AudioContext to create sound and all musical tracks
AudioContext ac;
/// Interaction Tracks
ArrayList<InteractionTrack> interTrackList;
// Drum Tracks
Track drumTrackList[];
int drumTrackNumber = 4;
Track BDTrack, snareTrack, HHTrack, FXTrack;
SamplePlayer BD, snare, HH, FX;

/// Music Time And Tempo variables for the live loop
Loop current_loop;
int loopTickes = 16;
int loopInteractionTicks = 8;
int interactionSlotNumber = loopInteractionTicks;
int ticksConvert = loopTickes / loopInteractionTicks;

int bpm = 240; //This is the programmrd beats-per-minute
int last_slot;
int slot;
float time_between_beats = 0;
float time;

/// Interaction Space Variables for customization of the intraction filed
int ColumNum = 9;
int interTrackNum = 4;
int interTopProc = 15, interBotProc = 15, interLeftProc = 15, interRightProc = 15;
PVector topLeftInterCorner = new PVector((screenWid / 100) * interLeftProc, (screenHigh / 100) * interTopProc);
PVector topRightInterCorner = new PVector((screenWid / 100) * (100 - interRightProc), (screenHigh / 100) * interTopProc);
PVector botLeftInterCorner = new PVector((screenWid / 100) * interLeftProc, (screenHigh / 100) * (100 - interBotProc));
PVector botRightInterCorner = new PVector((screenWid / 100) * (100 - interRightProc), (screenHigh / 100) * (100 - interBotProc));
int interWidth = (int)(topRightInterCorner.x - topLeftInterCorner.x);
int interHight = (int)(botLeftInterCorner.y - topLeftInterCorner.y);
int interSlotLength = interWidth / ColumNum;

Rectangle interRect = new Rectangle((int)topLeftInterCorner.x, (int)topLeftInterCorner.y, interWidth, interHight);

ArrayList<TuioObject> tuioObjectList = new ArrayList<TuioObject>();

void setup() {
  setupAudio();
  setupVisual();
  SetupLoop();
  ac.start();

  size(1600, 1000); 
  frameRate(60);

  tuioClient  = new TuioProcessing(this);
}

public void draw() {
  background(50, 150, 250);
  fill(255);
  tuioObjectList = tuioClient.getTuioObjectList();
  /// Draw Interaction Slots and clear all positions befor appling updated positions
  for (InteractionTrack inter : interTrackList) {
    inter.Draw();
    inter.ClearAllPostionMarkers();
  }
  /// Appling Updated positions of all interaction objects
  for (int i=0; i<tuioObjectList.size(); i++) {
    TuioObject tobj = tuioObjectList.get(i);
    printTobj( tobj);
    for (InteractionTrack inter : interTrackList) {
      if ( inter.IsIdInsideTrack( tobj.getPosition()))
      {
        inter.SetPostionMarker( tobj);
      }
    }
  }

  updateLoop();
}


void printTobj(TuioObject tobj) {
  float obj_size = object_size*scale_factor; 
  stroke(0);
  fill(0, 0, 0);
  pushMatrix();
  translate(tobj.getScreenX(width), tobj.getScreenY(height));
  rotate(tobj.getAngle());
  rect(-obj_size/2, -obj_size/2, obj_size, obj_size);
  popMatrix();
}

void SetupLoop() {
  current_loop = new Loop(loopTickes);
  time_between_beats = 60000 / bpm;
}

void updateLoop() {
  time = millis() % current_loop.loop_time;

  slot = int(time / time_between_beats) / ticksConvert;
  if (slot != last_slot) {
    for (int i =0; i < drumTrackNumber; i++) {
      drumTrackList[i].ChangeTime( slot, time);
    }
    for (InteractionTrack inter : interTrackList) {
      inter.ChangeTime( slot);
    }

    last_slot = slot;
  }
  current_loop.showLoop( time);
}

void setupAudio() {
  ac = new AudioContext();

  BDTrack = new Track( Beat.Beat_1_4, "loop/BD-1-Bar.wav", 13, TrackType.BDTrack, ac);
  snareTrack = new Track( Beat.Beat_1_1, "loop/snare.wav", 14, TrackType.SnareTrack, ac);  
  HHTrack= new Track( Beat.Beat_1_1, "loop/HH-8-Bar.wav", 15, TrackType.LoopTrack, ac);
  FXTrack= new Track( Beat.Beat_1_1, "loop/Efx-8-Bar.wav", 16, TrackType.LoopTrack, ac);

  drumTrackList = new Track[drumTrackNumber];
  drumTrackList[0] = BDTrack;
  drumTrackList[1] = snareTrack;
  drumTrackList[2] = HHTrack;
  drumTrackList[3] = FXTrack;

  interTrackList = new ArrayList<InteractionTrack>();
  String dirName = sketchPath("") + "piano\\v2\\";
  interTrackList.add(MakeInteractionTrack(0, dirName));
  dirName = sketchPath("") + "piano\\v1\\";
  interTrackList.add(MakeInteractionTrack(1, dirName));
  dirName = sketchPath("") + "piano\\v3\\";
  interTrackList.add(MakeInteractionTrack(2, dirName));
  dirName = sketchPath("") + "piano\\v1\\";
  interTrackList.add(MakeInteractionTrack(3, dirName));
}

InteractionTrack MakeInteractionTrack(int num, String dirName) {
  return new InteractionTrack(new Rectangle(interRect.x, 
    interRect.y + (num * (interRect.height / 4)), 
    interRect.width, interRect.height / 4), 
    new Color(10, 120, 40 + (num * 50)), 0.65, dirName, listFileNames(dirName));
}

void setupVisual() {
  font = createFont("verdana", 12);
  scale_factor = height/table_size;
  textFont(font, 22*scale_factor);
  noteImg = loadImage("note.png");
  noteImgA = loadImage("noteA.png");
  noteImgB = loadImage("noteB.png");
  noteImgC = loadImage("noteC.png");
  noteImgD = loadImage("noteD.png");
  noteImgE = loadImage("noteE.png");
  noteImgF = loadImage("noteF.png");
  noteImgG = loadImage("noteG.png"); 
  endImg = loadImage("end.png");
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void addTuioObject(TuioObject tobj) {
  if (debugLog) println("add obj "+tobj.getSymbolID()+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle());
}

void updateTuioObject (TuioObject tobj) {
  if (debugLog) println("set obj "+tobj.getSymbolID()+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle()
    +" "+tobj.getMotionSpeed()+" "+tobj.getRotationSpeed()+" "+tobj.getMotionAccel()+" "+tobj.getRotationAccel());
}
void removeTuioObject(TuioObject tobj) {
  if (debugLog) println("del obj "+tobj.getSymbolID()+" ("+tobj.getSessionID()+")");
}

void refresh(TuioTime frameTime) {
  if (debugLog) println("frame #"+frameTime.getFrameID()+" ("+frameTime.getTotalMilliseconds()+")");
  redraw();
}

void addSound(TuioObject tobj) {
  for (int i =0; i < drumTrackNumber; i++) {
    drumTrackList[i].TryToAddTrack(tobj);
  }
}

void updateSound(TuioObject tobj) {
  for (int i =0; i < drumTrackNumber; i++) {
    drumTrackList[i].UpdateTrackPlace(tobj);
  }
}

void removeSound(TuioObject tobj) {
  for (int i =0; i < drumTrackNumber; i++) {
    drumTrackList[i].RemoveTrack( tobj);
  }
}


String[] listFileNames(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    return names;
  } else {
    // If it's not a directory
    return null;
  }
}

// called when a cursor is added to the scene
void addTuioCursor(TuioCursor tcur) {
  if (debugLog) println("add cur "+tcur.getCursorID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY());
  //redraw();
}

// called when a cursor is moved
void updateTuioCursor (TuioCursor tcur) {
  if (debugLog) println("set cur "+tcur.getCursorID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY()
    +" "+tcur.getMotionSpeed()+" "+tcur.getMotionAccel());
  //redraw();
}

// called when a cursor is removed from the scene
void removeTuioCursor(TuioCursor tcur) {
  if (debugLog) println("del cur "+tcur.getCursorID()+" ("+tcur.getSessionID()+")");
  //redraw()
}

// --------------------------------------------------------------
// called when a blob is added to the scene
void addTuioBlob(TuioBlob tblb) {
  if (debugLog) println("add blb "+tblb.getBlobID()+" ("+tblb.getSessionID()+") "+tblb.getX()+" "+tblb.getY()+" "+tblb.getAngle()+" "+tblb.getWidth()+" "+tblb.getHeight()+" "+tblb.getArea());
  //redraw();
}

// called when a blob is moved
void updateTuioBlob (TuioBlob tblb) {
  if (debugLog) println("set blb "+tblb.getBlobID()+" ("+tblb.getSessionID()+") "+tblb.getX()+" "+tblb.getY()+" "+tblb.getAngle()+" "+tblb.getWidth()+" "+tblb.getHeight()+" "+tblb.getArea()
    +" "+tblb.getMotionSpeed()+" "+tblb.getRotationSpeed()+" "+tblb.getMotionAccel()+" "+tblb.getRotationAccel());
  //redraw()
}

// called when a blob is removed from the scene
void removeTuioBlob(TuioBlob tblb) {
  if (debugLog) println("del blb "+tblb.getBlobID()+" ("+tblb.getSessionID()+")");
  //redraw()
}