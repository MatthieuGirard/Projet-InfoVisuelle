//--PARAMETRES
float tailleTerrainX = 400, tailleTerrainZ = 300, hauteurTerrain = 20;
float tiltSpeed = 1;
float pasRotY = PI/8; //le pas de rotation de l'angle y, en radian
//transition
float tempsTransition = 0.5;

//--INTERNE
float platXRotation = 0, platYRotation = 0, platZRotation = 0; // rotation du plateau
Mover mover = new Mover();
Mode mode = Mode.Jeu;
float etat = 0; //entre 0 (jeu) et 1 (controle)
boolean run = true;

void setup() 
{
  noStroke();
  int ratioSize = 3; //généralement de 2 (640x360) à 5 (1920x1080)
  size(16*20*ratioSize, 9*20*ratioSize, P3D);
  initCylinder();
}

void draw() 
{
  updateMode();
  placeCamEtLum();
  rotateScene();
  
  
  //le terrain
  fill(200);
  pushMatrix();
    translate(0, -hauteurTerrain/2, 0);
    box(tailleTerrainX, hauteurTerrain, tailleTerrainZ);
  popMatrix();
  
  //une boule
  if (run)
    mover.update();
  mover.display();
  
  //un cylindre
  displayCylinders();
}

void rotateScene() {
  //roation du plateau
  float ratioEtat = 1-etat; //pour forcer une rotation nulle en mode contrôle.
  rotateX(platXRotation * ratioEtat);
  rotateY(platYRotation * ratioEtat);
  rotateZ(platZRotation * ratioEtat);
}

void placeCamEtLum()
{ 
  //les 2 points; initial et final, de jeu et de controle.
  float jeuZ = 300, jeuY = 400;
  float contrZ = 1, contrY = 300;
  
  float decalageMil = 0.3; // le rapport entre
                         // la distance entre le point de jeu et celui de controle et
                         // la distance entre le point milieu et le centre de rotation.
  
  float milieuZ = (jeuZ+contrZ)/2, milieuY = (jeuY+contrY)/2;
  PVector pente = new PVector(0, contrZ-jeuZ, -(contrY-jeuY));
  float centreRotZ = milieuZ+decalageMil*pente.z,  centreRotY = milieuY+decalageMil*pente.y;
  float diffRotJeuZ = jeuZ-centreRotZ, diffRotJeuY = jeuY-centreRotY;
  float rayon = sqrt(diffRotJeuZ*diffRotJeuZ+diffRotJeuY*diffRotJeuY);
  float minAngle = acos((jeuZ-centreRotZ)/rayon);
  float maxAngle = acos((contrZ-centreRotZ)/rayon);
  
  float angle = minAngle + (maxAngle-minAngle)*etat;
  float posCamZ = centreRotZ+cos(angle)*rayon, posCamY = centreRotY+sin(angle)*rayon;
  camera(0, posCamY, posCamZ, 0, 0, 0, 0, -1, 0);
  
  /* debug
  println("pos cam Z,Y: "+posCamZ+", "+posCamY);
  println("centreRot Z,Y: "+centreRotZ+", "+centreRotY);
  println("angle sur x: "+angle+", rayon: "+rayon);*/
  
  //lum
  ambientLight(102, 102, 102);
  directionalLight(50, 100, 125, 0, -1, 0);
  
  //le bg
  background(200);
}


void mouseDragged()
{
  if (!run)
    return;
  
  float tiltMaxAngle = PI/6;
  
  platXRotation = constrain( platXRotation + tiltSpeed*(mouseY-pmouseY)/64 , -tiltMaxAngle, tiltMaxAngle);
  platZRotation = constrain( platZRotation + tiltSpeed*(mouseX-pmouseX)/64 , -tiltMaxAngle, tiltMaxAngle);
}

void mouseWheel(MouseEvent event) {
  float delta = - event.getCount(); //negatif si vers l'utilisateur
  tiltSpeed = constrain( tiltSpeed + 0.05*delta , 0.2, 2 );
}

void keyPressed() {
  if (key != CODED) 
    return ;
  
  //gauche droite: tourne la plaque  
  if (keyCode == LEFT) {
    platYRotation = entrePiEtMoinsPi(platYRotation - pasRotY);
  }
  else if (keyCode == RIGHT) {
    platYRotation = entrePiEtMoinsPi(platYRotation + pasRotY);
  }
  
  //shift: mode contrôle
  if (keyCode == SHIFT || keyCode == CONTROL) {
    switch (mode) {
      case Jeu:
      case TransDown:
        setModeTransition(true);
        break;
    }
  }
}  

float entrePiEtMoinsPi(float a) {
  if (a > PI) return a - TWO_PI;
  else if (a < -PI) return a + TWO_PI;
  else return a;
}

void keyReleased() {
  if (key != CODED) 
    return ;
  
  //shift: mode contrôle
  if (keyCode == SHIFT || keyCode == CONTROL) {
    switch (mode) {
      case Controle:
      case TransUp:
        setModeTransition(false);
        break;
    }
  }
}

void updateMode()
{
  //println("mode: "+mode);
  switch (mode) {
    case Jeu:
      break;
      
    case TransUp:
      etat = constrain(etat + 1.0/tempsTransition/25, 0, 1);
      if (etat >= 1)
        setModeControle();
      break;
      
    case Controle:
      break;
      
    case TransDown:
      etat = constrain(etat - 1.0/tempsTransition/25, 0, 1);
      if (etat <= 0)
        setModeJeu();
      break;
  }
}

void setModeJeu()
{
  mode = Mode.Jeu;
  run = true;
}

void setModeTransition(boolean versControle)
{
  if (versControle)
  {
    mode = Mode.TransUp;
  } else {
    mode = Mode.TransDown;
  }
  run = false;
}

void setModeControle()
{
  mode = Mode.Controle;
  run = false;
}
