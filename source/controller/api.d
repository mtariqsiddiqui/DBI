module controller.api;

import std.algorithm.iteration;
import std.stdio;
import std.conv;
import std.json;
import std.array;
import std.typecons;
import vibe.data.bson;
import datasource;

__gshared DataSource _ds = new DataSource;

enum string config = import("model.json");
enum auto cfg = parseJSON(config);

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
		code = code ~ getJsonValue(cfg[mixin("k" ~ index.to!string)], "entity_type") 
					~ " " ~ key.get!string ~ " { ";

		static foreach (k; cfg[mixin("k" ~ index.to!string)]["fields"].array.map!(itm => itm).array)
			code = code ~ getJsonValue(k, "type") ~ " " ~ getJsonValue(k, "name") ~ "; ";

		code = code ~ "  @optional BsonObjectID _id; } \n";
	}
	return code;
}

/// Template for generating REST API interfaces
template ApiInterface(string implName)
{
	enum string ApiInterface = "interface " ~ implName ~ "ApplicationInterface {\n "
		~ implName ~ " get" ~ implName ~ "(string eid);\n"
		~ implName ~ "[] get" ~ implName ~ "s();\n"
		~ "size_t create" ~ implName ~ "(" ~ implName ~ " e);\n"
		~ "size_t update" ~ implName ~ "(" ~ implName ~ " e);\n"
		~ "size_t delete" ~ implName ~ "(" ~ implName ~ " e); } \n";

	pragma(msg, ApiInterface);
}

/// Template for generation REST API interface implementation classes
template ApiImplementation(string implName, string collection)
{
	// enum string collection = "banks";
	enum string ApiImplementation = "class " ~ implName ~ "ApplicationInterfaceImplementation : " ~ implName ~ "ApplicationInterface \n" 
		~ "{\n" ~ implName ~ " get" ~ implName ~ "(string eid) { \n"
		~ implName ~ " e; \n" ~ "e._id = BsonObjectID.fromString(eid); \n"
		~ "e = _ds.fetchOne!" ~ implName ~ "(e, \"" ~ collection ~ "\"); \n"
		~ "return e; } \n" ~ implName ~ "[] get" ~ implName ~ "s() { \n"
		~ implName ~ "[] e = _ds.fetchAll!" ~ implName ~ "(\"" ~ collection
		~ "\"); \n" ~ " return e; } \n" 
		~ " size_t create" ~ implName
		~ "(" ~ implName ~ " e) { \n" ~ "_ds.insert!" 
		~ implName ~ "(e, \""
		~ collection ~ "\"); \n" ~ " return 0; } \n" 
		~ " size_t update" ~ implName ~ "(" ~ implName ~ " e) { return 0; } \n" 
		~ " size_t delete" ~ implName ~ "(" ~ implName ~ " e) { return 0; } \n }";

	pragma(msg, ApiImplementation);
}

pragma(msg, parseEntities());
mixin(parseEntities()); // print parseEntities output to see the generated code

static foreach (index, key; cfg["ModelNames"].array.map!(item => item).array)
{
	mixin("enum string k" ~ index.to!string ~ " = \"" ~ key.get!string ~ "\";");
	
	mixin(ApiInterface!(mixin("\"" ~ key.get!string ~ "\"")));

	mixin(ApiImplementation!(
		mixin("\"" ~ key.get!string ~ "\""),
		mixin("\"" ~
		getJsonValue(cfg[mixin("k" ~ index.to!string)], "collection_name")
		 ~ "\"")
	));
}

import std.traits;
pragma(msg, [__traits(allMembers, Bank)]);
pragma(msg, [__traits(allMembers, BankApplicationInterfaceImplementation)]);
pragma(msg, [__traits(allMembers, BankApplicationInterface)]);
