package kwon.dongwook.events {
	
	import flash.events.Event;
	
	public class DataEvent extends Event {
		
		public function DataEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
		}
		
		public var data:*;
	}
}