// Find and draw the centroids of the blobs with labels in labelsToShow.
// labels is a linear array representing a 2-d array of width w. This array
// has the label number of each blob in an image.
void draw_centroids(int[] labels, int w, ArrayList labelsToShow) {
  int[][] xy = centroids(labels, w, labelsToShow); // Find all the centroids
  for (int l = 0; l < xy.length; l +=1) {
    draw_centroid(xy[l][0], xy[l][1]);
  }
}

// Find the centroid of all blobs with labels in labelsToShow from an array
// of labels with width w.
// See:
// http://en.wikipedia.org/wiki/Image_moment
// Returns an array of xy-arrays corresponding to the
// coordinates of the centroids of each label up to l
int[][] centroids(int[] labels, int w, ArrayList labelsToShow) {
  int[][] ij = new int[3][2];
  // Moment 00
  ij[0][0] = 0;
  ij[0][1] = 0;
  // Moment 10
  ij[1][0] = 1;
  ij[1][1] = 0;
  // Moment 01
  ij[2][0] = 0;
  ij[2][1] = 1;

  int[][] m = moments(labels, w, labelsToShow, ij); 
  int[][] xy = new int[labelsToShow.size()][2];
  for (int label = 0; label < m.length; label += 1) {
    int m00 = m[label][0];
    int m10 = m[label][1];
    int m01 = m[label][2];
    // Centroid x
    if (m00 > 0) {
      xy[label][0] = m10 / m00;
      // Centroid y
      xy[label][1] = m01 / m00;
    } else {
      xy[label][0] = -1;
      xy[label][1] = -1;
    }
  }
  return xy;
}

// Get a set of i-jth moments of all groups in labelsToShow from an array of labels
// with width w. ij is an array of 2-element integer arrays as follows:
// [[i0, j0], [i1, j1], ...]
// For each label, returns an array of moments
int[][] moments(int[] labels, int w, ArrayList<Integer> labelsToShow, int[][] ij) {
  int[][] m = new int[labelsToShow.size()][ij.length];
  for (int k = 0; k < labels.length; k += 1) {
    int x = xFromIndex(k, w);
    int y = yFromIndex(k, w);
    if (labels[k] > 0) {
      for (int n = 0; n < labelsToShow.size(); n += 1) {
        int label = labelsToShow.get(n);
        if (labels[k] == label) {
          for (int moment = 0; moment < ij.length; moment += 1) {
            int i = ij[moment][0];
            int j = ij[moment][1];
            m[n][moment] += Math.pow(x, i) * Math.pow(y, j); //<>//
          }
        }
      }
    }
  }
  return m;
}

// Draw the centroid onto the processing canvas
void draw_centroid(int x, int y) {
  int lineLength = 30;
  if (x >= 0 && y >= 0) {
    stroke(255, 255, 0); // yellow
    noFill();
    ellipse(x, y, lineLength / 2, lineLength / 2);
    line(x - lineLength / 2, y, x + lineLength / 2, y);
    line(x, y - lineLength / 2, x, y + lineLength / 2);
    fill(255);
    text(String.format("(%s, %s)", x, y), x - 20, y - 20);
  }
}
