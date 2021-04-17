module controller.api;


/// Dummy user
struct User
{
	/// First & Last Name
	string name;
	/// Age of this user
	int age;
}

/// API interface (required for registerRestInterface. Also makes API more easily documentable and allows for REST API clients)
interface MyAPI
{
    /// 
	User getUser();
	User[] getUsers();
	User getUser(string name);
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
		return [User("John Doe", 21), User("Peter Doe", 23), User("Mary Doe", 22)];
	}

	User getUser(string name)
	{
		return User(name, 44);
	}
}
