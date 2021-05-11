import vibe.d;
import std.array;
import std.algorithm.iteration;
import std.stdio;
import std.json;
import controller.api;
import templates;

void main()
{
	auto settings = new HTTPServerSettings;
	settings.port = 3000;
	settings.bindAddresses = ["::1", "127.0.0.1"];
	settings.sessionStore = new MemorySessionStore;

	auto router = new URLRouter;
	// calls index function when / is accessed
	router.get("/", &index);
	// router.get("/public*", &testing);
	// Serves files out of public folder
	// router.get("*", serveStaticFiles("./public/"));

	auto fsettings = new HTTPFileServerSettings;
	fsettings.serverPathPrefix = "/static";
	router.get("/static/*", serveStaticFiles("public/", fsettings));


	// Binds an instance of API-Implementation to the /api-url/ prefix. 
	static foreach (index, key; cfg["ModelNames"].array.map!(item => item).array)
	{
		mixin(RegisterRestRoute!(mixin("\"" ~ key.get!string ~ "ApplicationInterfaceImplementation" ~ "\""),
				mixin("\"" ~ toLower(key.get!string) ~ "-api\"")));
	}

	listenHTTP(settings, router);
	runApplication();
}

/// Rendering of Index URL
void index(HTTPServerRequest req, HTTPServerResponse res)
{
	res.render!("index.dt");
}

/// Rendering of Index URL
void testing(HTTPServerRequest req, HTTPServerResponse res)
{
	writeln(req.fullURL);
	writeln(req.requestURL);
	writeln(req.requestURI);
	string view = req.requestURL;
	import std.string;
	view = chompPrefix(view, "/") ~ ".dt";
	writeln(view);
	res.render!("testing.dt");
}
