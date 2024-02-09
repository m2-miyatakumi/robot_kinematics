
class Manipulator{
  int l_1 = 100;
  int w_1 = 20;
  int l_2 = 40;
  int w_2 = 20;
  int l_3 = 100;
  int w_3 = 20;
  int l_4 = 80;
  int w_4 = 20;
  int l_5 = 30;
  int w_5 = 10;
  float angle_1 = 0;
  float angle_2 = 0;
  float angle_3 = 0;
  float c_3 = 0;
  float s_3 = 0;
  float angle_4 = 0;
  float px, py, pz;
  boolean wall[][] = new boolean[7][5];
  
  Manipulator(){
    px = 0;
    py = 150;
    pz = 0;
    move(0, 100, 0);
  }
  
  void move(float new_Px, float new_Py, float new_Pz){
    px = new_Px;
    py = new_Py;
    pz = new_Pz;
    angle_1 = atan2(px, pz - l_1);
    c_3 = (pow(py - l_2, 2) + pow(px, 2) + pow(pz - l_1, 2) - pow(l_3, 2) - pow(l_4, 2)) / (2 * l_3 * l_4);
    s_3 = sqrt(1 - pow(c_3, 2));
    angle_3 = atan2(s_3, c_3);
    angle_2 = atan2((l_3 + c_3 * l_4) * px / sin(angle_1) - s_3 * l_4 * (py - l_2), s_3 * l_4 * px / sin(angle_1) + (l_3 + c_3 * l_4) * (py - l_2));
    angle_4 = - angle_2 - angle_3;
  }
  
  void displayArm(){
    pushMatrix();
    
    translate(0, 0, l_1/2);
    box(w_1, w_1, l_1);
    translate(0, 0, l_1/2);
    
    rotateY(angle_1);
    translate(0, l_2/2, 0);
    box(w_2, l_2, w_2);
    translate(0, l_2/2, 0);
    
    rotateX(angle_2);
    translate(0, l_3/2, 0);
    box(w_3, l_3, w_3);
    translate(0, l_3/2, 0);
    
    rotateX(angle_3);
    translate(0, l_4/2, 0);
    box(w_4, l_4, w_4);
    translate(0, l_4/2, 0);
    
    rotateX(angle_4);
    translate(0, l_5/2, 0);
    box(w_5, l_5, w_5);
    translate(0, l_5/2, 0);
    
    popMatrix();
  }
  
  void resetWall(){
    for (int x = 0; x < 5; x++){
      for (int z = 0; z < 7; z++){
        wall[z][x] = false;
      }
    }
  }
  
  void displayWall(){
    pushMatrix();
    translate(0, 200, 0);
    for (int x = 0; x < 5; x++){
      pushMatrix();
      for (int z = 0; z < 7; z++){
        if (((abs(px - x * 30) < 15) && (abs(pz - z * 30) < 15) && (py >= 160)) || (wall[z][x])){
          fill(0);
          wall[z][x] = true;
        }else{
          fill(255);
        }
        box(30, 30, 30);
        translate(0, 0, 30);
      }
      popMatrix();
      translate(30, 0, 0);
    }
    popMatrix();
  }
}

float camera_angle = 0;

Manipulator[] arms = new Manipulator[6];
Manipulator arm = new Manipulator();

void setup(){
  size(1200, 800, P3D);
  frameRate(100);
  for (int i = 0; i < 6; i++){
    arms[i] = new Manipulator();
  }
}

int i = 0;
float pt = 0;
int[] times = new int[] {1000, 10*1000, 60*1000, 60*10*1000, 60*60*1000, 60*60*10*1000};
int[] counts = new int[] {0, 0, 0, 0, 0, 0};

boolean auto = true;

void draw(){
  float t = millis();
  //println(t, pt);
  background(0);
  displayCoodinateAxis();
  stroke(128);
  
  if (keyPressed){
    if (key == 'a'){
      auto = true;
    }
    if (key == 'm'){
      auto = false;
    }
  }
  
  if (auto){
    camera(0, -500, 500, 0, 160, 0, 0, 0, -1);
    ArrayList<ArrayList<float[]>> paths = new ArrayList<ArrayList<float[]>>();
    paths.add(new ArrayList<float[]>(generatePath(int(t / 1000) % 10, 0.10, arms[0].px, arms[0].py, arms[0].pz)));
    paths.add(new ArrayList<float[]>(generatePath(int(t / (10*1000)) % 6, 0.3, arms[1].px, arms[1].py, arms[1].pz)));
    paths.add(new ArrayList<float[]>(generatePath(int(t / (60*1000)) % 10, 0.5, arms[2].px, arms[2].py, arms[2].pz)));
    paths.add(new ArrayList<float[]>(generatePath(int(t / (60*10*1000)) % 6, 1, arms[3].px, arms[3].py, arms[3].pz)));
    paths.add(new ArrayList<float[]>(generatePath(int(t / (60*60*1000)) % 10, 3, arms[4].px, arms[4].py, arms[4].pz)));
    paths.add(new ArrayList<float[]>(generatePath(int(t / (60*60*10*1000)) % 10, 5, arms[5].px, arms[5].py, arms[5].pz)));
    
    translate(-515, 0, 0);
    for (int n = 0; n < 6; n++){
      if (int(t / times[n]) - int(pt / times[n]) == 0){
        if (paths.get(n).size() > counts[n]){
          arms[n].move(paths.get(n).get(counts[n])[0], paths.get(n).get(counts[n])[1], paths.get(n).get(counts[n])[2]);
          counts[n]++;
        }
      }else{
        arms[n].resetWall();
        counts[n] = 0;
      }
      
      arms[n].displayArm();
      arms[n].displayWall();
      translate(180, 0, 0);
    }
  }else{
    camera(300*cos(camera_angle), 300*sin(camera_angle)+160, 300, 0, 160, 0, 0, 0, -1);
    if (keyPressed){
      if (key == 'r'){
        camera_angle += 0.05;
      }
      if (key == 'c'){
        arm.resetWall();
      }
      if (Character.isDigit(key)){
        ArrayList<float[]> path = generatePath(Character.getNumericValue(key), 0.2, arm.px, arm.py, arm.pz);
        if (path.size() > i){
          arm.move(path.get(i)[0], path.get(i)[1], path.get(i)[2]);
        }
      }
    }else{
      i = 0;
    }
    arm.displayArm();
    arm.displayWall();
    i++;
  }
  
  pt = t;
}

void displayCoodinateAxis(){
  stroke(255, 0, 0);
  line(0, 0, 0, 100, 0, 0);
  stroke(0, 255, 0);
  line(0, 0, 0, 0, 100, 0);
  stroke(0, 0, 255);
  line(0, 0, 0, 0, 0, 100);
}

ArrayList<float[]>  generatePath(int n, float s, float x, float y, float z){
  ArrayList<float[]> points = new ArrayList<float[]>();
  ArrayList<float[]> path = new ArrayList<float[]>();
  points.add(new float[] {x, y, z});
  if (n == 0){
    points.add(new float[] {30, 150, 150});
    points.add(new float[] {30, 160, 150});
    points.add(new float[] {90, 160, 150});
    points.add(new float[] {90, 160, 90});
    points.add(new float[] {90, 160, 30});
    points.add(new float[] {30, 160, 30});
    points.add(new float[] {30, 160, 90});
    points.add(new float[] {30, 160, 150});
    points.add(new float[] {30, 150, 150});
  }
  if (n == 1){
    points.add(new float[] {30, 150, 150});
    points.add(new float[] {30, 160, 150});
    points.add(new float[] {30, 160, 90});
    points.add(new float[] {30, 160, 30});
    points.add(new float[] {30, 150, 30});
  }
  if (n == 2){
    points.add(new float[] {90, 150, 150});
    points.add(new float[] {90, 160, 150});
    points.add(new float[] {30, 160, 150});
    points.add(new float[] {30, 160, 90});
    points.add(new float[] {90, 160, 90});
    points.add(new float[] {90, 160, 30});
    points.add(new float[] {30, 160, 30});
    points.add(new float[] {30, 150, 30});
  }
  if (n == 3){
    points.add(new float[] {90, 150, 150});
    points.add(new float[] {90, 160, 150});
    points.add(new float[] {30, 160, 150});
    points.add(new float[] {30, 160, 90});
    points.add(new float[] {90, 160, 90});
    points.add(new float[] {30, 160, 90});
    points.add(new float[] {30, 160, 30});
    points.add(new float[] {90, 160, 30});
    points.add(new float[] {90, 150, 30});
  }
  if (n == 4){
    points.add(new float[] {90, 150, 150});
    points.add(new float[] {90, 160, 150});
    points.add(new float[] {90, 160, 90});
    points.add(new float[] {30, 160, 90});
    points.add(new float[] {30, 160, 150});
    points.add(new float[] {30, 160, 90});
    points.add(new float[] {30, 160, 30});
    points.add(new float[] {30, 150, 30});
  }
  if (n == 5){
    points.add(new float[] {30, 150, 150});
    points.add(new float[] {30, 160, 150});
    points.add(new float[] {90, 160, 150});
    points.add(new float[] {90, 160, 90});
    points.add(new float[] {30, 160, 90});
    points.add(new float[] {30, 160, 30});
    points.add(new float[] {90, 160, 30});
    points.add(new float[] {90, 150, 30});
  }
  if (n == 6){
    points.add(new float[] {30, 150, 150});
    points.add(new float[] {30, 160, 150});
    points.add(new float[] {90, 160, 150});
    points.add(new float[] {90, 160, 90});
    points.add(new float[] {90, 160, 30});
    points.add(new float[] {30, 160, 30});
    points.add(new float[] {30, 160, 90});
    points.add(new float[] {90, 160, 90});
    points.add(new float[] {90, 150, 90});
  }
  if (n == 7){
    points.add(new float[] {90, 150, 150});
    points.add(new float[] {90, 160, 150});
    points.add(new float[] {30, 160, 150});
    points.add(new float[] {30, 160, 90});
    points.add(new float[] {30, 160, 30});
    points.add(new float[] {30, 150, 30});
  }
  if (n == 8){
    points.add(new float[] {30, 150, 150});
    points.add(new float[] {30, 160, 150});
    points.add(new float[] {90, 160, 150});
    points.add(new float[] {90, 160, 90});
    points.add(new float[] {30, 160, 90});
    points.add(new float[] {30, 160, 30});
    points.add(new float[] {90, 160, 30});
    points.add(new float[] {90, 160, 90});
    points.add(new float[] {30, 160, 90});
    points.add(new float[] {30, 160, 150});
    points.add(new float[] {30, 150, 150});
  }
  if (n == 9){
    points.add(new float[] {30, 150, 150});
    points.add(new float[] {30, 160, 150});
    points.add(new float[] {90, 160, 150});
    points.add(new float[] {90, 160, 90});
    points.add(new float[] {30, 160, 90});
    points.add(new float[] {30, 160, 150});
    points.add(new float[] {30, 160, 90});
    points.add(new float[] {30, 160, 30});
    points.add(new float[] {90, 160, 30});
    points.add(new float[] {90, 150, 30});
  }
  
  for (int i = 1; i < points.size(); i++){
    for (int j = 0; j < frameRate * s; j++){
      float dx = (points.get(i)[0] - points.get(i - 1)[0]) / (frameRate * s) * j;
      float dy = (points.get(i)[1] - points.get(i - 1)[1]) / (frameRate * s) * j;
      float dz = (points.get(i)[2] - points.get(i - 1)[2]) / (frameRate * s) * j;
      float[] pos = {points.get(i - 1)[0] + dx, points.get(i - 1)[1] + dy, points.get(i - 1)[2] + dz};
      path.add(pos);
    }
  }
  return path;
}
