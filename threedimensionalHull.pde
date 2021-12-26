//3d n-body simulation + convex hull visualizer by Michael Ma 2021

ArrayList<Circle> circles;
ArrayList<Face> faces;
ArrayList<Circle> hull;
final int n = 50;

//constants edited to enhance effect of gravity
final float G = 200;
final float dt = .1;

//softening 

final float soft = 3e2;
final float mass = 60;
boolean showAll = false;
boolean showNodes = false;

void keyPressed() {
  if (keyCode == 97) {
    showAll = !showAll;
    showNodes = false;
  } else if (keyCode == 98) {
    showNodes = !showNodes; 
    showAll = false;
  }
}

void setup() {
  faces = new ArrayList<Face>();
  circles = new ArrayList<Circle>();
  size(800, 800, P3D); 

  for (int i = 0; i < n; i++) {
     circles.add(new Circle(random(-200, 200), random(-200, 200) , random(0, 500), mass, i));    
  }
}

void draw() {
  
   background(255);
   translate(width / 2, height / 2, -600);
   int i = 0;
   int j = 0;
   hull();
   
   for (Circle c : circles) {
     
     //reset forces
     c.fx = 0;
     c.fy = 0;
     c.fz = 0;
     
     for (Circle c2: circles) {
       
        //We don't want duplicate pairs
        if (i < j) {
          
          float distx = c.x - c2.x;
          float disty = c.y - c2.y;
          float distz = c.z - c2.z;
          float dist = sqrt(distz * distz + distx * distx + disty * disty);
          
          //avoid division by 0
          if (dist < 1) {
             dist = 1;
          }
          
          float force = -(G * c.mass * c2.mass) / ((dist * dist) + (soft * soft));
          float fx = force * distx / dist;
          float fy = force * disty / dist;
          float fz = force * distz / dist;
          c.fx += fx;
          c.fy += fy;
          c.fz += fz;
          c2.fx -= fx;
          c2.fy -= fy;
          c2.fz -= fz;
        }
        j++;
      }
      
      c.move();
      i++;
      
      if (showAll) {
       drawSphere(c); 
      }
   }
   
   for(Face f: faces) {
      line(f.a.x, f.a.y, f.a.z, f.b.x, f.b.y, f.b.z);
      line(f.a.x, f.a.y, f.a.z, f.c.x, f.c.y, f.c.z);
      line(f.c.x, f.c.y, f.c.z, f.b.x, f.b.y, f.b.z);
      
      if (showNodes) {
        drawSphere(f.a);
        drawSphere(f.b);
        drawSphere(f.c);
      }
   }
}

Vector crossProduct (Vector one, Vector other) {
    float newX = one.y * other.z - one.z * other.y;
    float newY = one.z * other.x - one.x * other.z;
    float newZ = one.x * other.y - one.y * other.x;
    return new Vector(newX, newY, newZ);
}
  
double dotProduct (Vector one, Vector other) {
   return one.x * other.x + one.y * other.y + one.z * other.z;
} 

Vector subtract(Circle one, Circle two) {
   float x = one.x - two.x;
   float y = one.y - two.y;
   float z = one.z - two.z;
   return new Vector(x, y, z);
}

void hull () {
 faces.clear();
 //get every triplet
 for (int i = 0; i < n - 2; i++) {
   for (int j = i + 1; j < n - 1; j++) {
     for (int k = j + 1; k < n; k++) {
       
       Circle A = circles.get(i);
       Circle B = circles.get(j);
       Circle C = circles.get(k);
       Vector r1 = subtract(A, B);
       Vector r2 = subtract(A, C);
       
       //get orthogonal vector to face
       Vector cross = crossProduct(r1, r2);
       int num = 0;
       for (int index = 0; index < circles.size(); index++) {
           //avoid checking for points that are on the face
           if (index != i && index != j && index != k) {
             Circle curr = circles.get(index);
             if (dotProduct(cross, subtract(curr, A)) > 0) {
               num++;
             }
           }
       }
       
       //if every other point is on the other side of the face
       //it must be part of the convex hull
       if (num == n - 3 || num == 0) {
          faces.add(new Face(A, B, C)); 
       }
   }
  } 
 }
}

void drawSphere(Circle c) {
  translate(c.x, c.y, c.z);
  sphere(5);
  translate(-c.x, -c.y, -c.z);
}

class Circle {
  float x;
  float y;
  float z;
  float vx;
  float vy;
  float vz;
  float ax;
  float ay;
  float az;
  float mass;
  float fx;
  float fy;
  float fz;
  int id;
  Circle (float x, float y, float z, float mass, int id) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.mass = mass;
    this.id = id;
  }
  
  void move () {
    ax = fx / mass;
    ay = fy / mass;
    az = fz / mass;
    vx += ax * dt;
    vy += ay * dt;
    vz += az * dt;
    x += vx * dt;
    y += vy * dt;
    z += vz * dt; 
  }
}

class Vector {
 float x;
 float y; 
 float z;
 
 Vector (float x, float y, float z) {
   this.x = x;
   this.y = y;
   this.z = z;
 }
}

class Face {
  Circle a, b, c;
  Face(Circle a, Circle b, Circle c) {
    this.a = a;
    this.b = b;
    this.c = c;
  }
}

 
 
