module ast.lexer.token;

import ast.lexer.lexer;
import std.range.primitives;
import std.string;
import std.json;

class Token {
public:
	this(Lexer lexer, size_t start, size_t end) {
		this.lexer = lexer;
		this.start = start;
		this.end = end;
		this.length = lexer.Data[start..end].walkLength;
	}

	@property Lexer TheLexer() { return lexer; }
	@property size_t Start() { return start; }
	@property size_t End() { return end; }
	@property size_t Length() { return length; }

	JSONValue toJson() {
		return JSONValue([
				"class": JSONValue(this.classinfo.name),
				"start": JSONValue(start),
				"end": JSONValue(end),
				"length": JSONValue(length),
				"data": JSONValue(lexer.Data[start..end])
			]);
	}

	override string toString() {
		return toJson.toString;
	}

protected:
	Lexer lexer;
	size_t start, end;
	size_t length;
}

//Operator
enum OperatorType {
	CURLYBRACKET_OPEN, // {
	CURLYBRACKET_CLOSE, // }
	BRACKET_OPEN, // (
	BRACKET_CLOSE, // )
	SQUAREBRACKET_OPEN, // [
	SQUAREBRACKET_CLOSE, // ]
	
	PLUS, //+
	MINUS, //-
	ASTERISK, //*
	SLASH, // /
	DOT, //.
	EQUALS, //==
	ASSIGN, //=
	INCREMENT, //++
	DECREMENT, //--
	ADD_ASSIGN, //+=
	SUB_ASSIGN, //-=
	MUL_ASSIGN, //*=
	DIV_ASSIGN, // /=
	LEFT_SHIFT_ASSIGN, //<<=
	RIGHT_SHIFT_ASSIGN, //>>=
	LEFT_ROTATE_ASSIGN, //<<<=
	RIGHT_ROTATE_ASSIGN, //>>>=
	LEFT_ROTATE, //<<<
	RIGHT_ROTATE, //>>>
	LEFT_SHIFT, //<<
	RIGHT_SHIFT, //>>
	LESS_THAN_EQUAL, //<=
	GREATER_THAN_EQUAL, //>=
	LESS_THAN, //<
	GREATER_THAN, //>
	BIT_AND_ASSIGN, //&=
	LOG_AND_ASSIGN, //&&=
	DOUBLE_AND, //&&
	BIT_AND, //&
	BIT_OR_ASSIGN, //|=
	LOG_OR_ASSIGN, //||=
	LOG_OR, //||
	BIT_OR, //|
	BIT_XOR_ASSIGN, //^=
	LOG_XOR_ASSIGN, //^^=
	LOG_XOR, //^^
	BIT_XOR, //^
	COMMA, //,
	MODULO_ASSIGN, //%=
	MODULO, //%
	NOT_EQUALS, //!=
	LOG_NOT, //!
	BIT_NOT_ASSIGN, //~=
	BIT_NOT, //~
	VARIADIC, //...
	COLON, //:
	QUESTIONMARK //?
}
class OperatorToken : Token {
public:
	this(Lexer lexer, size_t start, size_t end, OperatorType type) {
		super(lexer, start, end);
		this.type = type;
	}

	@property OperatorType Type() { return type; }

	bool isType(OperatorType type) {
		return this.type == type;
	}

	override JSONValue toJson() {
		return JSONValue([
				"class": JSONValue(this.classinfo.name),
				"super": super.toJson,
				"type": JSONValue(type)
			]);
	}

private:
	OperatorType type;
} 

//Attributes
enum AttributeType {
	SPECIAL,

	LAZY,

	CONST,
	STATIC,
	
	PUBLIC,
	PRIVATE,
	PROTECTED,
}
class AttributeToken : Token {
public:
	this(Lexer lexer, size_t start, size_t end, AttributeType type) {
		super(lexer, start, end);
		this.type = type;
	}
	
	@property AttributeType Type() { return type; }
	@property string Extra() { return lexer.Data[start .. end]; }

	bool isType(AttributeType type) {
		return this.type == type;
	}

	override JSONValue toJson() {
		return JSONValue([
				"class": JSONValue(this.classinfo.name),
				"super": super.toJson,
				"type": JSONValue(type)
			]);
	}
private:
	AttributeType type;
}

//Types
enum TypeType {
	LAZY,
	AUTO,
	
	BOOL,
	
	BYTE,
	UBYTE,
	SHORT,
	USHORT,
	INT,
	UINT,
	LONG,
	ULONG,
	FLOAT,
	DOUBLE,
	
	STRING,
}
class TypeToken : Token {
public:
	this(Lexer lexer, size_t start, size_t end, TypeType type) {
		super(lexer, start, end);
		this.type = type;
	}
	
	@property TypeType Type() { return type; }
	@property string Extra() { return lexer.Data[start .. end]; }

	bool isType(TypeType type) {
		return this.type == type;
	}

	override JSONValue toJson() {
		return JSONValue([
				"class": JSONValue(this.classinfo.name),
				"super": super.toJson,
				"type": JSONValue(type)
			]);
	}
private:
	TypeType type;
}

//Values
enum ValueType {
	TRUE,
	FALSE,

	OCTALINT,
	OCTALLONG,

	HEXINT,
	HEXLONG,

	BINARYINT,
	BINARYLONG,

	FLOAT,
	DOUBLE,

	BYTE,
	UBYTE,
	SHORT,
	USHORT,
	INT,
	UINT,
	LONG,
	ULONG,

	STRING
}
class ValueToken : Token {
public:
	this(Lexer lexer, size_t start, size_t end, ValueType type) {
		super(lexer, start, end);
		this.type = type;
	}

	@property ValueType Type() { return type; }
	T Extra(T)() {
		import std.conv;

		if (type == ValueType.TRUE) {
			assert(is(typeof(T) == bool));
			return true;
		} else if (type == ValueType.FALSE) {
			assert(is(typeof(T) == bool));
			return false;
		} else if (type == ValueType.BYTE) {
			assert(is(typeof(T) == byte));
			return parse!T(lexer.Data[start .. end]);
		} else if (type == ValueType.UBYTE) {
			assert(is(typeof(T) == ubyte));
			return parse!T(lexer.Data[start .. end]);
		} else if (type == ValueType.SHORT) {
			assert(is(typeof(T) == short));
			return parse!T(lexer.Data[start .. end]);
		} else if (type == ValueType.USHORT) {
			assert(is(typeof(T) == ushort));
			return parse!T(lexer.Data[start .. end]);
		} else if (type == ValueType.INT) {
			assert(is(typeof(T) == int));
			return parse!T(lexer.Data[start .. end]);
		} else if (type == ValueType.UINT) {
			assert(is(typeof(T) == uint));
			return parse!T(lexer.Data[start .. end]);
		} else if (type == ValueType.LONG) {
			assert(is(typeof(T) == long));
			return parse!T(lexer.Data[start .. end]);
		} else if (type == ValueType.ULONG) {
			assert(is(typeof(T) == ulong));
			return parse!T(lexer.Data[start .. end]);
		} else if (type == ValueType.OCTALINT) {
			assert(is(typeof(T) == int));
			return parse!T(lexer.Data[start .. end], 8);
		} else if (type == ValueType.OCTALLONG) {
			assert(is(typeof(T) == long));
			return parse!T(lexer.Data[start .. end], 8);
		} else if (type == ValueType.HEXINT) {
			assert(is(typeof(T) == int));
			return parse!T(lexer.Data[start .. end], 16);
		} else if (type == ValueType.HEXLONG) {
			assert(is(typeof(T) == long));
			return parse!T(lexer.Data[start .. end], 16);
		} else if (type == ValueType.BINARYINT) {
			assert(is(typeof(T) == int));
			return parse!T(lexer.Data[start .. end], 2);
		} else if (type == ValueType.BINARYLONG) {
			assert(is(typeof(T) == long));
			return parse!T(lexer.Data[start .. end], 2);
		} else if (type == ValueType.FLOAT) {
			assert(is(typeof(T) == float));
			return parse!T(lexer.Data[start .. end]);
		} else if (type == ValueType.DOUBLE) {
			assert(is(typeof(T) == double));
			return parse!T(lexer.Data[start .. end]);
		} else if (type == ValueType.STRING) {
			assert(is(typeof(T) == string));
			return lexer.Data[start .. end];
		} else
			assert(0, "Unknown type!");
	}

	bool isType(ValueType type) {
		return this.type == type;
	}

	override JSONValue toJson() {
		return JSONValue([
				"class": JSONValue(this.classinfo.name),
				"super": super.toJson,
				"type": JSONValue(type)
			]);
	}
private:
	ValueType type;
}

//Keywords
enum KeywordType {
	//Real keywords
	IF,
	ELSE,
	FOR,
	WHILE,
	DO,
	RETURN,
	BREAK,
	SWITCH,
	DEFAULT,
	CASE,
	
	//Data container types
	CLASS,
	DATA,
	ALIAS,

	CAST,
		
	//Module system
	MODULE,
	IMPORT
}  
class KeywordToken : Token {
public:
	this(Lexer lexer, size_t start, size_t end, KeywordType type) {
		super(lexer, start, end);
		this.type = type;
	}
	
	@property KeywordType Type() { return type; }

	bool isType(KeywordType type) {
		return this.type == type;
	}

	override JSONValue toJson() {
		return JSONValue([
				"class": JSONValue(this.classinfo.name),
				"super": super.toJson,
				"type": JSONValue(type)
			]);
	}
private:
	KeywordType type;
}

//Variable names, Function names
class SymbolToken : Token {
public:
	this(Lexer lexer, size_t start, size_t end) {
		super(lexer, start, end);
	}
	
	@property string Symbol() { return lexer.Data[start .. end]; }

	override JSONValue toJson() {
		return JSONValue([
				"class": JSONValue(this.classinfo.name),
				"super": JSONValue(super.toJson)
			]);
	}
}

//;
class EndToken : Token {
public:
	this(Lexer lexer, size_t start, size_t end) {
		super(lexer, start, end);
	}

	override JSONValue toJson() {
		return JSONValue([
				"class": JSONValue(this.classinfo.name),
				"super": JSONValue(super.toJson)
			]);
	}
}