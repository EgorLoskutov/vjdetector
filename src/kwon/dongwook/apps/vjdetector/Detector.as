package kwon.dongwook.apps.vjdetector {

	
	import flash.display.BitmapData;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import kwon.dongwook.apps.vjdetector.filters.Preprocessor;
	import kwon.dongwook.apps.vjdetector.models.HaarCascade;
	import kwon.dongwook.apps.vjdetector.models.IntegralImage;
	import kwon.dongwook.apps.vjdetector.models.ResultFilter;
	import kwon.dongwook.events.DataEvent;
	
	/**
	 * 
	 * Based on Viola-Jones face detector algorithm
	 * Which is Robust Real-Time Face Detection
	 * http://lear.inrialpes.fr/people/triggs/student/vj/viola-ijcv04.pdf
	 * 
	 * Implementation from mostly OpenCV
	 * http://sourceforge.net/projects/opencvlibrary/
	 * 
	 * ****  Other resources ****
	 * Learning OpenCV
	 * http://oreilly.com/catalog/9780596516130/
	 * 
	 * Seeing with OpenCV
	 * http://www.cognotics.com/opencv/servo_2007_series/index.html
	 * 
	 * Marilena on Spark project
	 * http://www.libspark.org/browser/as3/Marilena
	 * 
	 * *** External projects ****
	 * FZip 
	 * http://codeazur.com.br/lab/fzip/
	 * 
	 * 
	 * Main Detector class.
	 * The detector uses config.txt file for all the configuration, if it's missing use default value of Config class.
	 * Also it requires loading the cascade files and a preprocessing shader file for filter. 
	 * 
	 * @version 1.0
	 * @author Dongwook, Kwon
	 * 
	 */
	public class Detector extends EventDispatcher {
		
		public static const READY:String = "ready";
		[Event(name="ready", type="flash.events.Event")]
		public static const ERROR:String = "error";
		[Event(name="error", type="flash.events.ErrorEvent")]
		

		private var _preprocessor:Preprocessor;
		
		private var _loader:DataLoader;
		private var _isReady:Boolean = false;
		
		private var _cascades:Dictionary;
		private var _config:Config;
		public function get config():Config { return _config; }
		private var _bitmap:BitmapData;
		private var _resultFilter:ResultFilter;
		
		public function getCascade(name:String = null):HaarCascade {
			if (name == null)
				name = _config.defaultCascadeName;
			return _cascades[name];
		}
		
		public function Detector() {
			_preprocessor = new Preprocessor();
			_preprocessor.addEventListener(Preprocessor.READY, function(event:Event):void {
				loadConfig();
			}, false, 0, true);
		}
		
		public function load():void {
			_preprocessor.load();
		}
		
		private function loadConfig():void {
			_loader = new DataLoader();
			_loader.addEventListener(DataLoader.COMPLETE, onLoadEventHandler, false, 0, true);
			_loader.load();
			_resultFilter = new ResultFilter();
		}
		
		private function onLoadEventHandler(event:DataEvent):void {
			_isReady = true;
			_cascades = event.data.cascades;
			_config = event.data.config;
			dispatchEvent(new Event(READY));
		}
		
		/**
		 * Main function of detect
		 * Just passing bitmapData which has things you want to detect.
		 * All the configuration for this detector goes into config.txt file which is represented in Config class
		 * 
		 * Result will be the vector of rectangles which has position of object in input bitmapData.
		 * If the detector failed to find any, it will return null
		 * 
		 * @param bitmapData 
		 * @return Vector of Rectangle
		 * 
		 * @see Config.as
		 */
		public function detect(bitmapData:BitmapData):Vector.<Rectangle> {
			if (_isReady) {
				_bitmap = bitmapData;
				return getFindObjectsOn(bitmapData);
			} else {
				dispatchEvent(new ErrorEvent(ERROR, false, true, "Detector isn't ready to use."));
			}
			return null;
		}
		
		private function getMaxCheckCount(bitmapData:BitmapData = null):uint {
			if (!bitmapData)
				bitmapData = _bitmap;
			var ww:uint = getCascade().trainedWindowSize.width;
			var wh:uint = getCascade().trainedWindowSize.height;
			var iw:uint = bitmapData.width - 10;
			var ih:uint = bitmapData.height - 10;
			var maxCheckCount:uint = 0;
			var scale:Number = _config.scaleFactor;
			for(var i:Number = 1; (i * ww) < iw && (i * wh) < ih; i *= scale)
				maxCheckCount++;
			return --maxCheckCount;
		}
		
		private function getFindObjectsOn(bitmapData:BitmapData):Vector.<Rectangle> {
			var objects:Vector.<Rectangle> = new Vector.<Rectangle>();
			var integralImage:IntegralImage = new IntegralImage(bitmapData, _preprocessor.getProcessedVector(bitmapData));
			var cascade:HaarCascade = getCascade();
			cascade.integralImage = integralImage;
			var width:uint = bitmapData.width , height:uint = bitmapData.height;
			
			var scaleFactor:Number = _config.scaleFactor;
			var minSize:Rectangle = _config.minSize.clone();
			var trainedWindowSize:Rectangle = cascade.trainedWindowSize;
			
			var maxCount:uint = getMaxCheckCount();
			var currentScale:Number = Math.pow(scaleFactor, maxCount-1);
			
			detectLoop: for (var count:uint = maxCount; count > 0; count--, currentScale /= scaleFactor) {
				var rect:Rectangle = new Rectangle();
				rect.width = Math.round(trainedWindowSize.width * currentScale);
				rect.height = Math.round(trainedWindowSize.height * currentScale);

				if (rect.width < minSize.width || rect.height < minSize.height)
					continue;

				var step:Point = new Point(1 , Math.max(currentScale, 2));
				var end:Point = new Point(Math.round((width - rect.width)/step.y), Math.round((height - rect.height)/step.y));
				var start:Point = new Point();
				cascade.setScaleAndWeight(currentScale);
				for (var iy:uint = start.y; iy < end.y; iy += step.y) {
					rect.y = Math.round(iy * step.y);
					for (var ix:uint = start.x; ix < end.x; ix += step.x) {
						rect.x = Math.round(ix * step.y);
						if (cascade.checkOf(rect)) {
							objects.push(rect.clone());
							if (_config.findBiggest && objects.length >= _config.minNeighbors)
								break detectLoop;
						}
					}
				}
			} 
			return _config.minNeighbors < 1 ? objects: _resultFilter.getResults(objects, _config.minNeighbors);
		}
		
	}
}