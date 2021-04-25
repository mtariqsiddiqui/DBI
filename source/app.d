import vibe.d;
import controller.api;
import std.stdio;
import std.json;

__gshared auto router = new URLRouter;

void main()
{
	auto settings = new HTTPServerSettings;
	settings.port = 3000;
	settings.bindAddresses = ["::1", "127.0.0.1"];
	// Enables sessions which are stored in memory
	// RedisSessionStore can also be used when connected with a Redis database.

	// Additional Session Stores: (third party)
	// MongoDB Session Store - available via the dependency `mongostore`
	settings.sessionStore = new MemorySessionStore;

	// __gshared auto router = new URLRouter;
	// calls index function when / is accessed
	router.get("/", &index);
	// Serves files out of public folder
	router.get("*", serveStaticFiles("./public/"));

	// Binds an instance of MyAPIImplementation to the /api/ prefix. All endpoints will have /api/ prefixed.
	// router.registerRestInterface(new MyAPIImplementation, "/api/");
	router.registerRestInterface(new BankApplicationInterfaceImplementation, "/api/");

	// Testing Start
	// MyAPIImplementation api = new MyAPIImplementation;
	BankApplicationInterfaceImplementation bpi = new BankApplicationInterfaceImplementation;
	// writeln(api.getUser());
	writeln(bpi.getBank("60808fc0a6314dd46c36224c"));
	writeln(bpi.getBanks());
	// Testing End

	listenHTTP(settings, router);
	
	runApplication();
}


/// Rendering of Index URL
void index(HTTPServerRequest req, HTTPServerResponse res)
{
	res.render!("index.dt");
}
