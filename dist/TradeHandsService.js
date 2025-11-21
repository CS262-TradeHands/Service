/**
 * This module implements a REST-inspired web service for the TradeHands DB hosted
 * on PostgreSQL for Azure.
 
 * @author: TradeHands Service Team
 * @date: Fall, 2025
 */
import 'dotenv/config'; // Load environment variables from .env
import express from 'express';
import pgPromise from 'pg-promise';
// Set up the database
const db = pgPromise()({
    host: process.env.DB_SERVER,
    port: parseInt(process.env.DB_PORT) || 5432,
    database: process.env.DB_DATABASE,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
});
// Configure the server and its routes
const app = express();
const port = parseInt(process.env.PORT) || 3000;
const router = express.Router();
router.use(express.json());
router.get('/', readHello);
app.use(router);
// Custom error handler - must be defined AFTER all routes
app.use((err, _req, res, _next) => {
    // Log the full error server-side for debugging
    console.error('Error:', err.message);
    console.error('Stack:', err.stack);
    // Send generic error to client (never expose internal details)
    res.status(500).json({
        error: 'An internal server error occurred'
    });
});
app.listen(port, () => {
    console.log(`Listening on port ${port}`);
});
/**
 * This utility function standardizes the response pattern for database queries,
 * returning the data using the given response, or a 404 status for null data
 * (e.g., when a record is not found).
 */
function returnDataOr404(response, data) {
    if (data == null) {
        response.sendStatus(404);
    }
    else {
        response.send(data);
    }
}
/**
 * This endpoint returns a simple hello-world message, serving as a basic
 * health check and welcome message for the API.
 */
function readHello(_request, response) {
    response.send('Hello, TradeHands!');
}
