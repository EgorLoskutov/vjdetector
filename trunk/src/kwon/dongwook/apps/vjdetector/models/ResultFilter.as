package kwon.dongwook.apps.vjdetector.models {
	
	import flash.geom.Rectangle;
	
	public class ResultFilter {
		
		/**
		 * It classifies rectangles and merge into one rectangle for each class
		 * If you decrease minimumNeighbors number, it will return more results 
		 * but it increases the possibility to include more noises.
		 * 2 ~ 3 is good in practice.
		 * 
		 * @param rawResults:Vector.<Rectangle>
		 * @param minimumNeighbors : minimum number of overlapped detection for merging into class 
		 * @return Vector.<Rectangle> : classified results
		 * 
		 */
		public function getResults(rawResults:Vector.<Rectangle>, minimumNeighbors:uint = 2):Vector.<Rectangle> {
			var groups:Vector.<Vector.<Rectangle>> = new Vector.<Vector.<Rectangle>>();
			groups.push(new Vector.<Rectangle>());
			rawResults.forEach(function(rect:Rectangle, srcIndex:uint, srcRects:Vector.<Rectangle>):void {
				var classified:Boolean = false;
				groups.forEach(function(rects:Vector.<Rectangle>, groupIndex:uint, groupRects:Vector.<Vector.<Rectangle>>):void {
					if (isClose(rect, getAverageRect(rects))) {
						classified = true;
						rects.push(rect);
					}
				}, this);
				if (!classified) {
					var newGroup:Vector.<Rectangle> = new Vector.<Rectangle>();
					newGroup.push(rect);
					groups.push(newGroup);
				}
			}, this);
			var filtered:Vector.<Rectangle> = new Vector.<Rectangle>();
			groups.forEach(function(rects:Vector.<Rectangle>, i:uint, groupRects:Vector.<Vector.<Rectangle>>):void {
				if (rects.length >= minimumNeighbors) {
					var average:Rectangle = getAverageRect(rects);
					if (average) {
						var index:int = hasClose(average, filtered);
						if (index > -1) {
							var temp:Vector.<Rectangle> = new Vector.<Rectangle>();
							temp.push(filtered[index]);
							temp.push(average);
							filtered[index] = getAverageRect(temp);
						} else {
							filtered.push(average);
						}
					}
				}
			}, this);
			return filtered;
		}
		
		private function hasClose(rect:Rectangle, rects:Vector.<Rectangle>):int {
			var close:int = -1;
			rects.some(function(result:Rectangle, i:uint, results:Vector.<Rectangle>):Boolean {
				if (isClose(rect, result)) {
					close = i;
					return true;
				} else {
					return false;
				}
			}, this);
			return close; 
		}
		
		private function isClose(src:Rectangle, target:Rectangle):Boolean {
			if (!target)
				return true;
			return target.contains(src.x + (src.width/2), src.y + (src.height/2));
		}
				
		private function getAverageRect(rects:Vector.<Rectangle>):Rectangle {
			if (rects.length == 0) {
				return null;
			} 
			var average:Rectangle = new Rectangle();
			var count:uint = 0;
			rects.sort(function(r1:Rectangle, r2:Rectangle):Number {
				return (r2.width * r2.height) - (r1.width * r1.height);
			}).forEach(function(rect:Rectangle, i:uint, vector:Vector.<Rectangle>):void {
				if ( (i != 0 && i < (vector.length-1)) || (vector.length < 4) ) {
					average.x += rect.x;
					average.y += rect.y;
					average.width += rect.width;
					average.height += rect.height;
					count++;
				}
			}, this);
			return new Rectangle(average.x/count, average.y/count, average.width/count, average.height/count);
		}
		
	}
}