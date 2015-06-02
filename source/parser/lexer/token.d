module parser.lexer.token;

import parser.lexer.lexer;

class Token {
public:
	this(Lexer lexer, size_t start, size_t end) {
		this.lexer = lexer;
		this.start = start;
		this.end = end;
	}

	@property Lexer TheLexer() { return lexer; }
	@property size_t Start() { return start; }
	@property size_t End() { return end; }

protected:
	Lexer lexer;
	size_t start, end;
}

//Variable names, Function names
class SymbolToken : Token {
public:
	this(Lexer lexer, size_t start, size_t end) {
		super(lexer, start, end);
	}

	@property string Symbol() { return lexer.Data[start .. end]; }

	override string toString() {
		return "[SymbolToken] " ~ lexer.Data[start .. end];
	}
}

enum KeywordType {
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

	CLASS,
	DATA,
	TYPEDEF,
	
	CONST,
	STATIC,

	PUBLIC,
	PRIVATE,
	PROTECTED,

	CAST,

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
	STRING
}  
class KeywordToken : Token {
public:
	this(Lexer lexer, size_t start, size_t end, KeywordType keyword) {
		super(lexer, start, end);
		this.keyword = keyword;
	}

	@property KeywordType Keyword() { return keyword; }

	override string toString() {
		return "[KeywordToken] " ~ lexer.Data[start .. end];
	}

private:
	KeywordType keyword;
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
	SEMICOLON //;
}
class OperatorToken : Token {
public:
	this(Lexer lexer, size_t start, size_t end, OperatorType operator) {
		super(lexer, start, end);
		this.operator = operator;
	}
	@property OperatorType Operator() { return operator; }

	override string toString() {
		return "[OperatorToken] " ~ lexer.Data[start .. end];
	}
private:
	OperatorType operator;
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

	STRING
}
class ValueToken : Token {
public:
	this(Lexer lexer, size_t start, size_t end, ValueType type) {
		super(lexer, start, end);
		this.type = type;
	}

	T Get(T)() {
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

	override string toString() {
		return "[ValueToken] " ~ lexer.Data[start .. end];
	}
private:
	ValueType type;
}