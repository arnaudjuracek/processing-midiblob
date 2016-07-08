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

public float contrast = 1.35;
public int buttonColor, buttonBgColor,
	visibleSnapshot = 1,
	blob_size_min = 5,
	blob_size_max = 50,
	threshold = 75,
	thresholdBlockSize = 489,
	thresholdConstant = 45,
	blobSizeThreshold = 20,
	blurSize = 4,
	minDepth = 0,
	maxDepth = 2047;
public boolean
	invert = false,
	show_blobs = true,
	useAdaptiveThreshold = false;

void setup(){
	size(1060, 500);
	frameRate(15);

	logo = loadImage("logo.png");

	DEPTH_MAP = new DepthMap(this, new int[]{980, 1027});
	BLOB_DETECTOR = new BlobDetector(this, 640, 480);

	initControls(650, 0);
}



// -------------------------------------------------------------------------
void draw() {
	surface.setTitle("kaleidos-midiblob — " +int(frameRate)+"fps");
	background(255);

	BLOB_DETECTOR.detect(DEPTH_MAP.getClippedDepthImage(), DEPTH_MAP.getAbsoluteClip());

	pushMatrix();
	translate(10, 10);
	switch(visibleSnapshot){
		case 0 :
			image(logo, 0, 0);
			break;
		case 1 :
			image(DEPTH_MAP.getRawDepthImage(), 0, 0);
			noStroke();
			fill(0, 255*.3);
			rect(0, 0, 640, 480);
			image(DEPTH_MAP.getClippedDepthImage(), DEPTH_MAP.getAbsoluteClip().x, DEPTH_MAP.getAbsoluteClip().y);
			DEPTH_MAP.drawClip();
			break;
		case 2 :
			image(BLOB_DETECTOR.preProcessedImage, 0, 0);
			DEPTH_MAP.drawClip();
			break;
		case 3 :
			image(BLOB_DETECTOR.processedImage, 0, 0);
			DEPTH_MAP.drawClip();
			break;
		case 4 :
			image(BLOB_DETECTOR.contoursImage, 0, 0);
			DEPTH_MAP.drawClip();
			break;
	}
	if(show_blobs) BLOB_DETECTOR.displayBlobs();
	popMatrix();
}



// -------------------------------------------------------------------------
boolean dragging = false;

void mouseDragged(){
	int x = mouseX - 10,
		y = mouseY - 10;

	if(visibleSnapshot > 0 && x > 0 && x < DEPTH_MAP.getWidth() && y > 0 && y < DEPTH_MAP.getHeight()){
		Rectangle c = DEPTH_MAP.getClip();

		if(!dragging){
			dragging = true;
			c.x = x;
			c.y = y;
		}

		c.width = x - c.x;
		c.height = y - c.y;
	}
}

void mouseReleased(){
	dragging = false;
	DEPTH_MAP.update(true);
}


void keyPressed() {
	if (key == 'r') setup();
  	else if (key == 'a') DEPTH_MAP.getDepthThreshold()[0] = constrain(DEPTH_MAP.getDepthThreshold()[0]+1, 0, DEPTH_MAP.getDepthThreshold()[1]);
  	else if (key == 's') DEPTH_MAP.getDepthThreshold()[0] = constrain(DEPTH_MAP.getDepthThreshold()[0]-1, 0, DEPTH_MAP.getDepthThreshold()[1]);
  	else if (key == 'z') DEPTH_MAP.getDepthThreshold()[1] = constrain(DEPTH_MAP.getDepthThreshold()[1]+1, DEPTH_MAP.getDepthThreshold()[0], 2047);
  	else if (key == 'x') DEPTH_MAP.getDepthThreshold()[1] = constrain(DEPTH_MAP.getDepthThreshold()[1]-1, DEPTH_MAP.getDepthThreshold()[0], 2047);

  	else if (key == 'f') DEPTH_MAP.SMOOTH_FRAME = !DEPTH_MAP.SMOOTH_FRAME;
}