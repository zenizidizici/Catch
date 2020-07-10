import ddf.minim.*;

Minim minim;
AudioPlayer small;
AudioPlayer medium;
AudioPlayer large;
AudioPlayer bgm;
AudioPlayer drop;
AudioPlayer badEnd;
AudioPlayer goodEnd;
AudioPlayer greatEnd;

//PVector location;
//PVector velocity;
//PVector gravity;

//UI
//score
int score = 0;
//timer
String timer = "60";
int time;
int interval = 60;

//platform
float platformY = 725;
float platformWidth = 250;
float platformHeight = 50;

boolean red = true;
boolean green = true;
boolean blue = true;

//balls
float[] ballX = {0,0,0,0};
float[] ballY = {-10, -210, -410, -610};

float[] ballDiameter = {0,0,0,0};

float fallSpeed;  
float[] direction = {1,1,1,1};

boolean reset = false;

void setup(){
  size(1280, 800); //screen resolution
  rectMode(CENTER); //centres control of platform
    
  minim = new
  Minim(this);
  
  score = 0;
  timer = "60";
  time = 60;
  interval = 60;
   
  small = minim.loadFile("small.wav");
  medium = minim.loadFile("medium.wav");
  large = minim.loadFile("large.wav");
  bgm = minim.loadFile("bgm.mp3");
  drop = minim.loadFile("splashu.wav");
  badEnd = minim.loadFile("fail.mp3");
  goodEnd = minim.loadFile("good.mp3");
  greatEnd = minim.loadFile("great.mp3");
   
  //location = new PVector(100,100);
  //velocity = new PVector(0,2.1);
  //gravity = new PVector(0,0.2);
  
  for(int i = 0; i < 4; i++)
  {
    ballX[i] = randomPosition();
  
    ballDiameter[i] = randomDiameter();
  }
  
  bgm.play();
  //text
  textSize(32);
  
  frameRate(60);
  noStroke();
  smooth();
}

void draw(){  
  background(0); //background black
  
  //location.add(velocity);
  //velocity.add(gravity);
  
  float platformX = constrain(mouseX, 125, width - 125); //restrict platform to the screen

  fill(getColour(red),getColour(green),getColour(blue));
  rect(platformX, platformY, platformWidth, platformHeight); //platform 
  fill(255);
  
  //balls
  fallSpeed = 10;
  //location.add(velocity);
  //velocity.add(gravity);
  
  for(int i = 0; i < 4; i++)
  {
    ballY[i] += fallSpeed * direction[i]; 
  }
  
  fill(setColourRed(ballDiameter[0]),setColourGreen(ballDiameter[0]),setColourBlue(ballDiameter[0]));  
  ellipse(ballX[0], ballY[0], ballDiameter[0], ballDiameter[0]);
  fill(setColourRed(ballDiameter[1]),setColourGreen(ballDiameter[1]),setColourBlue(ballDiameter[1]));  
  ellipse(ballX[1], ballY[1], ballDiameter[1], ballDiameter[1]);
  fill(setColourRed(ballDiameter[2]),setColourGreen(ballDiameter[2]),setColourBlue(ballDiameter[2]));  
  ellipse(ballX[2], ballY[2], ballDiameter[2], ballDiameter[2]);
  fill(setColourRed(ballDiameter[3]),setColourGreen(ballDiameter[3]),setColourBlue(ballDiameter[3]));  
  ellipse(ballX[3], ballY[3], ballDiameter[3], ballDiameter[3]);
  fill(255);
  
  //if(location.y > height)
  //{
    //velocity.y = velocity.y * -0.95;
    //velocity.y = height; 
  //}
  
  for(int j = 0; j < 4; j++)
  {
    if(ballY[j] < height/2 - 100 && ballDiameter[j] == 30 || ballY[j] < height/2 && ballDiameter[j] == 60)
    {
      direction[j] = 1; 
    }
    boolean collision = ballCollision(ballX[j], ballY[j], platformX, ballDiameter[j]);
    if(collision){
      if(ballDiameter[j] == 30) //small -> recycle ball to use
      {
         medium.rewind();
         medium.play();
         ballX[j] = randomPosition();
         ballY[j] = -10;
         ballDiameter[j] = randomDiameter();
         reset = true;
      }
      else if(ballDiameter[j] == 90 && !(reset)) //large -> medium
      {
        large.rewind();
        medium.play();
        direction[j] = -1;
        ballDiameter[j] = 60;
        
      }
      else if(ballDiameter[j] == 60 && !(reset)) //medium -> small
      {
        small.rewind();
        small.play();
        direction[j] = -1;
        ballDiameter[j] = 30;
      }
      red = false;
      green = true;
      blue = false;
    }
    if(ballY[j] >= height)
    {
      drop.rewind();
      drop.play();
      red = true;
      green = false;
      blue = false;
      ballX[j] = randomPosition();
      ballY[j] = -10;
      ballDiameter[j] = randomDiameter();
    }
  }
    
  text("Score: " + score, 50, 50);
  
  //timer
  time = interval - int(millis()/1000);
  timer = nf(time, 2);
  text("Time Left: " + timer, 1025, 50);
  if(time == 0)
  {
    bgm.pause();
    String result;
    String message;
    textAlign(CENTER);
    textSize(64);
    if(score <= 120)
    {
      badEnd.play();
      fill(255,0,0);
      result = "Poor";
      message = "Better luck next time";
    }
    else if(score > 120 && score <= 145)
    {
      goodEnd.play();
      fill(255,255,0); 
      result = "Good";
      message = "Well done";
    }
    else
    {
      greatEnd.play();
      fill(0,255,0); 
      result = "Amazing";
      message = "Exceptional performance";
    }
    //end.play();
    text("GAME OVER", width/2, height/2 - 64);
    textSize(32);
    text("Performance: " + result, width/2, height/2);
    text(message + "!", width/2, height/2 + 64);
    noLoop();
    //reset();
  }
}

float randomPosition(){
  return random(20, width - 20);
}

float randomDiameter(){
  float size[] = {30,60,90};
  int rand = (int)random(0,3);
  return size[rand];
}

boolean ballCollision(float ballX, float ballY, float platformX, float ballDiameter){
  //ball + platform collision
  float platformCollision = height - platformHeight - ballDiameter - 10;
  if(ballY == platformCollision && ballX > platformX - platformWidth/2 && ballX < platformX + platformWidth/2){
    //change ball size on bounce
    reset = false;
    score++;
    return true;
  }  
  return false;
}

int getColour(boolean on)
{
  if(on)
    return 255;
  return 0;
}

int setColourRed(float size)
{
  if(size == 30)
    return 179;  
  else if(size == 60)
    return 77;
  else
    return 0;
}

int setColourGreen(float size)
{
  if(size == 30)
    return 212;
  else if(size == 60)
    return 154;
  else
    return 71;
}

int setColourBlue(float size)
{
  if(size == 30)
    return 255;
  else if(size == 60)
    return 255;
  else
   return 179; 
}
