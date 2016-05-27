module ast.util.json;

import std.json;
import std.container.array;
import ast.parser.statement;
import ast.lexer.token;
import ast.parser.data;

JSONValue toJson(T)(Array!T arr) if (is(T : Statement) || is(T : Token) || is(T : Argument)) {
	JSONValue ret = parseJSON(`[]`);
	foreach (obj; arr)
		ret.array ~= obj.toJson();
	return ret;
}

JSONValue toJson(T)(T obj) if (is(T == enum)) {
	import std.traits;
	import std.format;

	foreach (i, e; EnumMembers!T)
		if (obj == e)
			return JSONValue(__traits(allMembers, T)[i]);

	return JSONValue(format("cast(%s)%d", T.stringof, cast(OriginalType!T)obj));
}

JSONValue toJson(T)(T obj) if (is(T == TypeContainer)) {
	if (auto _ = obj.peek!TypeToken)
		return _.toJson;
	else if (auto _ = obj.peek!SymbolToken)
		return _.toJson;
	else if (auto _ = obj.peek!NoData)
		return _.toJson;
	else
		assert(0, "You forgot to update the ast.util.json.toJson, silly!");
}
