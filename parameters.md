### Parameters for detect objects ###

  * Cascade file
  * Scale factor
  * Minimum size
  * Minimum Neighbour count
  * Find biggest
  * Do canny pruning

These are parameters affect result and speed to detect object in this detector which mostly the same in OpenCV 1.1 face detector.

**Cascade file**

It contains trained file which object you want to find like frontal face, eyes, upper body etc.
So you need to choose right trainned data.
I only use OpenCV 1.1's cascade files but you can find other trained files on the internet.
Depending on this trained file, result will be quite different.

**Scale factor & Minimum size**

In order to understand these parameters, you need to know little bit of how it finds objects.
The detector in this program starts by searching the certain area of a picture whether it has a object that you are interested which the cascade file is trained. And goes on to the next area until looks through the whole area of a picture.
Then increase the size of the area little bit and do it all again, so the size of the search area will be almostly as big as its picture.
Later the engine combines the results of found the areas.

The start size of the area to look for is the minimum size parameter.
So, if it's big, performance will be better than small size of it, but you can miss small faces than its area.

The scale factor is how much you want to increase this search area for the next iteration of search.
Big scale number will increase a lots of speed as you can guess, but too big number will skip lots of areas which lead bad results.

**Minimum Neighbour count**

From above explanation, You can notice the object detector searches target objects multiple times on a image with a different size of areas which means around target objects there will be lots of the same results.
So with minimum neighbour count parameter, detector decides whether this results should be included in final result or not.
If you set this to 0, detector will return all results it has.

**Find biggest**

Literally, it stops when finds the biggest object. Because the detector starts with the most biggest area first, the biggest object will be the first object it finds. It affects quite of speed, but it can't be wrong object. It's greatly helped to find on real time like finding a face using web cam.

**Do canny pruning**

It uses Canny edge detector which finds the all edges in a picture.
And if the search area doesn't have enough edges, skip that area to boost performance.
It's based on the fact that usually a face has lots of edges around eyes, lips, nose, shadow of hair etc.
Therefore, if you want to find multiple small size of faces in one big picture, it won't help that much, but with the big size of a face in a picture in this option will help to increase performance.

As usual of Haar like face detector, the result is affected a lot by lighting and an angle of head.
So you need to adjust these parameters for the best result.





