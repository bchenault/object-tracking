import processing.video.*;
import java.awt.Color;
import java.util.ArrayList;

Capture cam;
int w = 640, h = 480;
// Rich blue (my pen lid)
//float hmin = 0.52, hmax = 0.65, smin = 0.57, smax = 1, bmin = 0.33, bmax = 1;
float hmin = 0.52, hmax = 0.65, smin = 0.57, smax = 1, bmin = 0.33, bmax = 1;
color bgColour = color(0, 0, 0);
color fgColour = color(255, 255, 255);
int minBlobSize = 200; // A blob must be this big to be counted as an object. Otherwise it's just noise.
PFont boldFont = createFont("Arial Bold", 18);
boolean debug = false;

void setup() {
  // 640 480 30
  strokeWeight(2); // For drawing centroids
  if (debug) {
    size(w * 2, h);
  } else {
    size(w, h);
  }
  cam = new Capture(this, w, h, "/dev/video1", 30);
  cam.start();
  textFont(boldFont);
}

void draw() {
  if (cam.available() == true) {
    cam.read();
    cam.loadPixels();
    image(cam, 0, 0); // Show the left-hand unfiltered image
    for (int i = 0; i < cam.pixels.length; i += 1) {
      color c = cam.pixels[i];
      // Convert to HSB
      float[] hsb = Color.RGBtoHSB((int) red(c), (int) green(c), (int) blue(c), null);
      if (!hsbConstrained(hsb)){
        // Unconstrained pixels are foreground
        cam.pixels[i] = fgColour;
      } else{
        // Constrained values are black
        cam.pixels[i] = bgColour;
      } 
    }

    cam.updatePixels();
    smooth();
    cam.filter(ERODE);
    cam.filter(ERODE);
    cam.filter(ERODE);
    cam.filter(ERODE);
    cam.filter(DILATE);
    cam.filter(DILATE);
    cam.filter(DILATE);
    cam.filter(DILATE);
    if (debug) {
      // For debug: this shows the filtered image
      image(cam, w + 1, 0); // Show the right-hand filtered image
    }

    // Label blobs
    int[] labels = new int[cam.pixels.length];
    int l = 1; // Label number
    // Set labels
    for (int i = 0; i < cam.pixels.length; i += 1) {
      l = labelPixelsReturnL(labels, cam.pixels, i, l);
    }
    // Get blob sizes
    int[] sizes = new int[l];
    for (int i = 0; i < cam.pixels.length; i += 1) {
      if (labels[i] > 0) {
        sizes[labels[i] - 1] += 1;
      }
    }
    // Show centroids for blobs bigger than minBlobSize
    ArrayList labelsToShow = new ArrayList();
    for (int i = 0; i < sizes.length; i++) {
      if (sizes[i] > minBlobSize) {
        labelsToShow.add(i + 1);
      }
    }
    draw_centroids(labels, w, labelsToShow);
  }
  
  if (debug) {
    // For debug: Show the HSB limits
    fill(255);
    text(String.format("hmin: %.2f (qa)", hmin), 10, 10);   
    text(String.format("hmax: %.2f (ws)", hmax), 10, 30);                         
    text(String.format("smin: %.2f (ed)", smin), 10, 50);                         
    text(String.format("smax: %.2f (rf)", smax), 10, 70);                         
    text(String.format("bmin: %.2f (tg)", bmin), 10, 90);                         
    text(String.format("bmax: %.2f (yh)", bmax), 10, 110);
  }
}

boolean hsbConstrained(float[] hsb) {
  boolean constrained = false;
  constrained = constrained || constrained(hsb[0], hmin, hmax);
  constrained = constrained || constrained(hsb[1], smin, smax);
  constrained = constrained || constrained(hsb[2], bmin, bmax);
  return constrained;
}

boolean constrained(float x, float min, float max) {
  if (constrain(x, min, max) == x) {
    return false;
  } else {
    return true;
  }
}  


void keyPressed() {
  if (debug) {
    float stepSize = 0.01;
    switch (key) {
      case 113: hmin += stepSize; // q
                break;
      case 97: hmin -= stepSize; // a
                break;
      case 119: hmax += stepSize; // w
                break;
      case 115: hmax -= stepSize; // s
                break;
      case 101: smin += stepSize; // e
                break;
      case 100: smin -= stepSize; // d
                break;
      case 114: smax += stepSize; // r
                break;
      case 102: smax -= stepSize; // f
                break;
      case 116: bmin += stepSize; // t
                break;
      case 103: bmin -= stepSize; // g
                break;
      case 121: bmax += stepSize; // y
                break;
      case 104: bmax -= stepSize; // h
                break;
    }
  }
}
