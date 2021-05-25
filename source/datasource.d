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
import apigenerator : dbcfg;


// import vibe.db.mongo.settings;

/// DataSource class for Application Database Handling
class DataSource
{
    /// MongoDB Database hostname
    static string _dbhost = dbcfg["mongodb_host"].str;
    /// MongoDB Database port number
    static ushort _dbport = to!ushort(dbcfg["mongodb_port"].integer);
    /// MongoDB Database Name
    static string _dbname = dbcfg["mongodb_database"].str;

    /// Prepare Bson Data from provided object for database CRUD operations
    Bson prepareBsonData(T)(T t)
    {
        Bson b = Bson.emptyObject;
        foreach (key; __traits(allMembers, T))
        {
            static if (key == "_id" && typeid(mixin("t."~key)) == typeid(vibe.data.bson.BsonObjectID))
            {
                enum string code = "if (! t." ~ key ~ ".valid ) "
                    ~ "b[key] = BsonObjectID.generate();" ~ " else " ~ "b[key] = t." ~ key ~ ";";
                // pragma(msg, code);
                mixin(code);
            }
            else
            {
                // if member is type of Integer or Float and > 0 
                enum string code2 = " static if(__traits(isArithmetic, typeof(t." ~ key ~ "))) {" 
                    ~ " if(t." ~ key ~ " != 0) "
                    ~ " b[key] = t." ~ key ~ ";" 
                    ~ "} else static if(isSomeString!(typeof(t." ~ key ~ ")) || isSomeChar!(typeof(t." ~ key ~ "))) {"
                    ~ " if(t." ~ key ~ " !is null) "
                    ~ " b[key] = t." ~ key ~ "; }";
                // pragma(msg, code2);
                mixin(code2);
            }
        }
        return b;
    }

    /// Fetch only One document (record) from the MongoDB collection (table) for the matched _id or return Null
    Nullable!T fetchOne(T)(T t, string collection)
    {
        Bson b = prepareBsonData(t);
        auto _client = connectMongoDB(_dbhost, _dbport);
        auto _db = _client.getDatabase(_dbname);

        Nullable!T e = _db[collection].findOne!T(b);
        if (e.isNull)
            e = t;

        return e;
    }

    /// Fetch and return all the documents (records) from the given MongoDB collection (table)
    T[] fetchAll(T)(string collection)
    {
        T[] ta;
        try
        {
            auto _client = connectMongoDB(_dbhost, _dbport);
            auto _db = _client.getDatabase(_dbname);
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

    /// Insert the document (record) for the given entity into the MongoDB collection (table)
    void insert(T)(T t, string collection)
    {
        Bson bd = prepareBsonData!T(t);
        try
        {
            auto _client = connectMongoDB(_dbhost, _dbport);
            auto _db = _client.getDatabase(_dbname);
            _db[collection].insert(bd);
            _db.destroy();
            _client.destroy();
        }
        catch (MongoDBException e)
        {
            writeln("Mongo DB Exception occur. Message is " ~ e.message);
        }
    }

    /// Update the document (record) for the given entity into the MongoDB collection (table) for the matched _id
    void update(T)(T t, string collection)
    {
        Bson bd = prepareBsonData!T(t);
        try
        {
            auto _client = connectMongoDB(_dbhost, _dbport);
            auto _db = _client.getDatabase(_dbname);
        
            _db[collection].update(["_id" : t._id],bd, UpdateFlags.upsert);
            _db.destroy();
            _client.destroy();
        }
        catch (MongoDBException e)
        {
            writeln("Mongo DB Exception occur. Message is " ~ e.message);
        }
    }

    /// Delete the document (record) for the given entity from the MongoDB collection (table) for the matched _id
    void remove(T)(T t, string collection)
    {
        Bson bd = prepareBsonData!T(t);
        try
        {
            auto _client = connectMongoDB(_dbhost, _dbport);
            auto _db = _client.getDatabase(_dbname);
            writeln(t._id);
            _db[collection].remove(["_id" : t._id]);

            _db.destroy();
            _client.destroy();
        }
        catch (MongoDBException e)
        {
            writeln("Mongo DB Exception occur. Message is " ~ e.message);
        }
    }
}