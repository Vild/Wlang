module ast.parser.statement;

import ast.lexer.token;
import ast.parser.data;
import ast.parser.parser;
import std.container.array;
import std.json;
import std.string;
import std.variant;
import ast.util.json;

class Statement {
public:
	this(Parser parser, Array!AttributeToken attr) {
		this.parser = parser;
		this.attr = attr;
	}

	@property Parser TheParser() { return parser; }
	@property Array!AttributeToken Attributes() { return attr; }
	@property bool NeedEndToken() { return true; }

	JSONValue toJson() {
		return JSONValue([
				"class": JSONValue(typeof(this).classinfo.name),
				"attributes": attr.toJson
			]);
	}
	
	override string toString() {
		return toJson.toString;
	}

protected:
	Parser parser;
	Array!AttributeToken attr;
}

class VoidStatement : Statement {
public:
	this(Parser parser, Array!AttributeToken attr) {
		super(parser, attr);
	}

	override JSONValue toJson() {
		return JSONValue([
				"class": JSONValue(typeof(this).classinfo.name),
				"super": JSONValue(super.toJson)
			]);
	}
}

class ValueStatement : Statement {
public:
	this(Parser parser, Array!AttributeToken attr, ValueToken value) {
		super(parser, attr);
		this.value = value;
	}

	override JSONValue toJson() {
		return JSONValue([
				"class": JSONValue(typeof(this).classinfo.name),
				"super": super.toJson,
				"value": value.toJson
			]);
	}
private:
	ValueToken value;
}

class TriggerAfterStatement : Statement {
public:
	this(Parser parser, Array!AttributeToken attr, Statement stmt, Statement after) {
		super(parser, attr);
		this.stmt = stmt;
	}
	
	override JSONValue toJson() {
		return JSONValue([
				"class": JSONValue(typeof(this).classinfo.name),
				"super": super.toJson,
				"stmt": stmt.toJson,
				"after": after.toJson
			]);
	}
private:
	Statement stmt;
	Statement after;
}

class ConstantValueStatement : Statement {
public:
	this(Parser parser, Array!AttributeToken attr, long value) {
		super(parser, attr);
		this.value = value;
	}

	@property long Value() { return value;}
	
	override JSONValue toJson() {
		return JSONValue([
				"class": JSONValue(typeof(this).classinfo.name),
				"super": super.toJson,
				"value": JSONValue(value)
			]);
	}
private:
	long value;
}

class SymbolStatement : Statement {
public:
	this(Parser parser, Array!AttributeToken attr, SymbolToken symbol) {
		super(parser, attr);
		this.symbol = symbol;
	}

	@property SymbolToken Symbol() { return symbol; }

	override JSONValue toJson() {
		return JSONValue([
				"class": JSONValue(typeof(this).classinfo.name),
				"super": super.toJson,
				"symbol": symbol.toJson
			]);
	}
private:
	SymbolToken symbol;
}

class Scope : Statement {
public:
	this(Parser parser, Array!AttributeToken attr) {
		super(parser, attr);
	}

	Statement Add(Statement stmt) {
		list ~= stmt;
		return stmt;
	}

	@property ref Array!Statement List() { return list; }
	@property override bool NeedEndToken() { return false; }

	override JSONValue toJson() {
		return JSONValue([
				"class": JSONValue(typeof(this).classinfo.name),
				"super": super.toJson,
				"list": list.toJson
			]);
	}
private:
	Array!Statement list;

	//for nicer text output
	static uint indent = 0;
}

class VariableDefinitionStatement : Statement {
public:
	this(Parser parser, Array!AttributeToken attr, TypeContainer type, SymbolToken symbol, Statement startValue) {
		super(parser, attr);
		this.type = type;
		this.symbol = symbol;
		this.startValue = startValue;
	}

	@property TypeContainer Type() { return type; }
	@property SymbolToken Symbol() { return symbol; }
	@property Statement StartValue() { return startValue; }

	override JSONValue toJson() {
		return JSONValue([
				"class": JSONValue(typeof(this).classinfo.name),
				"super": super.toJson,
				"type": type.toJson,
				"symbol": symbol.toJson,
				"startValue": startValue.toJson
			]);
	}

private:
	TypeContainer type;
	SymbolToken symbol;
	Statement startValue;
}

class VariableAssignStatement : Statement {
public:
	this(Parser parser, Array!AttributeToken attr, SymbolToken symbol, Statement value) {
		super(parser, attr);
		this.symbol = symbol;
		this.value = value;
	}

	@property SymbolToken Symbol() { return symbol; }
	@property Statement Value() { return value; }
	
	override JSONValue toJson() {
		return JSONValue([
				"class": JSONValue(typeof(this).classinfo.name),
				"super": super.toJson,
				"symbol": symbol.toJson,
				"value": value.toJson
			]);
	}
	
private:
	SymbolToken symbol;
	Statement value;
}

class FunctionDefinitionStatement : Statement {
public:
	this(Parser parser, Array!AttributeToken attr, TypeContainer type, SymbolToken symbol, Array!Argument templates, Array!Argument arguments, Scope operations) {
		super(parser, attr);
		this.type = type;
		this.symbol = symbol;
		this.templates = templates;
		this.arguments = arguments;
		this.operations = operations;
	}
	
	@property TypeContainer Type() { return type; }
	@property SymbolToken Symbol() { return symbol; }
	@property Array!Argument Templates() { return templates; }
	@property Array!Argument Arguments() { return arguments; }
	@property Scope Operations() { return operations; }

	@property override bool NeedEndToken() { return false; }
	
	override JSONValue toJson() {
		return JSONValue([
				"class": JSONValue(typeof(this).classinfo.name),
				"super": super.toJson,
				"type": type.toJson,
				"symbol": symbol.toJson,
				"templates": templates.toJson,
				"arguments": arguments.toJson,
				"operations": operations.toJson
			]);
	}
	
private:
	TypeContainer type;
	SymbolToken symbol;
	Array!Argument templates;
	Array!Argument arguments;
	Scope operations;
}

class FunctionCallStatement : Statement {
public:
	this(Parser parser, Array!AttributeToken attr, SymbolToken symbol, Array!Statement templates, Array!Statement arguments) {
		super(parser, attr);
		this.symbol = symbol;
		this.templates = templates;
		this.arguments = arguments;
	}

	@property SymbolToken Symbol() { return symbol; }
	@property Array!Statement Templates() { return templates; }
	@property Array!Statement Arguments() { return arguments; }
	
	override JSONValue toJson() {
		return JSONValue([
				"class": JSONValue(typeof(this).classinfo.name),
				"super": super.toJson,
				"symbol": symbol.toJson,
				"templates": templates.toJson,
				"arguments": arguments.toJson
			]);
	}
	
private:
	SymbolToken symbol;
	Array!Statement templates;
	Array!Statement arguments;
}

class ValueContainerStatement : Statement {
public:
	this(Parser parser, Array!AttributeToken attr, Statement value) {
		super(parser, attr);
		this.value = value;
	} 
	
	@property Statement Value() { return value; }

	override JSONValue toJson() {
		return JSONValue([
				"class": JSONValue(typeof(this).classinfo.name),
				"super": super.toJson,
				"value": value.toJson
			]);
	}
private:
	Statement value;
}

class NotStatement : Statement {
public:
	this(Parser parser, Array!AttributeToken attr, Statement value) {
		super(parser, attr);
		this.value = value;
	} 
	
	@property Statement Value() { return value; }
	
	override JSONValue toJson() {
		return JSONValue([
				"class": JSONValue(typeof(this).classinfo.name),
				"super": super.toJson,
				"value": value.toJson
			]);
	}
private:
	Statement value;
}

class BitNotStatement : Statement {
public:
	this(Parser parser, Array!AttributeToken attr, Statement value) {
		super(parser, attr);
		this.value = value;
	} 
	
	@property Statement Value() { return value; }
	
	override JSONValue toJson() {
		return JSONValue([
				"class": JSONValue(typeof(this).classinfo.name),
				"super": super.toJson,
				"value": value.toJson
			]);
	}
private:
	Statement value;
}

class MathStatement : Statement {
public:
	this(Parser parser, Array!AttributeToken attr, OperatorType type, Statement left, Statement right) {
		super(parser, attr);
		this.type = type;
		this.left = left;
		this.right = right;
	} 
	
	@property OperatorType Type() { return type; }
	@property Statement Left() { return left; }
	@property Statement Right() { return right; }
	
	override JSONValue toJson() {
		return JSONValue([
				"class": JSONValue(typeof(this).classinfo.name),
				"super": super.toJson,
				"type": type.toJson,
				"left": left.toJson,
				"right": right.toJson
			]);
	}
private:
	OperatorType type;
	Statement left;
	Statement right;
}

class MathAssignStatement : Statement {
public:
	this(Parser parser, Array!AttributeToken attr, OperatorType type, Statement left, Statement right) {
		super(parser, attr);
		this.type = type;
		this.left = left;
		this.right = right;
	} 
	
	@property OperatorType Type() { return type; }
	@property Statement Left() { return left; }
	@property Statement Right() { return right; }
	
	override JSONValue toJson() {
		return JSONValue([
				"class": JSONValue(typeof(this).classinfo.name),
				"super": super.toJson,
				"type": type.toJson,
				"left": left.toJson,
				"right": right.toJson
			]);
	}
private:
	OperatorType type;
	Statement left;
	Statement right;
}

class ConditionalStatement : Statement {
public:
	this(Parser parser, Array!AttributeToken attr, OperatorType type, Statement left, Statement right) {
		super(parser, attr);
		this.type = type;
		this.left = left;
		this.right = right;
	} 
	
	@property OperatorType Type() { return type; }
	@property Statement Left() { return left; }
	@property Statement Right() { return right; }
	
	override JSONValue toJson() {
		return JSONValue([
				"class": JSONValue(typeof(this).classinfo.name),
				"super": super.toJson,
				"type": type.toJson,
				"left": left.toJson,
				"right": right.toJson
			]);
	}
private:
	OperatorType type;
	Statement left;
	Statement right;
}


class DataStatement : Statement {
public:
	this(Parser parser, Array!AttributeToken attr, SymbolToken symbol, Array!Argument templates, Scope operations) {
		super(parser, attr);
		this.symbol = symbol;
		this.templates = templates;
		this.operations = operations;
	}
	
	@property SymbolToken Symbol() { return symbol; }
	@property Array!Argument Templates() { return templates; }
	@property Scope Operations() { return operations; }
	
	@property override bool NeedEndToken() { return false; }
	
	override JSONValue toJson() {
		return JSONValue([
				"class": JSONValue(typeof(this).classinfo.name),
				"super": super.toJson,
				"symbol": symbol.toJson,
				"templates": templates.toJson,
				"operations": operations.toJson
			]);
	}
	
private:
	SymbolToken symbol;
	Array!Argument templates;
	Scope operations;
}

class ClassStatement : Statement {
public:
	this(Parser parser, Array!AttributeToken attr, SymbolToken symbol, Array!Argument templates, SymbolToken parent, Scope operations) {
		super(parser, attr);
		this.symbol = symbol;
		this.templates = templates;
		this.parent = parent;
		this.operations = operations;
	}
	
	@property SymbolToken Symbol() { return symbol; }
	@property Array!Argument Templates() { return templates; }
	@property SymbolToken Parent() { return parent; }
	@property Scope Operations() { return operations; }
	
	@property override bool NeedEndToken() { return false; }
	
	override JSONValue toJson() {
		return JSONValue([
				"class": JSONValue(typeof(this).classinfo.name),
				"super": super.toJson,
				"symbol": symbol.toJson,
				"templates": templates.toJson,
				"parent": parent ? parent.toJson : JSONValue("null"),
				"operations": operations.toJson
			]);
	}
	
private:
	SymbolToken symbol;
	Array!Argument templates;
	SymbolToken parent;
	Scope operations;
}