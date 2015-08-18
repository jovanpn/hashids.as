# hashids.as
ActionScript 3 version of Hashids library from http://hashids.org/

![hashids](http://hashids.org/public/img/hashids-logo-normal.png "Hashids")

======

Full Documentation
-------

A small ActionScript 3 class to generate YouTube-like ids from one or many numbers. Use hashids when you do not want to expose your database ids to the user. Read full documentation at: [http://hashids.org/actionscript](http://hashids.org/actionscript)

Installation
-------

Just drop org package with Hashids class into your project source folder.

Usage
-------

#### Encoding one number

You can pass a unique salt value so your hashids differ from everyone else's. I use "this is my salt" as an example.

```actionscript

import org.hashids.Hashids;

var hashids:Hashids = new Hashids("this is my salt");

var id:String = hashids.encode(12345);
```

`id` is now going to be:
	
	NkK9

#### Decoding

Notice during decoding, same salt value is used:

```actionscript

import org.hashids.Hashids;

var hashids:Hashids = new Hashids("this is my salt");

var numbers:Vector.<Number> = hashids.decode("NkK9");
```

`numbers` is now going to be:
	
	[ 12345 ]

#### Decoding with different salt

Decoding will not work if salt is changed:

```actionscript

import org.hashids.Hashids;

var hashids:Hashids = new Hashids("this is my pepper");

var numbers:Vector.<Number> = hashids.decode("NkK9");
```

`numbers` is now going to be:
	
	[]
	
#### Encoding several numbers

```actionscript

import org.hashids.Hashids;

var hashids:Hashids = new Hashids("this is my salt");

var id:String = hashids.encode(683, 94108, 123, 5);
```

`id` is now going to be:
	
	aBMswoO2UB3Sj

#### Decoding is done the same way

```actionscript

import org.hashids.Hashids;

var hashids:Hashids = new Hashids("this is my salt");

var numbers:Vector.<Number> = hashids.decode("aBMswoO2UB3Sj");
```

`numbers` is now going to be:
	
	[ 683, 94108, 123, 5 ]
	
#### Encoding and specifying minimum id length

Here we encode integer 1, and set the **minimum** id length to **8** (by default it's **0** -- meaning hashes will be the shortest possible length).

```actionscript

import org.hashids.Hashids;

var hashids:Hashids = new Hashids("this is my salt", 8);

var id:String = hashids.encode(1);
```

`id` is now going to be:
	
	gB0NV05e
	
#### Decoding

```actionscript

import org.hashids.Hashids;

var hashids:Hashids = new Hashids("this is my salt", 8);

var numbers:Vector.<Number> = hashids.decode("gB0NV05e");
```

`numbers` is now going to be:
	
	[ 1 ]
	
#### Specifying custom id alphabet

Here we set the alphabet to consist of valid hex characters: "0123456789abcdef"

```actionscript

import org.hashids.Hashids;

var hashids:Hashids = new Hashids("this is my salt", 0, "0123456789abcdef");

var id:String = hashids.encode(1234567);
```

`id` is now going to be:
	
	b332db5
	
#### Encoding hexadecimal numbers

Here we are encoding hexadecimal number passed as string (without 0x at the beginning): "fa2b8e964c1d3570"

```actionscript

import org.hashids.Hashids;

var hashids:Hashids = new Hashids("this is my salt");

var id:String = hashids.encodeHex("fa2b8e964c1d3570");
```

`id` is now going to be:
	
	bOv8ROn6O6crr6
	
#### Decoding

```actionscript

import org.hashids.Hashids;

var hashids:Hashids = new Hashids("this is my salt");

var hex:String = hashids.decodeHex("bOv8ROn6O6crr6");
```

`hex` is now going to be:
	
	fa2b8e964c1d3570
	
Randomness
-------

The primary purpose of hashids is to obfuscate ids. It's not meant or tested to be used for security purposes or compression.
Having said that, this algorithm does try to make these hashes unguessable and unpredictable:

#### Repeating numbers

```actionscript

import org.hashids.Hashids;

var hashids:Hashids = new Hashids("this is my salt");

var id:String = hashids.encode(5, 5, 5, 5);
```

You don't see any repeating patterns that might show there's 4 identical numbers in the hash:

	1Wc8cwcE

Same with incremented numbers:

```actionscript

import org.hashids.Hashids;

var hashids:Hashids = new Hashids("this is my salt");

var id = hashids.encode(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
```

`id` will be :
	
	kRHnurhptKcjIDTWC3sx
	
#### Incrementing number ids:

```actionscript

import org.hashids.Hashids;

var hashids:Hashids = new Hashids("this is my salt");

var id1:String = hashids.encode(1), /* NV */
	id2:String = hashids.encode(2), /* 6m */
	id3:String = hashids.encode(3), /* yD */
	id4:String = hashids.encode(4), /* 2l */
	id5:String = hashids.encode(5); /* rD */
```

Curses! #$%@
-------

This code was written with the intent of placing created hashes in visible places - like the URL. Which makes it unfortunate if generated hashes accidentally formed a bad word.

Therefore, the algorithm tries to avoid generating most common English curse words. This is done by never placing the following letters next to each other:
	
	c, C, s, S, f, F, h, H, u, U, i, I, t, T
	
Changelog
-------

**1.0.0**
	
- First commit

License
-------

MIT License. See the `LICENSE` file. You can use Hashids in open source projects and commercial products. Don't break the Internet.