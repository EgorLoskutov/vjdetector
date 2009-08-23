package kwon.dongwook.apps.vjdetector.models {
	
	import flash.geom.Rectangle;
	
	/**
	 * Parsing Cascade xml file which from OpenCV project.
	 * Therefore, The cascade xml file is compatiable with OpenCV's
	 * 
	 * @author Dongwook Kwon
	 * 
	 */
	public class HaarDataParser {

		private var _hasTiltedFeature:Boolean;
		private var _size:Rectangle;
		
		public function parse(xml:XML):HaarCascade {
			_hasTiltedFeature = false;
			var cascade:HaarCascade = new HaarCascade();
			var rootList:XMLList = xml.children();
			cascade.name = XML(xml.children()).name().toString();
			var point:Array = String(rootList.size).split(" ");
			if (point.length == 2) {
				cascade.trainedWindowSize.width = uint(point[0]);
				cascade.trainedWindowSize.height = uint(point[1]);
				_size = cascade.trainedWindowSize;
			}
			var stageList:XMLList = rootList.stages._;
			if (stageList.length() > 0) {
				cascade.stages = makeStages(stageList);
			}
			cascade.hasTiltedFeature = _hasTiltedFeature;
			return cascade;
		}
		
		private function makeStages(stageList:XMLList):Vector.<HaarStage> {
			var count:uint = 0;
			var previous:HaarStage;
			var stages:Vector.<HaarStage> = new Vector.<HaarStage>();
			for each (var stageNode:XML in stageList) {
				var current:HaarStage = new HaarStage(count++);
				current.threshold = Number(stageNode.stage_threshold);
				current.classifiers = makeClassifiers(stageNode.trees);
				current.parent = previous;
				if (previous)
					previous.child = current;
				previous = current;
				stages.push(current);
			}
			return stages;
		}
		
		private function makeClassifiers(treeList:XMLList):Vector.<HaarClassifier> {
			var classifiers:Vector.<HaarClassifier> = new Vector.<HaarClassifier>();
			for each (var treeNode:XML in treeList._._) {
				var classifier:HaarClassifier = new HaarClassifier(classifiers.length);
				classifier.feature = makeFeature(treeNode.feature);
				classifier.threshold = Number(treeNode.threshold);
				classifier.left = Number(treeNode.left_val);
				classifier.right = Number(treeNode.right_val);
				classifiers.push(classifier);
			}
			return classifiers;
		}
		
		private function makeFeature(featureList:XMLList):HaarFeature {
			var feature:HaarFeature = new HaarFeature();
			for each(var rect:XML in featureList.rects._) {
				var rectangle:HaarRectangle = HaarRectangle.createRectangleFrom(rect.toString(), _size);
				if (rectangle)
					feature.rectangles.push(rectangle);
			}
			feature.tilted = Boolean(int(featureList.tilted));
			if (feature.tilted)
				_hasTiltedFeature = true;
			return feature;
		}
		
	}
}