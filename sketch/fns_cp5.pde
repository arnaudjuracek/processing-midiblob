public ControlP5 cp5;
public RadioButton visibleSnapshot_toggle;
public Range blobsize_slider;
public Println console;
public Textarea console_area;
public float contrast = 1.35;
public int buttonColor, buttonBgColor,
	blob_size_min = 0,
	blob_size_max = 100,
	visibleSnapshot = 0,
	threshold = 75,
	thresholdBlockSize = 489,
	thresholdConstant = 45,
	blobSizeThreshold = 20,
	blurSize = 4,
	minDepth = 0,
	maxDepth = 2047;
public boolean
	invert = false,
	show_blobs = false,
	useAdaptiveThreshold = false;



// -------------------------------------------------------------------------
void initControls(int x, int y) {
	x+=10; y+=10;
	cp5 = new ControlP5(this);

	visibleSnapshot_toggle = cp5.addRadioButton("radioButton")
		.setPosition(x, y)
		.setSize(20,20)
		.setColorLabel(color(0))
		.setColorBackground(color(14, 0, 132))
		.setColorActive(color(250, 0, 100))
		.setItemsPerRow(6)
		.addItem("0",0)
		.addItem("1",1)
		.addItem("2",2)
		.addItem("3",3)
		// .addItem("4",4)
		.hideLabels();
	visibleSnapshot_toggle.activate(0);

	cp5.addToggle("show_blobs")
		.setLabel("blobs")
		.setColorLabel(color(0))
		.setColorBackground(color(14, 0, 132))
		.setColorForeground(color(250, 0 ,100))
		.setSize(20, 20)
		.setPosition(x + 105, 10)
		.getCaptionLabel()
		.getStyle()
		.setMargin(-19,0,0,25);

	cp5.addSlider("contrast")
		.setLabel("contrast")
		.setColorLabel(color(0))
		.setColorBackground(color(14, 0, 132))
		.setColorForeground(color(250, 0 ,100))
		.setPosition(x, y+=21)
		.setSize(125, 20)
		.setRange(0.0, 10.0);

	cp5.addToggle("invert")
		.setLabel("invert")
		.setColorLabel(color(0))
		.setColorBackground(color(14, 0, 132))
		.setColorForeground(color(250, 0 ,100))
		.setSize(20,20)
		.setPosition(x, y+=21)
		.getCaptionLabel()
		.getStyle()
		.setMargin(-19,0,0,25);

	// -------------------------------------------------------------------------

	cp5.addToggle("toggleAdaptiveThreshold")
		.setLabel("use adaptive threshold")
		.setColorLabel(color(0))
		.setColorBackground(color(14, 0, 132))
		.setColorForeground(color(250, 0 ,100))
		.setSize(20,20)
		.setPosition(x, y+=50)
		.getCaptionLabel()
		.getStyle()
		.setMargin(-19,0,0,25);

	cp5.addSlider("threshold")
		.setLabel("threshold")
		.setColorLabel(color(0))
		.setColorBackground(color(14, 0, 132))
		.setColorForeground(color(250, 0 ,100))
		.setPosition(x, y+=21)
		.setSize(125, 20)
		.setRange(0,255);

	cp5.addSlider("thresholdBlockSize")
		.setLabel("a.t. block size")
		.setColorLabel(color(0))
		.setColorBackground(color(14, 0, 132))
		.setColorForeground(color(250, 0 ,100))
		.setPosition(x, y+=21)
		.setSize(125, 20)
		.setRange(1,700);

	cp5.addSlider("thresholdConstant")
		.setLabel("a.t. constant")
		.setColorLabel(color(0))
		.setColorBackground(color(14, 0, 132))
		.setColorForeground(color(250, 0 ,100))
		.setPosition(x, y+=21)
		.setSize(125, 20)
		.setRange(-100,100);


	// -------------------------------------------------------------------------

	cp5.addSlider("blurSize")
		.setLabel("blur size")
		.setColorLabel(color(0))
		.setColorBackground(color(14, 0, 132))
		.setColorForeground(color(250, 0 ,100))
		.setPosition(x, y+=50)
		.setSize(125, 20)
		.setRange(1, 100);

	blobsize_slider = cp5.addRange("blobSizeThreshold")
		.setLabel("blob size range")
		.setColorLabel(color(0))
		.setBroadcast(false)
		.setPosition(x, y+=21)
		.setSize(125, 20)
		.setHandleSize(5)
		.setRange(0, 50)
		.setRangeValues(3, 50)
		.setBroadcast(true)
		.setColorForeground(color(250, 0, 100))
		.setColorBackground(color(14, 0, 132));


	// -------------------------------------------------------------------------

	console = cp5.addConsole(
				cp5.addTextarea("txt")
					.setPosition(x+=210, y=10)
					.setSize((width-x-10), (height-y-10))
					.setFont(createFont("", 10))
					.setLineHeight(14)
					.setColor(color(0))
					.setColorBackground(color(255))
					.setColorForeground(color(250, 0, 100)));

	setLock(cp5.getController("thresholdBlockSize"), true);
	setLock(cp5.getController("thresholdConstant"), true);

	buttonColor = cp5.getController("contrast").getColor().getForeground();
	buttonBgColor = cp5.getController("contrast").getColor().getBackground();
}

void toggleAdaptiveThreshold(boolean theFlag) {
	useAdaptiveThreshold = theFlag;
	if (useAdaptiveThreshold) {
		setLock(cp5.getController("threshold"), true);
		setLock(cp5.getController("thresholdBlockSize"), false);
		setLock(cp5.getController("thresholdConstant"), false);
	} else {
		setLock(cp5.getController("threshold"), false);
		setLock(cp5.getController("thresholdBlockSize"), true);
		setLock(cp5.getController("thresholdConstant"), true);
	}
}

void setLock(Controller theController, boolean theValue) {
	theController.setLock(theValue);
	if (theValue) {
		theController.setColorBackground(color(150,150));
		theController.setColorForeground(color(100,100));
	} else {
		theController.setColorBackground(color(buttonBgColor));
		theController.setColorForeground(color(buttonColor));
	}
}

void controlEvent(ControlEvent theEvent) {
	if(theEvent.isFrom(visibleSnapshot_toggle)) {
		visibleSnapshot = int(theEvent.getGroup().getValue());
	}
	if(theEvent.isFrom("blobSizeThreshold")) {
		// min and max values are stored in an array.
		// access this array with controller().arrayValue().
		// min is at index 0, max is at index 1.
		blob_size_min = int(theEvent.getController().getArrayValue(0));
		blob_size_max = int(theEvent.getController().getArrayValue(1));
	}
}