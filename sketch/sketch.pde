import controlP5.*;
import gab.opencv.*;
import java.awt.Rectangle;
import org.openkinect.freenect.*;
import org.openkinect.processing.*;


public DepthMap DEPTH_MAP;
public BlobDetector BLOB_DETECTOR;
public int angle;

void setup(){
	size(1480, 480);
	frameRate(15);

	DEPTH_MAP = new DepthMap(this, new int[]{980, 1027});
	BLOB_DETECTOR = new BlobDetector(this, 640, 480);
	angle = int(DEPTH_MAP.getKinect().getTilt());
	initControls(int(width*.5));
}



// -------------------------------------------------------------------------
void draw() {
	surface.setTitle(int(frameRate)+"fps" + " — " + "THRESHOLD: [" + DEPTH_MAP.getDepthThreshold()[0] + ", " + DEPTH_MAP.getDepthThreshold()[1] + "]");

	// if(mousePressed) image(DEPTH_MAP.getRawDepthImage(), 0, 0);
	// else image(DEPTH_MAP.getDepthImage(), 0, 0);

	image(DEPTH_MAP.getRawDepthImage(), 0, 0);

	fill(0, 255*.7);
	rect(0, 0, width, height);
	image(DEPTH_MAP.getClippedDepthImage(), DEPTH_MAP.getAbsoluteClip().x, DEPTH_MAP.getAbsoluteClip().y);
	DEPTH_MAP.drawClip();



	BLOB_DETECTOR.detect(DEPTH_MAP.getDepthImage(), DEPTH_MAP.getAbsoluteClip());
	pushMatrix();
		translate(width/2, 0);
		BLOB_DETECTOR.draw();
	popMatrix();
}



// -------------------------------------------------------------------------
boolean dragging = false;

void mouseDragged(){
	if(mouseX > 0 && mouseX < DEPTH_MAP.getWidth() && mouseY > 0 && mouseY < DEPTH_MAP.getHeight()){
		Rectangle c = DEPTH_MAP.getClip();

		if(!dragging){
			dragging = true;
			c.x = mouseX;
			c.y = mouseY;
		}

		c.width = mouseX - c.x;
		c.height = mouseY - c.y;
	}
}

void mouseReleased(){
	dragging = false;
	DEPTH_MAP.update(true);
}


void keyPressed() {
  	if (keyCode == UP) DEPTH_MAP.getKinect().setTilt(constrain(angle++, 0, 30));
	else if (keyCode == DOWN) DEPTH_MAP.getKinect().setTilt(constrain(angle--, 0, 30));
  	else if (key == 'r') setup();
  	else if (key == 'a') DEPTH_MAP.getDepthThreshold()[0] = constrain(DEPTH_MAP.getDepthThreshold()[0]+1, 0, DEPTH_MAP.getDepthThreshold()[1]);
  	else if (key == 's') DEPTH_MAP.getDepthThreshold()[0] = constrain(DEPTH_MAP.getDepthThreshold()[0]-1, 0, DEPTH_MAP.getDepthThreshold()[1]);
  	else if (key == 'z') DEPTH_MAP.getDepthThreshold()[1] = constrain(DEPTH_MAP.getDepthThreshold()[1]+1, DEPTH_MAP.getDepthThreshold()[0], 2047);
  	else if (key == 'x') DEPTH_MAP.getDepthThreshold()[1] = constrain(DEPTH_MAP.getDepthThreshold()[1]-1, DEPTH_MAP.getDepthThreshold()[0], 2047);

  	else if (key == 'f') DEPTH_MAP.SMOOTH_FRAME = !DEPTH_MAP.SMOOTH_FRAME;
}