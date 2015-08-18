package org.hashids
{
	public class Hashids
	{
		private static const DEFAULT_ALPHABET:String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
		
		private var salt:String = "";
		private var alphabet:String = "";
		private var seps:String = "cfhistuCFHISTU";
		private var minHashLength:int = 0;
		private var guards:String;
		
		public function Hashids(salt:String = "", minHashLength:int = 0, alphabet:String = DEFAULT_ALPHABET)
		{
			this.salt = salt;
			if(minHashLength < 0)
				this.minHashLength = 0;
			else
				this.minHashLength = minHashLength;
			this.alphabet = alphabet;
			
			var i:int;
			var j:int;
			var uniqueAlphabet:String = "";
			for(i=0; i<this.alphabet.length; i++)
			{
				if(uniqueAlphabet.indexOf("" + this.alphabet.charAt(i)) < 0)
					uniqueAlphabet += "" + this.alphabet.charAt(i);
			}
			
			this.alphabet = uniqueAlphabet;
			
			var minAlphabetLength:int = 16;
			if(this.alphabet.length < minAlphabetLength)
				throw new ArgumentError("Alphabet must contain at least " + minAlphabetLength + " unique characters.");
			
			if(this.alphabet.indexOf(" ") >= 0)
				throw new ArgumentError("Alphabet cannot contains spaces.");
			
			// seps should contain only characters present in alphabet;
			// alphabet should not contains seps
			for(i=0; i<this.seps.length; i++)
			{
				j = this.alphabet.indexOf(this.seps.charAt(i));
				if(j == -1)
					this.seps = this.seps.substring(0, i) + " " + this.seps.substring(i + 1);
				else
					this.alphabet = this.alphabet.substring(0, j) + " " + this.alphabet.substring(j + 1);
			}
			
			var whiteSpacesReg:RegExp = new RegExp("\\s+", "g");
			this.alphabet = this.alphabet.replace(whiteSpacesReg, "");
			this.seps = this.seps.replace(whiteSpacesReg, "");
			this.seps = this.consistentShuffle(this.seps, this.salt);
			
			var sepDiv:Number = 3.5;
			if((this.seps == "") || ((this.alphabet.length / this.seps.length) > sepDiv))
			{
				var seps_len:int = int(Math.ceil(this.alphabet.length / sepDiv));
				
				if(seps_len == 1)
					seps_len++;
				
				if(seps_len > this.seps.length)
				{
					var diff:int = seps_len - this.seps.length;
					this.seps += this.alphabet.substring(0, diff);
					this.alphabet = this.alphabet.substring(diff);
				}
				else
					this.seps = this.seps.substring(0, seps_len);
			}
			
			this.alphabet = this.consistentShuffle(this.alphabet, this.salt);
			
			var guardDiv:int = 12;
			var guardCount:int = Math.ceil(this.alphabet.length / guardDiv);
			
			if(this.alphabet.length < 3)
			{
				this.guards = this.seps.substring(0, guardCount);
				this.seps = this.seps.substring(guardCount);
			}
			else
			{
				this.guards = this.alphabet.substring(0, guardCount);
				this.alphabet = this.alphabet.substring(guardCount);
			}
		}
		
		/**
		 * Encode numbers to string
		 *
		 * @param numbers Numbers to encode
		 * @return Encoded string
		 */
		public function encode(...numbers):String
		{
			var number:Number;
			var nums:Vector.<Number> = new Vector.<Number>();
			for each (number in numbers)
			{
				if (number > Number.MAX_VALUE)
					throw new ArgumentError("Number can not be greater than " + Number.MAX_VALUE);
				nums.push(Number(number));
			}
			
			if(nums.length == 0)
				return "";
			
			return this._encode(nums);
		}
		
		/**
		 * Decode string to numbers
		 *
		 * @param hash Encoded string
		 * @return Decoded numbers
		 */
		public function decode(hash:String):Vector.<Number>
		{
			if(hash == "")
				return new Vector.<Number>();
			
			return this._decode(hash, this.alphabet);
		}
		
		/**
		 * Encode hexadecimal number to string
		 *
		 * @param hexa Hexadecimal number to encode
		 * @return Encoded string
		 */
		public function encodeHex(hexa:String):String
		{
			if(!hexa.match("^[0-9a-fA-F]+$"))
				return "";
			
			var matched:Vector.<Number> = new Vector.<Number>();
			var matcher:Array = hexa.match(new RegExp("[\\w\\W]{1,12}", "g"));
			
			for each(var match:String in matcher)
				matched.push(parseInt("1" + match, 16));
			
			return this._encode(matched);
		}
		
		/**
		 * Decode string to numbers
		 *
		 * @param hash Encoded string
		 * @return Decoded numbers
		 */
		public function decodeHex(hash:String):String
		{
			var result:String = "";
			var numbers:Vector.<Number> = this.decode(hash);
			
			for each(var number:Number in numbers)
				result += number.toString(16).substring(1);
			
			return result;
		}
		
		/* Private methods */
		private function _encode(numbers:Vector.<Number>):String
		{
			var numberHashInt:int = 0;
			var i:int;
			for(i = 0; i < numbers.length; i++)
				numberHashInt += (numbers[i] % (i+100));
			
			var alphabet:String = this.alphabet;
			var ret:String = alphabet.split("")[numberHashInt % alphabet.length];
			var num:Number;
			var sepsIndex:int;
			var guardIndex:int;
			var buffer:String;
			var ret_str:String = ret + "";
			var guard:String;
			
			for(i=0; i<numbers.length; i++)
			{
				num = numbers[i];
				buffer = ret + this.salt + alphabet;
				
				alphabet = this.consistentShuffle(alphabet, buffer.substring(0, alphabet.length));
				var last:String = this.hash(num, alphabet);
				
				ret_str += last;
				
				if(i+1 < numbers.length)
				{
					num %= (last.charCodeAt(0) + i);
					sepsIndex = int(num % this.seps.length);
					ret_str += this.seps.split("")[sepsIndex];
				}
			}
			
			if(ret_str.length < this.minHashLength)
			{
				guardIndex = (numberHashInt + ret_str.charCodeAt(0)) % this.guards.length;
				guard = this.guards.split("")[guardIndex];
				
				ret_str = guard + ret_str;
				
				if(ret_str.length < this.minHashLength)
				{
					guardIndex = (numberHashInt + ret_str.charCodeAt(2)) % this.guards.length;
					guard = this.guards.split("")[guardIndex];
					
					ret_str += guard;
				}
			}
			
			while(ret_str.length < this.minHashLength)
			{
				var halfLen:int = alphabet.length / 2;
				alphabet = this.consistentShuffle(alphabet, alphabet);
				ret_str = alphabet.substring(halfLen) + ret_str + alphabet.substring(0, halfLen);
				
				var excess:int = ret_str.length - this.minHashLength;
				if(excess > 0)
				{
					var start_pos:int = excess / 2;
					ret_str = ret_str.substring(start_pos, start_pos + this.minHashLength);
				}
			}
			
			return ret_str;
		}
		
		private function _decode(hash:String, alphabet:String):Vector.<Number>
		{
			var ret:Vector.<Number> = new Vector.<Number>();
			
			var i:int = 0;
			var regexp:RegExp = new RegExp("[" + this.guards + "]", "g");
			var hashBreakdown:String = hash.replace(regexp, " ");
			var hashArray:Array = hashBreakdown.split(" ");
			
			if(hashArray.length == 3 || hashArray.length == 2)
				i = 1;
			
			hashBreakdown = hashArray[i];
			
			var lottery:String = hashBreakdown.split("")[0];
			
			hashBreakdown = hashBreakdown.substring(1);
			hashBreakdown = hashBreakdown.replace(new RegExp("[" + this.seps + "]", "g"), " ");
			hashArray = hashBreakdown.split(" ");
			
			var subHash:String;
			var buffer:String;
			for each (var aHashArray:String in hashArray)
			{
				subHash = aHashArray;
				buffer = lottery + this.salt + alphabet;
				alphabet = this.consistentShuffle(alphabet, buffer.substring(0, alphabet.length));
				ret.push(this.unhash(subHash, alphabet));
			}
			
			if(!this._encode(ret) == hash)
				ret = new <Number>[0];
			
			return ret;
		}
		
		private function consistentShuffle(alphabet:String, salt:String):String
		{
			if(salt.length <= 0)
				return alphabet;
			
			var arr:Array = salt.split("");
			var asc_val:int;
			var j:int;
			var i:int;
			var v:int;
			var p:int;
			var tmp:String;
			for(i=alphabet.length-1, v=0, p=0; i > 0; i--, v++)
			{
				v %= salt.length;
				asc_val = String(arr[v]).charCodeAt(0);
				p += asc_val;
				j = (asc_val + v + p) % i;
				
				tmp = alphabet.charAt(j);
				alphabet = alphabet.substring(0, j) + alphabet.charAt(i) + alphabet.substring(j + 1);
				alphabet = alphabet.substring(0, i) + tmp + alphabet.substring(i + 1);
			}
			
			return alphabet;
		}
		
		private function hash(input:Number, alphabet:String):String
		{
			var hash:String = "";
			var alphabetLen:int = alphabet.length;
			var arr:Array = alphabet.split("");
			
			do
			{
				hash = arr[int(input % alphabetLen)] + hash;
				input = Math.floor(input/alphabetLen);
			}
			while(input > 0);
			
			return hash;
		}
		
		private function unhash(input:String, alphabet:String):Number
		{
			var number:Number = 0;
			var pos:Number;
			var input_arr:Array = input.split("");
			var i:int;
			
			for(i = 0; i < input.length; i++)
			{
				pos = alphabet.indexOf(input_arr[i]);
				number += pos * Math.pow(alphabet.length, input.length - i - 1);
			}
			
			return number;
		}
	}
}
