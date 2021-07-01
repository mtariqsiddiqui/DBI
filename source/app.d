module app;

import vibe.d;
import std.array;
import std.algorithm.iteration;
import std.stdio;
import std.json;
import std.string;

import apigenerator;
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
	router.get("/forms/*", &formsHandler);

	// Serves files out of public folder
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
void formsHandler(HTTPServerRequest req, HTTPServerResponse res)
{
	string context = chompPrefix(req.requestURI, "/forms/");
	/// nViewFlag 0 is defalut
	/// 1 ==> render form with context
	/// 2 ==> render index with Disabled message
	/// 0 ==> 404 Not found
	short nViewFlag = 0;

	foreach (key; vucfg["enabled_views"].array.map!(item => item).array)
	{
		if (key.get!string == context)
		{
			nViewFlag = 1;
			break;
		}
	}
	if (nViewFlag == 0)
	{
		foreach (key; vucfg["disabled_views"].array.map!(item => item).array)
		{
			if (key.get!string == context)
			{
				nViewFlag = 2;
				break;
			}
		}
	}

	if (nViewFlag == 1)
		res.render!("forms.dt", context);
	else if (nViewFlag == 2)
	{
		res.statusCode = 405; // 405 Method Not Allowed or Disabled
		res.render!("index_disabled.dt", context);
	}
	else if (nViewFlag == 0)
	{
		res.statusCode = 404; // 404 Not Found
		res.render!("index_404.dt");
	}
}
