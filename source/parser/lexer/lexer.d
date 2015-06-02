module parser.lexer.lexer;

import std.container;
import parser.lexer.exception;
import parser.lexer.token;
import std.regex;
import des.log;

class Lexer {
public:
	this(string data) {
		this.data = data;
		logger.info("Got data: ", data);
		process();
	}
	
	@property string Data() { return data; }
	@property Array!Token Tokens() { return tokens; } 
	
	size_t[2] GetLinePos(size_t index) {
		size_t row = 0 + 1; /* because human counting */
		size_t column = 0;
		
		logger.info("index: ", index, " data.length: ", data.length);
		if (index >= data.length)
			return [-1, -1];
		
		//Calculate the row and column number for the index
		for (int i = 0; i < index; i++)
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
		logger.info("Start with processing!");
		size_t lastCurrent = current;
		while (current < data.length) {
			lastCurrent = current;
			logger.info("Current token: ", current + 1, " out of ", data.length);
			parseToken();
			if (current == lastCurrent) {
				logger.error("Failed to parse token ", current + 1, " --> '", data[current], "'");
				break;
			}
		}
		logger.info("End of processing!");
	}
	
	void parseToken() {
		if (skipWhitespace())
			logger.info("Accepted whitespace!");
		else if (addOperator())
			logger.info("Accepted operator!");
		else if (addKeyword())
			logger.info("Accepted keyword!");
		else if (addValue())
			logger.info("Accepted value!");
		else if (addSymbol())
		logger.info("Accepted symbol!");
	else
			throw new LexerSyntaxError(this, current, data.length - 1);
	}
	
	bool add(alias re, T, args...)(args arg) {
		auto result = matchFirst(data[current..$], ctRegex!("^"~re));
		if (result.empty)
			return false;
		logger.info("Regex accepted: '", result[0], "' with the valid solution of '", re, "'");
		
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
		if (add!(`\{`, OperatorToken)(OperatorType.CURLYBRACKET_OPEN)) {}
		else if (add!(`\}`, OperatorToken)(OperatorType.CURLYBRACKET_CLOSE)) {}
		else if (add!(`\(`, OperatorToken)(OperatorType.BRACKET_OPEN)) {}
		else if (add!(`\)`, OperatorToken)(OperatorType.BRACKET_CLOSE)) {}
		else if (add!(`\[`, OperatorToken)(OperatorType.SQUAREBRACKET_OPEN)) {}
		else if (add!(`\]`, OperatorToken)(OperatorType.SQUAREBRACKET_CLOSE)) {}
		else if (add!(`\+`, OperatorToken)(OperatorType.PLUS)) {}
		else if (add!(`-`, OperatorToken)(OperatorType.MINUS)) {}
		else if (add!(`\*`, OperatorToken)(OperatorType.ASTERISK)) {}
		else if (add!(`/`, OperatorToken)(OperatorType.SLASH)) {}
		else if (add!(`\.`, OperatorToken)(OperatorType.DOT)) {}
		else if (add!(`==`, OperatorToken)(OperatorType.EQUALS)) {}
		else if (add!(`=`, OperatorToken)(OperatorType.ASSIGN)) {}
		else if (add!(`\+\+`, OperatorToken)(OperatorType.INCREMENT)) {}
		else if (add!(`--`, OperatorToken)(OperatorType.DECREMENT)) {}
		else if (add!(`\+=`, OperatorToken)(OperatorType.ADD_ASSIGN)) {}
		else if (add!(`-=`, OperatorToken)(OperatorType.SUB_ASSIGN)) {}
		else if (add!(`\*=`, OperatorToken)(OperatorType.MUL_ASSIGN)) {}
		else if (add!(`/=`, OperatorToken)(OperatorType.DIV_ASSIGN)) {}
		else if (add!(`<<=`, OperatorToken)(OperatorType.LEFT_SHIFT_ASSIGN)) {}
		else if (add!(`>>=`, OperatorToken)(OperatorType.RIGHT_SHIFT_ASSIGN)) {}
		else if (add!(`<<<=`, OperatorToken)(OperatorType.LEFT_ROTATE_ASSIGN)) {}
		else if (add!(`>>>=`, OperatorToken)(OperatorType.RIGHT_ROTATE_ASSIGN)) {}
		else if (add!(`<<<`, OperatorToken)(OperatorType.LEFT_ROTATE)) {}
		else if (add!(`>>>`, OperatorToken)(OperatorType.RIGHT_ROTATE)) {}
		else if (add!(`<<`, OperatorToken)(OperatorType.LEFT_SHIFT)) {}
		else if (add!(`>>`, OperatorToken)(OperatorType.RIGHT_SHIFT)) {}
		else if (add!(`<=`, OperatorToken)(OperatorType.LESS_THAN_EQUAL)) {}
		else if (add!(`>=`, OperatorToken)(OperatorType.GREATER_THAN_EQUAL)) {}
		else if (add!(`<`, OperatorToken)(OperatorType.LESS_THAN)) {}
		else if (add!(`>`, OperatorToken)(OperatorType.GREATER_THAN)) {}
		else if (add!(`&=`, OperatorToken)(OperatorType.BIT_AND_ASSIGN)) {}
		else if (add!(`&&=`, OperatorToken)(OperatorType.LOG_AND_ASSIGN)) {}
		else if (add!(`&&`, OperatorToken)(OperatorType.DOUBLE_AND)) {}
		else if (add!(`&`, OperatorToken)(OperatorType.BIT_AND)) {}
		else if (add!(`\|=`, OperatorToken)(OperatorType.BIT_OR_ASSIGN)) {}
		else if (add!(`\|\|=`, OperatorToken)(OperatorType.LOG_OR_ASSIGN)) {}
		else if (add!(`\|\|`, OperatorToken)(OperatorType.LOG_OR)) {}
		else if (add!(`\|`, OperatorToken)(OperatorType.BIT_OR)) {}
		else if (add!(`\^=`, OperatorToken)(OperatorType.BIT_XOR_ASSIGN)) {}
		else if (add!(`\^\^=`, OperatorToken)(OperatorType.LOG_XOR_ASSIGN)) {}
		else if (add!(`\^\^`, OperatorToken)(OperatorType.LOG_XOR)) {}
		else if (add!(`\^`, OperatorToken)(OperatorType.BIT_XOR)) {}
		else if (add!(`,`, OperatorToken)(OperatorType.COMMA)) {}
		else if (add!(`%=`, OperatorToken)(OperatorType.MODULO_ASSIGN)) {}
		else if (add!(`%`, OperatorToken)(OperatorType.MODULO)) {}
		else if (add!(`!=`, OperatorToken)(OperatorType.NOT_EQUALS)) {}
		else if (add!(`!`, OperatorToken)(OperatorType.LOG_NOT)) {}
		else if (add!(`~=`, OperatorToken)(OperatorType.BIT_NOT_ASSIGN)) {}
		else if (add!(`~`, OperatorToken)(OperatorType.BIT_NOT)) {}
		else if (add!(`\.\.\.`, OperatorToken)(OperatorType.VARIADIC)) {}
		else if (add!(`;`, OperatorToken)(OperatorType.SEMICOLON)) {}
		else
			return false;
		return true;
	}
	
	bool addKeyword() {
		if (add!(`if`, KeywordToken)(KeywordType.IF)) {}
		else if (add!(`else`, KeywordToken)(KeywordType.ELSE)) {}
		else if (add!(`for`, KeywordToken)(KeywordType.FOR)) {}
		else if (add!(`while`, KeywordToken)(KeywordType.WHILE)) {}
		else if (add!(`do`, KeywordToken)(KeywordType.DO)) {}
		else if (add!(`return`, KeywordToken)(KeywordType.RETURN)) {}
		else if (add!(`break`, KeywordToken)(KeywordType.BREAK)) {}
		else if (add!(`switch`, KeywordToken)(KeywordType.SWITCH)) {}
		else if (add!(`default`, KeywordToken)(KeywordType.DEFAULT)) {}
		else if (add!(`case`, KeywordToken)(KeywordType.CASE)) {}
		
		else if (add!(`class`, KeywordToken)(KeywordType.CLASS)) {}
		else if (add!(`data`, KeywordToken)(KeywordType.DATA)) {}
		else if (add!(`typedef`, KeywordToken)(KeywordType.TYPEDEF)) {}
		
		else if (add!(`const`, KeywordToken)(KeywordType.CONST)) {}
		else if (add!(`static`, KeywordToken)(KeywordType.STATIC)) {}
		
		else if (add!(`public`, KeywordToken)(KeywordType.PUBLIC)) {}
		else if (add!(`private`, KeywordToken)(KeywordType.PRIVATE)) {}
		else if (add!(`protected`, KeywordToken)(KeywordType.PROTECTED)) {}
		
		else if (add!(`cast`, KeywordToken)(KeywordType.CAST)) {}
		
		else if (add!(`bool`, KeywordToken)(KeywordType.BOOL)) {}
		
		else if (add!(`byte`, KeywordToken)(KeywordType.BYTE)) {}
		else if (add!(`ubyte`, KeywordToken)(KeywordType.UBYTE)) {}
		else if (add!(`short`, KeywordToken)(KeywordType.SHORT)) {}
		else if (add!(`ushort`, KeywordToken)(KeywordType.USHORT)) {}
		else if (add!(`int`, KeywordToken)(KeywordType.INT)) {}
		else if (add!(`uint`, KeywordToken)(KeywordType.UINT)) {}
		else if (add!(`long`, KeywordToken)(KeywordType.LONG)) {}
		else if (add!(`ulong`, KeywordToken)(KeywordType.ULONG)) {}
		else if (add!(`float`, KeywordToken)(KeywordType.FLOAT)) {}
		else if (add!(`double`, KeywordToken)(KeywordType.DOUBLE)) {}
		
		else if (add!(`string`, KeywordToken)(KeywordType.STRING)) {}
		
		else
			return false;
		return true;
	}

	bool addValue() {
		if (add!(`true`, ValueToken)(ValueType.TRUE)) {}
		else if (add!(`false`, ValueToken)(ValueType.FALSE)) {}

		else if (add!(`[\+-]?0[1-7][0-7]*`, ValueToken)(ValueType.OCTALINT)) {}
		else if (add!(`[\+-]?0[1-7][0-7]*l`, ValueToken)(ValueType.OCTALLONG)) {}

		else if (add!(`[\+-]?0x[\dabcdefABCDEF]+`, ValueToken)(ValueType.HEXINT)) {}
		else if (add!(`[\+-]?0x[\dabcdef]+l`, ValueToken)(ValueType.HEXLONG)) {}

		else if (add!(`[\+-]?0b[01]+`, ValueToken)(ValueType.BINARYINT)) {}
		else if (add!(`[\+-]?0b[01]+l`, ValueToken)(ValueType.BINARYLONG)) {}

		else if (add!(`[\+-]?\d+b`, ValueToken)(ValueType.INT)) {}
		else if (add!(`\+?\d+ub`, ValueToken)(ValueType.UINT)) {}
		else if (add!(`[\+-]?\d+s`, ValueToken)(ValueType.SHORT)) {}
		else if (add!(`\+?\d+us`, ValueToken)(ValueType.USHORT)) {}
		else if (add!(`[\+-]?\d+i?`, ValueToken)(ValueType.INT)) {}
		else if (add!(`\+?\d+ui?`, ValueToken)(ValueType.UINT)) {}
		else if (add!(`[\+-]?\d+l`, ValueToken)(ValueType.LONG)) {}
		else if (add!(`\+?\d+ul`, ValueToken)(ValueType.ULONG)) {}

		else if (add!(`[\+-]?(\d*\.\d+|\d+\.\d*|\d+)f`, ValueToken)(ValueType.FLOAT)) {}
		else if (add!(`[\+-]?(\d*\.\d+|\d+\.\d*)`, ValueToken)(ValueType.DOUBLE)) {}

		else if (add!(`"([^"]|\\")*"`, ValueToken)(ValueType.STRING)) {}

		else
			return false;
		return true;
	}

	bool addSymbol() {
		auto result = matchFirst(data[current..$], ctRegex!(`^[\p{L}_]+?`));
		logger.Debug("result: ", result);
		if (!result.empty) {
			tokens ~= new SymbolToken(this, current, current + result[0].length);
			current += result[0].length;
			return true;
		}
		return false;
	}
}

