-- TradeHands Database Schema for Azure PostgreSQL

DROP TABLE IF EXISTS interests CASCADE;
DROP TABLE IF EXISTS business_listings CASCADE;
DROP TABLE IF EXISTS buyers CASCADE;
DROP TABLE IF EXISTS app_users CASCADE;

-- User accounts
CREATE TABLE app_users (
    user_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100),
    last_name  VARCHAR(100),
    email      VARCHAR(255) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Business Listings
CREATE TABLE business_listings (
    business_id SERIAL PRIMARY KEY,
    owner_id INT REFERENCES app_users(user_id) ON DELETE SET NULL,
    name VARCHAR(255) NOT NULL,
    industry VARCHAR(100),
    asking_price_range VARCHAR(100),
    location VARCHAR(150),
    description TEXT,
    employees INT,
    years_in_operation INT,
    annual_revenue VARCHAR(100),
    monthly_revenue VARCHAR(100),
    profit_margin VARCHAR(50),
    reason_for_selling TEXT,
    website VARCHAR(255),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Buyers
CREATE TABLE buyers (
    buyer_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES app_users(user_id) ON DELETE SET NULL,
    name VARCHAR(100),
    city VARCHAR(150),
    title VARCHAR(150),
    interests TEXT[],
    avatar_url TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Buyers expressing interest in listings
CREATE TABLE interests (
    interest_id SERIAL PRIMARY KEY,
    buyer_id INT REFERENCES buyers(buyer_id) ON DELETE CASCADE,
    business_id INT REFERENCES business_listings(business_id) ON DELETE CASCADE,
    message TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE (buyer_id, business_id)
);

-- SAMPLE DATA (matches the mock data in Client)

INSERT INTO app_users (first_name, last_name, email, password_hash) VALUES
('David', 'Chen', 'david@techstartsolutions.com', 'hash1'),
('Bella', 'Smith', 'bella@boutique.com', 'hash2'),
('Maria', 'Lopez', 'maria@green-clean.com', 'hash3');

INSERT INTO business_listings (owner_id, name, industry, asking_price_range, location, description, employees, years_in_operation, annual_revenue, monthly_revenue, profit_margin, reason_for_selling, website)
VALUES
(1, 'TechStart Solutions', 'Tech', '$250,000 - $300,000', 'San Francisco, CA', 'Profitable SaaS company with recurring revenue and growing customer base.', 8, 5, '$500,000', '$42,000', '35%', 'Retiring after 25 years in tech industry.', 'www.techstartsolutions.com'),
(2, 'Bella''s Boutique', 'Retail', '$150,000 - $200,000', 'Austin, TX', 'Established women''s clothing boutique in prime downtown location with loyal customer base.', 3, 7, '$250,000', '$21,000', '20%', 'Moving to a new city.', NULL),
(3, 'Green Clean Services', 'Service', '$80,000 - $120,000', 'Denver, CO', 'Eco-friendly cleaning service with commercial and residential clients.', 12, 4, '$300,000', '$25,000', '28%', 'Starting new venture.', NULL),
(NULL, 'Craft Brewery Co.', 'Food & Beverage', '$400,000 - $500,000', 'Portland, OR', 'Popular local brewery with taproom and distribution network.', 15, 6, '$600,000', '$50,000', '32%', 'Seeking capital for expansion.', NULL),
(NULL, 'MediCare Plus', 'Healthcare', '$600,000 - $750,000', 'Miami, FL', 'Well-established medical practice with multiple locations.', 25, 12, '$1,000,000', '$83,000', '40%', 'Retirement.', NULL);

INSERT INTO buyers (name, city, title, interests)
VALUES
('Khaled', 'San Francisco, CA', 'Investor / Entrepreneur', ARRAY['Tech', 'SaaS']),
('Miriam', 'Austin, TX', 'Retail Buyer', ARRAY['Retail', 'Fashion']),
('Bobby', 'Denver, CO', 'Service Business Investor', ARRAY['Service', 'Cleaning']),
('Mickey', 'Portland, OR', 'Brewery Enthusiast', ARRAY['Food & Beverage']),
('Sandra', 'Miami, FL', 'Healthcare Investor', ARRAY['Healthcare']),
('Alex', 'Seattle, WA', 'Tech Acquirer', ARRAY['Tech']);

-- interests??
INSERT INTO interests (buyer_id, business_id, message)
VALUES
(1, 1, 'Interested in acquiring TechStart Solutions for expansion.'),
(2, 2, 'Would like to discuss the boutique''s sales data.'),
(4, 4, 'Passionate about breweries, seeking collaboration.');


-- SAMPLE QUERIES

-- 1. Get all business listings
SELECT * FROM business_listings ORDER BY business_id;

-- 2. Search listings by keyword
SELECT * FROM business_listings
WHERE LOWER(name) LIKE LOWER('%tech%')
   OR LOWER(industry) LIKE LOWER('%tech%')
   OR LOWER(location) LIKE LOWER('%tech%');

-- 3. Show all buyers interested in each business
SELECT b.name AS buyer_name, bl.name AS business_name, i.message, i.created_at
FROM interests i
JOIN buyers b ON i.buyer_id = b.buyer_id
JOIN business_listings bl ON i.business_id = bl.business_id
ORDER BY bl.business_id;

-- 4. Get all businesses owned by a user
SELECT bl.* FROM business_listings bl
JOIN app_users u ON u.user_id = bl.owner_id
WHERE u.email = 'david@techstartsolutions.com';

