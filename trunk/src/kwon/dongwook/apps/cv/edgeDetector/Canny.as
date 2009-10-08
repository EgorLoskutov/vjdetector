package kwon.dongwook.apps.cv.edgeDetector {
	
	import flash.display.BitmapData;
	import flash.display.Shader;
	import flash.filters.*;
	import flash.geom.Point;
	import flash.utils.*;
	
	import kwon.dongwook.apps.cv.effect.Histogram;
	
	/**
	 * Implementation of Canny Edge detector
	 * http://www.cvmt.dk/education/teaching/f09/VGIS8/AIP/canny_09gr820.pdf
	 * 
	 * @author Dongwook Kwon
	 * 
	 */
	public class Canny {
		
		[Embed(source="./filters/BlackAndWhiteFilter.pbj", mimeType="application/octet-stream")]
		private	var BlackAndWhiteFilter:Class;
		
		[Embed(source="./filters/GaussionSmooth.pbj", mimeType="application/octet-stream")]
		private	var GaussionFilter:Class;
		
		[Embed(source="./filters/Gradient.pbj", mimeType="application/octet-stream")]
		private var GradientFilter:Class;
		
		[Embed(source="./filters/NonmaximumSuppression.pbj", mimeType="application/octet-stream")]
		private var NonmaxSuppressionFilter:Class;

		private var _blackAndWhiteFilter:ShaderFilter;
		private var _gaussionFilter:ShaderFilter;
		private var _gradientFilter:ShaderFilter;
		private var _nonmaxSuppressionFilter:ShaderFilter;

		public static var highThreshold:Number = 0xFF * 0.3;
		public static var lowThreshold:Number = 0xFF * 0.15;
		
		private var _ps:Vector.<uint>;
		private var _bitmapWidth:uint;
		private var _bitmapHeight:uint;
		
		public function Canny() {
			makeFilters();
		}
		
		public function edge(target:BitmapData, applyBlackAndWhiteFilter:Boolean = true, applyEqualizeHistogramFilter:Boolean = true):BitmapData {
			return detect(target, applyBlackAndWhiteFilter, applyEqualizeHistogramFilter);
		}
		
		private function makeFilters():void {
			_blackAndWhiteFilter = new ShaderFilter(new Shader(new BlackAndWhiteFilter() as ByteArray));
			_gaussionFilter = new ShaderFilter(new Shader(new GaussionFilter() as ByteArray));
			_gradientFilter = new ShaderFilter(new Shader(new GradientFilter() as ByteArray));
			_nonmaxSuppressionFilter = new ShaderFilter(new Shader(new NonmaxSuppressionFilter() as ByteArray));
		}
		
		private function detect(source:BitmapData, applyBnW:Boolean = true, applyEqualizeHistogram:Boolean = true):BitmapData {
			_bitmapWidth = source.width;
			_bitmapHeight = source.height;
			var result:BitmapData = source.clone();
			
			var origin:Point = new Point(0, 0);
			if (applyBnW)
				result.applyFilter(result, result.rect, origin, _blackAndWhiteFilter);
			if (applyEqualizeHistogram)
				Histogram.equalize(result);
			
			result.applyFilter(result, result.rect, origin, _gaussionFilter);
			result.applyFilter(result, result.rect, origin, _gradientFilter);
			result.applyFilter(result, result.rect, origin, _nonmaxSuppressionFilter);
			applyHysteresis(result);
			return result;
		}
		
		private function checkConnection(px:int, py:int, current:int):Boolean {
			for (var i:int = 0; i < 9; i++) {
				var col:int = px + ((i % 3) -1);
				var row:int = py + (Math.floor(i / 3) -1);

				if (!(col < 0 || col >= _bitmapWidth || row < 0 || row >= _bitmapHeight || i == 4)) {
					var index:int = (row * _bitmapWidth) + col;
					var red:uint = getRed(_ps[index]);
					if (red >= highThreshold) {
						_ps[current] = 0xFFFFFFFF;
						return true;
					} else if (red >= lowThreshold && col >= px && row >= py) {
						if (checkConnection(col, row, index)) {
							_ps[index] = 0xFFFFFFFF;
							return true;
						}
					}
				}
			}
			return false;
		}
		
		private function applyHysteresis(src:BitmapData):BitmapData {
			_ps = src.getVector(src.rect);
			var len:int = _ps.length;

			for(var i:int = 0; i < len; i++) {
				var red:uint = getRed(_ps[i]);
				if (red >= highThreshold) {
					_ps[i] = 0xFFFFFFFF;
				} else if (red >= lowThreshold) {
					var px:uint = i % _bitmapWidth;
					var py:uint = Math.floor(i / _bitmapWidth);
					if (!checkConnection(px, py, i)) {
						_ps[i] = 0xFF000000;
					}
				} else {
					_ps[i] = 0xFF000000;
				}
				
			}
			src.setVector(src.rect, _ps);
			return src;
		}
		
		private function getRed(p:uint):uint {
			return (0x00FF0000 & p) >> 16;
		}

	}
}