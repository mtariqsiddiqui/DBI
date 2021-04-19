module controller.api;

import std.algorithm.iteration;
import std.stdio;
import std.conv;
import std.json;
import std.array;
import vibe.data.bson;

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

		code = code ~ " } \n";
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

/// Dummy user
struct User
{
	/// First & Last Name
	string name;
	/// Age of this user
	int age;
}

unittest
{
	auto b1 = Bank("SAMBASARI", "SAMBA Financials", 1);
	assert(b1.id == "SAMBASARI");
	assert(b1.branch_code == 1);
}

/// API interface (required for registerRestInterface. Also makes API more easily documentable and allows for REST API clients)
interface MyAPI
{
	/// 
	User getUser();
	User[] getUsers();
}

/// Implementation of API Interface
class MyAPIImplementation : MyAPI
{
	// GET /api/user
	User getUser()
	{
		return User("John Doe", 21);
	}

	// GET /api/users
	User[] getUsers()
	{
		return [
			User("John Doe", 21), User("Peter Doe", 23), User("Mary Doe", 22)
		];
	}
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
		code = code ~ key.get!string ~ " get" ~ key.get!string ~ "(string id);\n";
		code = code ~ key.get!string ~ "[] get" ~ key.get!string ~ "s(string id);\n";
		code = code ~ "size_t create" ~ key.get!string ~ "(" ~ key.get!string ~ " e);\n";
		code = code ~ "size_t update" ~ key.get!string ~ "(" ~ key.get!string ~ " e);\n";
		code = code ~ "size_t delete" ~ key.get!string ~ "(" ~ key.get!string ~ " e);\n";
		code = code ~ " } \n";
	}
	return code;
}

pragma(msg, generateEntityInterfaces());

mixin(generateEntityInterfaces());

// interface BankApplicationInterface
// {
// 	Bank getBank(string id);
// 	Bank[] getBanks(string id);
// 	size_t createBank(Bank e);
// 	size_t updateBank(Bank e);
// 	size_t deleteBank(Bank e);
// }

/// Bank Implementation methods
class BankApplicationInterfaceImplementation : BankApplicationInterface
{
	Bank getBank(string id)
	{
		Bank b = Bank("SAMBASARI_1", "SAMBA Financial Groups.", 1);
		return b;
	}

	Bank[] getBanks(string id)
	{
		Bank[] banks = [
			Bank("SAMBASARI_1", "SAMBA Financial Groups.", 1),
			Bank("SAMBASARI_2", "SAMBA Financial Groups.", 2),
			Bank("SAMBASARI_3", "SAMBA Financial Groups.", 3)
		];
		return banks;
	}

	size_t createBank(Bank e)
	{
		return 0;
	}

	size_t updateBank(Bank e)
	{
		return 0;
	}

	size_t deleteBank(Bank e)
	{
		return 0;
	}
}