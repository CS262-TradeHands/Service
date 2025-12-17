/**
 * This module implements a REST-inspired web service for the TradeHands DB hosted
 * on PostgreSQL for Azure.
 
 * @author: TradeHands Service Team
 * @date: Fall, 2025
 */

import 'dotenv/config' // Load environment variables from .env
import express from 'express';
import pgPromise from 'pg-promise';
import cors from "cors";


// Import types for compile-time checking.
import type { Request, Response, NextFunction } from 'express';
import type { User, UserInput } from "./User.js";
import type { Buyer, BuyerInput } from "./Buyer.js";
import type { Listing, ListingInput } from "./Listing.js"
import type { Match, MatchInput } from "./Match.js"


// Set up the database
const db = pgPromise()({
    host: process.env.DB_SERVER,
    port: parseInt(process.env.DB_PORT as string) || 5432,
    database: process.env.DB_DATABASE,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
});

// Configure the server and its routes
const app = express();

app.use(cors({
  origin: [
    "https://tradehands.vercel.app",
    // optional: allow local dev too
    "http://localhost:19006",
    "http://localhost:3000"
  ],
  methods: ["GET", "POST", "DELETE", "OPTIONS"],
  allowedHeaders: ["Content-Type", "Authorization"],
}));

const port: number = parseInt(process.env.PORT as string) || 3000;
const router = express.Router();

router.use(express.json());
router.get('/', readHello);
router.get('/users', readUsers);
router.get('/users/:id', readUser);

router.get('/buyers', readBuyers);
router.get('/buyers/:id', readBuyer);

router.get('/listings', readListings);
router.get('/listings/:id', readListing);


router.post('/users', createUser);
router.post('/buyers', createBuyer);
router.post('/listings', createListing);

router.delete('/users/:id', deleteUser);
router.delete('/buyers/:id', deleteBuyer);
router.delete('/listings/:id', deleteListing);

router.get('/matches', readMatches);
router.get('/matches/:id', readMatch);
router.post('/matches', createMatch);
router.delete('/matches/:id', deleteMatch);

app.use(router);

// Custom error handler - must be defined AFTER all routes
app.use((err: Error, _req: Request, res: Response, _next: NextFunction): void => {
    // Log the full error server-side for debugging
    console.error('Error:', err?.message);
    console.error('Stack:', err?.stack);

    void _next; // make lint happy

    // Send generic error to client (never expose internal details)
    res.status(500).json({
        error: 'An internal server error occurred'
    });
});

app.listen(port, (): void => {
    console.log(`Listening on port ${port}`);
});

/**
 * This utility function standardizes the response pattern for database queries,
 * returning the data using the given response, or a 404 status for null data
 * (e.g., when a record is not found).
 */
function returnDataOr404(response: Response, data: unknown): void {
    if (data == null) {
        response.sendStatus(404);
    } else {
        response.send(data);
    }
}

/**
 * This endpoint returns a simple hello-world message, serving as a basic
 * health check and welcome message for the API.
 */
function readHello(_request: Request, response: Response): void {
    response.send('Hello, TradeHands!');
}

/**
 * Retrieves all users from the database.
 */
function readUsers(_request: Request, response: Response, next: NextFunction): void {
    db.manyOrNone('SELECT * FROM AppUser')
        .then((data: User[]): void => {
            // data is a list, never null, so returnDataOr404 isn't needed.
            response.send(data);
        })
        .catch((error: Error): void => {
            next(error);
        });
}

/**
 * Retrieves a specific user by ID.
 */
function readUser(request: Request, response: Response, next: NextFunction): void {
    db.oneOrNone('SELECT * FROM AppUser WHERE user_id=${id}', request.params)
        .then((data: User | null): void => {
            returnDataOr404(response, data);
        })
        .catch((error: Error): void => {
            next(error);
        });
}

/**
 * Create a new user.
 * Expects body with: first_name, last_name, email, phone?, password_hash, profile_image_url?, verified?, private?
 * Returns the created user (including user_id).
 */
function createUser(request: Request, response: Response, next: NextFunction): void {
    db.one(
        `INSERT INTO AppUser (first_name, last_name, email, phone, password_hash, profile_image_url, verified, private)
         VALUES ($(first_name), $(last_name), $(email), $(phone), $(password_hash), $(profile_image_url), false, false)
         RETURNING user_id`,
        request.body as UserInput
    )
        .then((data: {user_id: number}): void => {
            response.status(201).send(data);
        })
        .catch((error: Error): void => {
            next(error);
        });
}

/**
 * Delete a user by id, essentially acting as a delete all.
 * Casades deletion of listing and profile records first using tx() to ensure all are deleted atomically.
 * Returns the id of the user account that was deleted or 404 if the user account does not exist.
 */
function deleteUser(request: Request, response: Response, next: NextFunction): void {
    db.tx((t) => {
        return t.none('DELETE FROM BuyerProfile WHERE user_id=${id}', request.params)
            .then(() => {
                return t.none('DELETE FROM BusinessListing WHERE owner_id=${id}', request.params);
            })
            .then(() => {
                return t.oneOrNone('DELETE FROM AppUser WHERE user_id=${id} RETURNING user_id', request.params);
            });
    })
        .then((data: { user_id: number } | null): void => {
            returnDataOr404(response, data);
        })
        .catch((error: Error): void => {
            next(error);
        });
}

/**
 * Delete a buyer profile by id.
 * Casades deletion of ProfileMatch records first using tx() to ensure both are deleted atomically.
 * Returns the id of the buyer profile that was deleted or 404 if the profile does not exist.
 */
function deleteBuyer(request: Request, response: Response, next: NextFunction): void {
    db.tx((t) => {
        return t.none('DELETE FROM ProfileMatch WHERE buyer_id=${id}', request.params)
            .then(() => {
                return t.oneOrNone('DELETE FROM BuyerProfile WHERE buyer_id=${id} RETURNING buyer_id', request.params);
            });
    })
        .then((data: { buyer_id: number } | null): void => {
            returnDataOr404(response, data);
        })
        .catch((error: Error): void => {
            next(error);
        });
}

/**
 * Delete a business listing by id.
 * Casades deletion of ProfileMatch records first using tx() to ensure both are deleted atomically.
 * Returns the id of the business listing that was deleted or 404 if the listing does not exist.
 */
function deleteListing(request: Request, response: Response, next: NextFunction): void {
    db.tx((t) => {
        return t.none('DELETE FROM ProfileMatch WHERE business_id=${id}', request.params)
            .then(() => {
                return t.oneOrNone('DELETE FROM BusinessListing WHERE business_id=${id} RETURNING business_id', request.params);
            });
    })
        .then((data: { business_id: number } | null): void => {
            returnDataOr404(response, data);
        })
        .catch((error: Error): void => {
            next(error);
        });
}

/**
 * Retrieves all buyers from the database.
 */
function readBuyers(_request: Request, response: Response, next: NextFunction): void {
    db.manyOrNone('SELECT * FROM BuyerProfile')
        .then((data: Buyer[]): void => {
            response.send(data);
        })
        .catch((error: Error): void => {
            next(error);
        });
}

/**
 * Retrieves a specific buyer by ID.
 */
function readBuyer(request: Request, response: Response, next: NextFunction): void {
    db.oneOrNone('SELECT * FROM BuyerProfile WHERE buyer_id=${id}', request.params)
        .then((data: Buyer | null): void => {
            returnDataOr404(response, data);
        })
        .catch((error: Error): void => {
            next(error);
        });
}

/**
 * Create a new buyer profile.
 * Expects body with: user_id, title, about, experience, budget_range_lower, budget_range_higher, city, state, country,
 * industries (string[]), size_preference, timeline, linkedin_url?
 * Returns the created buyer profile (including buyer_id).
 */
function createBuyer(request: Request, response: Response, next: NextFunction): void {
    db.one(
        `INSERT INTO BuyerProfile (user_id, title, about, experience, budget_range_lower, budget_range_higher,
                                   city, state, country, industries, size_preference, timeline, linkedin_url)
         VALUES ($(user_id), $(title), $(about), $(experience), $(budget_range_lower), $(budget_range_higher),
                 $(city), $(state), $(country), $(industries), $(size_preference), $(timeline), $(linkedin_url))
         RETURNING buyer_id`,
         request.body as BuyerInput
    )
        .then((data: {buyer_id: number}): void => {
            response.status(201).send(data);
        })
        .catch((error: Error): void => {
            next(error);
        });
}

/**
 * Retrieves all listings from the database.
 */
function readListings(_request: Request, response: Response, next: NextFunction): void {
    db.manyOrNone('SELECT * FROM BusinessListing')
        .then((data: Listing[]): void => {
            response.send(data);
        })
        .catch((error: Error): void => {
            next(error);
        });
}

/**
 * Retrieves a specific listing by ID.
 */
function readListing(request: Request, response: Response, next: NextFunction): void {
    db.oneOrNone('SELECT * FROM BusinessListing WHERE business_id=${id}', request.params)
        .then((data: Listing | null): void => {
            returnDataOr404(response, data);
        })
        .catch((error: Error): void => {
            next(error);
        });
}

/**
 * Create a new business listing.
 * Expects body with: owner_id, name, industry, city, state, country, image_url?, asking_price_upper_bound, asking_price_lower_bound,
 * description, employees, years_in_operation, annual_revenue, monthly_revenue, profit_margin, timeline, website?
 * Returns the created listing (including business_id).
 */
function createListing(request: Request, response: Response, next: NextFunction): void {
    db.one(
        `INSERT INTO BusinessListing (owner_id, name, industry, city, state, country, image_url,
                                      asking_price_upper_bound, asking_price_lower_bound, description, employees,
                                      years_in_operation, annual_revenue, monthly_revenue, profit_margin, timeline, website)
         VALUES ($(owner_id), $(name), $(industry), $(city), $(state), $(country), $(image_url),
                 $(asking_price_upper_bound), $(asking_price_lower_bound), $(description), $(employees),
                 $(years_in_operation), $(annual_revenue), $(monthly_revenue), $(profit_margin), $(timeline), $(website))
         RETURNING business_id`,
        request.body as ListingInput
    )
        .then((data: {business_id: number}): void => {
            response.status(201).send(data);
        })
        .catch((error: Error): void => {
            next(error);
        });
}

/**
 * Retrieves all interest matches from the database.
 */
function readMatches(_request: Request, response: Response, next: NextFunction): void {
    db.manyOrNone('SELECT * FROM ProfileMatch')
        .then((data: Match[]): void => {
            // data is a list, never null, so returnDataOr404 isn't needed.
            response.send(data);
        })
        .catch((error: Error): void => {
            next(error);
        });
}

/**
 * Retrieves one specific interest match from the database by ID.
 */
function readMatch(request: Request, response: Response, next: NextFunction): void {
    db.oneOrNone('SELECT * FROM ProfileMatch WHERE interest_id=${id}', request.params)
        .then((data: Match | null): void => {
            returnDataOr404(response, data);
        })
        .catch((error: Error): void => {
            next(error);
        });
}

/**
 * Creates an interest match and posts it to the database.
 */
function createMatch(request: Request, response: Response, next: NextFunction): void {
    db.one(
        `INSERT INTO ProfileMatch (buyer_id, business_id)
         VALUES ($(buyer_id), $(business_id))
         RETURNING interest_id`,
        request.body as MatchInput
    )
        .then((data: {interest_id: number}): void => {
            response.status(201).send(data);
        })
        .catch((error: Error): void => {
            next(error);
        });
}

/**
 * Delete an interest match by id.
 * Returns the id of the interest match that was deleted or 404 if the profile does not exist.
 */
function deleteMatch(request: Request, response: Response, next: NextFunction): void {
    db.tx((t) => {
        return t.none('DELETE FROM ProfileMatch WHERE interest_id=${id}', request.params)
    })
        .then((data: { interest_id: number } | null): void => {
            returnDataOr404(response, data);
        })
        .catch((error: Error): void => {
            next(error);
        });
}