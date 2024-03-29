package kwon.dongwook.apps.vjdetector.models {
	
	
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	
	
	/**
	 * Integral Image
	 * Behind the theory of this calculation is from Robust Real-Time face detection
	 * by PAUL VIOLA, MICHAEL J. JONES
	 * Take a look at this document for detail.
	 * http://lear.inrialpes.fr/people/triggs/student/vj/viola-ijcv04.pdf
	 * 
	 * Also the book, Learning OpenCV by Gary bradski, Adrian Kaehler, was greatly helped.
	 * 
	 * @author Dongwook, Kwon
	 * 
	 */
	public class IntegralImage {
		
		private var _bitmapData:BitmapData;
		private var _sum:Vector.<Number>;
		private var _squareSum:Vector.<Number>;
		private var _width:uint;
		private var _height:uint;
		private var _length:uint;
		
		
		public function IntegralImage(bitmapData:BitmapData, pixelVector:Vector.<uint> = null) {
			_bitmapData = bitmapData;
			_width = _bitmapData.width + 1;
			_height = _bitmapData.height + 1;
			_length = _width * _height;
			_sum = new Vector.<Number>(_length, true);
			_squareSum = new Vector.<Number>(_length, true);
			if (pixelVector == null)
				pixelVector = _bitmapData.getVector(_bitmapData.rect);
			calculate(pixelVector, _bitmapData.rect);
		}
		
		private function calculate(pixels:Vector.<uint>, size:Rectangle):void {
			var oWidth:uint = size.width;
			var oHeight:uint = size.height;
			var iWidth:uint = oWidth + 1;
			
			for(var y:uint = 0; y < oHeight; y++) {
				for(var x:uint = 0; x < oWidth; x++) {
					var oxy:uint = x + (y * oWidth);
					var ipxy:uint = x + ((y+1) * (iWidth));
					var ixpy:uint = (x+1) + (y * (iWidth));
					var ixy:uint = (x+1) + ((y+1) * (iWidth));
					var ipxpy:uint = x + (y * (iWidth));
					
					var blue:uint = uint(pixels[oxy] & 0x000000FF);
					_sum[ixy] = blue + _sum[ipxy] + _sum[ixpy] - _sum[ipxpy];
					_squareSum[ixy] = (blue * blue) + _squareSum[ipxy] + _squareSum[ixpy] - _squareSum[ipxpy];
				}
			}
		}
		
		public function getSumOf(rect:Rectangle):Number {
			return _sum[int((rect.bottom * _width) + rect.right)] - // D
					_sum[int((rect.bottom * _width) + rect.x)] - // C
					_sum[int((rect.y * _width) + rect.right)] + // B
					_sum[int((rect.y * _width) + rect.x)]; // A
		}
		
		public function getSquareSumOf(rect:Rectangle):Number {
			return _squareSum[int((rect.bottom * _width) + rect.right)] - // D
					_squareSum[int((rect.bottom * _width) + rect.x)] - // C
					_squareSum[int((rect.y * _width) + rect.right)] + // B
					_squareSum[int((rect.y * _width) + rect.x)]; // A
		}
		
	}
}