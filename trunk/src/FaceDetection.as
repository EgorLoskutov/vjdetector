package {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	import kwon.dongwook.apps.vjdetector.Detector;
	import kwon.dongwook.log.TimeRecorder;
	import kwon.dongwook.utils.MathUtil;

	[SWF(width="1000", height="700", backgroundColor="#000000", framerate="30")]
	public class FaceDetection extends Sprite {
		
		private var _detector:Detector;
		private var _loader:Loader;
		private var _borderCanvas:Sprite;
		private var _videoMode:Boolean = false;
		private var _video:Video;
		private var _bitmapData:BitmapData;
		private var _paintMatrix:Matrix;
		private var _camera:Camera;
		private var _onCamera:Boolean = false;
		private var _message:TextField;
		
		public function FaceDetection() {
			_message = new TextField();
			_message.width = 200;
			_message.height = 200;
			_message.x = 580;
			_message.y = 380;
			addChild(_message);
			_detector = new Detector();
			_detector.addEventListener(Detector.READY, onReadyEventHandler);
			_detector.load();
		}
		
		private function createChildren():void {
			_borderCanvas = new Sprite();
		}
		
		private function onReadyEventHandler(event:Event):void {
			createChildren();
			p("Ready to detect face");
			if (_videoMode) {
				createVideo();
			} else {
				_loader = new Loader();
				_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadImageEventHandler, false, 0, true);
				_loader.load(new URLRequest("lena.jpg"));
			}
		}
		
		private function createVideo():void {
			_camera = Camera.getCamera();
			if (_camera != null) {
				_camera.addEventListener(flash.events.Event.ACTIVATE, onCameraActivityEventHandler);
				_video = new Video(_camera.width, _camera.height);
				_video.attachCamera(_camera);
				addChild(_video);
				addChild(_borderCanvas);
			}
		}
		
		private function onCameraActivityEventHandler(event:Event):void {
			if (!_onCamera) {
				_onCamera = true;
				_bitmapData = new BitmapData(_camera.width, _camera.height, false, 0);
				_paintMatrix = new Matrix();
				var timer:Timer = new Timer(1000);
				timer.addEventListener(TimerEvent.TIMER, onTimeForCameraEventHandler, false, 0, true);
				timer.start();
			}
		}
		
		private function onTimeForCameraEventHandler(event:TimerEvent):void {
			_bitmapData.lock();
			_bitmapData.draw(_video);
			_bitmapData.unlock();
			startDetect(_bitmapData);
		}
		
		private function onLoadImageEventHandler(event:Event):void {
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadImageEventHandler);
			addChild(_loader.content);
			addChild(_borderCanvas);
			var timer:Timer = new Timer(200, 1);
			timer.addEventListener(TimerEvent.TIMER, onTimeForImageEventHandler, false, 0, true);
			timer.start();
		}
		
		private function onTimeForImageEventHandler(event:TimerEvent):void {
			_bitmapData = Bitmap(_loader.content).bitmapData;
			startDetect(_bitmapData);
		}
		
		private function startDetect(bitmap:BitmapData):void {
			TimeRecorder.start("Start detect", _message);
			var faces:Vector.<Rectangle> = _detector.detect(bitmap);
			TimeRecorder.end("End detect : " + faces.length, _message);
			if (faces) {
				_borderCanvas.graphics.clear();
				faces.forEach(function (face:Rectangle, index:int, vector:Vector.<Rectangle>):void {
					drawBorder(face);
				}, this);
			}
		}
		
		private function drawBorder(rect:Rectangle):void {
			_borderCanvas.graphics.lineStyle(2, 0x14B0FF * MathUtil.randomInRange(0, 255));
			_borderCanvas.graphics.drawEllipse(rect.x, rect.y, rect.width, rect.height);
		}
		
	}
}
