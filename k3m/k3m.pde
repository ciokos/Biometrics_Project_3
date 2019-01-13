//loaded image
PImage image;

//dimensions of the image
int w, h;

//bitmap array
int[] bitmap;

//deletion array
IntList A0, A1, A2, A3, A4, A5, A1pix;

//mask
int[] mask;

//file name
String filename = "signature.png";

void setup() {
  //create window
  //to fit the image you can change the size of the window
  size(419, 600);
  background(30); //<>//
  image = loadImage("../" + filename);
  bitmap = new int[image.pixels.length];
  w = image.width;
  h = image.height;
  
  A0 = new IntList(new int[]{3, 6, 7, 12, 14, 15, 24, 28, 30, 31, 48, 56, 60,
      62, 63, 96, 112, 120, 124, 126, 127, 129, 131, 135,
      143, 159, 191, 192, 193, 195, 199, 207, 223, 224,
      225, 227, 231, 239, 240, 241, 243, 247, 248, 249,
      251, 252, 253, 254});

  A1 = new IntList(new int[]{7, 14, 28, 56, 112, 131, 193, 224});

  A2 = new IntList(new int[]{7, 14, 15, 28, 30, 56, 60, 112, 120, 131, 135,
      193, 195, 224, 225, 240});

  A3 = new IntList(new int[]{7, 14, 15, 28, 30, 31, 56, 60, 62, 112, 120,
      124, 131, 135, 143, 193, 195, 199, 224, 225, 227,
      240, 241, 248});

  A4 = new IntList(new int[]{7, 14, 15, 28, 30, 31, 56, 60, 62, 63, 112, 120,
      124, 126, 131, 135, 143, 159, 193, 195, 199, 207,
      224, 225, 227, 231, 240, 241, 243, 248, 249, 252});

  A5 = new IntList(new int[]{7, 14, 15, 28, 30, 31, 56, 60, 62, 63, 112, 120,
      124, 126, 131, 135, 143, 159, 191, 193, 195, 199,
      207, 224, 225, 227, 231, 239, 240, 241, 243, 248,
      249, 251, 252, 254});

  A1pix = new IntList(new int[]{3, 6, 7, 12, 14, 15, 24, 28, 30, 31, 48, 56,
         60, 62, 63, 96, 112, 120, 124, 126, 127, 129, 131,
         135, 143, 159, 191, 192, 193, 195, 199, 207, 223,
         224, 225, 227, 231, 239, 240, 241, 243, 247, 248,
         249, 251, 252, 253, 254});
         
  mask = new int[]{128, 1, 2, 4, 8, 16, 32, 64};
  image = binarize(image, 128);
  thinning();
  drawBitmap();
}

void thinning() {
  boolean changed = true;
  while(changed) {
    changed = phase(A0, 2);
    phase(A1, 0);
    phase(A2, 0);
    phase(A3, 0);
    phase(A4, 0);
    phase(A5, 0);
    phase(A1pix, 0);
  }
}

boolean phase(IntList A, int newValue) {
  boolean changed = false;
  int focus = 2;
  if(newValue > 1)
    focus = 1;
  for(int y = 0; y < h; y++) {
    for(int x = 0; x < w; x++) {
      if(bitmap[x + y * w] == focus) {
        int weight = useMask(y, x);
        if(A.hasValue(weight)) {
          bitmap[x + y * w] = newValue;
          changed = true;
        }
      }
    }
  }
  return changed;
}

int useMask(int y, int x) {
  IntList neighbours = new IntList();
  // top left
  if(x-1 >= 0 && y-1 >= 0)
    neighbours.append(bitmap[x - 1 + (y-1) * w]);
  else
    neighbours.append(0);
    
  // top
  if(y-1 >= 0)
    neighbours.append(bitmap[x + (y-1) * w]);
  else
    neighbours.append(0);
    
  // top right
  if(x+1 < w && y-1 >= 0)
    neighbours.append(bitmap[x + 1 + (y-1) * w]);
  else
    neighbours.append(0);
    
  // right
  if(x+1 < w)
    neighbours.append(bitmap[x + 1 + y * w]);
  else
    neighbours.append(0);
    
  // bottom right
  if(y+1 < h && x+1 < w)
   neighbours.append(bitmap[x + 1 + (y+1) * w]);
  else
    neighbours.append(0);
    
  // bottom
  if(y+1 < h)
    neighbours.append(bitmap[x + (y+1) * w]);
  else
    neighbours.append(0);
    
  // bottom left
  if(y+1 < h && x-1 >= 0)
    neighbours.append(bitmap[x - 1 + (y+1) * w]);
  else
    neighbours.append(0);
    
  // left
  if(x-1 >= 0)
    neighbours.append(bitmap[x - 1 + y * w]);
  else
    neighbours.append(0);

  return weight(neighbours);
}

int weight(IntList list) {
  int sum = 0;
  for(int i = 0; i < list.size(); i++) {
    if(list.get(i) > 0)
      sum += mask[i];
  }
  return sum;
}



void drawBitmap() {
  //create new image with height and width of the original image
  PImage img = createImage(image.width, image.height, RGB);
  //begin work on pixel level
  loadPixels();
  //loop through every pixel
  for (int i=0; i<img.pixels.length; i++) {
    //set color of the new pixel
    if(bitmap[i] > 0)
      img.pixels[i] = color(0);
    else {
      img.pixels[i] = color(255);
    }
  }
  //end work on pixels
  updatePixels();
  image(img, 0, 0, w, h);
  img.save("skeleton-"+filename);
}

 //<>//

PImage binarize(PImage img, float T) {
  //create new image with height and width of the original image
  PImage bin = createImage(img.width, img.height, RGB);
  //begin work on pixel level
  loadPixels();
  //loop through every pixel
  for (int i=0; i<img.pixels.length; i++) {
    //take color of the original pixel
    color c = img.pixels[i];
    //take average of red, green and blue channels
    float avg = (red(c) + green(c) + blue(c))/3;
    //compare it with T and set to white or black
    if(avg<T) {
     avg = 0;
     bitmap[i] = 1;
    } else {
     avg = 255; 
     bitmap[i] = 0;
    }
    //set color of the new pixel
    bin.pixels[i] =  color(avg);
  }
  //end work on pixels
  updatePixels();
  //return the result
  return bin;
}
