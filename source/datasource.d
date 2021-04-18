module datasource;
import std.array;
import std.stdio;

import vibe.core.log;
import vibe.db.mongo.mongo;
import vibe.db.mongo.settings;


MongoClient getDatabaseClient()
{
    auto client = connectMongoDB("127.0.0.1", 27017);
    return client;
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

///
MongoDatabase getMongoDBDatabase()
{
    auto db = getDatabaseClient().getDatabase("db1");
    return db;
}

/// 
MongoCollection getCollection(MongoDatabase db, string cname)
{
    return db[cname];
}

