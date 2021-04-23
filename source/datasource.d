module datasource;

import std.conv;
import std.array;
import std.stdio;
import std.range;
import std.json;
import std.traits;
import std.typecons;

import vibe.core.log;
import vibe.db.mongo.mongo;

// import vibe.db.mongo.settings;

/// DataSource class for Application Database Handling
class DataSource
{
    /// Prepare Bson Data from provided object for database CRUD operations
    Bson prepareBsonData(T)(T t)
    {
        Bson b = Bson.emptyObject;
        foreach (key; __traits(allMembers, T))
        {
            static if (key == "_id")
            {
                enum string code = "if ( is ( typeof ( t." ~ key ~ " is null ) ) ) "
                    ~ "b[key] = BsonObjectID.generate();" ~ " else " ~ "b[key] = t." ~ key ~ ";";
                pragma(msg, code);
                mixin(code);
            }
            // if member is type of Integer or Float and > 0
            enum string code2 = " static if(__traits(isArithmetic, typeof(t." ~ key ~ "))) " ~ " if(t." ~ key ~ " != 0) "
                ~ " b[key] = t." ~ key ~ ";" ~ " static if(isSomeString!(typeof(t."
                ~ key ~ ")) || isSomeChar!(typeof(t." ~ key ~ "))) " ~ " if(t."
                ~ key ~ " !is null) " ~ " b[key] = t." ~ key ~ ";";
            pragma(msg, code2);
            mixin(code2);
        }
        return b;
    }

    Nullable!T fetchOne(T)(T t, string collection)
    {
        Bson b = prepareBsonData(t);
        auto _client = connectMongoDB("127.0.0.1", 27017);
        auto _db = _client.getDatabase("db1");

        write("This is Prepared BSON : ");
        writeln(b);

        Nullable!T e = _db[collection].findOne!T(b);
        writeln(e);

        if (e.isNull)
        {
            e = e.init;
            writeln(e);
        }
        return e;
    }

    T[] fetchAll(T)(string collection)
    {
        T[] ta;
        try
        {
            auto _client = connectMongoDB("127.0.0.1", 27017);
            auto _db = _client.getDatabase("db1");
            foreach (e; _db[collection].find!T())
                ta ~= e;
            _db.destroy();
            _client.destroy();
        }
        catch (MongoDBException e)
        {
            writeln("Mongo DB Exception occur. Message is " ~ e.message);
        }
        return ta;
    }

    size_t insert(T)(T t, string collection)
    {
        Bson bd = prepareBsonData!T(t);
        try
        {
            auto _client = connectMongoDB("127.0.0.1", 27017);
            auto _db = _client.getDatabase("db1");
            _db[collection].insert(bd);
            _db.destroy();
            _client.destroy();
        }
        catch (MongoDBException e)
        {
            writeln("Mongo DB Exception occur. Message is " ~ e.message);
        }
        return 0;
    }

    size_t update(T)(T t)
    {
        return 0;
    }

    size_t remove(T)(T t)
    {
        return 0;
    }
}
