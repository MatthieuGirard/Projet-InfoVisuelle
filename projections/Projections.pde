// --- PART I

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

// for part 1
/*
void setup() {
  size(400, 400);
}
void draw() {
  My3DPoint eye = new My3DPoint(-100, -100, -5000);
  My3DPoint origin = new My3DPoint(0, 0, 0); //The first vertex of your cuboid
  My3DBox input3DBox = new My3DBox(origin, 100,150,300);
  projectBox(eye, input3DBox).render();
}*/

// ---PART II

float[] homogeneous3DPoint (My3DPoint p) {
  float[] result = {p.x, p.y, p.z , 1};
  return result;
}

float[][] rotateXMatrix(float angle) {
  return(new float[][] {
    {1, 0 , 0 , 0},
    {0, cos(angle), -sin(angle) , 0},
    {0, sin(angle) , cos(angle) , 0},
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

void setup () {
  size(1000,1000);
}

void draw() {
  background(255, 255, 150);
  My3DPoint eye = new My3DPoint(0, 0, -50);
  My3DPoint origin = new My3DPoint(0, 0, 0);
  My3DBox input3DBox = new My3DBox(origin, 100, 150, 300);
  
  
  //projectBox(eye, input3DBox).render();
  
  //rotated around x
  input3DBox = transformBox(input3DBox, rotateXMatrix(PI/8) );
  projectBox(eye, input3DBox).render();
  
  //rotated and translated
  input3DBox = transformBox(input3DBox, translationMatrix(100, 100, 0) );
  projectBox(eye, input3DBox).render();
  
  //rotated, translated, and scaled
  input3DBox = transformBox(input3DBox, scaleMatrix(2, 2, 2) );
  projectBox(eye, input3DBox).render();
}


