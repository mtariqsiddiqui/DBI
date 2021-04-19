module datasource;
import std.array;
import std.stdio;

import vibe.core.log;
import vibe.db.mongo.mongo;
import vibe.db.mongo.settings;

/// DataSource class for Application Database Handling
final class DataSource
{
private:
    MongoClient _client;
    MongoDatabase _db;
    MongoCollection _collection;

public:
    ///
    this(string host, string database, string collection)
    {
        _client = connectMongoDB(host);
        _db = _client.getDatabase(database);
        _collection = _client.getDatabase(_db)[collection];
    }

    // fetchOne
    // fetchAll
    // upsert
    // remove

    // /// 
    // MongoClient getDatabaseClient()
    // {
    //     auto _client = connectMongoDB("127.0.0.1", 27017);
    //     return _client;
    // }

    // ///
    // MongoDatabase getMongoDBDatabase(string db)
    // {
    //     _db = getDatabaseClient().getDatabase(db);
    //     return _db;
    // }

    // /// 
    // MongoCollection getCollection(MongoDatabase db, string cname)
    // {
    //     return db[cname];
    // }
}

// auto db1 = client.getDatabase("db1");
// auto banks = db1["banks"];

// pragma(msg, typeof(banks));

// Bson b1 = Bson([
//         "bankId": Bson("RJHISARI"),
//         "bankName": Bson("Al-Rajhi Bank."),
//         "branchCode": Bson(1)
//         ]);
// banks.insert(b1);
