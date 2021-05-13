module controller.api;

import std.algorithm.iteration;
import std.stdio;
import std.conv;
import std.json;
import std.array;
import std.typecons;
import std.traits;
import vibe.data.bson;
import datasource;
import templates;
import std.uni : toLower;

__gshared DataSource _ds = new DataSource;
__gshared enum auto cfg = parseJSON(import("model.json"));
__gshared enum auto navcfg = parseJSON(import("navigation.json"));
__gshared enum auto vucfg = parseJSON(import("view.json"));

/// The getJsonValue function takes JSONValue object and return its value or _none for missing values.
static string getJsonValue(JSONValue _obj, string key)
{
	if (const(JSONValue)* _key = key in _obj)
	{
		if (_key.type() == JSONType.string)
			return _key.get!string;
		if (_key.type() == JSONType.integer)
			return to!string(_key.get!int);
		else
			return "_none";
	}
	return "_none";
}

/// The parseEntities function read the JSON configuration and generated the code accordingly
static string parseEntities()
{
	string code = "";
	static foreach (index, key; cfg["ModelNames"].array.map!(item => item).array)
	{
		mixin("enum string k" ~ index.to!string ~ " = \"" ~ key.get!string ~ "\";");
		code = code ~ getJsonValue(cfg[mixin("k" ~ index.to!string)],
				"entity_type") ~ " " ~ key.get!string ~ " { ";

		static foreach (k; cfg[mixin("k" ~ index.to!string)]["fields"].array.map!(itm => itm).array)
			code = code ~ getJsonValue(k, "type") ~ " " ~ getJsonValue(k, "name") ~ "; ";

		code = code ~ "  @optional BsonObjectID _id; } \n";
	}
	return code;
}

pragma(msg, parseEntities());
mixin(parseEntities()); // print parseEntities output to see the generated code
// Parsing the configuration and creating REST API Interfaces and its Implementation classes during compilation
static foreach (index, key; cfg["ModelNames"].array.map!(item => item).array)
{
	mixin("enum string k" ~ index.to!string ~ " = \"" ~ key.get!string ~ "\";");

	mixin(ApiInterface!(mixin("\"" ~ key.get!string ~ "\"")));

	mixin(ApiImplementation!(mixin("\"" ~ key.get!string ~ "\""),
			mixin("\"" ~ getJsonValue(cfg[mixin("k" ~ index.to!string)], "collection_name") ~ "\"")));

	pragma(msg, [__traits(allMembers, mixin(key.get!string))]);
	pragma(msg, [__traits(allMembers, mixin(key.get!string ~ "ApplicationInterface"))]);
	pragma(msg, [__traits(allMembers, mixin(key.get!string ~ "ApplicationInterfaceImplementation"))]);
}