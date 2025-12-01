# CS 262 TradeHands Data Service

This is the Data Service Application for the [TradeHands App](https://github.com/CS262-TradeHands/Project), which is deployed here:

* <https://tradehands-bpgwcja7g5eqf2dp.canadacentral-01.azurewebsites.net/>

At this URL, the following endpoints are implemented:

* `/` &mdash; a hello message for the TradeHands Webservice
* `/users` &mdash; the full list of user accounts
* `/users/:id` &mdash; the single user account with the given ID (e.g., `/users/1`)
* `/buyers` &mdash; the full list of buyer profiles
* `/buyers/:id` &mdash; the single buyer profile with the given ID (e.g., `/buyers/1`)
* `/listings` &mdash; the full list of business listings
* `/listings/:id` &mdash; the single business listing with the given ID (e.g., `/listings/1`)
* POST `/users` &mdash; adds a user account to the database and returns it's automatically generated user id
* POST `/buyers` &mdash; adds a buyer profile to the database and returns it's automatically generated buyer id
* POST `/listings` &mdash; adds a business listing to the database and returns it's automatically generated business id

It is based on the standard Azure App Service tutorial for Node.js.

The database is relational with the schema specified in the sql/ sub-directory and is hosted on Azure PostgreSQL. The database server, user and password are stored as Azure application settings so that they aren’t exposed in this public repo.

Link to the [Client Application](https://github.com/CS262-TradeHands/Client).
