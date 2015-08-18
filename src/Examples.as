package
{
	import flash.display.Sprite;
	
	import org.hashids.Hashids;
	
	public class Examples extends Sprite
	{
		private var hash:Hashids;
		private var id:String;
		private var numbers:Vector.<Number>;
		private var hex:String;
		
		public function Examples()
		{
			/*Encoding and decoding one number*/
			trace("ONE NUMBER");
			hash = new Hashids("this is my salt");
			
			/*Encoding*/
			id = hash.encode(1);
			/*Decoding*/
			numbers = hash.decode(id);
			
			trace("Hashed number:", id);
			trace("Unhashed number:", numbers);
			trace("------------------------------------------------");
			
			
			
			
			
			/*Encoding and decoding multiple numbers*/
			trace("MULTIPLE NUMBERS");
			hash = new Hashids("this is my salt");
			
			/*Encoding*/
			id = hash.encode(1, 2, 3);
			/*Decoding*/
			numbers = hash.decode(id);
			
			trace("Hashed numbers:", id);
			trace("Unhashed numbers:", numbers);
			trace("------------------------------------------------");
			
			
			
			
			
			/*Encoding and decoding multiple numbers with custom length*/
			trace("MULTIPLE NUMBERS WITH CUSTOM LENGTH");
			hash = new Hashids("this is my salt", 8);
			
			/*Encoding*/
			id = hash.encode(1, 2, 3);
			/*Decoding*/
			numbers = hash.decode(id);
			
			trace("Hashed numbers:", id);
			trace("Unhashed numbers:", numbers);
			trace("------------------------------------------------");
			
			
			
			
					
			/*Encoding and decoding multiple numbers with custom length and alphabet*/
			trace("MULTIPLE NUMBERS WITH CUSTOM LENGTH AND ALPHABET");
			hash = new Hashids("this is my salt", 8, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890");
			
			/*Encoding*/
			id = hash.encode(1, 2, 3);
			/*Decoding*/
			numbers = hash.decode(id);
			
			trace("Hashed numbers:", id);
			trace("Unhashed numbers:", numbers);
			trace("------------------------------------------------");
			
			
			
			
			
			/*Encodin and decoding Hexadecimal strings with custom length and alphabet*/
			trace("HEXADECIMAL STRING WITH CUSTOM LENGTH AND ALPHABET");
			hash = new Hashids("this is my salt", 8, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890");
			
			/*Encoding*/
			id = hash.encodeHex("fa2b8e964c1d3570");
			/*Decoding*/
			hex = hash.decodeHex(id);
			
			trace("Hashed hex:", id);
			trace("Unhashed hex:", hex);
			trace("------------------------------------------------");
		}
	}
}