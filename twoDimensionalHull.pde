ArrayList<Circle> circles;
ArrayList<Circle> march;
int n = 55;
float G = 6.67e-3;
float dt = .1;
float soft = 3e2;
int col = 0;

void setup() {
  frameRate(60);
  march = new ArrayList<Circle>();
  circles = new ArrayList<Circle> ();
  size(800, 800); 

  for (int i = 0; i < n; i++) {
     circles.add(new Circle(random(200, 600), random(200, 600), random(-20, 20), random(-20, 20), 59, i));    
  }
}

void draw() {
   background(255,255,255);
   stroke(0);
   col++;
   int i = 0;
   int j = 0;
   
   for (Circle c : circles) {
     //reset forces
     c.fx = 0;
     c.fy = 0;
     for (Circle c2: circles) {
        if (i < j) {
          float distx = c.x - c2.x;
          float disty = c.y - c2.y;
          float dist = sqrt(distx*distx + disty*disty);
          if (dist < 1) {
             dist = 1;
          }
          
          float force = -(200 * c.mass * c2.mass) / ((dist * dist) + (soft * soft));
          float fx = force * distx / dist;
          float fy = force * disty / dist;
          c.fx += fx;
          c.fy += fy;
          c2.fx -= fx;
          c2.fy -= fy;
        }
                
        j++;
     }
     
     c.ax = c.fx / c.mass;
     c.ay = c.fy / c.mass;
     c.vx += c.ax * dt;
     c.vy += c.ay * dt;
     c.x += c.vx * dt;
     c.y += c.vy * dt;
     fill(0);
     circle(c.x, c.y, 5);
     
     i++;
   }
   
   march();
   for (int index = 1; index < march.size(); index++) {
      Circle last = march.get(index - 1);
      Circle curr = march.get(index);
      line(last.x, last.y, curr.x, curr.y);
   }
}

boolean orientCCW(Circle p, Circle q, Circle r) {
    return ((q.y - p.y) * (r.x - q.x)) - ((q.x - p.x) * (r.y - q.y)) < 0;
}

void march() {
   march.clear();
   
   //get left most
   int left = 0;
   for (int i = 1; i < n; i++) {
       if (circles.get(i).x < circles.get(left).x)
          left = i;
   }
   
   int p = left;
   int q;
   
   march.add(circles.get(p));
   do {
      //wrap around
      q = (p + 1) % n;
      
      for (int i = 0; i < n; i++) 
        if (orientCCW(circles.get(p), circles.get(i), circles.get(q)))
          q = i;
      
      march.add(circles.get(q));
      p = q;
   } while (p != left);
}

class Circle {
  float x;
  float y;
  float vx;
  float vy;
  float ax;
  float ay;
  float mass;
  float fx;
  float fy;
  int id;
  Circle (float x, float y, float vx, float vy, float mass, int id) {
    this.x = x;
    this.y = y;
    this.mass = mass;
    this.id = id;
  }
}


 
 
