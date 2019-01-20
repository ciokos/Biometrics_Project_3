//loaded image
PImage image;

//dimensions of the image
int w, h;

//bitmap array
int[] bitmap;

//deletion array
IntList A0, A1, A2, A3, A4, A5, A1pix;

//mask for calculating weights
int[] mask;

//file name
String filename = "fingerprint.png";

void setup() {
  //create window
  //to fit the image you can change the size of the window
  size(419, 600);   //<>//
  
  // load image
  image = loadImage("../" + filename);
  
  // initialize bitmap array
  bitmap = new int[image.pixels.length];
  
  // save width and height of the image
  w = image.width;
  h = image.height;
  
  // initialize deletion arrays
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
         
  // initialize th mask
  mask = new int[]{128, 1, 2, 4, 8, 16, 32, 64};
  
  // convert image to grayscale and binarize with a given threshold
  image = binarize(image, 120);
  
  // thinning of the binary image
  thinning();
  
  // draw the result
  drawBitmap();
}


// main function of the algorithm
void thinning() {
  // flag for detecting changes
  boolean changed = true;
  // do phases until there is no change
  while(changed) {
    // execute all phases
    changed = false;
    phase(A0, 2, 1); //<>//
    if(phase(A1, 0, 2))
      changed = true;
    if(phase(A2, 0, 2))
      changed = true;
    if(phase(A3, 0, 2))
      changed = true;
    if(phase(A4, 0, 2))
      changed = true;
    if(phase(A5, 0, 2))
      changed = true;
    phase6();
  }
  // execute last phase
  phase(A1pix, 0, 2);
}

// function for implementing all of the phases
// A: deletion array for the phase
// newValue: new value of the pixel (0 or 2)
// focus: are we looking for border pixels (2) or any object (1)
boolean phase(IntList A, int newValue, int focus) {
  // flag for detecting changes
  boolean changed = false;
  // loop through every pixel
  for(int y = 0; y < h; y++) {
    for(int x = 0; x < w; x++) {
      // do you want to look at this pixel?
      if(bitmap[x + y * w] == focus) {
        // if yes, calculate its weight
        int weight = useMask(y, x);
        // is the result in the deletion array?
        if(A.hasValue(weight)) {
          // set pixel to new value
          bitmap[x + y * w] = newValue;
          // set flag
          changed = true;
        }
      }
    }
  }
  // return the flag value
  return changed;
}

void phase6() {
  // loop through every pixel
  for(int y = 0; y < h; y++) {
    for(int x = 0; x < w; x++) {
      // do you want to look at this pixel?
      if(bitmap[x + y * w] > 0) {
        bitmap[x + y * w] = 1;
      }
    }
  }
}

// find neighbours of the pixel in given coordinates
// use the mask to calculate weights
int useMask(int y, int x) {
  // list for recording neighbours
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
    
  // calculate and return weight
  return weight(neighbours);
}

// calculate weight for the given neighbours list
int weight(IntList list) {
  // int for recording sum
  int sum = 0;
  // go through every neighbour
  for(int i = 0; i < list.size(); i++) {
    // if it's not a 0 add a corresponding mask value
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
