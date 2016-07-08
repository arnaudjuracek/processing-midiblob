public class Blob {
	private PApplet parent;
	public Contour contour;
	public boolean available;
	public boolean delete;

	private int initTimer = 15;
	public int timer;
	public int id;

	private PVector position, p_position;

	public Blob(PApplet parent, int id, Contour c) {
		this.parent = parent;
		this.id = id;
		this.contour = new Contour(parent, c.pointMat);

		this.available = true;
		this.delete = false;
		this.timer = initTimer;

		this.position = this.computePosition();
		this.p_position = this.position;
	}



	// -------------------------------------------------------------------------
	public void display(){ this.display(-1); }
	public void display(int id) {
		Rectangle r = contour.getBoundingBox();

		fill(14, 0, 132, map(this.timer, 0, this.initTimer, 0, 127));
		stroke(255);
		strokeWeight(2);
		rect(r.x, r.y, r.width, r.height);

		stroke(250, 0, 100);
		strokeWeight(10);
		point(this.position.x, this.position.y);

		strokeWeight(4);
		line(this.p_position.x, this.p_position.y, this.position.x, this.position.y);

		if(id>=0){
			fill(255);
			textSize(14);
			text(""+id +" ("+this.id+")", r.x+6, r.y+18);
		}
	}



	// -------------------------------------------------------------------------
	public void update(Contour newC){
		this.contour = new Contour(parent, newC.pointMat);
		this.p_position = this.position;
		this.position = this.computePosition();
	}

	public void countDown(){ this.timer--; }
	public boolean dead(){ return (this.timer < 0); }
	public Rectangle getBoundingBox(){ return contour.getBoundingBox(); }

	// -------------------------------------------------------------------------
	public PVector computePosition(){
		Rectangle r = this.getBoundingBox();
		return new PVector( r.x + r.width*.5, r.y + r.height*.5 );
	}

	public PVector getPosition(){ return this.position; }
	public PVector getPrevPosition(){ return this.p_position; }
	public float getDeltaPosition(){ return this.position.dist(this.p_position); }
}

