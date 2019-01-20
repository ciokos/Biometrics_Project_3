// loaded image
PImage image;

// dimensions of the image
int w, h;

// bitmap array
int[] bitmap;

// deletion array
IntList del;

// mask
int[] mask;

// file name
String filename = "fingerprint.png";

void setup() {
  // create window
  // to fit the image you can change the size of the window
  size(419, 600);
  background(30); //<>//
  
  // load image 
  image = loadImage("../" + filename);
  
  // initialize bitmap array
  bitmap = new int[image.pixels.length];
  
  // set width and height
  w = image.width;
  h = image.height;
  
  // initialize the deletion array
  del = new IntList(new int[]{3, 5, 7, 12, 13, 14, 15, 20, 
  21, 22, 23, 28, 29, 30, 31, 48,
  52, 53, 54, 55, 56, 60, 61, 62,
  63, 65, 67, 69, 71, 77, 79, 80,
  81, 83, 84, 85, 86, 87, 88, 89,
  91, 92, 93, 94, 95, 97, 99, 101,
  103, 109, 111, 112, 113, 115, 116, 117,
  118, 119, 120, 121, 123, 124, 125, 126,
  127, 131, 133, 135, 141, 143, 149, 151,
  157, 159, 181, 183, 189, 191, 192, 193,
  195, 197, 199, 205, 207, 208, 209, 211,
  212, 213, 214, 215, 216, 217, 219, 220,
  221, 222, 223, 224, 225, 227, 229, 231,
  237, 239, 240, 241, 243, 244, 245, 246,
  247, 248, 249, 251, 252, 253, 254, 255});
  
  // initialize mask array
  mask = new int[]{128, 1, 2, 4, 8, 16, 32, 64};
  
  // use the algorithm
  thinning();
  
  // draw the result
  drawBitmap();
}

// the main function of the algorithm
void thinning() {
  // convert image to grayscale and binarize
  image = binarize(image, 128);
  boolean changed = true;
  // while the algorithm changes something
  while(changed) {
    // find and mark twos and threes
    mark2sAnd3s();
    // find and delete fours
    delete4s();
    // use the mask and use the deletion array
    changed = useMask();
  }
}

boolean useMask() {
  // list for recording neighbours
  IntList neighbours = new IntList();
  // variable for detecting changes
  boolean changed = false;
  // for all twos and threes in the image
  
  for (int N = 2; N <= 3; N++) {
    for(int y = 0; y < h; y++) {
      for(int x = 0; x < w; x++) {
        if(bitmap[x + y * w] == N) {
          neighbours.clear();
          // add all neighbours to the list
          //starting from the top left corner
          //and going clockwise
          
          // top left
          if(x-1 >= 0 && y-1 >= 0) {
            neighbours.append(bitmap[x - 1 + (y-1) * w]);
          } else { neighbours.append(0); }
          // top
          if(y-1 >= 0) {
            neighbours.append(bitmap[x + (y-1) * w]);
          } else { neighbours.append(0); }
          // top right
          if(x+1 < w && y-1 >= 0) {
            neighbours.append(bitmap[x + 1 + (y-1) * w]);
          } else { neighbours.append(0); }
          // right
          if(x+1 < w) {
            neighbours.append(bitmap[x + 1 + y * w]);
          } else { neighbours.append(0); }
          // bottom right
          if(y+1 < h && x+1 < w) {
            neighbours.append(bitmap[x + 1 + (y+1) * w]);
          } else { neighbours.append(0); }
          // bottom
          if(y+1 < h) {
            neighbours.append(bitmap[x + (y+1) * w]);
          } else { neighbours.append(0); }
          // bottom left
          if(y+1 < h && x-1 >= 0) {
            neighbours.append(bitmap[x - 1 + (y+1) * w]);
          } else { neighbours.append(0); }
          // left
          if(x-1 >= 0) {
            neighbours.append(bitmap[x - 1 + y * w]);
          } else { neighbours.append(0); }
          
          // calculate weight for the neighbours
          int weight = weight(neighbours);
          
          // is the weight in the deletion array?
          if(del.hasValue(weight)) {
            // mark as background
            bitmap[x + y * w] = 0;
            // set flag
            changed = true;
          }
          // otherwise it's an object
          else
            bitmap[x + y * w] = 1;
        }
      }
    }
  }
  return changed;
}

// use mask and return sum weight of given neighbours
int weight(IntList list) {
  int sum = 0;
  for(int i =0; i < list.size(); i++) {
    if(list.get(i) > 0)
      sum += mask[i];
  }
  return sum;
}

void mark2sAnd3s() {
  // look at all pixels
  for(int y = 0; y < h; y++) {
    for(int x = 0; x < w; x++) {
      // look only at ones
      if(bitmap[x + y * w] == 1) {
        // is there a zero on left, right, top or bottom?
        // if yes mark as contour
        if(x-1 >= 0 && bitmap[x - 1 + y * w] == 0) {
          bitmap[x + y * w] = 2;
        }
        else if(x+1 < w && bitmap[x + 1 + y * w] == 0) {
          bitmap[x + y * w] = 2;
        }
        else if(y-1 >= 0 && bitmap[x + (y-1) * w] == 0) {
          bitmap[x + y * w] = 2;
        }
        else if(y+1 < h && bitmap[x + (y+1) * w] == 0) {
          bitmap[x + y * w] = 2;
        }
        // otherwise, is there a zero in the corners?
        // if yes set as elbow point
        else if(x-1 >= 0 && y-1 >= 0 && bitmap[x - 1 + (y-1) * w] == 0) {
          bitmap[x + y * w] = 3;
        }
        else if(x+1 < w && y-1 >= 0 && bitmap[x + 1 + (y-1) * w] == 0) {
          bitmap[x + y * w] = 3;
        }
        else if(y+1 < h && x-1 >= 0 && bitmap[x - 1 + (y+1) * w] == 0) {
          bitmap[x + y * w] = 3;
        }
        else if(y+1 < h && x+1 < w && bitmap[x + 1 + (y+1) * w] == 0) {
          bitmap[x + y * w] = 3;
        }
      }
    }
  }
}

void delete4s() {
  // list for recording neighbours
  IntList neighbours = new IntList();
  // look at every pixel
  for(int y = 0; y < h; y++) {
    for(int x = 0; x < w; x++) {
      // is it a contour point?
      if(bitmap[x + y * w] == 2) {
        neighbours.clear();
        // record all neighbours:
        
        // top left
        if(x-1 >= 0 && y-1 >= 0) {
          neighbours.append(bitmap[x - 1 + (y-1) * w]);
        } else { neighbours.append(0); }
        // top
        if(y-1 >= 0) {
          neighbours.append(bitmap[x + (y-1) * w]);
        } else { neighbours.append(0); }
        // top right
        if(x+1 < w && y-1 >= 0) {
          neighbours.append(bitmap[x + 1 + (y-1) * w]);
        } else { neighbours.append(0); }
        // right
        if(x+1 < w) {
          neighbours.append(bitmap[x + 1 + y * w]);
        } else { neighbours.append(0); }
        // bottom right
        if(y+1 < h && x+1 < w) {
          neighbours.append(bitmap[x + 1 + (y+1) * w]);
        } else { neighbours.append(0); }
        // bottom
        if(y+1 < h) {
          neighbours.append(bitmap[x + (y+1) * w]);
        } else { neighbours.append(0); }
        // bottom left
        if(y+1 < h && x-1 >= 0) {
          neighbours.append(bitmap[x - 1 + (y+1) * w]);
        } else { neighbours.append(0); }
        // left
        if(x-1 >= 0) {
          neighbours.append(bitmap[x - 1 + y * w]);
        } else { neighbours.append(0); }
        
        // check if it is a "four"
        // if yes, mark as background (delete)
        if(is4(neighbours))
          bitmap[x + y * w] = 0;
      }
    }
  }
}

// checks if a point with given neighbours is a "four"
boolean is4(IntList list) {
  // are there only zeros?
  if(list.max() < 1)
    return false;
  // find a zero
  while(list.get(0)>0) {
    list.append(list.remove(0));
  }
  // from that zero find a closest one
  while(list.get(0)<1) {
    list.append(list.remove(0));
  }
  // record length of the "trail"
  int len = 0;
  // did I already found a "trail"?
  boolean finished = false;
  // every neighbour value
  for(int i : list) {
    // is it a background or an object?
    if(i>0) {
      // is it a secord trail?
      if(finished)
        return false;
      // increase trail length
      len++;
    }
    else
      // if it's a zero I finished my trail
      finished = true;
  }
  // check for length of the trail
  if (len < 2 || len > 4)
    return false;
  return true;
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
