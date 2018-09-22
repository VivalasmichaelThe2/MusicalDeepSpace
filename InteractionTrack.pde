
class InteractionTrack {
  /// New Variables
  Rectangle rec;
  Color trackColor;
  ArrayList<InteractionSlot> interTrackList;
  ArrayList<Note> keyBoard;
  int noteSlots[] = new int[interactionSlotNumber];

  InteractionTrack(Rectangle placementRect, Color col, float gainVol, String dirName, String names[]) {
    keyBoard = new ArrayList<Note>();
    for(int i = 0;i<7;i++){
    keyBoard.add(new Note(dirName  +  names[i], gainVol, ac));
    }

    trackColor = col;
    rec = placementRect;
    interTrackList  = new ArrayList<InteractionSlot>(); 
    int rectWidth = placementRect.width / interactionSlotNumber;
    for (int i = 0; i < interactionSlotNumber; i++) {
      Rectangle r = new Rectangle(placementRect.x + (i * (placementRect.width / interactionSlotNumber)), placementRect.y, 
        rectWidth, placementRect.height);
      Color slotCol = new Color(trackColor.getRed() + (i * 15), trackColor.getGreen(), trackColor.getBlue());
      InteractionSlot slot = new InteractionSlot(r, slotCol);
      interTrackList.add(slot);
    }
    ClearAllPostionMarkers();
  }
  void Draw() {
    fill(trackColor.getRed(), trackColor.getGreen(), trackColor.getBlue());
    rect(rec.x, rec.y, rec.width, rec.height);
    for (int i = 0; i < interactionSlotNumber; i++) {
      interTrackList.get(i).Draw();
    }
    fill(0);
  }

  boolean IsIdInsideTrack(TuioPoint point) {
    if (rec.contains(point.getScreenX(width), point.getScreenY(height))) {   
      return true;
    } else {
      return false;
    }
  }

  void SetPostionMarker(TuioObject tobj) {
    TuioPoint point = tobj.getPosition(); 
    for (int i = 0; i < interactionSlotNumber; i++) {
      if (interTrackList.get(i).IsInSlot(point)) {
        interTrackList.get(i).SetPlace(tobj);
        noteSlots[i] = interTrackList.get(i).note;
      }
    }
  }

  void ClearAllPostionMarkers() {
    for (int i = 0; i < interactionSlotNumber; i++) {
      noteSlots[i] = -1;
      interTrackList.get(i).ClearPlace();
    }
  }

  /// Next Time Slot Has Come
  void ChangeTime(int slot) {
    if (slot >= 0 && slot < interactionSlotNumber && noteSlots[slot] >= 0) {
      keyBoard.get(noteSlots[slot]).Play();
    }
  }
}