ControlP5 cp5;
int buttonColor;
int buttonBgColor;

float contrast = 1.35;
int brightness = 0;
int threshold = 75;
boolean useAdaptiveThreshold = false; // use basic thresholding
int thresholdBlockSize = 489;
int thresholdConstant = 45;
int blobSizeThreshold = 20;
int blurSize = 4;

void initControls(int x) {
	cp5 = new ControlP5(this);

  	// Slider for contrast
  	cp5.addSlider("contrast")
     	.setLabel("contrast")
     	.setPosition(x, 50)
     	.setRange(0.0,6.0);

  	// Slider for threshold
  	cp5.addSlider("threshold")
     	.setLabel("threshold")
     	.setPosition(x, 110)
     	.setRange(0,255);

  	// Toggle to activae adaptive threshold
  	cp5.addToggle("toggleAdaptiveThreshold")
     	.setLabel("use adaptive threshold")
     	.setSize(10,10)
     	.setPosition(x, 144);

  	// Slider for adaptive threshold block size
  	cp5.addSlider("thresholdBlockSize")
     	.setLabel("a.t. block size")
     	.setPosition(x, 180)
     	.setRange(1,700);

  	// Slider for adaptive threshold constant
  	cp5.addSlider("thresholdConstant")
     	.setLabel("a.t. constant")
     	.setPosition(x, 200)
     	.setRange(-100,100);

  	// Slider for blur size
  	cp5.addSlider("blurSize")
     	.setLabel("blur size")
     	.setPosition(x, 260)
     	.setRange(1,20);

  	// Slider for minimum blob size
  	cp5.addSlider("blobSizeThreshold")
     	.setLabel("min blob size")
     	.setPosition(x, 290)
     	.setRange(0,60);

  	buttonColor = cp5.getController("contrast").getColor().getForeground();
  	buttonBgColor = cp5.getController("contrast").getColor().getBackground();
}

void toggleAdaptiveThreshold(boolean theFlag) {
  	useAdaptiveThreshold = theFlag;
  	if (useAdaptiveThreshold) {
    	// Lock basic threshold
    	setLock(cp5.getController("threshold"), true);
    	// Unlock adaptive threshold
    	setLock(cp5.getController("thresholdBlockSize"), false);
    	setLock(cp5.getController("thresholdConstant"), false);
  	} else {
    	// Unlock basic threshold
    	setLock(cp5.getController("threshold"), false);
    	// Lock adaptive threshold
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