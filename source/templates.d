module templates;

/// Template for generating REST API interfaces
template ApiInterface(string implName)
{
	enum string ApiInterface = "interface " ~ implName ~ "ApplicationInterface {\n "
		~ implName ~ " get" ~ implName ~ "(string eid);\n"
		~ implName ~ "[] get" ~ implName ~ "s();\n"
		~ "void create" ~ implName ~ "(" ~ implName ~ " e);\n"
		~ "void update" ~ implName ~ "(" ~ implName ~ " e);\n"
		~ "void delete" ~ implName ~ "(" ~ implName ~ " e); } \n";

	pragma(msg, ApiInterface);
}

/// Template for generation REST API interface implementation classes
template ApiImplementation(string implName, string collection)
{
	enum string ApiImplementation = "class " ~ implName ~ "ApplicationInterfaceImplementation : " ~ implName ~ "ApplicationInterface \n" 
		~ "{\n" 
		~ implName ~ " get" ~ implName ~ "(string eid) { \n"
		~ implName ~ " e; \n" ~ "e._id = BsonObjectID.fromString(eid); \n"
		~ "e = _ds.fetchOne!" ~ implName ~ "(e, \"" ~ collection ~ "\"); \n" ~ "return e; } \n" 
		~ implName ~ "[] get" ~ implName ~ "s() { \n" ~ implName ~ "[] e = _ds.fetchAll!" ~ implName ~ "(\"" ~ collection ~ "\"); \n return e; } \n" 
		~ " void create" ~ implName ~ "(" ~ implName ~ " e) { \n writeln(\"create"~ implName~" >>\");\n" ~ 
		"_ds.insert!" ~ implName ~ "(e, \"" ~ collection ~ "\"); \n /*return 0;*/ } \n" 
		~ " void update" ~ implName ~ "(" ~ implName ~ " e) { \n writeln(\"update"~ implName~" >>\");\n" ~
		"_ds.update!" ~ implName ~ "(e, \"" ~ collection ~ "\"); \n /*return 0;*/ } \n" 
		~ " void delete" ~ implName ~ "(" ~ implName ~ " e) { \n writeln(\"delete"~ implName~" >>\");\n" ~
		"_ds.remove!" ~ implName ~ "(e, \"" ~ collection ~ "\"); \n /*return 0;*/ } \n } " ;

	pragma(msg, ApiImplementation);
}

/// Template for registrering REST route for its REST implementation 
template RegisterRestRoute(string className, string url)
{
    enum string RegisterRestRoute = "router.registerRestInterface(new " ~ className ~ ", \"" ~ url ~ "\");" ;

   	pragma(msg, RegisterRestRoute);
}