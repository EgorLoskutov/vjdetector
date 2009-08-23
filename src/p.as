package {
	
	public function p(object:*, name:String = "object"):void {
			trace("---------- " + name + "------------");
			if (object == undefined) {
				trace("undefined");
			} else if (object is XML) {
				trace("XML >> " + name + "\n" + object.toString());
			} else if (object is String || object is Number || object is Boolean) {
				trace( name + ": >" + object + "<");
			} else {
				var length:uint = 0;
				for (var str:* in object) {
					length++;
					trace(name + "[" + str + "]=>" + object[str] + "<");
				}
				trace("--- Length : " + length);
			}
			trace("--------------------------------");
	}
}