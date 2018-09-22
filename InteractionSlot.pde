class InteractionSlot {
  Rectangle rec;
  Color slotColor;
  PVector point;
  int objectID;
  long objectSession;
  boolean hasActiveObject = false;
  public int note;
  void Draw() {
    fill(slotColor.getRed(), slotColor.getGreen(), slotColor.getBlue());
    rect(rec.x, rec.y, rec.width, rec.height);
    if (hasActiveObject) {
      rect(point.x, point.y, 10, 10);
    }
  }
  
  int WhatNoteIsThat(PVector po){
    int netHight = (int)rec.getY() - (int)po.y;
    int heightSlot = (int)rec.getHeight() / 7;
    return -(netHight / heightSlot);
    //return 0;
  }

  InteractionSlot(Rectangle placementRect, Color col) {
    slotColor = col;
    rec = placementRect;
  }

  boolean IsInSlot( TuioPoint po ) {
    if (rec.contains(po.getScreenX(width), po.getScreenY(height))) {
      return true;
    } else {
      return false;
    }
  }
  void SetPlace(TuioObject tobj) {
    if (!hasActiveObject) {
      slotColor = new Color(slotColor.getRed(), slotColor.getGreen() + 10, slotColor.getBlue());
    }
    
    TuioPoint po = tobj.getPosition();
    point = new PVector(po.getScreenX(width), po.getScreenY(height));
    note = WhatNoteIsThat(point);
    println("note #" + note +"");
    objectID = tobj.getSymbolID();
    objectSession = tobj.getSessionID();
    hasActiveObject = true;
  }
  void ClearPlace() {
    if (hasActiveObject) {
      note = -1;
      point = new PVector(-1, -1);
      slotColor = new Color(slotColor.getRed(), slotColor.getGreen() - 10, slotColor.getBlue());
      objectID = -1;
      objectSession = -1;
      hasActiveObject = false;
    }
  }

  void UpdatePlace(TuioPoint po) {
    println("The Function --UpdatePlace(TuioPoint po)-- was called and i dont know what it is doing");
    point = new PVector(po.getScreenX(width), po.getScreenY(height));
    slotColor = new Color(slotColor.getRed(), slotColor.getGreen() + 100, slotColor.getBlue());
  }
}