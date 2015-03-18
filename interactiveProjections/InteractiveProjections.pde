// --- code of week 2

class My2DPoint {
  float x,y;
  My2DPoint(float x, float y) {
    this.x = x;
    this.y = y;
  }
}

class My3DPoint {
  float x,y,z;
  My3DPoint(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
}

My2DPoint projectPoint(My3DPoint eye, My3DPoint p) 
{
  My3DPoint tp = new My3DPoint(
      (p.x-eye.x),
      (p.y-eye.y), 
      (p.z-eye.z)
    );
    
  float f = -eye.z;
  
  return new My2DPoint(tp.x*f/tp.z, tp.y*f/tp.z);
}

class My2DBox {
  My2DPoint[] s;
  My2DBox(My2DPoint[] s) {
    this.s = s;
  }
  
  void render() 
  {
    //fill(color(204, 153, 0));
    stroke(0,255, 0);
    rendCarre(s, 0);
    stroke(255, 0, 0);
    rendCarre(s, 4);
    stroke(0,0,255);
    rendLien(s);
  }
  
  void rendCarre(My2DPoint[] s, int offset)
  {
    for (int i=offset; i<offset+4; i++)
    {
      int t = (i+1)%(4)+offset;
      line(s[i].x, s[i].y, s[t].x, s[t].y);
    }
  }
  
  void rendLien(My2DPoint[] s)
  {
    for (int i=0; i<4; i++)
    {
      int t = (i+4)%8;
      line(s[i].x, s[i].y, s[t].x, s[t].y);
      
    }
  }
  
}

class My3DBox {
  My3DPoint[] p;
  
  My3DBox(My3DPoint origin, float dimX, float dimY, float dimZ){
    float x = origin.x;
    float y = origin.y;
    float z = origin.z;
    this.p = new My3DPoint[]{
      new My3DPoint(x,y+dimY,z+dimZ),
      new My3DPoint(x,y,z+dimZ),
      new My3DPoint(x+dimX,y,z+dimZ),
      new My3DPoint(x+dimX,y+dimY,z+dimZ),
      new My3DPoint(x,y+dimY,z),
      origin,
      new My3DPoint(x+dimX,y,z),
      new My3DPoint(x+dimX,y+dimY,z)
    };
  }
  
  My3DBox(My3DPoint[] p) {
  this.p = p;
  }
}

My2DBox projectBox (My3DPoint eye, My3DBox box) {
  My2DPoint[] s = new My2DPoint[8];
  for (int i=0; i<8; i++)
  {
    s[i] = projectPoint(eye, box.p[i]);
  }
  return new My2DBox(s);
}

float[] homogeneous3DPoint (My3DPoint p) {
  float[] result = {p.x, p.y, p.z , 1};
  return result;
}

float[][] rotateXMatrix(float angle) {
  return(new float[][] {
    {1, 0 , 0 , 0},
    {0, cos(angle), sin(angle) , 0},
    {0, -sin(angle) , cos(angle) , 0},
    {0, 0 , 0 , 1}
  });
}

float[][] rotateYMatrix(float angle) {
  return(new float[][] {
    {cos(angle), 0 , sin(angle) , 0},
    {0, 1, 0 , 0},
    {-sin(angle), 0 , cos(angle) , 0},
    {0, 0 , 0 , 1}
  });
}
float[][] rotateZMatrix(float angle) {
  return(new float[][] {
    {cos(angle), -sin(angle) , 0, 0},
    {sin(angle) , cos(angle) , 0, 0},
    {0, 0 , 1 , 0},
    {0, 0 , 0 , 1}
  });
}

float[][] translationMatrix(float x, float y, float z) {
  return(new float[][] {
    {1, 0 , 0, x},
    {0 ,1 , 0, y},
    {0, 0 , 1 , z},
    {0, 0 , 0 , 1}
  });
}

float[][] scaleMatrix(float x, float y, float z) {
  return(new float[][] {
    {x, 0 , 0, 0},
    {0 ,y , 0, 0},
    {0, 0 , z , 0},
    {0, 0 , 0 , 1}
  });
}

float[] matrixProduct(float[][] a, float[] b) {
  float[] p = new float[4];
  for (int i=0; i<4; i++)
  {
    for (int j=0; j<4; j++)
    {
      p[i] += a[i][j]*b[j];
    }
  }
 return p;
}

My3DPoint euclidian3DPoint (float[] a) {
  My3DPoint result = new My3DPoint(a[0]/a[3], a[1]/a[3], a[2]/a[3]);
  return result;
}

My3DBox transformBox(My3DBox box, float[][] transformMatrix) {
  My3DPoint[] n = new My3DPoint[8];
  for (int i=0; i<8; i++)
  {
    n[i] = euclidian3DPoint( matrixProduct(transformMatrix, homogeneous3DPoint(box.p[i]) ) );
  }
  return new My3DBox(n);
}

// --- WEEK 3
// --- PART I

float angleX = 0;
float angleY = 0;
//float scale = 1;

void mouseDragged()
{
  //scale += 0.1*(mouseY-pmouseY);
  
  //angleX += PI*(mouseY-pmouseY)/64;
  //angleY += PI*(mouseX-pmouseX)/64;
}
 // for part I

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      angleX += PI/8;
    } else if (keyCode == DOWN) {
      angleX -= PI/8;
    } 
    
    if (keyCode == LEFT) {
      angleY += PI/8;
    } else if (keyCode == RIGHT) {
      angleY -= PI/8;
    }
  }
}


void setup () {
  size(1000,1000);
}

void draw() {
  background(255, 150, 150);
  My3DPoint eye = new My3DPoint(0, 0, -5000);
  My3DPoint origin = new My3DPoint(0, 0, 0);
  My3DBox input3DBox = new My3DBox(origin, 100, 150, 300);
    
  //rotate
  input3DBox = transformBox(input3DBox, rotateXMatrix(angleX) );
  input3DBox = transformBox(input3DBox, rotateYMatrix(angleY) );
  //rotated and translated
  input3DBox = transformBox(input3DBox, translationMatrix(200, 200, 0) );
  //rotated, translated, and scaled
  input3DBox = transformBox(input3DBox, scaleMatrix(2, 2, 2) );
  
  //render box
  projectBox(eye, input3DBox).render();
}

// --- PART 2
/*
float depth = 2000;

void setup() 
{
  size(500, 500, P3D);
  noStroke();
}

//step 2-3
void draw() {
  background(200);
  lights();
  camera(mouseX, mouseY, 450, 250, 250, 0, 0, 1, 0);
  translate(width/2, height/2, 0);
  rotateX(PI/8);
  rotateY(PI/8);
  box(100, 80, 60);
  translate(100, 0, 0);
  sphere(50);
}

void draw() {
  camera(width/2, height/2, depth, 250, 250, 0, 0, 1, 0);
  directionalLight(50, 100, 125, 0, -1, 0);
  ambientLight(102, 102, 102);
  background(200);
  translate(width/2, height/2, 0);
  float rz = map(mouseY, 0, height, 0, PI);
  float ry = map(mouseX, 0, width, 0, PI);
  rotateZ(rz);
  rotateY(ry);
  for (int x = -2; x <= 2; x++) {
    for (int y = -2; y <= 2; y++) {
      for (int z = -2; z <= 2; z++) {
        pushMatrix();
        translate(100 * x, 100 * y, -100 * z);
        box(50);
        popMatrix();
      }
    }
  }
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      depth -= 50;
    }
    else if (keyCode == DOWN) {
      depth += 50;
    }
  }
}*/
