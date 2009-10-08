package kwon.dongwook.apps.vjdetector.samples {

	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import kwon.dongwook.apps.vjdetector.Detector;
	import kwon.dongwook.apps.vjdetector.samples.views.ImagePanel;
	import kwon.dongwook.apps.vjdetector.samples.views.MenuPanel;
	import kwon.dongwook.apps.vjdetector.samples.views.VideoPanel;
	import kwon.dongwook.events.DataEvent;
	import kwon.dongwook.utils.Animator;
	
	[SWF(width="600", height="500", backgroundColor="#000000", framerate="30")]
	public class Showcase extends Sprite {

		private var _detector:Detector;
		private var _isImageMode:Boolean = true;
		private var _startTime:Date;
		private var _resultMessage:String;

		public function Showcase() {
			createViews();
			createModels();
		}
		
		private function createViews():void {
			_imagePanel.addEventListener(ImagePanel.LOADED, onLoadImageEventHandler);
			_imagePanel.addEventListener(ImagePanel.FLIP, onFlipEventHandler);
			_imagePanel.mainView = this;
			_videoPanel.visible = false;
			_videoPanel.addEventListener(VideoPanel.FLIP, onFlipEventHandler);
			_videoPanel.menuPanel = _menuPanel;
			_menuPanel.addEventListener(MenuPanel.START_DETECT, onDetectEventHandler);
			_menuPanel.addEventListener(MenuPanel.STOP_DETECT, onStopDetectEventHandler);
			_menuPanel.addEventListener(MenuPanel.SHOW_EDGE, showEdgeEventHandler);
		}
		
		private function createModels():void {
			_detector = new Detector();
			_detector.addEventListener(Detector.READY, onReadyDetectorEventHandler, false, 0, true);
			_detector.load();
		}

		private function showEdgeEventHandler(event:DataEvent):void {
			var panel:MovieClip = _isImageMode ? _imagePanel: _videoPanel;
			panel._edge.visible = Boolean(event.data);
		}
		
		private function detect(bitmapData:BitmapData):void {
			_startTime = new Date();
			var rects:Vector.<Rectangle> = _detector.detect(bitmapData);
			var panel:MovieClip = _isImageMode ? _imagePanel: _videoPanel;
			if (_detector.config.doCannyPruning) {
				if (_detector.config.showCannyEdge) {
					panel.drawEdge(bitmapData);
				} else if (panel._edge.bitmap.bitmapData != null) {
					panel.disposeEdge();
				}
			}
			
			drawResults(rects, panel);
			_resultMessage = "Find (" + rects.length + ") faces\n";
			_resultMessage += "Elapsed time : " + ((new Date().getTime() - _startTime.getTime()) / 1000) + "secs\n"; 
			_menuPanel.displayResult(_resultMessage);
			displayLoading(false);
		}
		
		public function drawResults(areas:Vector.<Rectangle>, container:MovieClip):void {
			if (container._results.numChildren > 0)
				container._results.removeChildAt(0);
			if (areas.length > 0) {
				var canvas:Sprite = new Sprite();
				for each(var area:Rectangle in areas) {
					var rect:FrameRect = new FrameRect();
					rect.x = area.x;
					rect.y = area.y;
					rect.width = area.width;
					rect.height = area.height;
					canvas.addChild(rect);
				}
				container._results.addChildAt(canvas, 0);
			}
		}
		
		private var _timer:Timer;
		// Event Handlers
		private function onDetectEventHandler(event:Event):void {
			if (_isImageMode) {
				displayLoading(true);
				var timer:Timer = new Timer(100, 1);
				timer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
					detect(_imagePanel.bitmapData);
				}, false, 0, true);
				timer.start();
			} else {
				if (_timer == null) {
					_timer = new Timer(1000, 0);
					_timer.addEventListener(TimerEvent.TIMER, onTimerToDetectOnVideoEventHandler);
				}
				_timer.start();
			}
		}
		
		private function onTimerToDetectOnVideoEventHandler(event:TimerEvent):void {
			detect(_videoPanel.bitmapData);
		}
		
		private function onReadyDetectorEventHandler(event:Event):void {
			displayLoading(false);
			_menuPanel.config = _detector.config;
		}
		
		private function onLoadImageEventHandler(event:Event):void {
			_isImageMode = true;
			_menuPanel.detectButton = true;
			displayLoading(false);
			drawResults(new Vector.<Rectangle>(), _imagePanel);
		}
		
		private function onFlipEventHandler(event:Event):void {
			_isImageMode = event.target is VideoPanel;
			if (_isImageMode && _timer != null) {
				_timer.stop();
			}
			var targetClip:MovieClip = !_isImageMode ? _videoPanel: _imagePanel;
			Animator.flip(MovieClip(event.target), targetClip, _isImageMode, callBackFromAnimator);
		}
		
		private function onStopDetectEventHandler(event:Event):void {
			if (!_isImageMode) {
				_timer.stop();
			}
		}
		
		private function callBackFromAnimator():void {
			if(_isImageMode) {
				
			} else {
				_videoPanel.startVideo();
			}
			_menuPanel.switchVideoMode(!_isImageMode);
		}
		
		public function displayLoading(show:Boolean):void {
			_loadingPanel.visible = show;
		}
		
	}
}
