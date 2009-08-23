package kwon.dongwook.apps.vjdetector.models {
	
	
	public class HaarClassifier {
		
		public var index:uint;
		public var feature:HaarFeature;
		public var threshold:Number;
		public var right:Number;
		public var left:Number;
		
		public function HaarClassifier(index:uint = 0) {
			this.index = index;
		}

	}
}