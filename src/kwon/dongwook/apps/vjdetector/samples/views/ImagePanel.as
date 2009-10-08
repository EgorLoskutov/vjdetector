package kwon.dongwook.apps.vjdetector.samples.views {
	
		
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	
	import kwon.dongwook.apps.vjdetector.samples.Showcase;
	import kwon.dongwook.network.FileUploader;
	
	public class ImagePanel extends MovieClip {
		
		[Event(name="loaded", type="flash.events.Event")]
		public static const LOADED:String = "loaded";
		
		[Event(name="flip", type="flash.events.Event")]
		public static const FLIP:String = "flip";
		
		private var _bitmapData:BitmapData;
		public function get bitmapData():BitmapData {
			if (_bitmapData != null) {
				_bitmapData.dispose();
			}
			if (_bitmap.width <= _frameWidth && _bitmap.height <= _frameHeight) {
				_bitmapData = new BitmapData(_bitmap.width, _bitmap.height, false);
				_bitmapData.draw(_container);
				_results.x = _edge.x = _container.x;
				_results.y = _edge.y = _container.y;
			} else {
				_bitmapData = new BitmapData(_frameWidth, _frameHeight, false);
				_bitmapData.draw(_container, 
					new Matrix(1, 0, 0, 1, _container.x - _containerX, _container.y - _containerY));
			}
			setEdgeBitmapData(_bitmapData);
			return _bitmapData;
		}
		
		public var mainView:Showcase;
		private var _bitmap:Bitmap;
		private var _loader:Loader;
		private var _uploadedImage:Boolean = false;
		private var _mousePressed:Boolean = false;
		private var _containerX:Number;
		private var _containerY:Number;
		private const ZOOM_STEP:Number = 0.1;
		
		private var _frameWidth:uint = 360;
		private var _frameHeight:uint = 450;
		
		public function ImagePanel() {
			super();
			setEventHandlers();
			setMouseEventHandlers(true);
			_containerX = _container.x;
			_containerY = _container.y;
			_edge.visible = false;
		}
		
		public function drawEdge(bData:BitmapData):void {
			_edge.bitmap.bitmapData.draw(bData);
		}
		
		public function disposeEdge():void {
			if (_edge.bitmap.bitmapData != null) {
				_edge.bitmap.bitmapData.dispose();
			}
		}
		
		private function setEdgeBitmapData(bm:BitmapData):void {
			disposeEdge();
			_edge.bitmap.bitmapData = bm.clone();
		}
		
		private function setEventHandlers():void {
			_uploadButton.addEventListener(MouseEvent.CLICK, onUploadButtonClickEventHandler);
			_useTestImageButton.addEventListener(MouseEvent.CLICK, onUseTestImageButtionClickEventHandler);
			_useVideoButton.addEventListener(MouseEvent.CLICK, onVideoButtonClickEventHandler);
			_zoomInButton.addEventListener(MouseEvent.CLICK, zoomInEventHandler);
			_zoomOutButton.addEventListener(MouseEvent.CLICK, zoomOutEventHandler);
		}
		
		private function setMouseEventHandlers(setEvents:Boolean = true):void {
			if (setEvents) {
				_container.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownEventHandler);
				_container.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveEventHandler);
				_container.addEventListener(MouseEvent.MOUSE_UP, mouseUpEventHandler);
				_container.addEventListener(MouseEvent.MOUSE_OUT, mouseOutEventHandler);
			} else {
				_container.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownEventHandler);
				_container.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveEventHandler);
				_container.removeEventListener(MouseEvent.MOUSE_UP, mouseUpEventHandler);
				_container.removeEventListener(MouseEvent.MOUSE_OUT, mouseOutEventHandler);
			}
		}
		
		private function enableZoom(setOn:Boolean = true):void {
			_zoomInButton.enable(setOn);
			_zoomOutButton.enable(setOn);
		}
		
		private function useTestImage():void {
			enableZoom(false);
			removeBitmap();
			var bData:BitmapData = new LenaImage(_container.width, _container.height);
			_bitmap = new Bitmap(bData);
			_container.addChildAt(_bitmap, 0);
			dispatchEvent(new Event(LOADED));
		}
		
		private function removeBitmap():void {
			_results.x = _edge.x = _container.x = _containerX;
			_results.y = _edge.y = _container.y = _containerY;
			if (_bitmap != null || _container.numChildren > 0) {
				_container.removeChildAt(0);
			}
			if (_bitmapData != null) {
				_bitmapData.dispose();
			}
			if (_edge.bitmap.bitmapData != null) {
				_edge.bitmap.bitmapData.dispose();
			}
		}
		
		private function setImage(image:Bitmap):void {
			removeBitmap();
			enableZoom(true);
			_bitmap = image;
			_container.addChildAt(_bitmap, 0);
		}
		
		// EventHandlers
		private function onImageLoadedEventHandler(event:Event):void {
			_uploadedImage = true;
			setImage(Bitmap(_loader.content));
			dispatchEvent(new Event(LOADED));
		}
		
		private function onImageUploadedEventHandler(event:Event):void {
			var fileURL:String = event.target.fileURL;
			if (!_loader) {
				_loader = new Loader();
				_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageLoadedEventHandler, false, 0, false);
				_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void {
					trace("io error; " + event);
				});
			} else {
				_loader.unload();
			}
			_loader.load(new URLRequest(fileURL));
		}
		
		private function onUploadButtonClickEventHandler(event:MouseEvent):void {
			_uploadedImage = true;
			if (mainView)
				mainView.displayLoading(true);
			var fileUploader:FileUploader = new FileUploader("http://actionfigure.pe.kr/service/file/save", "http://actionfigure.pe.kr/service/files/");
			fileUploader.addEventListener(FileUploader.LOADED, onImageUploadedEventHandler, false, 0, false);
			fileUploader.addEventListener(Event.CANCEL, cancelImageEventHandler);
			fileUploader.upload();
		}
		
		private function cancelImageEventHandler(event:Event):void {
			_uploadedImage = false;
			if (mainView)
				mainView.displayLoading(false);
		}
		
		private function onUseTestImageButtionClickEventHandler(event:MouseEvent):void {
			_uploadedImage = false;
			useTestImage();
		}
		
		private function onVideoButtonClickEventHandler(event:MouseEvent):void {
			_uploadedImage = false;
			dispatchEvent(new Event(FLIP));
		}
		
		private function zoomOutEventHandler(event:Event):void {
			if (_zoomOutButton._enabled) {
				_bitmap.scaleX -= ZOOM_STEP;
				_bitmap.scaleY -= ZOOM_STEP;
				checkZoomButtons();
			}
		}
		
		private function checkZoomButtons():void {
			_zoomOutButton.enable(!((_bitmap.width <= _frameWidth && _bitmap.scaleX <= 1) ||
					(_bitmap.height <= _frameHeight && _bitmap.scaleY <= 1)));
			_zoomInButton.enable(!(_bitmap.scaleX >= 2 || _bitmap.scaleY >= 2));
		}
		
		private function zoomInEventHandler(event:Event):void {
			if (_zoomInButton._enabled) {
				_bitmap.scaleX += ZOOM_STEP;
				_bitmap.scaleY += ZOOM_STEP;
				checkZoomButtons();
			}
		}
		
		private function mouseDownEventHandler(event:MouseEvent):void {
			if (_uploadedImage && !_mousePressed) {
				_mousePressed = true;
				_container.startDrag();
			}
		}
		
		private function mouseOutEventHandler(event:MouseEvent):void {
			if (_uploadedImage && _mousePressed) {
				_mousePressed = false;
				_container.stopDrag();
			}
		}
		
		private function mouseMoveEventHandler(event:MouseEvent):void {
			if (_uploadedImage && _mousePressed) {
			}
		}
		
		private function mouseUpEventHandler(event:MouseEvent):void {
			if (_uploadedImage && _mousePressed) {
				_mousePressed = false;
				_container.stopDrag();
			}
		}
	}
}