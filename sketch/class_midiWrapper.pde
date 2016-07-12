public class MidiWrapper{

	private PApplet parent;
	private MidiBus bus;
	private boolean sending;

	public int[] NOTES = {20};
	public int
		INDEX = 0,
		CHANNEL = 10;




	// -------------------------------------------------------------------------
	public MidiWrapper(PApplet parent){
		this.parent = parent;
		this.bus = this.prompt();
		// this.bus = new MidiBus(this, -1, 2);
		this.sending = false;
		this.INDEX = 0;
	}

	public MidiBus prompt(){
		MidiBus bus = null;
		String device = (String) JOptionPane.showInputDialog(
			null,
			"Select a Midi Output Device",
			"Midi Output Device selection",
			JOptionPane.PLAIN_MESSAGE,
			null,
			MidiBus.availableOutputs(),
			MidiBus.availableOutputs()[0]
		);

		try{
			bus = new MidiBus(this, -1, device);
		}catch(NullPointerException e){
			println(e);
			exit();
		}

		return bus;
	}

	// -------------------------------------------------------------------------
	public void trigger(int value){ this.trigger(value, false); }
	public void trigger(){ this.trigger(0, false); }
	public void trigger(boolean newNote){ this.trigger(0, newNote); }
	public void trigger(int value, boolean newNote){
		if(newNote){
			// this.INDEX = int(random(this.NOTES.length));
			this.INDEX = ++this.INDEX%this.NOTES.length;
		}

		this.bus.sendControllerChange(this.CHANNEL, this.NOTES[this.INDEX], value);
		println("CC("+ this.CHANNEL+ ", "+ this.NOTES[this.INDEX] +", "+ value +")");
	}


	public void send(int channel, int number, int value){
		this.bus.sendControllerChange(channel, number, value);
	}

	public void on(int channel, int pitch, int velocity){
		if(!this.sending){
			midi_button.setColorBackground(color(250, 0, 100));
			this.bus.sendNoteOn(channel, pitch, velocity);
			// println("NoteOn("+channel+", "+pitch+", "+velocity+")");
			this.sending = true;
		}
  	}

  	public void off(int channel, int pitch, int velocity){
  		if(this.sending){
  			midi_button.setColorBackground(color(14, 0 , 132));
  			this.bus.sendNoteOff(channel, pitch, velocity);
  			// println("NoteOff("+channel+", "+pitch+", "+velocity+")");
  			this.sending = false;
  		}
	}

	public void delay(int time) {
  		int current = millis();
  		while (millis () < current+time) Thread.yield();
	}

}