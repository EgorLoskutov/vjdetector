
package kwon.dongwook.apps.vjdetector {
	
	import flash.display.BitmapData;
	import flash.display.Shader;
	import flash.filters.ShaderFilter;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	import kwon.dongwook.apps.cv.effect.Histogram;
		
	/**
	 * It apply black and white filter and equalize histogram into new bitmapData.
	 * 
	 * 
	 * @author Dongwook, Kwon
	 * 
	 */
	public class Preprocessor {
		
		[Embed(source="./filters/BlackAndWhiteKernel.pbj", mimeType="application/octet-stream")]
		public	var BlackAndWhiteKernel:Class;
		
		private var _blackAndWhiteFilter:ShaderFilter;
		
		public function Preprocessor() {
			_blackAndWhiteFilter = new ShaderFilter(new Shader(new BlackAndWhiteKernel() as ByteArray));
		}
		
		/**
		 * 
		 * 
		 * This will change bitmap into black and white image and equliaze histogram 
		 * for increase an accuracy of detection
		 * 
		 * Detector requires 8 bit black and white image
		 * So, Return value contains only the pixel of blue channel which is 8 bit.
		 * 
		 * @param bitmapData
		 * @return Vector of pixels of blue channel 
		 * 
		 */
		public function getProcessedVector(bitmapData:BitmapData):Vector.<uint> {
			bitmapData.applyFilter(bitmapData, bitmapData.rect, new Point(0, 0), _blackAndWhiteFilter);
			return Histogram.equalize(bitmapData);
		}
		
	}
}