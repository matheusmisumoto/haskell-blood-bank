# Blood Bank Management

This project is a blood bank management system that uses Haskell with Yesod Web Framework. The data is stored using a SQL database.

Developed by [Matheus Ferreira](https://github.com/MathOli/) and [Matheus Misumoto](https://matheusmisumoto.dev/) in 2021, during classes at São Paulo State Technological College.

Originally, this project was made using PostgreSQL and hosted on Heroku. However, after the termination of Heroku Free Dynos in 2022, I decided to migrate to Google Cloud.

The updated version is hosted using Cloud Run, using environment variables to connect to MySQL/MariaDB database.

The previous version still available both on release and on ``v1.0-postgresql`` branch.

More information about this project: https://matheusmisumoto.dev/tecnologia/desenvolvimento-web/blood-center-control-haskell.html

## Features

* Admin and user roles
* User management (create, edit and delete)
* Donators management (create, edit and delete)
* Collection management (create, edit and delete)
* Show today's schedule of blood collection

## Haskell Setup

1. If you haven't already, [install Stack](https://haskell-lang.org/get-started)
	* On POSIX systems, this is usually `curl -sSL https://get.haskellstack.org/ | sh`
2. Install the `yesod` command line tool: `stack install yesod-bin --install-ghc`
3. Build libraries: `stack build`

If you have trouble, refer to the [Yesod Quickstart guide](https://www.yesodweb.com/page/quickstart) for additional detail.

## Development

Start a development server with:

```
stack exec -- yesod devel
```

As your code changes, your site will be automatically recompiled and redeployed to localhost.

## Documentation

* Read the [Yesod Book](https://www.yesodweb.com/book) online for free
* Check [Stackage](http://stackage.org/) for documentation on the packages in your LTS Haskell version, or [search it using Hoogle](https://www.stackage.org/lts/hoogle?q=). Tip: Your LTS version is in your `stack.yaml` file.
* For local documentation, use:
	* `stack haddock --open` to generate Haddock documentation for your dependencies, and open that documentation in a browser
	* `stack hoogle <function, module or type signature>` to generate a Hoogle database and search for your query
* The [Yesod cookbook](https://github.com/yesodweb/yesod-cookbook) has sample code for various needs