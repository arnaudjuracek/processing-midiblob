public class Blob {
	private PApplet parent;
	public Contour contour;
	public boolean available;
	public boolean delete;

	private int initTimer = 5; //127;
	public int timer;

	int id;

	Blob(PApplet parent, int id, Contour c) {
		this.parent = parent;
		this.id = id;
		this.contour = new Contour(parent, c.pointMat);

		available = true;
		delete = false;

		timer = initTimer;
	}

	void display() {
		Rectangle r = contour.getBoundingBox();

		float opacity = map(timer, 0, initTimer, 0, 127);

		fill(14, 0, 132, opacity);
		stroke(255);
		strokeWeight(2);
		rect(r.x, r.y, r.width, r.height);

		fill(255);
		textSize(26);
		text(""+id, r.x+10, r.y+30);
	}


	void update(Contour newC) {

		contour = new Contour(parent, newC.pointMat);

		// Is there a way to update the contour's points without creating a new one?
		/*ArrayList<PVector> newPoints = newC.getPoints();
		Point[] inputPoints = new Point[newPoints.size()];

		for(int i = 0; i < newPoints.size(); i++){
		  inputPoints[i] = new Point(newPoints.get(i).x, newPoints.get(i).y);
		}
		contour.loadPoints(inputPoints);*/

		timer = initTimer;
	}

	void countDown() {
		timer--;
	}

	// I am deed, delete me
	boolean dead() {
		if (timer < 0) return true;
		return false;
	}

	public Rectangle getBoundingBox() {
		return contour.getBoundingBox();
	}
}

