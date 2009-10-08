package kwon.dongwook.apps.vjdetector.samples.views {
	
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.Camera;
	import flash.media.Video;

	public class VideoPanel extends MovieClip {
		
		public static const FLIP:String = "flip";
		
		private var _video:Video;
		private var _camera:Camera;
		private const CAMERA_WIDTH_SCALE:Number = 1.5;
		private const CAMERA_HEIGHT_SCALE:Number = 1.5; 
		
		public var menuPanel:MenuPanel;
		
		public var _bitmapData:BitmapData;
		public function get bitmapData():BitmapData {
			_bitmapData.lock();
			_bitmapData.draw(_video);
			_bitmapData.unlock();
			return _bitmapData;
		}
		
		public function VideoPanel() {
			_useImageButton.addEventListener(MouseEvent.CLICK, onClickUseImageButtonEventListener);
		}
		
		public function startVideo():void {
			_camera = Camera.getCamera();
			if (_camera != null) {
				if (_video == null) {
					var w:uint = _camera.width * CAMERA_WIDTH_SCALE;
					var h:uint = _camera.height * CAMERA_HEIGHT_SCALE;
					_video = new Video(w, h);
					_container.addChild(_video);
					_bitmapData = new BitmapData(w, h, false, 0);
					_container.x = _results.x = _edge.x = -(w / 2);
					_container.y = _results.y = _edge.y = -(h / 2);
					_edge.visible = false;
					_edge.bitmap.bitmapData = new BitmapData(w, h, false, 0);
				}
				_video.attachCamera(_camera);
			} else {
				trace("No Camera");
				if (menuPanel)
					menuPanel.displayResult("No camera");
			}
		}
		
		public function stopVideo():void {
			_video.attachCamera(null);
		}
		
		private function onClickUseImageButtonEventListener(event:MouseEvent):void {
			stopVideo();
			dispatchEvent(new Event(FLIP));
		}
		
		public function drawEdge(bData:BitmapData):void {
			_edge.bitmap.bitmapData.draw(bData);
		}
		
		public function disposeEdge():void {
			
		}
	}
}