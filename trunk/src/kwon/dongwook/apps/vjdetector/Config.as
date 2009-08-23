package kwon.dongwook.apps.vjdetector {
	
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import kwon.dongwook.utils.StringUtil;
	
	/**
	 * Configuration file for detector
	 * Because the most of the parameters are from OpenCV, if you're familiar with OpenCV
	 * it's easy to figure out.
	 * 
	 * @author Dongwook, Kwon
	 * 
	 */
	public class Config {
		
		
		/**
		 * it's not implemented feature.
		 * In OpenCV, Canny Edge detection is used to prune scan for speeding up of detection
		 * However, I'm not sure Canny Edge detection is fast enough in Flash.
		 * It requires tests but worth to try.
		 *  
		 */
		public static const DO_CANNY_PRUNING:uint = 1;
		
		/** 
		 * The location of cascade file which is zipped 
		 * In order to generate proper zip file, you need fzip-prepare.py file
		 * Take a look at http://codeazur.com.br/lab/fzip/ for details.
		 * 
		 */
		public var dataFile:String = "data/haarcascades.zip";
		public var cascadeFiles:Dictionary;
		
		/**
		 *  default name of cascade file which is used for current detection
		 */ 
		public var defaultCascadeName:String = "haarcascade_frontalface_default";
		
		/** 
		 *	The detector searches target objects on all the area of the image from the size of minSize through biggest it can get.
		 *	After scan with minSize of area, the area of scanning will be increased by scaleFactor which means,
		 *	in this case, 1.3 will increase 30% of previous size.
		 *	It will affect of speed and accuracy, so if you increase scaleFactor, 
		 *	the detector will lose an accuracy while gaining a speed and vice versa
		 * 	Basically it's the same parameter as in OpenCV
		 */  
		public var scaleFactor:Number = 1.3;
		
		public var flags:uint = 0;
		
		/**
		 * It will tell how many overlapped results take as one result.
		 * Usually detector finds a lots of different scale of faces around one face including noises.
		 * In order to tell the result is right object, this parameter will be used.
		 * If the number of one group of the result is below this, that result take it as a noise.
		 * 
		 * By increasing this number you can get less but correct result.
		 * Lower number of this parameter will give you more results but might be more noise too.
		 * 
		 * With small size of image
		 * 1~2 should be good number in practice.
		 * And for large size of image
		 * 3~4 is better result
		 * 
		 * Setting this to 0 will give you all the detected results. 
		 * 
		 */
		public var minNeighbors:uint = 2;
		
		/**
		 * Starting size for scanning image of detection.
		 * By increasing this parameter the detection speed will be up.
		 * However you need to keep that in mind that the detector can not find any object/face small than this size.
		 * 
		 */
		public var minSize:Rectangle = new Rectangle(0, 0, 40, 40);
		
		/**
		 * When it's true, detector will return the results as soon as find the minNeighbors number of the results 
		 * It will greatly increase the speed but lose an accuracy and it will return only one object(face).
		 * 
		 */
		public var findBiggest:Boolean = false;
		
		public function Config() {
			cascadeFiles = new Dictionary();
			cascadeFiles["haarcascade_frontalface_default"] = "haarcascade_frontalface_default.xml";
		}
		
		/**
		 * 
		 * @param name : the name of the Cascade file
		 * @return : the path of the cascade file
		 * 
		 */
		public function getFilePath(name:String = null):String {
			return cascadeFiles[ (name == null ? defaultCascadeName: name)];
		}
		
		/**
		 * 
		 * @param path : path of the cascade file
		 * @return : the name of Cascade file
		 * 
		 */
		public function getName(path:String):String {
			path = StringUtil.trim(path);
			for (var str:String in cascadeFiles) {
				if (cascadeFiles[str] == path)
					return str;
			}
			return undefined;
		}
		
	}
}