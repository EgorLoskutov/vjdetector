
package kwon.dongwook.apps.vjdetector.filters {
	
	import flash.display.BitmapData;
	import flash.display.Shader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filters.ShaderFilter;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.filters.ColorMatrixFilter;
		
	public class Preprocessor extends EventDispatcher {
		
		[Event(name="ready", type="flash.events.Event")]
		public static const READY:String = "ready";

		private const FILE_NAME:String = "preprocessFilter.pbj";
		private var _filter:ShaderFilter;
		
		public function load():void {
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE, function(event:Event):void {
				var shader:Shader = new Shader();
				shader.byteCode = loader.data;
				_filter = new ShaderFilter(shader);
				dispatchEvent(new Event(READY));
			}, false, 0, true);
			loader.load(new URLRequest(FILE_NAME));
		}
		
		/**
			For speed up, intially I planned to use PixelBender, 
			but it seems there is no way to deal with a histogram in PixelBender 
			nor to pass array from Flash yet, I was not able to implement it.
			If Official version of PixelBender supports one of features, 
			merge all this into PixelBender shader will increase speed.
			Currently I'm not sure, black and white shader is faster than flash's color matrix filter.
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
			/*
			var r:Number = 0.2126, g:Number = 0.7152, b:Number = 0.0722;
			var blackAndWhite:Array = 	[r, g, b, 0, 0,
										 r, g, b, 0, 0,
										 r, g, b, 0, 0,
										 0, 0, 0, 1, 0];
										 */
			var processed:BitmapData = new BitmapData(bitmapData.width, bitmapData.height, false, 0);
//			processed.applyFilter(bitmapData, bitmapData.rect, new Point(0, 0), new ColorMatrixFilter(blackAndWhite));
			processed.applyFilter(bitmapData, bitmapData.rect, new Point(0, 0), _filter);
			return equalizeHistogram(processed);
		}
		
		private function equalizeHistogram(bitmapData:BitmapData):Vector.<uint> {
			var histogram:Vector.<Number> = bitmapData.histogram(bitmapData.rect)[2];
			var equalizedHistogram:Vector.<uint> = new Vector.<uint>(256, true);
			var size:uint = bitmapData.width * bitmapData.height;
			var accumulated:Number = 0;
			for (var i:uint = 0; i < 256; i++) {
				var current:Number = (histogram[i] / size) + accumulated;
				equalizedHistogram[i] = Math.round(current * 255);
				accumulated = current;
			}
			var pixels:Vector.<uint> = bitmapData.getVector(bitmapData.rect);
			var length:uint = pixels.length;
			var equalizedPixels:Vector.<uint> = new Vector.<uint>(length, true);
			for (i = 0; i < length; i++) {
				var index:uint = uint((pixels[i] << 24) >>> 24);
				var color:uint = uint(equalizedHistogram[index]);
				equalizedPixels[i] = color;
			}
			return equalizedPixels;
		}
		
	}
}