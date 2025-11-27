/**
 * This module implements a REST-inspired web service for the TradeHands DB hosted
 * on PostgreSQL for Azure.
 
 * @author: TradeHands Service Team
 * @date: Fall, 2025
 */

import 'dotenv/config' // Load environment variables from .env
import express from 'express';
import pgPromise from 'pg-promise';

// Import types for compile-time checking.
import type { Request, Response, NextFunction } from 'express';
import type { User } from "./User.js";
import type { Buyer } from "./Buyer.js";
import type { Listing } from "./Listing.js"


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