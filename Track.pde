

/// Drum and loop track type
public enum TrackType { 
  LoopTrack, BDTrack, SnareTrack
};



  class Track {
  /// The Sample Play variables 
  SamplePlayer sample;
  Gain gain;
  ///The number of beat slots in a loop
  int loopSize;
  /// The activating ID
  int fidusalID;
  ///When is loop to play
  boolean toPlay[];
  ///Is Loop To Play
  boolean isActive;
  /// Dose loop need 2 return next beat (Only forLoop Tracks)
  boolean doseLoopReturnNextBeat = false;
  /// Determins the type of loop
  TrackType trackType;
  int x;
  int y;
  Beat trackBeat;
  Track( Beat beat, String sampleName, 
    int fiducalId, TrackType type, AudioContext ac) {
    trackType = type;
    loopSize = 32;
    trackBeat = beat; 
    x =0;
    y=0;
    fidusalID =fiducalId;
    isActive = false;
    sample = new SamplePlayer(ac, SampleManager.sample(sketchPath("") + sampleName));
    sample.setKillOnEnd(false);
    sample.setToEnd();
    gain = new Gain(ac, 2, 1.2);
    gain.addInput(sample);
    ac.out.addInput(gain);
    toPlay = new boolean[loopSize];
    SetBeatNotes(loopSize, beat);
  }
  /// Tests if the id belongs to the track and activates it
  void TryToAddTrack(TuioObject tobj) {
    if (IsFromFidu(tobj.getSymbolID())) {
      ///If is a loop track
      if (trackType == TrackType.LoopTrack) {
        doseLoopReturnNextBeat = true;
      }
      /// If is a sample based track
      else {
        SetActive(true, tobj.getScreenX(width), tobj.getScreenY(height));
      }

    }
  }
  /// Next Time Slot Has Come
  void ChangeTime(int slot, double time) {
    if (doseLoopReturnNextBeat) {
      doseLoopReturnNextBeat = false;
      isActive = true;
      sample.setPosition(time);
      Play();
    }
    /// For sample based tracks and restart loops
    if ( DosePlayNow(slot)  && isActive) {
      Play();
    }
    if( DosePlayNow(slot)  && !isActive){
       Stop();
    }
    
  }

  /// Tests if the id belongs to the track and updates position
  void UpdateTrackPlace(TuioObject tobj) {
    if (IsFromFidu(tobj.getSymbolID())) {
      SetActive(true, tobj.getScreenX(width), tobj.getScreenY(height));
    }
  }

  void RemoveTrack(TuioObject tobj) {
    if ( IsFromFidu(tobj.getSymbolID())) {
      SetActive(false, 0, 0);
      Stop();
      /// For Loop Based tracks
      if(doseLoopReturnNextBeat){
      doseLoopReturnNextBeat = false;
      }
    }
  }

  void Stop() {
    isActive = false;
    sample.setToEnd();
  }



  boolean DosePlayNow(int beat) {
    return toPlay[beat];
  }
  boolean IsFromFidu(int fidu) {
    if (fidusalID == fidu) {
      return true;
    }
    return false;
  }
  void Play() {
    sample.setToLoopStart();
    sample.start();
  }

  void SetActive(boolean _isActive, int _x, int _y) {
    x = _x;
    y = _y;
    isActive = _isActive;
    /// Set Track To Active  
    if (isActive) {
      /// if tempo slot beat
      if (trackType != TrackType.LoopTrack) {
        SetBeatByY(_x);
      }
      ///if is a pre recorded loop
      else {
      }
    }
    /// Set Track To Not Active  
    else{
   // Stop();
    }
  }

  void SetBeatByY(int _y) {
    Beat newBeat;
    /// BD Track Beats
    if (trackType == TrackType.BDTrack) {
      if (_y >= 1200) {
        newBeat = Beat.Beat_1_32_3;
      }  
      else if (_y >= 900) {
        newBeat = Beat.Beat_1_32_2;
      }
      else if (_y >= 600) {
        newBeat = Beat.Beat_1_16;
      } else if (_y >= 300) {
        newBeat = Beat.Beat_1_8;
      } else {
        newBeat = Beat.Beat_1_4;
      }
    }
    ///Snare Track
    else if (trackType == TrackType.SnareTrack) {
      if (_y >= 1200) {
         newBeat = Beat.Beat_3_5;
      }  
      else if (_y >= 900) {
        newBeat = Beat.Beat_3_4;
      }
      else if (_y >= 600) {
         newBeat = Beat.Beat_3_3;
      } else if (_y >= 300) {
        newBeat = Beat.Beat_3_2;
      } else {
       newBeat = Beat.Beat_3_1;
      }

    }
    ///Loop Track
    else {
      newBeat = Beat.Beat_1_1;
    }
 
    trackBeat = newBeat;
    SetBeatNotes(loopSize, trackBeat);
  }

  /// Activates boolean aray in charge of timing
  void SetBeatNotes(int loopSize, Beat beat) {
    for (int i =0; i<32; i++) {
      toPlay[i] = false;
    }
    switch (beat) {

    case Beat_3_2:
      {
        toPlay[2] = true;  
        toPlay[6] = true; 
        toPlay[10] = true; 
        toPlay[14] = true;
        toPlay[18] = true;  
        toPlay[22] = true; 
        toPlay[26] = true; 
        toPlay[30] = true; 
        break;
      }
       case Beat_3_1:
      {
       toPlay[4] = true; 
       toPlay[7] = true; 
       toPlay[12] = true;
       toPlay[20] = true; 
       toPlay[23] = true; 
       toPlay[28] = true;
       toPlay[30] = true;
       toPlay[31] = true;
        break;
      }
      
    case Beat_3_3:
      {
        toPlay[2] = true; 
        toPlay[6] = true;  
        toPlay[7] = true; 
        toPlay[10] = true;
        toPlay[14] = true;
        toPlay[15] = true; 
        toPlay[18] = true; 
        toPlay[22] = true;  
        toPlay[23] = true; 
        toPlay[26] = true;
        toPlay[30] = true;
        toPlay[31] = true; 
        break;
      }
    case Beat_3_4:
      {
        toPlay[1] = true; 
        toPlay[3] = true; 
        toPlay[5] = true; 
        toPlay[7] = true;
        toPlay[9] = true; 
        toPlay[11] = true; 
        toPlay[13] = true; 
        toPlay[15] = true;
        toPlay[17] = true; 
        toPlay[19] = true; 
        toPlay[21] = true; 
        toPlay[23] = true;
        toPlay[25] = true; 
        toPlay[27] = true; 
        toPlay[29] = true; 
        toPlay[31] = true;  
        break;
      }
      
        case Beat_3_5:
      {
        for (int i=0; i<32; i+=3) {
          toPlay[i] = true;
        }
         for (int i=0; i<32; i+=4) {
           if(i > 3 && i < 20)
           toPlay[i] = true;
        }
         for (int i=0; i<32; i+=7) {
          toPlay[i] = true;
        }
        for (int i=0; i<32; i+=9) {
          toPlay[i] = true;
        }
        
         toPlay[7] = false;
         toPlay[18] = false;

        break;
      }
      
    case Beat_1_1:
      {
        toPlay[0] = true;   
        break;
      }
    case Beat_1_2:
      {
        toPlay[0] = true; 
        toPlay[8] = true; 
        break;
      } 
    case Beat_1_4:
      {
        for (int i=0; i<32; i+=8) {
          toPlay[i] = true;
        }
        toPlay[9] = true; 
         toPlay[15] = true; 
        break;
      }
    case Beat_1_8:
      {
        for (int i=0; i<32; i+=4) {
          toPlay[i] = true;
        }
        break;
      }
    case Beat_1_16:
      {
        for (int i=0; i<32; i+=2) {
          toPlay[i] = true;
        }
        break;
      }
      case Beat_1_32:
      {
        for (int i=0; i<32; i++) {
          toPlay[i] = true;
        }
        break;
      }
      case Beat_1_32_2:
      {
         toPlay[0] = true;
         toPlay[3] = true;
         toPlay[4] = true;
         toPlay[7] = true;
         toPlay[8] = true;
         toPlay[11] = true;
         toPlay[12] = true;
         toPlay[15] = true;
         toPlay[16] = true;
         toPlay[19] = true;
         toPlay[20] = true;
         toPlay[23] = true;
         toPlay[24] = true;
         toPlay[27] = true;
         toPlay[28] = true;
         toPlay[31] = true;
        break;
      }
       case Beat_1_32_3:
      {
        for (int i=0; i<32; i+=4) {
          toPlay[i] = true;
        }
         for (int i=0; i<32; i+=6) {
          toPlay[i] = true;
        }
         for (int i=0; i<32; i+=7) {
          toPlay[i] = true;
        }
          for (int i=0; i<32; i+=9) {
          toPlay[i] = true;
        }

        break;
      }
      
    }
  }
}