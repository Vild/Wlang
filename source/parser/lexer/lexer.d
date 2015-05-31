module parser.lexer.lexer;

import std.container;
import parser.lexer.exception;
import parser.lexer.token;
import std.regex;

class Lexer {
	public:
	this(string data) {
		this.data = data;
		process();
	}
	
	
	@property string Data() { return data; }
	@property Array!Token Tokens() { return tokens; } 
	
	size_t[2] GetLinePos(size_t index) {
		size_t row = 0 + 1; /* because human counting */
		size_t column = 0;

		if (index > data.length)
			return [-1, -1];
		
		for (int i = 0; i < index + 1; i++)
			if (data[i] == '\n') {
				row++;
				column = 0;
				continue;
			} else 
				column++;
		
		return [row, column];
	}
	
	private:
	string data;
	Array!Token tokens;
	
	size_t current;
	
	void process() {
		while (current < data.length - 1)
			parseToken();
	}
	
	void parseToken() {
		bool result = skipWhitespace() ||
			addOperator() ||
				addKeywork() ||
				addSymbol();

		if (!result)
			throw new LexerSyntaxError(this, current, data.length);
	}

	bool add(re, T, args...)(args arg) {
		enum result = matchFirst(data[current..$], ctRegex!("^"~re));
		if (result.empty)
			return false;
		
		tokens ~= new T(this, current, current + result[0].length, arg);
		current += result[0].length;
		return true;
	}

	bool skipWhitespace() {
		import core.stdc.ctype;
		if (!data[current].isspace)
			return false;
		while (data[++current].isspace) {}
		return true;
	}

	bool addOperator() {
		if (add!("\\{", OperatorToken)(OperatorType.CURLYBRACKET_OPEN)) {}
		else if (add!("}", OperatorToken)(OperatorType.CURLYBRACKET_CLOSE)) {}
		else if (add!("\\(", OperatorToken)(OperatorType.BRACKET_OPEN)) {}
		else if (add!("\\)", OperatorToken)(OperatorType.BRACKET_CLOSE)) {}
		else if (add!("\\[", OperatorToken)(OperatorType.SQUAREBRACKET_OPEN)) {}
		else if (add!("]", OperatorToken)(OperatorType.SQUAREBRACKET_CLOSE)) {}
		else if (add!("\\+", OperatorToken)(OperatorType.PLUS)) {}
		else if (add!("-", OperatorToken)(OperatorType.MINUS)) {}
		else if (add!("\\*", OperatorToken)(OperatorType.ASTERISK)) {}
		else if (add!("/", OperatorToken)(OperatorType.SLASH)) {}
		else if (add!(".", OperatorToken)(OperatorType.DOT)) {}
		else if (add!("==", OperatorToken)(OperatorType.EQUALS)) {}
		else if (add!("=", OperatorToken)(OperatorType.ASSIGN)) {}
		else if (add!("++", OperatorToken)(OperatorType.INCREMENT)) {}
		else if (add!("--", OperatorToken)(OperatorType.DECREMENT)) {}
		else if (add!("+=", OperatorToken)(OperatorType.ADD_ASSIGN)) {}
		else if (add!("-=", OperatorToken)(OperatorType.SUB_ASSIGN)) {}
		else if (add!("*=", OperatorToken)(OperatorType.MUL_ASSIGN)) {}
		else if (add!("/=", OperatorToken)(OperatorType.DIV_ASSIGN)) {}
		else if (add!("<<=", OperatorToken)(OperatorType.LEFT_SHIFT_ASSIGN)) {}
		else if (add!(">>=", OperatorToken)(OperatorType.RIGHT_SHIFT_ASSIGN)) {}
		else if (add!("<<<=", OperatorToken)(OperatorType.LEFT_ROTATE_ASSIGN)) {}
		else if (add!(">>>=", OperatorToken)(OperatorType.RIGHT_ROTATE_ASSIGN)) {}
		else if (add!("<<<", OperatorToken)(OperatorType.LEFT_ROTATE)) {}
		else if (add!(">>>", OperatorToken)(OperatorType.RIGHT_ROTATE)) {}
		else if (add!("<<", OperatorToken)(OperatorType.LEFT_SHIFT)) {}
		else if (add!(">>", OperatorToken)(OperatorType.RIGHT_SHIFT)) {}
		else if (add!("<=", OperatorToken)(OperatorType.LESS_THAN_EQUAL)) {}
		else if (add!(">=", OperatorToken)(OperatorType.GREATER_THAN_EQUAL)) {}
		else if (add!("<", OperatorToken)(OperatorType.LESS_THAN)) {}
		else if (add!(">", OperatorToken)(OperatorType.GREATER_THAN)) {}
		else if (add!("&=", OperatorToken)(OperatorType.BIT_AND_ASSIGN)) {}
		else if (add!("&&=", OperatorToken)(OperatorType.LOG_AND_ASSIGN)) {}
		else if (add!("&&", OperatorToken)(OperatorType.DOUBLE_AND)) {}
		else if (add!("&", OperatorToken)(OperatorType.BIT_AND)) {}
		else if (add!("|=", OperatorToken)(OperatorType.BIT_OR_ASSIGN)) {}
		else if (add!("||=", OperatorToken)(OperatorType.LOG_OR_ASSIGN)) {}
		else if (add!("||", OperatorToken)(OperatorType.LOG_OR)) {}
		else if (add!("|", OperatorToken)(OperatorType.BIT_OR)) {}
		else if (add!("\\^=", OperatorToken)(OperatorType.BIT_XOR_ASSIGN)) {}
		else if (add!("\\^\\^=", OperatorToken)(OperatorType.LOG_XOR_ASSIGN)) {}
		else if (add!("\\^\\^", OperatorToken)(OperatorType.LOG_XOR)) {}
		else if (add!("\\^", OperatorToken)(OperatorType.BIT_XOR)) {}
		else if (add!(",", OperatorToken)(OperatorType.COMMA)) {}
		else if (add!("%=", OperatorToken)(OperatorType.MODULO_ASSIGN)) {}
		else if (add!("%", OperatorToken)(OperatorType.MODULO)) {}
		else if (add!("!=", OperatorToken)(OperatorType.NOT_EQUALS)) {}
		else if (add!("!", OperatorToken)(OperatorType.LOG_NOT)) {}
		else if (add!("~=", OperatorToken)(OperatorType.BIT_NOT_ASSIGN)) {}
		else if (add!("~", OperatorToken)(OperatorType.BIT_NOT)) {}
		else if (add!("\\.\\.\\.", OperatorToken)(OperatorType.VARIADIC)) {}
		else if (add!(";", OperatorToken)(OperatorType.SEMICOLON)) {}
		else
			return false;
		return true;
	}

	bool addKeywork() {
		if (add!("if", KeywordType)(KeyworkType.IF)) {}
		else if (add!("else", KeywordType)(KeyworkType.ELSE)) {}
		else if (add!("for", KeywordType)(KeyworkType.FOR)) {}
		else if (add!("while", KeywordType)(KeyworkType.WHILE)) {}
		else if (add!("do", KeywordType)(KeyworkType.DO)) {}
		else if (add!("return", KeywordType)(KeyworkType.RETURN)) {}
		else if (add!("break", KeywordType)(KeyworkType.BREAK)) {}
		else if (add!("switch", KeywordType)(KeyworkType.SWITCH)) {}
		else if (add!("default", KeywordType)(KeyworkType.DEFAULT)) {}
		else if (add!("case", KeywordType)(KeyworkType.CASE)) {}
		
		else if (add!("class", KeywordType)(KeyworkType.CLASS)) {}
		else if (add!("data", KeywordType)(KeyworkType.DATA)) {}
		else if (add!("typedef", KeywordType)(KeyworkType.TYPEDEF)) {}
		
		else if (add!("const", KeywordType)(KeyworkType.CONST)) {}
		else if (add!("static", KeywordType)(KeyworkType.STATIC)) {}
		
		else if (add!("public", KeywordType)(KeyworkType.PUBLIC)) {}
		else if (add!("private", KeywordType)(KeyworkType.PRIVATE)) {}
		else if (add!("protected", KeywordType)(KeyworkType.PROTECTED)) {}

		else if (add!("cast", KeywordType)(KeyworkType.CAST)) {}

		else if (add!("bool", KeywordType)(KeyworkType.BOOL)) {}

		else if (add!("byte", KeywordType)(KeyworkType.BYTE)) {}
		else if (add!("ubyte", KeywordType)(KeyworkType.UBYTE)) {}
		else if (add!("short", KeywordType)(KeyworkType.SHORT)) {}
		else if (add!("ushort", KeywordType)(KeyworkType.USHORT)) {}
		else if (add!("int", KeywordType)(KeyworkType.INT)) {}
		else if (add!("uint", KeywordType)(KeyworkType.UINT)) {}
		else if (add!("long", KeywordType)(KeyworkType.LONG)) {}
		else if (add!("ulong", KeywordType)(KeyworkType.ULONG)) {}
		else if (add!("float", KeywordType)(KeyworkType.FLOAT)) {}
		else if (add!("double", KeywordType)(KeyworkType.DOUBLE)) {}

		else if (add!("string", KeywordType)(KeyworkType.STRING)) {}

		else
			return false;
		return true;
	}

	bool addSymbol() {
		auto re = ctRegex!(`^[\p{L}_]+?`);
		auto result = matchFirst(data[current..$], re);
		if (!result.empty) {
			tokens ~= new SymbolToken(this, current, result[0].length);
			return true;
		}
		return false;
	}
}

