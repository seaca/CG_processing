// ray-tracing

class Ball{
  PVector pos;
  float rad;
  color col;
  float orbR;
  float th, rotVel;
}

Ball[] balls = new Ball[6];
PVector camPos, lightPos, rayDst;
void setup(){
  for (int i=0; i<balls.length; i++) balls[i] = new Ball();
  size(640, 480, P3D);
  balls[0].pos = new PVector(0,0,0);
  balls[0].orbR = 0;
  balls[0].rad = 30;
  balls[0].th = TWO_PI/3*1;
  balls[0].rotVel = 0;
  balls[0].col = color(#ff6600);
  balls[1].pos = new PVector(0,0,0);
  balls[1].orbR = 50;
  balls[1].rad = 5;
  balls[1].th = TWO_PI/4*1;
  balls[1].rotVel = PI/40;
  balls[1].col = color(#ddddee);
  balls[2].pos = new PVector(0,0,0);
  balls[2].orbR = 70;
  balls[2].rad = 8;
  balls[2].th = TWO_PI/5*9;
  balls[2].rotVel = PI/60;
  balls[2].col = color(#dddd00);
  balls[3].pos = new PVector(0,0,0);
  balls[3].orbR = 90;
  balls[3].rad = 8;
  balls[3].th = TWO_PI/2*6;
  balls[3].rotVel = PI/80;
  balls[3].col = color(#0000ff);
  balls[4].pos = new PVector(0,0,0);
  balls[4].orbR = 110;
  balls[4].rad = 5;
  balls[4].th = TWO_PI/5*3;
  balls[4].rotVel = PI/100;
  balls[4].col = color(#dd8822);
  balls[5].pos = new PVector(0,0,0);
  balls[5].orbR = 140;
  balls[5].rad = 15;
  balls[5].th = TWO_PI/5*8;
  balls[5].rotVel = PI/120;
  balls[5].col = color(#aa8888);
  camPos = new PVector(0,100,200);
  // cam direction is fixed on X-Y plane
  lightPos = new PVector(0,100,0);
}

float intersec(PVector rayDst, PVector rayDir, Ball ball){
  PVector tmpVec;
  float proj, tmp;
  float dist = -1;
  
  tmpVec = PVector.sub(rayDst, ball.pos);
  proj = tmpVec.dot(rayDir);
  tmp = tmpVec.dot(tmpVec) - sq(ball.rad);
  if (sq(proj) > tmp){
    dist = proj - sqrt(sq(ball.rad) - (tmpVec.dot(tmpVec) - sq(proj)));
  }
  return dist;
}

color getRayCol(PVector pos, PVector dir, float eng){
  int i, tgt = -1;
  float dist = 1, minDist=1e6;
  PVector normal = new PVector();
  PVector lightDir = new PVector();
  PVector intersecPos = new PVector();
 
  for (i=0; i<balls.length; i++){
    dist = intersec(pos, dir, balls[i]);
    if (dist > 0 && dist < minDist){
      minDist = dist;
      tgt = i;
    }
  }
  dist = minDist;
  float objr=0, objg=0, objb=0;
  if (tgt == -1){
    // checker tiled floor
    if (dir.y > 0){
      dist = abs((pos.y-(-50))/dir.y);
      intersecPos.x = pos.x - dist*dir.x;
      intersecPos.y = -50;
      intersecPos.z = pos.z - dist*dir.z;
      if (abs(intersecPos.x)<300 && abs(intersecPos.z)<300){
        if ((floor(intersecPos.x/50)+floor(intersecPos.z/50)) % 2 == 0){
          objr = objg = objb = 160;
        } else {
          objr = objg = objb = 200;
        }
      }
      lightDir = PVector.sub(lightPos,intersecPos).normalize();      
      normal = new PVector(0,1,0);
    }
  } else {
    // ball
    intersecPos = PVector.sub(pos, PVector.mult(dir, dist));
    objr = red(balls[tgt].col);
    objg = green(balls[tgt].col);
    objb = blue(balls[tgt].col);
    lightDir = PVector.sub(lightPos, intersecPos).normalize();
    normal = PVector.sub(intersecPos, balls[tgt].pos).normalize();
  }
  // get color
  float r=0,g=0,b=0;
  float cosTh;
  cosTh = max(PVector.dot(lightDir, normal),0);
  r = objr*(cosTh/sq(dist/150)+0.3); g = objg*(cosTh/sq(dist/150)+0.3); b = objb*(cosTh/sq(dist/150)+0.3);
  return color(min(255,r),min(255,g),min(255,b));
}

void draw(){
  for (Ball ball:balls){
    if ((ball.th += ball.rotVel) > TWO_PI) ball.th -= TWO_PI;
    ball.pos.x = ball.orbR * cos(ball.th);
    ball.pos.z = ball.orbR * sin(ball.th);
  }
  loadPixels();
  for (int i=0; i<width; i++){
    float x = (i - width/2);
    for (int j=0; j<height; j++){
      float y = -(j - height/2);
      float rayEng = 1.0;
      PVector rayDir = new PVector(camPos.x - x, camPos.y - y, camPos.z - 0).normalize();
      pixels[i+j*width] = getRayCol(camPos, rayDir,  1.0);
    }
  }
  updatePixels();
  saveFrame("frame/#####.tif");
//  noLoop();
}