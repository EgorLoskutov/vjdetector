package kwon.dongwook.network {
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	
	
	public class FileUploader extends EventDispatcher {
		
		public static const LOADED:String = "loaded";
		[Event(name="loaded", type="flash.events.Event")]
		
		public static const CANCEL:String = Event.CANCEL;
		[Event(name=CANCEL, type="flash.events.Event")]
		
		private var _fileRef:FileReference;
		private var _serverURL:String;
		private var _filePath:String;
		private var _fileName:String;
		
		public function FileUploader(serviceURL:String, fileURL:String) {
			_serverURL = serviceURL;
			_filePath = fileURL;
			_fileRef = new FileReference();
			_fileRef.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, onUploadCompleteEventHandler, false, 0, false);
			_fileRef.addEventListener(Event.SELECT, onSelectEventHandler, false, 0, false);
			_fileRef.addEventListener(Event.CANCEL, function(e:Event):void {
				dispatchEvent(new Event(Event.CANCEL));
			}, false, 0, true);
		}
		
		public function upload():void {
			var filter:FileFilter = new FileFilter("Images (*.jpg, *.jpeg, *.gif, *.png)", "*.jpg;*.jpeg;*.gif;*.png");
			_fileRef.browse([filter]);
		}
		
		public function get fileURL():String {
			return _filePath + _fileName;
		}
		
		private function onUploadCompleteEventHandler(event:Event):void {
			dispatchEvent(new Event(FileUploader.LOADED));
		}
		
		private function onSelectEventHandler(event:Event):void {
			_fileName = _fileRef.name;
			_fileRef.upload(new URLRequest(_serverURL));
		}

	}
}