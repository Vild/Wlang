module ast.parser.parser;

import ast.lexer.lexer;
import ast.lexer.token;
import ast.parser.exception;
import ast.parser.statement;
import wlang.io.log;
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
		Log log = Log.MainLogger();
		log.Info("Start with parser!");
		if (!process(root)) {
			log.Error("Failed parsing!");
			return;
		}
		writeln();
		if (current >= tokens.length)
			processedAll = true;

		log.Info("End of parser!");
	}

	bool process(Scope curScope) {
		import std.stdio;

		while(current < tokens.length) {
			write("\rCurrent token: ", current + 1, " out of ", tokens.length);
			Statement stmt = getStatement(Array!AttributeToken());
			curScope.Add(stmt);
			if (stmt.NeedEndToken)
				match!EndToken;
		}
		return true;
	}

	Statement getStatement(Array!AttributeToken parrentAttr) {
		Array!AttributeToken attr = parrentAttr;
		Statement stmt;
		while (has!AttributeToken)
			attr ~= get!AttributeToken[0];

		if (auto _ = getScopeStatement(attr))
			stmt = _;
		else if (auto _ = getDefinitionStatement(attr))
			stmt = _;
		else if (auto _ = getCallStatement(attr))
			stmt = _;

		else if (auto _ = getOperatorStatement(attr))
			stmt = _;
		else if (auto _ = getValueStatement(attr))
			stmt = _;
		else
			throw new UnknownStatementException(this, tokens, current);

		if (auto _ = getAfterOperatorStatement(attr, stmt))
			return _;

		return stmt;
	}

	Statement getScopeStatement(Array!AttributeToken attr) {
		if (has!(OperatorToken, OperatorType.CURLYBRACKET_OPEN)) {
			get!(OperatorToken, OperatorType.CURLYBRACKET_OPEN);
			Scope newScope = new Scope(this, attr);

			while (!has!(OperatorToken, OperatorType.CURLYBRACKET_CLOSE)) {
				Statement stmt = getStatement(attr);
				newScope.Add(stmt);
				if (stmt.NeedEndToken)
					match!EndToken;
			}

			get!(OperatorToken, OperatorType.CURLYBRACKET_CLOSE);
			return newScope;
		}
		return null;
	}

	Statement getDefinitionStatement(Array!AttributeToken attr) {
		TypeContainer type;
		SymbolToken symbol;
		if (has!(TypeToken, SymbolToken)) {
			auto d = get!(TypeToken, "type", SymbolToken, "symbol");
			type = TypeContainer(d.type);
			symbol = d.symbol;
		} else if (has!(SymbolToken, SymbolToken)) {
			auto d = get!(SymbolToken, "type", SymbolToken, "symbol");
			type = TypeContainer(d.type);
			symbol = d.symbol;
		}

		if (type.hasValue && symbol) { // auto name
			if (has!EndToken) //auto name;
				return new VariableDefinitionStatement(this, attr, type, symbol, new VoidStatement(this, attr));
			else if (has!(OperatorToken, OperatorType.ASSIGN)) {
				get!OperatorToken;
				return new VariableDefinitionStatement(this, attr, type, symbol, getStatement(attr));
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

				Scope ops = cast(Scope)getScopeStatement(attr);
				if (!ops)
					throw new UnknownStatementException(this, tokens, current);

				if (t2.length) // has both arguments and template
					return new FunctionDefinitionStatement(this, attr, type, symbol, t1, t2, ops);
				else // has only arguments, t1 = arguments, t2 = empty
					return new FunctionDefinitionStatement(this, attr, type, symbol, t2, t1, ops);
			} else
				throw new UnknownStatementException(this, tokens, current);
		} else if (has!(KeywordToken, KeywordType.DATA, SymbolToken)) {
			auto d = get!(KeywordToken, SymbolToken, "symbol");

			Array!Argument tem;

			if (has!(OperatorToken, OperatorType.BRACKET_OPEN)) {
				get!(OperatorToken);
				AddArgsDefinition(tem, attr);
				match!(OperatorToken, OperatorType.BRACKET_CLOSE);
			}

			Scope ops = cast(Scope)getScopeStatement(attr);
			if (!ops)
				throw new UnknownStatementException(this, tokens, current);

			return new DataStatement(this, attr, d.symbol, tem, ops);
		} else if (has!(KeywordToken, KeywordType.CLASS, SymbolToken)) {
			auto d = get!(KeywordToken, SymbolToken, "symbol");

			Array!Argument tem;
			SymbolToken parent;

			if (has!(OperatorToken, OperatorType.BRACKET_OPEN)) {
				get!(OperatorToken);
				AddArgsDefinition(tem, attr);
				match!(OperatorToken, OperatorType.BRACKET_CLOSE);
			}

			if (has!(OperatorToken, OperatorType.COLON)) {
				get!OperatorToken;
				parent = match!SymbolToken[0]; //TODO: Parse template for parent
			}

			Scope ops = cast(Scope)getScopeStatement(attr);
			if (!ops)
				throw new UnknownStatementException(this, tokens, current);

			return new ClassStatement(this, attr, d.symbol, tem, parent, ops);
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
				if (auto _ = getOperatorStatement(attr)) //CHEAT CHEAT, to only take one token! getStatement will generate a functioncall
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
		} else if (has!(OperatorToken, OperatorType.BIT_NOT)) {
			get!OperatorToken;
			return new BitNotStatement(this, attr, getStatement(attr));
		} else if (has!(OperatorToken, OperatorType.INCREMENT)) {
			get!OperatorToken;
			return new MathAssignStatement(this, attr, OperatorType.ADD_ASSIGN, getStatement(attr), new ConstantValueStatement(this, attr, 1));
		} else if (has!(OperatorToken, OperatorType.DECREMENT)) {
			get!OperatorToken;
			return new MathAssignStatement(this, attr, OperatorType.SUB_ASSIGN, getStatement(attr), new ConstantValueStatement(this, attr, 1));
		}
		return null;
	}

	Statement getAfterOperatorStatement(Array!AttributeToken attr, Statement stmt) {
		if (
			has!(OperatorToken, OperatorType.PLUS) ||
			has!(OperatorToken, OperatorType.MINUS) ||
			has!(OperatorToken, OperatorType.ASTERISK) ||
			has!(OperatorToken, OperatorType.SLASH) ||
			has!(OperatorToken, OperatorType.LEFT_ROTATE) ||
			has!(OperatorToken, OperatorType.RIGHT_ROTATE) ||
			has!(OperatorToken, OperatorType.LEFT_SHIFT) ||
			has!(OperatorToken, OperatorType.RIGHT_SHIFT) ||
			has!(OperatorToken, OperatorType.DOUBLE_AND) ||
			has!(OperatorToken, OperatorType.BIT_AND) ||
			has!(OperatorToken, OperatorType.LOG_OR) ||
			has!(OperatorToken, OperatorType.BIT_OR) ||
			has!(OperatorToken, OperatorType.LOG_XOR) ||
			has!(OperatorToken, OperatorType.BIT_XOR) ||
			has!(OperatorToken, OperatorType.MODULO)) {
			auto d = get!(OperatorToken, "type");
			return new MathStatement(this, attr, d.type.Type, stmt, getStatement(attr));
		} else if (
			has!(OperatorToken, OperatorType.ADD_ASSIGN) ||
			has!(OperatorToken, OperatorType.SUB_ASSIGN) ||
			has!(OperatorToken, OperatorType.MUL_ASSIGN) ||
			has!(OperatorToken, OperatorType.DIV_ASSIGN) ||
			has!(OperatorToken, OperatorType.LEFT_ROTATE_ASSIGN) ||
			has!(OperatorToken, OperatorType.RIGHT_ROTATE_ASSIGN) ||
			has!(OperatorToken, OperatorType.LEFT_SHIFT_ASSIGN) ||
			has!(OperatorToken, OperatorType.RIGHT_SHIFT_ASSIGN) ||
			has!(OperatorToken, OperatorType.LOG_AND_ASSIGN) ||
			has!(OperatorToken, OperatorType.BIT_AND_ASSIGN) ||
			has!(OperatorToken, OperatorType.LOG_OR_ASSIGN) ||
			has!(OperatorToken, OperatorType.BIT_OR_ASSIGN) ||
			has!(OperatorToken, OperatorType.LOG_XOR_ASSIGN) ||
			has!(OperatorToken, OperatorType.BIT_XOR_ASSIGN) ||
			has!(OperatorToken, OperatorType.MODULO_ASSIGN) ||
			has!(OperatorToken, OperatorType.BIT_NOT_ASSIGN)) {
			auto d = get!(OperatorToken, "type");
			return new MathAssignStatement(this, attr, d.type.Type, stmt, getStatement(attr));
		} else if (
			has!(OperatorToken, OperatorType.EQUALS) ||
			has!(OperatorToken, OperatorType.LESS_THAN_EQUAL) ||
			has!(OperatorToken, OperatorType.GREATER_THAN_EQUAL) ||
			has!(OperatorToken, OperatorType.LESS_THAN) ||
			has!(OperatorToken, OperatorType.GREATER_THAN) ||
			has!(OperatorToken, OperatorType.NOT_EQUALS)) {
			auto d = get!(OperatorToken, "type");
			return new MathAssignStatement(this, attr, d.type.Type, stmt, getStatement(attr));
		} else if (has!(OperatorToken, OperatorType.INCREMENT)) {
			get!OperatorToken;
			return new TriggerAfterStatement(this, attr, stmt,
				new MathAssignStatement(this, attr, OperatorType.ADD_ASSIGN, stmt,
					new ConstantValueStatement(this, attr, 1)));
		} else if (has!(OperatorToken, OperatorType.INCREMENT)) {
			get!OperatorToken;
			return new TriggerAfterStatement(this, attr, stmt,
				new MathAssignStatement(this, attr, OperatorType.SUB_ASSIGN, stmt,
					new ConstantValueStatement(this, attr, 1)));
		} else if (has!(OperatorToken, OperatorType.ASSIGN)) {
			get!OperatorToken;
			SymbolToken sym;
			if (auto _ = cast(SymbolStatement)stmt)
				sym = _.Symbol;
			else
				throw new ExpectedException!SymbolStatement(this, tokens, current-1);
			return new VariableAssignStatement(this, attr, sym, getStatement(attr));
		}

		return null;
	}

	Statement getValueStatement(Array!AttributeToken attr) {
		if (has!(ValueToken))
			return new ValueStatement(this, attr, get!(ValueToken, "value").value);
		else if (has!(SymbolToken))
			return new SymbolStatement(this, attr, get!(SymbolToken, "symbol").symbol);
		return null;
	}

	bool has(pattern...)() {
		if (current >= tokens.length)
			return false;
		pragma(msg, genericPeekImpl!("return false;", "", pattern));
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
		mixin(genericPeekImpl!("throw new ExpectedException!%s(this, tokens, current+%d);", "p.stringof, idx", pattern)); // "

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
					mixin(`ret ~= format("if (!cast(%s)tokens[current+%d] || !(cast(%s)tokens[current+%d]).isType(%s)) "~onFail~"\n", p.stringof, idx, p.stringof, idx, "`~typeof(pattern[i+1]).stringof~"."~pattern[i+1].stringof~`", `~extraData~`);`);
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
				arg.type = TypeContainer(NoData());

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

