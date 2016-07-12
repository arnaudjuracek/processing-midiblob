public class BlobAnalysis{
	private PApplet parent;
	public MidiWrapper MIDI;
	private BlobDetector detector;
	private Chart chart;
	private SignalFilter filter;

	private int max;
	private float MAX_FV;
	private float threshold = 10;

	// -------------------------------------------------------------------------
	public BlobAnalysis(PApplet parent, BlobDetector detector, Chart chart){
		this.parent = parent;
		this.detector = detector;
		this.chart = chart.setRange(-10, 100)
						.addDataSet("v")
						.setData("v", new float[100])

						.addDataSet("vf")
						.setData("vf", new float[100])
						.setColors("vf", color(255), color(255))

						.addDataSet("threshold")
						.setColors("threshold", color(250, 0, 100), color(250, 0, 100))
						.setData("threshold", new float[2])

						.setStrokeWeight(3);

		for(int i=0; i<2; i++) this.chart.push("threshold", this.threshold);

		this.filter = new SignalFilter(parent);
		this.MIDI = new MidiWrapper(parent);
		this.MAX_FV = 0;
	}




	// -------------------------------------------------------------------------
	float pfv = 0;
	public void update(){
		this.filter.setMinCutoff(filter_cutoff);
		this.filter.setBeta(filter_beta);
		if(filter_threshold!=this.threshold){
			this.threshold = filter_threshold;
			for(int i=0; i<2; i++) this.chart.push("threshold", this.threshold);
		}

		float v = this.computeAverageDelta();
		float fv = this.filter.filterUnitFloat(v);

		if(v>0){
			// if(fv>this.threshold && pfv<this.threshold) this.MIDI.send(0, 64, 127);
			if(fv>this.threshold) this.MIDI.trigger(int(map(fv, this.threshold, this.MAX_FV, 0, 127)), (pfv<this.threshold));
			// if(fv>this.threshold && pfv<this.threshold) this.MIDI.on(0, 64, 127);
			// else if(fv<this.threshold && pfv>this.threshold) this.MIDI.off(0, 64, 127);
			if(fv > this.MAX_FV) this.MAX_FV = fv;
			this.chart.push("v", v);
			this.chart.push("vf", fv);
		}

		if(fv<this.threshold && pfv>this.threshold){
			// this.MIDI.off(0, 64, 127);
			for(int note : this.MIDI.NOTES){
				this.MIDI.send(this.MIDI.CHANNEL, note, 0);
			}

			if(this.MAX_FV > 0) this.MAX_FV = 0;
		}

		pfv = fv;
	}

	private float computeAverageDelta(){
		float avg = 0;
		if(this.detector.blobList.size()>0){
			// for(Blob b : this.detector.blobList) avg += b.getDeltaPosition();
			for(Blob b : this.detector.blobList) avg += b.getDelta();
			avg /= this.detector.blobList.size();
		}
		return avg;
	}
}