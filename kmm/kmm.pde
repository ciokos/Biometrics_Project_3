//a button
Button button;

//loaded image
PImage image;

//dimensions of the image
int w, h;

//bitmap array
int[] bitmap;

//deletion array
IntList del;

//mask
int[] mask;

//file name
String filename = "houses.png";

void setup() {
  //create window
  //to fit the image you can change the size of the window
  size(419, 600);
  background(30); //<>//
  image = loadImage("../" + filename);
  bitmap = new int[image.pixels.length];
  w = image.width;
  h = image.height;
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
  mask = new int[]{128, 1, 2, 4, 8, 16, 32, 64};
  image = binarize(image, 128);
  thinning();
  drawBitmap();
}

void thinning() {
  int diff = 1;
  while(diff>0) {
    mark2sAnd3s();
    delete4s();
    diff = useMask();
  }
}

int useMask() {
  IntList neighbours = new IntList();
  int difference = 0;
  for (int N = 2; N <= 3; N++) {
    for(int y = 0; y < h; y++) {
       for(int x = 0; x < w; x++) {
         if(bitmap[x + y * w] == N) {
           neighbours.clear();
        
          // top left
          if(x-1 >= 0 && y-1 >= 0) {
            neighbours.append(bitmap[x - 1 + (y-1) * w]);
          }
          // top
          if(y-1 >= 0) {
            neighbours.append(bitmap[x + (y-1) * w]);
          }
          // top right
          if(x+1 < w && y-1 >= 0) {
            neighbours.append(bitmap[x + 1 + (y-1) * w]);
          }
          // right
          if(x+1 < w) {
            neighbours.append(bitmap[x + 1 + y * w]);
          }
          // bottom right
          if(y+1 < h && x+1 < w) {
            neighbours.append(bitmap[x + 1 + (y+1) * w]);
          }
          // bottom
          if(y+1 < h) {
            neighbours.append(bitmap[x + (y+1) * w]);
          }
          // bottom left
          if(y+1 < h && x-1 >= 0) {
            neighbours.append(bitmap[x - 1 + (y+1) * w]);
          }
          // left
          if(x-1 >= 0) {
            neighbours.append(bitmap[x - 1 + y * w]);
          }
          int weight = (weight(neighbours));
          if(del.hasValue(weight)) {
            bitmap[x + y * w] = 0;
            difference++;
          }
          else
            bitmap[x + y * w] = 1;
        }
      }
    }
  }
  return difference;
}

int weight(IntList list) {
  int sum = 0;
  for(int i =0; i < list.size(); i++) {
    if(list.get(i) > 0)
      sum += mask[i];
  }
  return sum;
}

void mark2sAnd3s() {
  for(int y = 0; y < h; y++) {
    for(int x = 0; x < w; x++) {
      if(bitmap[x + y * w] == 1) {
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
  IntList neighbours = new IntList();
  for(int y = 0; y < h; y++) {
    for(int x = 0; x < w; x++) {
      if(bitmap[x + y * w] == 2) {
        neighbours.clear();
        
        // top left
        if(x-1 >= 0 && y-1 >= 0) {
          neighbours.append(bitmap[x - 1 + (y-1) * w]);
        }
        // top
        if(y-1 >= 0) {
          neighbours.append(bitmap[x + (y-1) * w]);
        }
        // top right
        if(x+1 < w && y-1 >= 0) {
          neighbours.append(bitmap[x + 1 + (y-1) * w]);
        }
        // right
        if(x+1 < w) {
          neighbours.append(bitmap[x + 1 + y * w]);
        }
        // bottom right
        if(y+1 < h && x+1 < w) {
          neighbours.append(bitmap[x + 1 + (y+1) * w]);
        }
        // bottom
        if(y+1 < h) {
          neighbours.append(bitmap[x + (y+1) * w]);
        }
        // bottom left
        if(y+1 < h && x-1 >= 0) {
          neighbours.append(bitmap[x - 1 + (y+1) * w]);
        }
        // left
        if(x-1 >= 0) {
          neighbours.append(bitmap[x - 1 + y * w]);
        }
        if(is4(neighbours))
          bitmap[x + y * w] = 0;
      }
    }
  }
}

boolean is4(IntList list) {
  if(list.max() < 1)
    return false;
  while(list.get(0)>0) {
    list.append(list.remove(0));
  }
  while(list.get(0)<1) {
    list.append(list.remove(0));
  }
  int len = 0;
  boolean finished = false;
  for(int i : list) {
    if(i>0) {
      len++;
      if(finished)
        return false;
    }
    else
      finished = true;
  }
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
    if(bitmap[i] == 2)
      img.pixels[i] = color(0, 0, 255);
    else if(bitmap[i] == 1) {
      img.pixels[i] = color(0);
    }
    else if(bitmap[i] == 3) {
      img.pixels[i] = color(0, 255, 0);
    }
    else if(bitmap[i] == 4) {
      img.pixels[i] = color(255, 0, 0);
    }
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
