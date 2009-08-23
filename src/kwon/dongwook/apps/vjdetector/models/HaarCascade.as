
 
package kwon.dongwook.apps.vjdetector.models {
	
	
	import flash.geom.Rectangle;
	
	public class HaarCascade {

		private var _scale:Number;
		private var _weightScale:Number;
				
		public var name:String;
		public var trainedWindowSize:Rectangle;
		public var stages:Vector.<HaarStage>;
		private var _integralImage:IntegralImage;
		public var hasTiltedFeature:Boolean;
		
		public function set integralImage(image:IntegralImage):void { _integralImage = image; }
		public function get integralImage():IntegralImage {
			if (_integralImage == null)
				trace("Error : There is no Integral Image.");
			return _integralImage;
		}
		
		public function HaarCascade() {
			trainedWindowSize = new Rectangle();
		}
		
		private var _scaledWindowSize:Rectangle;
		
		/**
		 * Will rescale and re-weight all the classifiers
		 * Need to set this before check of the area of image
		 * 
		 * @param value : scale 
		 * 
		 */
		public function setScaleAndWeight(value:Number):void {
			if (_scale == value)
				return;

			_scale = value;
			if (!_scaledWindowSize)
				_scaledWindowSize = new Rectangle();
			_scaledWindowSize.width = Math.round(trainedWindowSize.width * _scale);
			_scaledWindowSize.height = Math.round(trainedWindowSize.height * _scale);
			_weightScale = 1 / (_scaledWindowSize.width * _scaledWindowSize.height);
			var correctionRatio:Number = _weightScale * (hasTiltedFeature ? 0.5: 1);
			for each(var stage:HaarStage in stages) {
				for each(var classifier:HaarClassifier in stage.classifiers) {
					classifier.feature.setScaleAndWeight(_scale, correctionRatio);
				}
			}
		}

		/**
		 * Checking the area of the image whether it has object/face. 
		 * 
		 * @param rect : Area of image to check
		 * @return Boolean whether this area contains Object/Face 
		 * 
		 */
		public function checkOf(rect:Rectangle):Boolean {
			var mean:Number = integralImage.getSumOf(rect) * _weightScale;
			var varianceNormalizeFactor:Number = (integralImage.getSquareSumOf(rect) * _weightScale) - (mean * mean);
			varianceNormalizeFactor = varianceNormalizeFactor >= 0 ? Math.sqrt(varianceNormalizeFactor): 1;
			var sum:Number = 0;
			for each(var stage:HaarStage in stages) {
				var stageSum:Number = 0;
				var stageThreshold:Number = stage.threshold;
				for each(var classifier:HaarClassifier in stage.classifiers) {
					var feature:HaarFeature = classifier.feature;
					sum = feature.getSumAt(rect.topLeft, integralImage);
					stageSum += (sum < (classifier.threshold * varianceNormalizeFactor)) ? classifier.left: classifier.right;
				}
				if (stageSum < stageThreshold)
					return false;
			}
			return true;
		}
	}
}