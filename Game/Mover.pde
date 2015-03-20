


class Mover {
  float mass;
  float radius;
  PVector location;
  PVector velocity;
  PVector acceleration;
  float restViApresChoc = 0.8; //ratio de restitution de la vitesse après un choc statique
  float gravityConstant = 0.7;
  float frictionMagnitude = 0.1;
  float empietementTolere = 1;
    
  
  Mover(float radius, float mass) {
    location = new PVector(0,0,0);
    velocity = new PVector(0,0,0);
    acceleration = new PVector(0,0,0);
    this.radius = radius;
    this.mass = mass;
  }
  
  Mover() {
    this(15.0, 1.0);
  }
 
  void update() {
    
    // frottement, frein. s'oppose à la vitesse :
    PVector frein = velocity.get();
    frein.normalize();
    frein.mult(-frictionMagnitude);
    
    // accélération : 
    acceleration.z = 
      sin( platXRotation ) * gravityConstant +
      frein.z;
    acceleration.x = 
      - sin( platZRotation ) * gravityConstant +
      frein.x;
    acceleration.y =
      frein.y;
    
    // update la vitesse puis la position :
    velocity.add(acceleration);
    location.add(velocity);
    
    // contrôle la position :
    checkEdges();
    checkCylinderCollision();
  }
  
  void display() {
    pushMatrix();
      noStroke();
      fill(0,0,255);
      translate(location.x, radius + location.y, location.z);
      sphere(radius);
    popMatrix();
  }
  
  void checkEdges() {
    if (location.x > tailleTerrainX/2) {
      location.x = tailleTerrainX/2;
      velocity.x *= -1;
    }
    else if (location.x < -tailleTerrainX/2) {
      location.x = -tailleTerrainX/2;
      velocity.x *= -1;
    }
    if (location.z > tailleTerrainZ/2) {
      location.z = tailleTerrainZ/2;
      velocity.z *= -1;
    }
    else if (location.z < -tailleTerrainZ/2) {
      location.z = -tailleTerrainZ/2;
      velocity.z *= -1;
    }
  }
  
  void checkCylinderCollision() {
    for (PVector v : cylindersPos) {
      if (collide2D(v, cylinderRadius, location, radius)) {
        //il y a une collision; on modifie la vitesse du mover.
        //V' = V − 2(V · n)n
        PVector n = PVector.sub(v, location);
        n.normalize();
        
        PVector vn2n = PVector.mult(n, velocity.dot(n)*2);
        velocity.sub(vn2n);
        velocity.mult(restViApresChoc);
        
        //on update sa position
        //on le pousse hors de la balle selon n (selon tolérance pour optimiser)
        float empietement = cylinderRadius + radius - v.dist(location);
        if (empietement >= empietementTolere) {
          PVector correction = PVector.mult(n, empietement);
          location.sub(correction);
        }
      }
    }
  }
  
  //utilise x and z, centre de 2 spheres et leurs rayons
  boolean collide2D(PVector p1, float r1, PVector p2, float r2) {
    PVector v = p1.get();
    v.sub(p2);
    v.y = 0;
    return v.magSq() <= (r1+r2)*(r1+r2);
  }
}
