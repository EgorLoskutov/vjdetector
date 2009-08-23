package kwon.dongwook.utils {
	
	public class StringUtil {
	    
	    
	    public static function trim(str:String):String {
	    	if (str == null) return '';
			var temp:String = str;
			var reg:RegExp = /^(\s*)([\W\w]*)(\b\s*$)/;
			if (reg.test(temp))
				temp = temp.replace(reg, '$2');
			reg = / +/g;
			temp = temp.replace(reg, " ");
			if (temp == " ") 
				temp = "";
			return temp;
	    }

	}
}