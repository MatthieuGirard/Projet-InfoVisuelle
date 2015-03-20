class Mover {
  //-- parametres
  boolean perteEnergieApresChocActivee = true;
  float ratioEnergieApresChoc = 0.8; //ratio de restitution de l'énergie après un choc statique
  float gravityConstant = 0.7;
  float frictionMagnitude = 0.1;
  float empietementMaxContre = 0.4; //en dessous de ces valeurs, le mover est considéré contre un obstacle
  float vitesseMaxContre = 0.1;     //vitesse normale de collision
  
  
  //-- interne
  float mass;
  float radius;
  PVector location;
  PVector velocity;
  PVector acceleration;
  float epsilon = empietementMaxContre/10;
  
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
    frein.mult(-frictionMagnitude*gravityConstant);
    
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
    boolean collision = false;
    if (location.x > tailleTerrainX/2) {
      location.x = tailleTerrainX/2;
      velocity.x *= -1;
      collision = true;
    }
    else if (location.x < -tailleTerrainX/2) {
      location.x = -tailleTerrainX/2;
      velocity.x *= -1;
      collision = true;
    }
    if (location.z > tailleTerrainZ/2) {
      location.z = tailleTerrainZ/2;
      velocity.z *= -1;
      collision = true;
    }
    else if (location.z < -tailleTerrainZ/2) {
      location.z = -tailleTerrainZ/2;
      velocity.z *= -1;
      collision = true;
    }
    //pas besoin et frein à mort la boule lorsqu'elle roule contre un bord
    //if (collision && perteEnergieApresChocActivee) {
    //  perdEnergie(velocity, ratioEnergieApresChoc);
    //}
  }
  
  void checkCylinderCollision() {
    for (PVector c : cylindersPos) {
      if (collide2D(c, cylinderRadius, location, radius)) {
        //il y a une collision; on modifie la vitesse du mover.
        //l'empiètement du mover sur la sphere
        float empietement = cylinderRadius + radius - location.dist(c);
        
        //on trouve le point où a lieu la collision -> dépend de l t.q. ( |m + l*(m' - m) - c| = ray1 + ray2 )
        PVector m = PVector.sub(location, velocity); //précédente location
        PVector mmp = velocity.get();  //m' - m = mm', déplacement = velocity
        PVector cm = PVector.sub(m, c); //
        float l1 = solve(mmp.magSq(), 2*(mmp.x*cm.x + mmp.y*cm.y + mmp.z*cm.z), cm.magSq() - sq(radius+cylinderRadius), false);
        float l2 = solve(mmp.magSq(), 2*(mmp.x*cm.x + mmp.y*cm.y + mmp.z*cm.z), cm.magSq() - sq(radius+cylinderRadius), true);
        float l = (abs(l1) <= abs(l2)) ? l1 : l2;
        
        PVector oldLoc = location.get();
        //on le place contre la sphere
        location = PVector.add(m, PVector.mult(mmp, l) );
        
        //on calcule la normale de la collision (obstacle -> mover)
        PVector n = location.get();
        n.sub(c);
        n.normalize();
        
        /* debug: le probleme vient lorsqu'il y a 2 collision la même frame.
        if(location.dist(oldLoc)>10)
          println("--- ENORME ------------------------------------------------------------");
        println("jump:    "+location.dist(oldLoc));
        println("from:    "+oldLoc);
        println("to:      "+location);
        println("obstacle pos,rayon : "+c+", "+cylinderRadius);
        println("jump:    "+PVector.sub( location, oldLoc ));
        println("vitesse: "+velocity+"\n");
        if ( estContre(c, cylinderRadius, n, empietement) )
          println("contre!");*/
          
          
        //on update la vitesse
        if ( estContre(c, cylinderRadius, n, empietement) ) {
          //on considère le mover comme contre la sphere.
          //on annule sa vitesse normale (dirigée contre l'obstacle)
          //V' = V − (V · n)n
          velocity.add( PVector.mult(n, velocity.get().dot(n)) );
        } else {
          //il y a collision, la balle rebondit
          //V' = V − 2(V·n)n
          velocity.sub( PVector.mult(n, velocity.dot(n)*2) );
          //si on perd l'energie au choc
          if (perteEnergieApresChocActivee)
            perdEnergie(velocity, ratioEnergieApresChoc);
        }
      }
    }
  }
  
  // find an x for ax^2 + bx + c = 0
  float solve(float a, float b, float c, boolean biggerAnsw) {
    float dis = b*b - 4*a*c;
    float disSqrt = sqrt(dis); //lancera une exception si (dis < 0)
    int sgn = (biggerAnsw) ? 1 : -1;
    return (-b + sgn*disSqrt) / (2*a);
  }
  
  
  
  //retourne true si le mover est contre le cercle (sphere) (par empiètement et vitesse contre faible)
  //la normale de la collision.
  boolean estContre(PVector v, float r, PVector normale, float empietement) {
    return  empietement <= empietementMaxContre &&
            this.velocity.dot(normale) <= vitesseMaxContre;
  }
  
  //utilise x and z, centre de 2 spheres et leurs rayons
  boolean collide2D(PVector p1, float r1, PVector p2, float r2) {
    PVector v = p1.get();
    v.sub(p2);
    v.y = 0;
    return v.magSq() <= (r1+r2)*(r1+r2);
  }
  
  //retourne une vitesse amortie. prend un vecteur vitesse et le ration de restitution de l'energie après le choc.
  void perdEnergie(PVector vitesse, float ratioRestitution) {
    float nv = sqrt(vitesse.magSq() * ratioRestitution);
    vitesse.limit(nv);
  }
}
