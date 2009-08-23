package kwon.dongwook.apps.vjdetector {
	
	import deng.fzip.FZip;
	import deng.fzip.FZipEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.utils.Dictionary;
	
	import kwon.dongwook.apps.vjdetector.models.HaarCascade;
	import kwon.dongwook.apps.vjdetector.models.HaarDataParser;
	import kwon.dongwook.events.DataEvent;
	import kwon.dongwook.utils.StringUtil;
	
	public class DataLoader extends EventDispatcher {
		
		private const CONFIG_FOLDER:String = "config.txt";
		
		public static const COMPLETE:String = "complete";
		[Event(name="complete", type="kwon.dongwook.events.DataEvent")]
		
		private var _loader:URLLoader;
		private var _zipLoader:FZip;
		private var _config:Config;
		private var _xmls:Object;
		private var _cascades:Dictionary;
		private var _parser:HaarDataParser;
		
		public function DataLoader() {
			_loader = new URLLoader();
			_config = new Config();
			_loader.addEventListener(Event.COMPLETE, onLoadConfigEventHandler);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, onErrorEventHandler, false, 0, true);
			_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onErrorEventHandler, false, 0, true);
		}
		
		public function load():void {
			_loader.load(new URLRequest(CONFIG_FOLDER));
		}
		
		private function onErrorEventHandler(event:Event):void {
//			trace("Failed to load config file. Use default value");
			loadCascadeFile();
		}

		private function onLoadConfigEventHandler(event:Event):void {
			var vars:URLVariables = new URLVariables(_loader.data);
			if (vars.defaultCascade)
				_config.defaultCascadeName = StringUtil.trim(vars.defaultCascade);
			if (vars.dataFile)
				_config.dataFile = StringUtil.trim(vars.dataFile);
			if (vars.scaleFactor)
				_config.scaleFactor = Number(StringUtil.trim(vars.scaleFactor));
			var size:Array = StringUtil.trim(vars.minSize).split(",");
			if (size && size.length > 1) {
				_config.minSize.width = Number(size[0]);
				_config.minSize.height = Number(size[1]);
			}
			if (vars.flags)
				_config.flags = uint(StringUtil.trim(vars.flags));
			if (vars.minNeighbors)
				_config.minNeighbors = uint(StringUtil.trim(vars.minNeighbors));
			if (vars.findBiggest)
				_config.findBiggest = Boolean(vars.findBiggest == "true");

			try {
				var files:Array = vars.cascadeFiles.split(",");
				for (var str:String in files) {
					var file:Array = files[str].split(":");
					_config.cascadeFiles[StringUtil.trim(file[0])] = StringUtil.trim(file[1]);
				}
			} catch (e:Error) {
				trace("Error while loading config file. >>" + e.toString());
			} finally {
				loadCascadeFile();
			}
		}
		
		private function loadCascadeFile():void {
			_loader.removeEventListener(IOErrorEvent.IO_ERROR, onErrorEventHandler);
			_loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onErrorEventHandler);
			_loader.removeEventListener(Event.COMPLETE, onLoadConfigEventHandler);
			_loader.close();
			_loader = undefined;
			_cascades = new Dictionary();
			_parser = new HaarDataParser();
			_zipLoader = new FZip();
			_zipLoader.addEventListener(FZipEvent.FILE_LOADED, onLoadDataEventHandler, false, 0, true);
			_zipLoader.addEventListener(Event.COMPLETE, onDoneLoadEventHandler, false, 0, true);
			_zipLoader.load(new URLRequest(_config.dataFile));
		}
				
		private function onLoadDataEventHandler(event:FZipEvent):void {
			var data:String = event.file.getContentAsString(false);
			XML.ignoreWhitespace = true;
			XML.ignoreComments = true;
			XML.ignoreProcessingInstructions = true;
			var xml:XML = new XML(data);
			var cascade:HaarCascade = _parser.parse(xml);
			if (cascade) {
				if (!_config.cascadeFiles.hasOwnProperty(cascade.name)) {
					_config.cascadeFiles[cascade.name] = event.file.filename;
				}
				_cascades[cascade.name] = cascade;
			}
		}
		
		private function onDoneLoadEventHandler(event:Event):void {
			if (_zipLoader.hasEventListener(FZipEvent.FILE_LOADED))
				_zipLoader.removeEventListener(FZipEvent.FILE_LOADED, onLoadDataEventHandler, false);
			_zipLoader.close();
			_zipLoader = undefined;
			var e:DataEvent = new DataEvent(COMPLETE);
			e.data = new Object();
			e.data.cascades = _cascades;
			e.data.config = _config;
			dispatchEvent(e);
		}

	}
}