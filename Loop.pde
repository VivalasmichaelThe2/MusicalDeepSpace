
class Loop {
  //This is the evolutionary unit
  //it consists of all the sounds that play during a loop
  int loop_tickes;
  int loop_time; //in milliseconds
  int plays_left;
  /// Screen Draw variables for : void show_loop(Loop thisloop, float time)
  int TempoSlotLength = screenWid / 16;
  int totalTempoBarLength = int(TempoSlotLength * loopTickes );
  int tempoCurserWidth = 6;


  Loop(Loop parent) {
    plays_left = 0;
    if (parent == null) {
      loop_tickes = 32;
      loop_time = 60000/bpm * loop_tickes; //2000
    } else {
      loop_tickes = parent.loop_tickes;
      loop_time = parent.loop_time;
    }
  }

  Loop(int ticks) {
    plays_left = 0;
    loop_tickes = ticks;
    loop_time = 60000/bpm * loop_tickes; //2000
  }

  void showLoop( float time) {
    /// Make Tempo Text 1 - 8
    for (int i=0; i<this.loop_tickes; i++) {
      if ((i % 2) == 0) {
        text(((i/2)+1), TempoSlotLength*i, 22);
      }
    }
    /// Make Tempo Slots
    stroke(255);
    for (int i=0; i<this.loop_tickes + 1; i++) {
      /// Numbers for 1/8
      if ((i % 2) == 0) {
        line((TempoSlotLength * i) - 5, 0, (TempoSlotLength * i) - 5, 30);
      }
      /// Lines for 1/16
      else {
        line((TempoSlotLength * i) - 5, 20, (TempoSlotLength * i) - 5, 30);
      }
    }
    /// Make Buttom Tempo Line
    line(0, 30, screenWid, 30);

    /// Make Tempo Curser Line Move
    stroke(255, 0, 0);
    int tempoCurser = int(totalTempoBarLength * time / this.loop_time);
    for (int i = 0; i<tempoCurserWidth; i++) {
      line(tempoCurser + i, 0, tempoCurser + i, 30 );
    }

    stroke(0);
    int place = 0;
    text("slot: " + (slot), 5, 70 + (place++ * 40));
    text("bpm: " + bpm, 5, 70 + (place++ * 40));
    text("Loop size: " + this.loop_tickes, 5, 70 + (place++ * 40));
    text("time between beats: " + time_between_beats, 5, 70 + (place++ * 40));
    text("time: " +time, 5, 70 + (place++ * 40));
  }
} 