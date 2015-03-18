class Mover {
  PVector location;
  PVector velocity;
  PVector acceleration;
  float mass;
  
  Mover() {
    location = new PVector(0,0,0);
    velocity = new PVector(0,0,0);
    acceleration = new PVector(0,0,0);
    mass = 1;
  }
 
  void update() {
    
    // frottement, frein. s'oppose à la vitesse :
    float frictionMagnitude = 0.1;
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
  }
  
  void display() {
    noStroke();
    fill(255);
    translate(location.x, 30 + location.y, location.z);
    sphere(20);
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
}
