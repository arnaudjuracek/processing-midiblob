public class BlobAnalysis{
	private PApplet parent;
	private MidiWrapper MIDI;
	private BlobDetector detector;
	private Chart chart;
	private SignalFilter filter;

	private int max;
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
						.setColors("vf", color(250, 0, 100), color(250, 0, 100))

						.addDataSet("threshold")
						.setColors("threshold", color(255), color(255))
						.setData("threshold", new float[2])

						.setStrokeWeight(3);

		for(int i=0; i<2; i++) this.chart.push("threshold", this.threshold);

		this.filter = new SignalFilter(parent);
		this.MIDI = new MidiWrapper(parent);
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
			if(fv>this.threshold && pfv<this.threshold) this.MIDI.on(0, 64, 127);
			else if(fv<this.threshold && pfv>this.threshold) this.MIDI.off(0, 64, 127);

			this.chart.push("v", v);
			this.chart.push("vf", fv);
		}else{
			this.MIDI.off(0, 64, 127);
		}

		pfv = fv;
	}

	private float computeAverageDelta(){
		float avg = 0;
		if(this.detector.blobList.size()>0){
			for(Blob b : this.detector.blobList) avg += b.getDeltaPosition();
			// avg /= this.detector.blobList.size();
		}
		return avg;
	}


	private void graph(){
		// this.chart.push("mousex", map(mouseX, 0, width, -1, 1) * 10);
		// this.chart.push("mousey", map(mouseY, 0, height, -1, 1) * 10);
	}
}