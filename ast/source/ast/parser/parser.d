module ast.parser.parser;

import ast.lexer.lexer;
import ast.lexer.token;
import ast.parser.exception;
import ast.parser.statement;
import des.log;
import std.container.array;
import std.traits;
import std.typecons;
import ast.parser.data;

class Parser {
public:
	this(Lexer lexer) {
		this.lexer = lexer;
		root = new Scope(this, Array!AttributeToken());
		tokens = lexer.Tokens; //Remove overhead
		run();
		if (!processedAll)
			throw new Exception("\nTODO: havn't processed all tokens");
	}

	@property Scope Root() { return root; }

private:
	Lexer lexer;
	Scope root;
	Array!Token tokens;
	bool processedAll = false;

	size_t current = 0;

	void run() {
		import std.stdio;
		logger.info("Start with parser!");
		if (!process(root)) {
			logger.error("Failed parsing!");
			return;
		}
		writeln();
		if (current >= tokens.length)
			processedAll = true;
		
		logger.info("End of parser!");
	}

	bool process(Scope curScope) {
		import std.stdio;

		while(current < tokens.length) {
			write("\rCurrent token: ", current + 1, " out of ", tokens.length);
			getStatement(curScope);
		}
		return true;
	}


	Statement getStatement(Scope curScope) {
		Array!AttributeToken attr;
		while (has!AttributeToken)
			attr ~= get!AttributeToken[0];

		if (has!(OperatorToken, OperatorType.CURLYBRACKET_OPEN)) { // {
			get!(OperatorToken, OperatorType.CURLYBRACKET_OPEN);
			Scope newScope = new Scope(this, attr);

			while (!has!(OperatorToken, OperatorType.CURLYBRACKET_CLOSE))
				getStatement(newScope);
			get!(OperatorToken, OperatorType.CURLYBRACKET_CLOSE);
			return curScope.Add(newScope);
		} else if (has!(TypeToken, SymbolToken, EndToken)) { // auto name;
			auto d = get!(TypeToken, "type", SymbolToken, "symbol", EndToken);
			return curScope.Add(new VariableDefinitionStatement(this, attr, d.type, d.symbol, ValueContainer(NoData)));
		} else if (has!(TypeToken, SymbolToken, OperatorToken, OperatorType.ASSIGN, ValueToken, EndToken)) { // auto name = value;
			auto d = get!(TypeToken, "type", SymbolToken, "symbol", OperatorToken, OperatorType.ASSIGN, ValueToken, "value", EndToken);
			return curScope.Add(new VariableDefinitionStatement(this, attr, d.type, d.symbol, ValueContainer(d.value)));
		} else if (has!(TypeToken, SymbolToken, OperatorToken, OperatorType.ASSIGN, SymbolToken, EndToken)) { // auto name = name;
			auto d = get!(TypeToken, "type", SymbolToken, "symbol", OperatorToken, OperatorType.ASSIGN, SymbolToken, "value", EndToken);
			return curScope.Add(new VariableDefinitionStatement(this, attr, d.type, d.symbol, ValueContainer(d.value)));
		} else if (has!(TypeToken, SymbolToken, OperatorToken, OperatorType.BRACKET_OPEN)) { // auto name(
			auto d = get!(TypeToken, "type", SymbolToken, "symbol", OperatorToken, OperatorType.BRACKET_OPEN);

			Array!Argument t1; // Tier one of arguments, could be template args
			Array!Argument t2; // Second Tier, can only be arguments

			AddArgs(t1);

			match!(OperatorToken, OperatorType.BRACKET_CLOSE);

			if (has!(OperatorToken, OperatorType.BRACKET_OPEN)) {
				get!(OperatorToken);
				AddArgs(t2);
				match!(OperatorToken, OperatorType.BRACKET_CLOSE);
			}

			return curScope.Add(new FunctionDefinitionStatement(this, attr, d.type, d.symbol, t1, t2));
		}
		throw new UnknownStatementException(this, tokens, current);
	}


	bool has(pattern...)() {
		mixin(genericPeekImpl!("return false;", "", pattern));
		return true;
	}

	auto peek(pattern...)() {
		mixin("alias retType = Tuple!("~genericReturnTypeImpl!pattern~");");
		retType ret;
		
		mixin(genericReturnValueImpl!pattern);
		return ret;
	}

	auto get(pattern...)() {
		auto ret = peek!pattern;
		foreach (i, p; pattern)
			static if (is(p : Token))
				current++;
		return ret;
	}

	auto match(pattern...)() {
		import std.stdio;
		mixin(genericPeekImpl!("throw new ExpectedException!%s(this, tokens, current+%d);", "p.stringof, idx", pattern));

		return get!pattern;
	}
		
	static string genericPeekImpl(string onFail, string extraData, pattern...)() {
		import std.string;
		string ret = "";
		int idx = 0;
		foreach (i, p; pattern) {
			static if (is(p : Token)) {
				static if (__traits(compiles, typeof(pattern[i+1])) && is(typeof(pattern[i+1]) == enum)) {
					static assert(hasMember!(p, "isType") && __traits(compiles, (cast(p*)null).isType(pattern[i+1])),
						format("The type '%s' hasn't got a function called isType for the type of '%s'. Please fix!", p.stringof, typeof(pattern[i+1]).stringof)
						);
					mixin(`ret ~= format("if (!cast(%s)tokens[current+%d] || !(cast(%s)tokens[current+%d]).isType(%s)) "~onFail~"\n", p.stringof, idx, p.stringof, idx, pattern[i+1].stringof, `~extraData~`);`);
				} else
					mixin(`ret ~= format("if (!cast(%s)tokens[current+%d]) "~onFail~"\n", p.stringof, idx, `~extraData~`);`);
				idx++;
			}
		}
		
		return ret;
	}
	static string genericReturnTypeImpl(pattern...)() {
		string ret = "";
		foreach (idx, p; pattern) {
			static if (is(p : Token)) {
				static if (idx)
					ret ~= ", ";
				ret ~= p.stringof;
			} else static if (is(typeof(p) : string)) {
				static if (idx)
					ret ~= ", ";
				ret ~= p.stringof;
			}
		}
		return ret;
	}
	static string genericReturnValueImpl(pattern...)() {
		import std.string;
		string ret = "";
		int idx = 0;
		foreach (i, p; pattern) {
			static if (is(p : Token)) {
				ret ~= format("ret[%d] = cast(%s)tokens[current+%d];\n", idx, p.stringof, idx);
				idx++;
			}
		}
		
		return ret;
	}

	void AddArgs(ref Array!Argument list) {
		while (true) {
			if (has!(OperatorToken, OperatorType.BRACKET_CLOSE))
				break;
			Argument arg;
			if (has!TypeToken) {
				auto d = get!(TypeToken, "type");
				arg.type = TypeContainer(d.type);
			} else if (has!(SymbolToken, SymbolToken)) {
				auto d = get!(SymbolToken, "type");
				arg.type = TypeContainer(d.type);
			} else
				arg.type = TypeContainer(NoData);

			auto sym = get!(SymbolToken, "symbol");
			arg.symbol = sym.symbol;
			
			if (has!(OperatorToken, OperatorType.ASSIGN)) {
				get!(OperatorToken, OperatorType.ASSIGN);
				if (has!ValueToken)
					arg.value = ValueContainer(get!(ValueToken, "value").value);
				else if (has!SymbolToken)
					arg.value = ValueContainer(get!(SymbolToken, "value").value);
				else
					throw new UnknownStatementException(this, tokens, current);
			} else
				arg.value = ValueContainer(NoData);
			
			list ~= arg;
			if (!has!(OperatorToken, OperatorType.COMMA))
				break;
			get!(OperatorToken, OperatorType.COMMA);
		}
	}

}

