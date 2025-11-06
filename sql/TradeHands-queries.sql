-- SAMPLE QUERIES for the TradeHands Database

-- 1. Get all business listings
SELECT * FROM BusinessListing ORDER BY business_id;

-- 2. Search listings by keyword
SELECT * FROM BusinessListing
WHERE LOWER(name) LIKE LOWER('%tech%')
   OR LOWER(industry) LIKE LOWER('%tech%')
   OR LOWER(location) LIKE LOWER('%tech%');

-- 3. Show all buyers interested in each business
SELECT b.name AS buyer_name, bl.name AS business_name, i.message, i.created_at
FROM ProfileMatch i
JOIN BuyerProfile b ON i.buyer_id = b.buyer_id
JOIN BusinessListing bl ON i.business_id = bl.business_id
ORDER BY bl.business_id;

-- 4. Get all businesses owned by a user
SELECT bl.* FROM BusinessListing bl
JOIN AppUser u ON u.user_id = bl.owner_id
WHERE u.email = 'david@techstartsolutions.com';