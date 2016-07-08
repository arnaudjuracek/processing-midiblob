public class MidiWrapper{

	private PApplet parent;
	private MidiBus bus;

	private boolean sending;



	// -------------------------------------------------------------------------
	public MidiWrapper(PApplet parent){
		this.parent = parent;
		// this.bus = new MidiBus(this, -1, 1);
		this.bus = this.prompt();
		this.sending = false;
	}

	public MidiBus prompt(){
		String device = (String) JOptionPane.showInputDialog(
			null,
			"Select a Midi Output Device",
			"Midi Output Device selection",
			JOptionPane.PLAIN_MESSAGE,
			null,
			MidiBus.availableOutputs(),
			MidiBus.availableOutputs()[0]
		);
		return new MidiBus(this, -1, (int) ((device==null) ? 0 : int(device)));
	}

	// -------------------------------------------------------------------------
	public void send(int channel, int number, int value){
		this.bus.sendControllerChange(channel, number, value);
	}

	public void on(int channel, int pitch, int velocity){
		if(!this.sending){
			this.bus.sendNoteOn(channel, pitch, velocity);
			println("NoteOn("+channel+", "+pitch+", "+velocity+")");
			this.sending = true;
		}
  	}

  	public void off(int channel, int pitch, int velocity){
  		if(this.sending){
  			this.bus.sendNoteOff(channel, pitch, velocity);
  			println("NoteOff("+channel+", "+pitch+", "+velocity+")");
  			this.sending = false;
  		}
	}

	public void delay(int time) {
  		int current = millis();
  		while (millis () < current+time) Thread.yield();
	}

}