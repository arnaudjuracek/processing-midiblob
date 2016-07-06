public class BlobDetector{

	private PApplet parent;
	private int width, height;

	private OpenCV opencv;
	private ArrayList<Contour> contours, newBlobContours;
	private ArrayList<Blob> blobList;
	private int blobCount = 0;

	private PImage src, preProcessedImage, processedImage, contoursImage;



	// -------------------------------------------------------------------------
	public BlobDetector(PApplet parent, int width, int height){
		this.parent = parent;
		this.width = width;
		this.height = height;

		this.opencv = new OpenCV(parent, width, height);
		this.contours = new ArrayList<Contour>();
		this.blobList = new ArrayList<Blob>();
	}



	// -------------------------------------------------------------------------
	public void detect(PImage input){
		this.detect(input, new Rectangle(0, 0, input.width, input.height));
	}

	public void detect(PImage input, Rectangle clip){
		this.opencv.loadImage(input);
		// this.opencv.setROI(clip.x, clip.y, clip.width, clip.height);
		src = opencv.getSnapshot();


		// pre-process
		opencv.gray();
		// opencv.brightness(brightness);
		opencv.contrast(contrast);

		preProcessedImage = opencv.getSnapshot();

		if (useAdaptiveThreshold) {
			// Block size must be odd and greater than 3
			if (thresholdBlockSize%2 == 0) thresholdBlockSize++;
			if (thresholdBlockSize < 3) thresholdBlockSize = 3;

			opencv.adaptiveThreshold(thresholdBlockSize, thresholdConstant);
		} else opencv.threshold(threshold);

		// Invert (black bg, white blobs)
		// opencv.invert();

		// Reduce noise - Dilate and erode to close holes
		opencv.dilate();
		opencv.erode();
		opencv.blur(blurSize);
		processedImage = opencv.getSnapshot();


		this.detectBlobs();
		contoursImage = opencv.getSnapshot();
	}

	public void draw(){
		pushMatrix();
			translate(width-src.width, 0);
			displayImages();
			pushMatrix();
				scale(0.5);
				translate(src.width, src.height);
				this.displayBlobs();
			popMatrix();
		popMatrix();
	}



	private void detectBlobs() {
	  	// Contours detected in this frame
	  	// Passing 'true' sorts them by descending area.
	  	contours = opencv.findContours(true, true);
	  	newBlobContours = getBlobsFromContours(contours);

	  	// Check if the detected blobs already exist are new or some has disappeared.

	  	if (blobList.isEmpty()) {
			// Just make a Blob object for every face Rectangle
			for (int i = 0; i < newBlobContours.size(); i++) {
		  		println("+++ New blob detected with ID: " + blobCount);
		  		blobList.add(new Blob(this.parent, blobCount, newBlobContours.get(i)));
		  		blobCount++;
			}
	  	} else if (blobList.size() <= newBlobContours.size()) {
			boolean[] used = new boolean[newBlobContours.size()];
			// Match existing Blob objects with a Rectangle
			for (Blob b : blobList) {
		   		// Find the new blob newBlobContours.get(index) that is closest to blob b
		   		// set used[index] to true so that it can't be used twice
		   		float record = 50000;
		   		int index = -1;
		   		for (int i = 0; i < newBlobContours.size(); i++) {
			 		float d = dist(newBlobContours.get(i).getBoundingBox().x, newBlobContours.get(i).getBoundingBox().y, b.getBoundingBox().x, b.getBoundingBox().y);
			 		//float d = dist(blobs[i].x, blobs[i].y, b.r.x, b.r.y);
			 		if (d < record && !used[i]) {
			   			record = d;
			   			index = i;
			 		}
		   		}
		   		used[index] = true;
		   		b.update(newBlobContours.get(index));
			}

			for (int i = 0; i < newBlobContours.size(); i++) {
				if (!used[i]) {
					println("+++ New blob detected with ID: " + blobCount);
					blobList.add(new Blob(this.parent, blobCount, newBlobContours.get(i)));
					//blobList.add(new Blob(blobCount, blobs[i].x, blobs[i].y, blobs[i].width, blobs[i].height));
					blobCount++;
		  		}
			}

	  	} else {
			for (Blob b : blobList) b.available = true;

			// Match Rectangle with a Blob object
			for (int i = 0; i < newBlobContours.size(); i++) {
		  		// Find blob object closest to the newBlobContours.get(i) Contour
		  		// set available to false
		   		float record = 50000;
		   		int index = -1;
		   		for (int j = 0; j < blobList.size(); j++) {
			 		Blob b = blobList.get(j);
			 		float d = dist(newBlobContours.get(i).getBoundingBox().x, newBlobContours.get(i).getBoundingBox().y, b.getBoundingBox().x, b.getBoundingBox().y);
			 		//float d = dist(blobs[i].x, blobs[i].y, b.r.x, b.r.y);
			 		if (d < record && b.available) {
			   			record = d;
			   			index = j;
			 		}
		   		}

		   		Blob b = blobList.get(index);
		   		b.available = false;
		   		b.update(newBlobContours.get(i));
			}

			for (Blob b : blobList) {
		  		if (b.available) {
					b.countDown();
					if (b.dead()) {
			  			b.delete = true;
					}
		  		}
			}
	  	}

	  	// Delete any blob that should be deleted
	  	for (int i = blobList.size()-1; i >= 0; i--) {
			Blob b = blobList.get(i);
			if (b.delete) {
	  			blobList.remove(i);
			}
  		}
	}




	ArrayList<Contour> getBlobsFromContours(ArrayList<Contour> newContours) {

	  ArrayList<Contour> newBlobs = new ArrayList<Contour>();

	  // Which of these contours are blobs?
	  for (int i=0; i<newContours.size(); i++) {

		Contour contour = newContours.get(i);
		Rectangle r = contour.getBoundingBox();

		if (//(contour.area() > 0.9 * src.width * src.height) ||
			(r.width < blobSizeThreshold || r.height < blobSizeThreshold))
		  continue;

		newBlobs.add(contour);
	  }

	  return newBlobs;
	}





	private void displayImages() {
	  	pushMatrix();
	  		scale(0.5);
	  		image(preProcessedImage, src.width, 0);
	  		image(processedImage, 0, src.height);
	  		image(src, src.width, src.height);
	  	popMatrix();

	  	stroke(255);
	  	fill(255);
	  	textSize(12);
	  	text("Pre-processed Image", src.width/2 + 10, 25);
	  	text("Processed Image", 10, src.height/2 + 25);
	  	text("Tracked Points", src.width/2 + 10, src.height/2 + 25);
	}

	private void displayBlobs() {
	  	for (Blob b : blobList) {
			strokeWeight(1);
			b.display();
	  	}
	}

	void displayContoursBoundingBoxes() {

	  for (int i=0; i<contours.size(); i++) {

		Contour contour = contours.get(i);
		Rectangle r = contour.getBoundingBox();

		if (//(contour.area() > 0.9 * src.width * src.height) ||
			(r.width < blobSizeThreshold || r.height < blobSizeThreshold))
		  continue;

		stroke(255, 0, 0);
		fill(255, 0, 0, 150);
		strokeWeight(2);
		rect(r.x, r.y, r.width, r.height);
	  }
	}
}