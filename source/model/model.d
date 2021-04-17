module model.model;

import std.algorithm.iteration;
import std.stdio;
import std.conv;
import std.json;
import std.array;

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

unittest
{
    auto b1 = Bank("SAMBASARI", "SAMBA Financials", 1);
    assert(b1.id == "SAMBASARI");
    assert(b1.branch_code == 1);
}
