import processing.pdf.*;
import toxi.geom.*;

//import toxi.processing.*;

//ArrayList topLevelTris;
Isotri originalTri;
PImage img;

void setup(){
  size(1200, 800);
  background(255);
  smooth();
  
  img=loadImage("bubbles.jpg"); 

  float newSize = 3000;
  float triHeight =  (float)Math.sqrt((newSize * newSize) - (newSize / 2)*(newSize/2));   
  Tripoint mid = new Tripoint(width/2, height/2 - 2000);
  originalTri = new Isotri(mid, newSize, true);
   beginRecord(PDF, "01.pdf"); 
}

void draw(){
}

void mouseMoved(){
  //check to see if mouse is over a top level tri.
  Vec2D mouseVec = new Vec2D(mouseX, mouseY);
  if(isPointInTri(mouseVec, originalTri)){
      originalTri.clicked(mouseVec);
  }
}

void mousePressed(){
  endRecord();
}

/*
Function to detect if a given point is within the bounds of a given triangle
*/
boolean isPointInTri(Vec2D mouseVec, Isotri currentTri){

 Vec2D a = new Vec2D(0,0);
 Vec2D b = new Vec2D(0,0);
 Vec2D c = new Vec2D(0,0);
 
 if(currentTri.pointUp){
    a = new Vec2D(currentTri.originPoint.x, currentTri.originPoint.y);
    b = new Vec2D((float) Math.cos(degreesToRadians(60))*currentTri.sideLength + currentTri.originPoint.x, (float) Math.sin(degreesToRadians(60))*currentTri.sideLength + currentTri.originPoint.y);
    c = new Vec2D((float) Math.cos(degreesToRadians(120))*currentTri.sideLength + currentTri.originPoint.x, (float) Math.sin(degreesToRadians(120))*currentTri.sideLength + currentTri.originPoint.y);
 }else{ 
   a = new Vec2D(currentTri.originPoint.x  - (currentTri.sideLength/2), currentTri.originPoint.y);
   b = new Vec2D( (float) Math.cos(degreesToRadians(0))*currentTri.sideLength + (currentTri.originPoint.x - currentTri.sideLength/2), (float) Math.sin(degreesToRadians(0))*currentTri.sideLength + currentTri.originPoint.y);
   c = new Vec2D( (float) Math.cos(degreesToRadians(60))*currentTri.sideLength + (currentTri.originPoint.x - currentTri.sideLength/2), (float) Math.sin(degreesToRadians(60))*currentTri.sideLength + currentTri.originPoint.y);
 }
   if(mouseVec.isInTriangle(a,b,c)){
     return true;
   }
   else{
    return false; 
   }
}

double degreesToRadians(float degIn){
  double output = (degIn*Math.PI)/180;
  return output;
}
  
  
/*
Subdividing triangle class
*/
class Isotri{
  Tripoint originPoint;
  float sideLength;
  float triHeight;
  boolean isSubdivided = false;
  ArrayList directDescendents;
  boolean pointUp;
  
  Isotri(Tripoint tOriginPoint, float tSideLength, boolean tPointUp){
    directDescendents = new ArrayList();
    pointUp = tPointUp;
    originPoint = tOriginPoint;
    println(originPoint);
    sideLength = tSideLength;
    triHeight = calcTriHeight(sideLength/2);
    draw();
  } 
  
  float calcTriHeight(float _sideLength){
    float triHeight = (float)Math.sqrt((_sideLength * _sideLength) - (_sideLength / 2)*(_sideLength/2));
    return triHeight;
  }
  
  void clicked(Vec2D mouseVec){
    //drill down till not in subdivided triangle.
    if(this.isSubdivided){
      for(int i = 0; i < this.directDescendents.size(); i++){
        Isotri currentTri = (Isotri) this.directDescendents.get(i);
        if(isPointInTri(mouseVec, currentTri)){
           currentTri.clicked(mouseVec); 
          // println(currentTri);
        }
      }
    //if un subdivided, subdivide.
    }else{
     this.subdivide();
    }
  }
  
  void draw(){
    float angle;
   // float newHeight = triHeight;
    
    // draw a triangle pointing up
    if(pointUp){
      fill(img.get(int(this.originPoint.x), int(this.originPoint.y)));
      noStroke();
      triangle(
         originPoint.x, originPoint.y,
         (float) Math.cos(degreesToRadians(60))*sideLength + originPoint.x, (float) Math.sin(degreesToRadians(60))*sideLength + originPoint.y,
         (float) Math.cos(degreesToRadians(120))*sideLength + originPoint.x, (float) Math.sin(degreesToRadians(120))*sideLength + originPoint.y
       ); 
     }
     
     //draw triangle pointing down
     else{
       fill(img.get(int(this.originPoint.x), int(this.originPoint.y)));
       noStroke();
      
       triangle(
         originPoint.x - (sideLength/2), originPoint.y,
         (float) Math.cos(degreesToRadians(0))*sideLength + (originPoint.x - sideLength/2), (float) Math.sin(degreesToRadians(0))*sideLength + originPoint.y,
         (float) Math.cos(degreesToRadians(60))*sideLength + (originPoint.x - sideLength/2), (float) Math.sin(degreesToRadians(60))*sideLength + originPoint.y
        );       
     }
     
  }
  
  void subdivide(){
    //create 4 new traingles within current tri.
    this.isSubdivided = true;
    float newSize = this.sideLength/2;
    
    if(this.pointUp){
      directDescendents.add(new Isotri(new Tripoint(originPoint.x, originPoint.y), newSize, true));
      directDescendents.add(new Isotri(new Tripoint(originPoint.x, originPoint.y + triHeight), newSize, false));
      directDescendents.add(new Isotri(new Tripoint(originPoint.x+(newSize/2), originPoint.y + triHeight), newSize, true));
      directDescendents.add(new Isotri(new Tripoint(originPoint.x-(newSize/2), originPoint.y + triHeight), newSize, true));
    }
    else{
     directDescendents.add(new Isotri(new Tripoint(originPoint.x, originPoint.y+triHeight), newSize, false));
      directDescendents.add(new Isotri(new Tripoint(originPoint.x, originPoint.y), newSize, true));
      directDescendents.add(new Isotri(new Tripoint(originPoint.x+(newSize/2), originPoint.y), newSize, false));
      directDescendents.add(new Isotri(new Tripoint(originPoint.x-(newSize/2), originPoint.y), newSize, false));
    }
  };
}
  
class Tripoint{
   float x;
   float y;  
   Tripoint(float tx, float ty){
     x = tx;
     y = ty;
   }
}
