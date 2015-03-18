//-- parametres
float cylinderRadius = 20;  //radius
float cylinderHeight = 30;    
int cylinderResolution = 42;  //# point

  
//-- interne
PShape cylinder;
ArrayList<PVector> cylindersPos = new ArrayList();

void mouseReleased() {
  if (mode == Mode.Controle) {
    //nouveau cylindre ! :D
    //on trouve la position sur l'ecran (en pixel) de l'extrêmité du terrain
    PVector pos3D = new PVector(-tailleTerrainX, 0, tailleTerrainZ);
    PVector pos2D = new PVector( screenX(pos3D.x, pos3D.y, pos3D.z), screenY(pos3D.x, pos3D.y, pos3D.z) );
    PVector pos2DCentre = new PVector( pos2D.x - width/2, pos2D.y - height/2 );
    //on trouve l'échelle du terrain sur l'écran (par rapport au centre de l'écran)
    PVector echelle = new PVector( tailleTerrainX/pos2DCentre.x, tailleTerrainZ/pos2DCentre.y );
    PVector newCylinderPos = new PVector( -(mouseX - width/2)*echelle.x , 0, (mouseY - height/2)*echelle.y );
    
    //on l'ajoute uniquement s'il est sur le terrain
    if (standInTerrain2D(newCylinderPos))
      cylindersPos.add(newCylinderPos);
  }
}

//over x and z coordonate
boolean standInTerrain2D(PVector pos) {
  return standIn2D(pos, -tailleTerrainX/2, tailleTerrainX/2, -tailleTerrainZ/2, tailleTerrainZ/2);
}
//over x and z coordonate
boolean standIn2D(PVector pos, float minX, float maxX, float minZ, float maxZ) {
  return pos.x == constrain(pos.x, minX, maxX) && pos.z == constrain(pos.z, minZ, maxZ);
}

void displayCylinders() {
  for (PVector v : cylindersPos) {
    printCylinder(v);
  }
}

void printCylinder(PVector cylinderPos) {
  pushMatrix();
    translate(cylinderPos.x, cylinderPos.y, cylinderPos.z);
    noStroke();
    fill(255, 255, 0);
    shape(cylinder);
  popMatrix();
}

void initCylinder() {
  //les points du cerlce du cylindre
  float angle;
  float[] x = new float[cylinderResolution + 1];
  float[] z = new float[cylinderResolution + 1];
  //get the x and y position on a circle for all the sides
  for(int i = 0; i < x.length; i++) {
    angle = (TWO_PI / cylinderResolution) * i;
    x[i] = sin(angle) * cylinderRadius;
    z[i] = cos(angle) * cylinderRadius;
  }
  
  //le tube
  PShape openCylinder = createShape();
  openCylinder.beginShape(QUAD_STRIP);
  for(int i = 0; i < x.length; i++) {
    openCylinder.vertex(x[i], 0, z[i]);
    openCylinder.vertex(x[i], cylinderHeight, z[i]);
  }
  openCylinder.endShape();
  
  //le fond (dessus)
  PShape topCylinder = createShape();
  topCylinder.beginShape(TRIANGLE_FAN);
  topCylinder.vertex(0, cylinderHeight, 0);
  for(int i = 0; i < x.length; i++) {
    topCylinder.vertex(x[i], cylinderHeight, z[i]);
  }
  topCylinder.endShape();
  
  //on groupe le tout en cylindre
  cylinder = createShape(GROUP);
  cylinder.addChild(topCylinder);
  cylinder.addChild(openCylinder);
}

//shape(openCylinder);
