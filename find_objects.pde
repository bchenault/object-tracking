// Label pixel x using the array labels. colours is the
// image pixel array. l is the current highest label number
int labelPixelsReturnL(int[] labels, int[] colours, int x, int l) {
  // Following this algorithm:
  // http://www.labbookpages.co.uk/software/imgProc/blobDetection.html
  if (colours[x] == fgColour) {
    int minLabel = smallestKernelLabel(labels, w, x);
    if (minLabel == 0) {
      // neighbours A, B, C and D are unlabelled (equal to zero)
      labels[x] = l;
      l += 1;
    } else {
      // Label X and A, B, C and D (if foreground) with minimum label
      labels[x] = minLabel;
      setKernelLabelsIfForeground(labels, cam.pixels, x, w, minLabel);
    }
  }
  return l;
}

// http://www.labbookpages.co.uk/software/imgProc/blobDetection.html
// Return all the labels of x's upper/left neighbours, A, B, C and D:
// ABC
// DX
int[] kernelLabels(int[] labels, int w, int x) {
  int[] neighbours = kernelIndices(x, w);
  int[] neighbourLabels = new int[neighbours.length];

  for (int i = 0; i < neighbours.length; i += 1) {
    // Check each element of the neightbours A, B, C and D and
    // if the label is bigger than the maxLabel, increase maxLabel
    if (neighbours[i] >= 0) {
      neighbourLabels[i] = labels[neighbours[i]];
    }
  }
  return neighbourLabels;
}

// http://www.labbookpages.co.uk/software/imgProc/blobDetection.html
// Find the smallest label among x's upper/left neighbours, A, B, C and D:
// ABC
// DX
int smallestKernelLabel(int[] labels, int w, int x) {
  int minLabel = Integer.MAX_VALUE;
  int[] neighbourLabels = kernelLabels(labels, w, x);
  for (int i = 0; i < neighbourLabels.length; i += 1) {
    // Check each element of the neightbours A, B, C and D and
    // if the label is smaller than minLabel, increase minLabel
    int neighbourLabel = neighbourLabels[i];
    if (neighbourLabel > 0) {
      minLabel = min(minLabel, neighbourLabel);
    }
  }
  if (minLabel == Integer.MAX_VALUE) {
    // All neighbours have 0 label
    return 0;
  } else {
    return minLabel;
  }
}

// Set all kernel neighbours to l if they're foreground
// Neighbours are A, B, C and D in:
// ABC
// DX
void setKernelLabelsIfForeground(int[] labels, color[] colours, int x, int w, int l) {
  int[] neighbours = kernelIndices(x, w);
  for (int i = 0; i < neighbours.length; i += 1) {
    int neighbourIndex = neighbours[i];
    if (neighbourIndex >= 0) {
      if (colours[neighbourIndex] == fgColour) {
        labels[neighbourIndex] = l;
      }
    }
  }
}

// The indices of each of the pixels in the kernel
// starting from element i of an array. The array
// relates to a box of width w.
// The kernel is A, B, C and D in:
// ABC
// DX
int[] kernelIndices(int i, int w) {
  int[] xOffsets = {
    -1, 0, 1, -1
  };
  int[] yOffsets = {
    -1, -1, -1, 0
  };
  int x = xFromIndex(i, w);
  int y = yFromIndex(i, w);
  int[] neighbours = new int[4];
  for (int j = 0; j < 4; j += 1) {
    neighbours[j] = indexFromXY(x + xOffsets[j], y + yOffsets[j], w);
  }
  return neighbours;
}

// Convert from an index of a linear array, to 
// the x-value of a 2d array of width w
int xFromIndex(int i, int w) {
  return i % w;
}

// Convert from an index of a linear array, to 
// the y-value of a 2d array of width w
int yFromIndex(int i, int w) {
  return i / w;
}

// Convert the x, y co-ordinates of a 2d array
// of width w to the index of a linear array
int indexFromXY(int x, int y, int w) {
  if (x >= 0 && y >= 0 && x < w) {
    return y * w + x;
  } else {
    return -1;
  }
}
