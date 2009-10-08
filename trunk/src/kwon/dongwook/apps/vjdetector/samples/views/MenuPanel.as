package kwon.dongwook.apps.vjdetector.samples.views {
	
	
	import fl.events.*;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import kwon.dongwook.apps.vjdetector.Config;
	import kwon.dongwook.events.DataEvent;
	

	public class MenuPanel extends MovieClip {
		
		public static const START_DETECT:String = "startDetect";
		[Event(name="startDetect", type="flash.events.Event")]
		
		public static const STOP_DETECT:String = "stopDetect";
		[Event(name="stopDetect", type="flash.events.Event")]
		
		public static const SHOW_EDGE:String = "showEdge";
		[Event(name="showEdge", type="kwon.dongwook.events.DataEvent")]
		
		private var _findBiggestForImage:Boolean = false;
		private var _enableDetect:Boolean = false;
		private var _doCannyPruning:Boolean = true;
		private var _showCannyEdge:Boolean = false;
		
		private var _tempVideoConfig:Config;
		private var _tempImageConfig:Config;
		private var _config:Config;
		
		public function MenuPanel() {
			super();

			_scaleFactorField.addEventListener(SliderEvent.CHANGE, changeScaleFactorEventHandler);
			_minSizeField.addEventListener(SliderEvent.CHANGE, changeMinSizeEventHandler);
			_minNeighborField.addEventListener(Event.CHANGE, changeMinNeighborEventHandler);
			_cascadeFilesField.addEventListener(Event.CHANGE, changeCascadeEventHandler);
			_detectButton.addEventListener(MouseEvent.CLICK, clickDetectButtonEventHandler);
			_findBiggestField.addEventListener(MouseEvent.CLICK, clickFindBiggestEventHandler);
			_doCannyPruningField.addEventListener(MouseEvent.CLICK, clickDoCannyPruningEventHandler);
			_showCannyEdgeField.addEventListener(MouseEvent.CLICK, clickShowCannyEdgeEventHandler);
			
			_tempVideoConfig = new Config();			
			_tempVideoConfig = new Config();
			_tempVideoConfig.scaleFactor = 1.4;
			_tempVideoConfig.minNeighbors = 1;
			_tempVideoConfig.minSize = new Rectangle(0, 0, 50, 50);
			_tempVideoConfig.findBiggest = true;
			_tempVideoConfig.doCannyPruning = false;
			_tempVideoConfig.showCannyEdge = false;
			_tempImageConfig = new Config();
		}
		
		public function switchVideoMode(turnOn:Boolean):void {
			displayResult("");
			if (turnOn) {
				copyConfig(_tempImageConfig, _config);
				copyConfig(_config, _tempVideoConfig);
				_enableDetect = _detectButton.enabled;
				_detectButton.enabled = true;
				_detectButton.toggle = true;
				_findBiggestForImage = _findBiggestField.selected;
				_doCannyPruning = _doCannyPruningField.selected;
				_showCannyEdge = _showCannyEdgeField.selected;
				_findBiggestField.selected = _tempVideoConfig.findBiggest;
				_doCannyPruningField.selected = _tempVideoConfig.doCannyPruning;
				_showCannyEdgeField.selected = _tempVideoConfig.showCannyEdge;
			} else {
				copyConfig(_tempVideoConfig, _config);
				copyConfig(_config, _tempImageConfig);
				_detectButton.label = "Detect";
				_detectButton.enabled = _enableDetect;
				_detectButton.toggle = false;
				_findBiggestField.selected = _findBiggestForImage;
				_doCannyPruningField.selected = _doCannyPruning;
				_showCannyEdgeField.selected = _showCannyEdge;
			}
			_showCannyEdgeField.enabled = _config.doCannyPruning;
		}
		
		private function copyConfig(target:Config, src:Config):void {
			target.minSize = src.minSize.clone();
			target.scaleFactor = src.scaleFactor;
			target.minNeighbors = src.minNeighbors;
			target.doCannyPruning = src.doCannyPruning;
			target.showCannyEdge = src.showCannyEdge;
			setFields(src);
		}
		
		private function setFields(obj:Config):void {
			scaleFactor = _scaleFactorField.value = obj.scaleFactor;
			minSize = _minSizeField.value = obj.minSize.width;
			_minNeighborField.value = obj.minNeighbors;
			
		}
		
		public function set config(obj:Config):void {
			_config = obj;
			setFields(obj);
			for (var fileName:String in _config.cascadeFiles) {
				_cascadeFilesField.addItem({label:fileName.replace("haarcascade_", ""), data:fileName});
				if (fileName == _config.defaultCascadeName)
					_cascadeFilesField.selectedIndex = _cascadeFilesField.length-1;
			}
			_findBiggestField.selected = _config.findBiggest;
			_doCannyPruningField.selected = _config.doCannyPruning;
			_showCannyEdgeField.selected = _config.showCannyEdge;
			_tempVideoConfig
		}
		
		public function displayResult(message:String):void {
			_resultLabel.text = message;
		}
		
		public function set detectButton(enable:Boolean):void {
			_detectButton.enabled = enable;
		}
		
		private function set scaleFactor(value:Number):void {
			_scaleFactorLabel.text = "Scale factor : " + _config.scaleFactor;
		}
		
		private function set minSize(value:Number):void {
			_minSizeLabel.text = "Minimum size : " + _config.minSize.width + " x " + _config.minSize.height;			
		}
		
		// Event Handlers
		private function changeScaleFactorEventHandler(event:SliderEvent):void {
			_config.scaleFactor = event.target.value;
			scaleFactor = event.target.value;
		}

		private function changeMinSizeEventHandler(event:SliderEvent):void {
			_config.minSize.width = _config.minSize.height = event.target.value;
			minSize = event.target.value;
		}
		
		private function changeMinNeighborEventHandler(event:Event):void {
			_config.minNeighbors = event.target.value;
		}
		
		private function changeCascadeEventHandler(event:Event):void {
			_config.defaultCascadeName = event.target.value;
		}
		
		private function clickDetectButtonEventHandler(event:MouseEvent):void {
			if (_detectButton.toggle) {
				_detectButton.label = _detectButton.selected ? "Detect": "STOP";
				dispatchEvent(new Event(_detectButton.selected ? STOP_DETECT: START_DETECT));
			} else {
				_detectButton.label = "Detect";
				_resultLabel.text = "Start detect : ";
				dispatchEvent(new Event(START_DETECT));
			}
		}
		
		private function clickFindBiggestEventHandler(event:MouseEvent):void {
			_config.findBiggest = event.target.selected;
		}
		
		private function clickDoCannyPruningEventHandler(event:MouseEvent):void {
			_config.doCannyPruning = event.target.selected;
			if (!_config.doCannyPruning) {
				_showCannyEdgeField.selected = false;
				var dEvent:DataEvent = new DataEvent(SHOW_EDGE);
				dEvent.data = false;
				dispatchEvent(dEvent);
			}
			_showCannyEdgeField.enabled = _config.doCannyPruning;
		}
		
		private function clickShowCannyEdgeEventHandler(event:MouseEvent):void {
			_config.showCannyEdge = event.target.selected;
			var dataEvent:DataEvent = new DataEvent(SHOW_EDGE);
			dataEvent.data = event.target.selected;
			dispatchEvent(dataEvent);
		}
	}
}