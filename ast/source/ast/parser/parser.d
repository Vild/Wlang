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
			Statement stmt = getStatement(Array!AttributeToken());
			curScope.Add(stmt);
			if (stmt.NeedEndToken)
				match!(EndToken);
		}
		return true;
	}


	Statement getStatement(Array!AttributeToken parrentAttr) {
		Array!AttributeToken attr = parrentAttr;
		while (has!AttributeToken)
			attr ~= get!AttributeToken[0];
		if (auto _ = getScopeStatement(attr))
			return _;
		else if (auto _ = getDefinitionStatement(attr))
			return _;
		else if (auto _ = getCallStatement(attr))
			return _;

		else if (auto _ = getOperatorStatement(attr))
			return _;
		else if (auto _ = getValueStatement(attr))
			return _;
		else
			throw new UnknownStatementException(this, tokens, current);
	}

	Statement getScopeStatement(Array!AttributeToken attr) {
		if (has!(OperatorToken, OperatorType.CURLYBRACKET_OPEN)) {
			get!(OperatorToken, OperatorType.CURLYBRACKET_OPEN);
			Scope newScope = new Scope(this, attr);
			
			while (!has!(OperatorToken, OperatorType.CURLYBRACKET_CLOSE)) {
				Statement stmt = getStatement(attr);
				newScope.Add(stmt);
				if (stmt.NeedEndToken)
					match!(EndToken);
			}

			get!(OperatorToken, OperatorType.CURLYBRACKET_CLOSE);
			return newScope;
		}
		return null;
	}

	Statement getDefinitionStatement(Array!AttributeToken attr) {
		if (has!(TypeToken, SymbolToken)) { // auto name
			auto d = get!(TypeToken, "type", SymbolToken, "symbol");

			if (has!EndToken) //auto name;
				return new VariableDefinitionStatement(this, attr, d.type, d.symbol, new VoidStatement(this, attr));
			else if (has!(OperatorToken, OperatorType.ASSIGN)) {
				get!OperatorToken;
				return new VariableDefinitionStatement(this, attr, d.type, d.symbol, getStatement(attr));
			} else if (has!(OperatorToken, OperatorType.BRACKET_OPEN)) {
				get!OperatorToken;

				Array!Argument t1; // Tier one of arguments, could be template args
				Array!Argument t2; // Second Tier, can only be arguments
				
				AddArgsDefinition(t1, attr);
				
				match!(OperatorToken, OperatorType.BRACKET_CLOSE);
				
				if (has!(OperatorToken, OperatorType.BRACKET_OPEN)) {
					get!(OperatorToken);
					AddArgsDefinition(t2, attr);
					match!(OperatorToken, OperatorType.BRACKET_CLOSE);
				}
				
				if (t2.length) // has both arguments and template
					return new FunctionDefinitionStatement(this, attr, d.type, d.symbol, t1, t2);
				else // has only arguments, t1 = arguments, t2 = empty
					return new FunctionDefinitionStatement(this, attr, d.type, d.symbol, t2, t1);
			} else
				throw new UnknownStatementException(this, tokens, current);
		}
		return null;
	}

	Statement getCallStatement(Array!AttributeToken attr) {
		Array!Statement t;
		Array!Statement args;
		if (has!(SymbolToken, OperatorToken, OperatorType.LOG_NOT)) { // name!(T)(args);
			auto symbol = get!(SymbolToken, "symbol", OperatorToken).symbol;
			if (has!(OperatorToken, OperatorType.BRACKET_OPEN)) {
				get!(OperatorToken);
				AddArgsValue(t, attr);
				match!(OperatorToken, OperatorType.BRACKET_CLOSE);
			} else {
				if (auto _ = getOperatorStatement(attr)) //CHEAT CHEAT
					t ~= _;
				else if (auto _ = getValueStatement(attr))
					t ~= _;
				else
					throw new UnknownStatementException(this, tokens, current);
			}

			match!(OperatorToken, OperatorType.BRACKET_OPEN);
			AddArgsValue(args, attr);
			match!(OperatorToken, OperatorType.BRACKET_CLOSE);
			return new FunctionCallStatement(this, attr, symbol, t, args);
		} else if (has!(SymbolToken, OperatorToken, OperatorType.BRACKET_OPEN)) { // name(args);
			auto symbol = get!(SymbolToken, "symbol", OperatorToken).symbol;
			AddArgsValue(args, attr);
			match!(OperatorToken, OperatorType.BRACKET_CLOSE);
			return new FunctionCallStatement(this, attr, symbol, t, args);
		}
		return null;
	}

	Statement getOperatorStatement(Array!AttributeToken attr) {
		//Handles "pre-operators" like !true
		if (has!(OperatorToken, OperatorType.BRACKET_OPEN)) {
			get!OperatorToken;
			Statement stmt = new ValueContainerStatement(this, attr, getStatement(attr));
			match!(OperatorToken, OperatorType.BRACKET_CLOSE);
			return stmt;
		} else if (has!(OperatorToken, OperatorType.LOG_NOT)) {
			get!OperatorToken;
			return new NotStatement(this, attr, getStatement(attr));
		}
		return null;
	}

	Statement getValueStatement(Array!AttributeToken attr) {
		Statement stmt = null;
		if (has!(ValueToken))
			stmt = new ValueStatement(this, attr, get!(ValueToken, "value").value);
		else if (has!(SymbolToken))
			stmt = new SymbolStatement(this, attr, get!(SymbolToken, "symbol").symbol);
		if (stmt) {
			if (has!(OperatorToken, OperatorType.PLUS)) {
				get!OperatorToken;
				return new PlusStatement(this, attr, stmt, getStatement(attr));
			}
		}
		return stmt;
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

	void AddArgsDefinition(ref Array!Argument list, Array!AttributeToken attr) {
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
				arg.defaultValue = getStatement(attr);
			} else
				arg.defaultValue = new VoidStatement(this, attr);
			
			list ~= arg;
			if (!has!(OperatorToken, OperatorType.COMMA))
				break;
			get!(OperatorToken, OperatorType.COMMA);
		}
	}

	void AddArgsValue(ref Array!Statement list, Array!AttributeToken attr) {
		while (true) {
			if (has!(OperatorToken, OperatorType.BRACKET_CLOSE))
				break;
			
			list ~= getStatement(attr);
			
			if (!has!(OperatorToken, OperatorType.COMMA))
				break;
			get!(OperatorToken, OperatorType.COMMA);
		}
	}
}

