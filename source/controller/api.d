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

/// The parseEntities function read the JSON configuration and generated the code accordingly
static string parseEntities()
{
	string code = "";
	enum string config = import("model.json");
	immutable auto c1 = parseJSON(config);
	static foreach (index, key; c1["ModelNames"].array.map!(item => item).array)
	{
		mixin("enum string k" ~ index.to!string ~ " = \"" ~ key.get!string ~ "\";");
		code = code ~ getJsonValue(c1[mixin("k" ~ index.to!string)],
				"entity_type") ~ " " ~ key.get!string ~ " { ";

		static foreach (k; c1[mixin("k" ~ index.to!string)]["fields"].array.map!(itm => itm).array)
			code = code ~ getJsonValue(k, "type") ~ " " ~ getJsonValue(k, "name") ~ "; ";

		code = code ~ "  @optional BsonObjectID _id; } \n";
	}
	return code;
}

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

pragma(msg, parseEntities());
mixin(parseEntities()); // print parseEntities output to see the generated code

unittest
{
	auto b1 = Bank("SAMBASARI", "SAMBA Financials", 1);
	assert(b1.id == "SAMBASARI");
	assert(b1.branch_code == 1);
}

/// The parseEntities function read the JSON configuration and generated the code accordingly
static string generateEntityInterfaces()
{
	string code = "";
	enum string config = import("model.json");
	immutable auto c1 = parseJSON(config);

	static foreach (index, key; c1["ModelNames"].array.map!(item => item).array)
	{
		code = code ~ "interface " ~ key.get!string ~ "ApplicationInterface {\n ";
		code = code ~ key.get!string ~ " get" ~ key.get!string ~ "(string eid);\n";
		code = code ~ key.get!string ~ "[] get" ~ key.get!string ~ "s();\n";
		code = code ~ "size_t create" ~ key.get!string ~ "(" ~ key.get!string ~ " e);\n";
		code = code ~ "size_t update" ~ key.get!string ~ "(" ~ key.get!string ~ " e);\n";
		code = code ~ "size_t delete" ~ key.get!string ~ "(" ~ key.get!string ~ " e);\n";
		code = code ~ " } \n";
	}
	return code;
}

pragma(msg, generateEntityInterfaces());
mixin(generateEntityInterfaces());

import std.traits;

pragma(msg, [__traits(allMembers, Bank)]);
// pragma(msg, [__traits(allMembers, BankApplicationInterfaceImplementation)]);
// pragma(msg, [__traits(allMembers, BankApplicationInterface)]);

template ApiImplementation(alias implName, string collection)
{
	// enum string collection = "banks";
	enum string ApiImplementation =  "class " ~ implName ~ "ApplicationInterfaceImplementation : " ~ implName ~ "ApplicationInterface" ~
	"{" ~
	implName ~ " get" ~ implName ~ "(string eid) { " ~
	implName ~ " e;" ~
	"e._id = BsonObjectID.fromString(eid);" ~
	"e = _ds.fetchOne!" ~ implName ~ "(e, \"" ~ collection ~ "\");" ~
	"return e; } " ~
	implName ~ "[] get" ~ implName ~ "s() { " ~
	implName ~ "[] e = _ds.fetchAll!" ~ implName ~ "(\"" ~ collection ~ "\"); " ~
	" return e; } " ~
	" size_t create" ~ implName ~ "(" ~ implName ~ " e) { " ~
	"_ds.insert!" ~ implName ~ "(e, \"" ~ collection ~ "\"); " ~
	" return 0; } " ~
	" size_t update" ~ implName ~ "(" ~ implName ~ " e) { return 0; } " ~
	" size_t delete" ~ implName ~ "(" ~ implName ~ " e) { return 0;	} " ~
	"}" ;

	pragma(msg, ApiImplementation);

}

mixin(ApiImplementation!("Bank",  "banks"));
mixin(ApiImplementation!("Biller",  "billers"));

/// Bank Implementation methods
// class BankApplicationInterfaceImplementation : BankApplicationInterface
// {
// 	Bank getBank(string eid)
// 	{
// 		Bank bank;
// 		bank._id = BsonObjectID.fromString(bid);
// 		bank = _ds.fetchOne!Bank(bank, "banks");
// 		return bank;
// 	}

// 	Bank[] getBanks()
// 	{
// 		Bank[] banks = _ds.fetchAll!Bank("banks");
// 		return banks;
// 	}

// 	size_t createBank(Bank e)
// 	{
// 		_ds.insert!Bank(e, "banks");
// 		return 0;
// 	}

// 	size_t updateBank(Bank e)
// 	{
// 		return 0;
// 	}

// 	size_t deleteBank(Bank e)
// 	{
// 		return 0;
// 	}
// }
