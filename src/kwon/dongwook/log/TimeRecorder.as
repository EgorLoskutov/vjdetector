package kwon.dongwook.log {
	
	import flash.text.TextField;
	
	public class TimeRecorder {
		
		private static var startTime:Date;
		
		public static function start(message:String, field:TextField = null):void {
			startTime = new Date();
			var string:String = ">> start time : " + startTime + ",\n\tof " + message + "\n\t\t-----------";
			if (field)
				field.text = string;
			trace(string);
		}
		
		public static function end(message:String, field:TextField = null):void {
			var now:Date = new Date();
			var duration:Number = (now.getTime() - startTime.getTime()) / 1000;
			var string:String = ">> duration : " + duration + " sec,\n\tof " + message + "\n\t\t-----------";
			if (field)
				field.text = string;
			trace(string);
		}
	}
}