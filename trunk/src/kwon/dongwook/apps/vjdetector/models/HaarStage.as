package kwon.dongwook.apps.vjdetector.models {
	
	public class HaarStage {

		public static const THRESHOLD_BIAS:Number = 0; // 0.0001
				
		public var index:uint;
		public var threshold:Number;
		public var classifiers:Vector.<HaarClassifier>;
		
		public var next:HaarStage;
		public var child:HaarStage;
		public var parent:HaarStage;
		
		public function HaarStage(index:uint = 0) {
			this.index = index;
		}

	}
}