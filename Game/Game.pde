float camEloignement = 600;
float camHauteur = 150;
float platXRotation = 0;
float platYRotation = 0;
float platZRotation = 0;
float tiltSpeed = 1;
float tiltMaxAngle = PI/6;
float gravityConstant = 2;
float tailleTerrainX = 300;
float tailleTerrainZ = 300;

Mover mover;

void setup() 
{
  size(500, 500, P3D);
  noStroke();
  mover = new Mover();
}

void draw() {
  camera(0, camHauteur, camEloignement, 0, 0, 0, 0, -1, 0);
  directionalLight(50, 100, 125, 0, -1, 0);
  ambientLight(102, 102, 102);
  background(200);
  
  rotateY(platYRotation);
  rotateX(platXRotation);
  rotateZ(platZRotation);
  
  fill(200);
  box(tailleTerrainX, 20, tailleTerrainZ);
  
  mover.update();
  mover.display();
}


void mouseDragged()
{
  platXRotation = bound( platXRotation + tiltSpeed*(mouseY-pmouseY)/64 , -tiltMaxAngle, tiltMaxAngle);
  platZRotation = bound( platZRotation + tiltSpeed*(mouseX-pmouseX)/64 , -tiltMaxAngle, tiltMaxAngle);
}

void mouseWheel(MouseEvent event) {
  float delta = - event.getCount(); //negatif si vers l'utilisateur
  tiltSpeed = bound( tiltSpeed + 0.05*delta , 0.2, 2 );
}

void keyPressed() {
  if (key != CODED) 
    return ;
    
  if (keyCode == LEFT) {
    platYRotation -= PI/8;
  }
  else if (keyCode == RIGHT) {
    platYRotation += PI/8;
  }
}


//bound f to be at min. min and at max. max :)
float bound(float f, float min, float max)
{
  return constrain(f, min, max);
  /*if (f < min)
    return min;
  if (f > max)
    return max;
  return f;*/
}
