public class Blob {
	private PApplet parent;
	public Contour contour;
	public boolean available;
	public boolean delete;

	private int initTimer = 15;
	public int timer;
	public int id;

	public Blob(PApplet parent, int id, Contour c) {
		this.parent = parent;
		this.id = id;
		this.contour = new Contour(parent, c.pointMat);

		this.available = true;
		this.delete = false;
		this.timer = initTimer;
	}



	// -------------------------------------------------------------------------
	public void display(){ this.display(-1); }
	public void display(int id) {
		Rectangle r = contour.getBoundingBox();

		fill(14, 0, 132, map(this.timer, 0, this.initTimer, 0, 127));
		stroke(255);
		strokeWeight(2);
		rect(r.x, r.y, r.width, r.height);

		if(id>=0){
			fill(255);
			textSize(14);
			text(""+id, r.x+6, r.y+18);
		}
	}



	// -------------------------------------------------------------------------
	public void update(Contour newC){ this.contour = new Contour(parent, newC.pointMat); }
	public void countDown(){ this.timer--; }
	public boolean dead(){ return (this.timer < 0); }
	public Rectangle getBoundingBox(){ return contour.getBoundingBox(); }
}

