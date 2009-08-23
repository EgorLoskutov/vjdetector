package kwon.dongwook.apps.vjdetector.models {
	
	import flash.geom.Rectangle;
	
	import kwon.dongwook.utils.StringUtil;
	
	public class HaarRectangle {
		
		private var _rect:Rectangle;
		private var _scaledRect:Rectangle;
		private var _weight:Number;
		private var _scale:Number = 1;
		private var _scaledWeight:Number;
		
		public function get x():Number { return _scaledRect.x; }
		public function get y():Number { return _scaledRect.y; }
		public function get w():Number { return _scaledRect.width; }
		public function get h():Number { return _scaledRect.height; }
		public function get weight():Number { return _weight; }
		public function get area():Number { return w * h; }
		public function get rectangle():Rectangle { return new Rectangle(x, y, w, h); }
		
		public function set scale(value:Number):void { 
			_scale = value;
			_scaledRect = new Rectangle(Math.round(_scale * _rect.x),
										Math.round(_scale * _rect.y),
										Math.round(_scale * _rect.width),
										Math.round(_scale * _rect.height));
		}
		
		public function set scaledWeight(value:Number):void { _scaledWeight = value; }
		public function get scaledWeight():Number { return _scaledWeight; }
		
			
		public function HaarRectangle(x:uint = 0, y:uint = 0, w:uint = 0, h:uint = 0, weight:Number = 0) {
			_rect = new Rectangle(x, y, w, h);
			_weight = weight;
		}
		
		public static function createRectangleFrom(string:String, size:Rectangle, spliter:String = " "):HaarRectangle {
			string = StringUtil.trim(string);
			var data:Array = string.split(spliter);
			if (data.every(function(item:String, idx:uint, ary:Array):Boolean {
				return validate(idx, ary, size);
			})) {
				return new HaarRectangle(uint(data[0]),		uint(data[1]),
										uint(data[2]),		uint(data[3]),
										Number(data[4]));
			}
			trace("Invalid Rectangle data.");
			return null;
		}
		
		private static function validate(idx:uint, ary:Array, size:Rectangle):Boolean {
			var hasAllData:Function = function():Boolean {
				return ( ary.length > 4 && !isNaN(ary[idx]));
			}
			var withinLimit:Function = function():Boolean {
				if (idx < 4 && Number(ary[idx]) < 0)
					return false;
				if (idx == 2)
					return (Number(ary[idx]) <= size.width); 
				else if (idx == 3)
					return (Number(ary[idx]) <= size.height);
				return true;
			}
			return hasAllData() && withinLimit();
		}

	}
}