/**
 * kaleidos_midiblob
 * @author: Arnaud Juracek (@arnaudjuracek)
 * @date: 2016-07-04
 * @url: https://github.com/arnaudjuracek/processing-midiblob
 *
 * Persistence algorithm by Daniel Shifmann:
 * http://shiffman.net/2011/04/26/opencv-matching-faces-over-time/
 *
 * Based on openCV Image filtering by Jordi Tost
 * https://github.com/jorditost/ImageFiltering/tree/master/ImageFilteringWithBlobPersistence
 */

import controlP5.*;
import gab.opencv.*;
import java.awt.Rectangle;
import org.openkinect.freenect.*;
import org.openkinect.processing.*;
import processing.video.*;


public DepthMap DEPTH_MAP;
public BlobDetector BLOB_DETECTOR;
public PImage logo;
public int angle;

void setup(){
	size(1060, 500);
	frameRate(15);

	logo = loadImage("logo.png");

	DEPTH_MAP = new DepthMap(this, new int[]{980, 1027});
	BLOB_DETECTOR = new BlobDetector(this, 640, 480);
	angle = int(DEPTH_MAP.getKinect().getTilt());
	initControls(650, 0);
}



// -------------------------------------------------------------------------
void draw() {
	surface.setTitle("kaleidos-midiblob — " +int(frameRate)+"fps");
	background(255);

	BLOB_DETECTOR.detect(DEPTH_MAP.getDepthImage(), DEPTH_MAP.getAbsoluteClip());

	switch(visibleSnapshot){
		case 0 :
			image(logo, 0, 0);
			break;
		case 1 :
			image(DEPTH_MAP.getRawDepthImage(), 10, 10);
			noStroke();
			fill(0, 255*.7);
			rect(10, 10, 640, 480);
			image(DEPTH_MAP.getClippedDepthImage(), DEPTH_MAP.getAbsoluteClip().x, DEPTH_MAP.getAbsoluteClip().y);
			DEPTH_MAP.drawClip();
			break;
		case 2 :
			image(BLOB_DETECTOR.preProcessedImage, 10, 10);
			DEPTH_MAP.drawClip();
			break;
		case 3 :
			image(BLOB_DETECTOR.processedImage, 10, 10);
			DEPTH_MAP.drawClip();
			break;
		case 4 :
			image(BLOB_DETECTOR.contoursImage, 10, 10);
			DEPTH_MAP.drawClip();
			break;
	}

	if(show_blobs) BLOB_DETECTOR.displayBlobs();
}



// -------------------------------------------------------------------------
boolean dragging = false;

void mouseDragged(){
	if(visibleSnapshot > 0 && mouseX > 0 && mouseX < DEPTH_MAP.getWidth() && mouseY > 0 && mouseY < DEPTH_MAP.getHeight()){
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