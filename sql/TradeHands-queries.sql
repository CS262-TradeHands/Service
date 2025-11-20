-- SAMPLE QUERIES for the TradeHands Database

-- Get all users of the app
SELECT * FROM AppUser;

-- Get all business listings
SELECT * FROM BusinessListing;

-- Get all buyer profiles
SELECT * FROM BuyerProfile;

-- Search listings by keyword 'tech'
SELECT * FROM BusinessListing
WHERE LOWER(name) LIKE LOWER('%tech%')
   OR LOWER(industry) LIKE LOWER('%tech%');

-- Search listings by asking price
SELECT name, asking_price_upper_bound FROM BusinessListing
WHERE asking_price_upper_bound < 500000;

-- Find listings of a certain size
SELECT name, employees, monthly_revenue FROM BusinessListing
WHERE employees < 15
AND monthly_revenue < 50000;

-- Find buyers with more than 10 years of experience and a specified budget
SELECT first_name, experience, budget_range_higher FROM AppUser
JOIN BuyerProfile ON BuyerProfile.user_id = AppUser.user_id
WHERE experience > 10
AND budget_range_higher > 1000000;

-- Show all buyers matched with each business
SELECT u.first_name, u.last_name, name, rating, i.created_at
FROM ProfileMatch i
JOIN BuyerProfile b ON i.buyer_id = b.buyer_id
JOIN AppUser u ON u.user_id = b.user_id
JOIN BusinessListing bl ON i.business_id = bl.business_id
ORDER BY bl.business_id;

-- Get all businesses owned by a user
SELECT bl.* FROM BusinessListing bl
JOIN AppUser u ON u.user_id = bl.owner_id
WHERE u.email = 'david@techstartsolutions.com';