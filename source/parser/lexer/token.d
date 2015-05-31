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

	@property string Symbol() { return lexer[start..end]; }
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

private:
	OperatorType operator;
}

//Values
enum ValueType {
	TRUE,
	FALSE,

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
	OCTALINT,
	OCTALLONG,
	HEXINT,
	HEXLONG,
	BINARYINT,
	BINARYLONG,

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
			//assert(is(typeof(T) == typeof(bool)));
			return true;
		}/+ else if (type == ValueType.FALSE) {
			assert(T is bool);
			return false;
		} else if (type == ValueType.BYTE) {
			assert(T is byte);
			return parse!T(lexer.Data[start .. end]);
		} else if (type == ValueType.UBYTE) {
			assert(T is ubyte);
			return parse!T(lexer.Data[start .. end]);
		} else if (type == ValueType.SHORT) {
			assert(T is short);
			return parse!T(lexer.Data[start .. end]);
		} else if (type == ValueType.USHORT) {
			assert(T is ushort);
			return parse!T(lexer.Data[start .. end]);
		} else if (type == ValueType.INT) {
			assert(T is int);
			return parse!T(lexer.Data[start .. end]);
		} else if (type == ValueType.UINT) {
			assert(T is uint);
			return parse!T(lexer.Data[start .. end]);
		} else if (type == ValueType.LONG) {
			assert(T is long);
			return parse!T(lexer.Data[start .. end]);
		} else if (type == ValueType.ULONG) {
			assert(T is ulong);
			return parse!T(lexer.Data[start .. end]);
		} else if (type == ValueType.FLOAT) {
			assert(T is float);
			return parse!T(lexer.Data[start .. end]);
		} else if (type == ValueType.DOUBLE) {
			assert(T is double);
			return parse!T(lexer.Data[start .. end]);
		} else if (type == ValueType.OCTALINT) {
			assert(T is int);
			return parse!T(lexer.Data[start .. end], 8);
		} else if (type == ValueType.OCTALLONG) {
			assert(T is long);
			return parse!T(lexer.Data[start .. end], 8);
		} else if (type == ValueType.HEXINT) {
			assert(T is int);
			return parse!T(lexer.Data[start .. end], 16);
		} else if (type == ValueType.HEXLONG) {
			assert(T is long);
			return parse!T(lexer.Data[start .. end], 16);
		} else if (type == ValueType.BINARYINT) {
			assert(T is int);
			return parse!T(lexer.Data[start .. end], 2);
		} else if (type == ValueType.BINARYLONG) {
			assert(T is long);
			return parse!T(lexer.Data[start .. end], 2);
		} else if (type == ValueType.STRING) {
			assert(T is string);
			return lexer.Data[start .. end];
		} +/else
			assert(0, "Unknown type!");
	}

private:
	ValueType type;
}