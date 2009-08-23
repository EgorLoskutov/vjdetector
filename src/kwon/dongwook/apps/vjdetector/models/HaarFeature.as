package kwon.dongwook.apps.vjdetector.models {
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class HaarFeature {
		
		public var rectangles:Vector.<HaarRectangle>;
		public var tilted:Boolean = false;
		
		public function HaarFeature() {
			rectangles = new Vector.<HaarRectangle>();
		}

		public function getSumAt(offset:Point, fromImage:IntegralImage):Number {
			var sum:Number = 0;
			rectangles.forEach(function(rect:HaarRectangle, i:int, vector:Vector.<HaarRectangle>):void {
				var area:Rectangle = rect.rectangle;
				area.offsetPoint(offset);
				sum += fromImage.getSumOf(area) * rect.scaledWeight; 
			}, this);
			return sum;
		}
		
		public function setScaleAndWeight(s:Number, w:Number):void {
			scale = s;
			weight = w;
		}
		
		private function set scale(value:Number):void {
			for each(var rect:HaarRectangle in rectangles) {
				rect.scale = value;
			}
		}
		
		private function set weight(value:Number):void {
			var sumExceptFirst:Number = 0;
			for (var idx:int = rectangles.length - 1; idx >= 0; idx--) {
				var rect:HaarRectangle = rectangles[idx];
				if (idx == 0) {
					rect.scaledWeight = -(sumExceptFirst / rect.area);
				} else {
					rect.scaledWeight = rect.weight * value;
					sumExceptFirst += rect.area * rect.scaledWeight;
				}
			}
		}
	}
}