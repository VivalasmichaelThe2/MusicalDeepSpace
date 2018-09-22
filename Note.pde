
class Note {
  int noteBeat;
  SamplePlayer sample;
  Gain gain;

  Note(String sampleName, float gainVol, AudioContext ac) {
    noteBeat = -1;
    println("sample: " + sampleName );
    sample = new SamplePlayer(ac, SampleManager.sample( sampleName));
    sample.setKillOnEnd(false);
    gain = new Gain(ac, 2, gainVol);
    gain.addInput(sample);
    ac.out.addInput(gain);
    sample.setToEnd();
  }


  void Reset() {
    sample.setToLoopStart();
  }
  void Play() {
    sample.setToLoopStart();
    sample.start();
  }

  void Stop() {
    sample.setToEnd();
  }
}