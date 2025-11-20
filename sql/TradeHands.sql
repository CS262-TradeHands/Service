-- TradeHands Database Schema for Azure PostgreSQL

DROP TABLE IF EXISTS ProfileMatch CASCADE;
DROP TABLE IF EXISTS BusinessListing CASCADE;
DROP TABLE IF EXISTS BuyerProfile CASCADE;
DROP TABLE IF EXISTS AppUser CASCADE;

-- User accounts
CREATE TABLE AppUser (
    user_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(50) UNIQUE NOT NULL,
    phone VARCHAR(50),
    password_hash VARCHAR(60) NOT NULL,
    profile_image_url VARCHAR(255),
    verified BOOLEAN,
    private BOOLEAN,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Business Listings
CREATE TABLE BusinessListing (
    business_id SERIAL PRIMARY KEY,
    owner_id INT REFERENCES AppUser(user_id) ON DELETE SET NULL,
    name VARCHAR(50) NOT NULL,
    industry VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50),
    image_url VARCHAR(255),
    asking_price_upper_bound INT, -- in USD
    asking_price_lower_bound INT, -- in USD
    description TEXT,
    employees INT, -- people
    years_in_operation INT, -- years
    annual_revenue INT, -- in USD
    monthly_revenue INT, -- in USD
    profit_margin INT, -- percentage
    timeline INT, -- months
    website VARCHAR(255),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Buyers
CREATE TABLE BuyerProfile (
    buyer_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES AppUser(user_id) ON DELETE SET NULL,
    title VARCHAR(50),
    about TEXT,
    experience FLOAT, -- years
    budget_range_lower INT, -- USD
    budget_range_higher INT, -- USD
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50),
    industries VARCHAR(100)[],
    size_preference VARCHAR(100), -- Small, Small-Medium, Medium, Large
    timeline INT, -- months
    linkedin_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Matches between buyers and owners
CREATE TABLE ProfileMatch (
    interest_id SERIAL PRIMARY KEY,
    buyer_id INT REFERENCES BuyerProfile(buyer_id) ON DELETE CASCADE,
    business_id INT REFERENCES BusinessListing(business_id) ON DELETE CASCADE,
    rating INT,     --percent that represents how strong the match is
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE (buyer_id, business_id)
);

-- SAMPLE DATA (matches the mock data in Client)

INSERT INTO AppUser (first_name, last_name, email, phone, profile_image_url, password_hash, verified, private) VALUES
--Owners
('David', 'Chen', 'david@techstartsolutions.com', '5551234567', NULL, 'hash1', true, false),
('Isabella', 'Moore', 'isabella@bellaboutique.com', '5552345678', NULL, 'hash2', true, false),
('Miguel', 'Alvarez', 'miguel@greenclean.co', '5553456789', NULL, 'hash3', true, false),
('Sam', 'Patel', 'sam@craftbrewco.com', '5554567890', NULL, 'hash4', true, false),
('Dr. Priya', 'Sharma', 'priya@medicarplus.com', '5555678901', NULL, 'hash5', true, false),
--Buyers
('Khaled', 'Nguyen', 'khaled.nguyen@example.com', '5556789012', NULL, 'hash6', true, false),
('Miriam', 'Reyes', 'miriam.reyes@example.com', '1555768901', NULL, 'hash7', true, false),
('Bobby', 'Ortiz', 'bobby.ortiz@example.com', '5557890123', NULL, 'hash8', true, false),
('Mickey', 'Turner', 'mickey.turner@example.com', '5558901234', NULL, 'hash9', true, false),
('Sandra', 'Lopez', 'sandra.lopez@example.com', '5559012345', NULL, 'hash10', true, false),
('Alex', 'Kim', 'alex.kim@example.com', '5550123456', NULL, 'hash11', true, false),
--Special
('Holger', 'Woerner', 'Holger.Woerner@bakery.com', '491635551584', NULL, 'hash12', true, false);

INSERT INTO BusinessListing (owner_id, name, industry, asking_price_lower_bound, asking_price_upper_bound, city, state, country, description, employees, years_in_operation, annual_revenue, monthly_revenue, profit_margin, timeline, website)
VALUES
(1, 'TechStart Solutions', 'Tech', 250000, 300000, 'San Francisco', 'California', 'USA', 'Profitable SaaS company with recurring revenue and growing customer base.', 8, 5, 500000, 42000, 35, 3, 'www.techstartsolutions.com'),
(2, 'Bella''s Boutique', 'Retail', 150000, 200000, 'Austin', 'Texas', 'USA', 'Established women''s clothing boutique in prime downtown location with loyal customer base.', 3, 7, 250000, 21000, 20, 5, NULL),
(3, 'Green Clean Services', 'Service', 80000, 120000, 'Denver', 'Colorado', 'USA', 'Eco-friendly cleaning service with commercial and residential clients.', 12, 4, 300000, 25000, 28, 12, NULL),
(4, 'Craft Brewery Co.', 'Food & Beverage', 400000, 500000, 'Portland', 'Oregon', 'USA', 'Popular local brewery with taproom and distribution network.', 15, 6, 600000, 50000, 32, 9, NULL),
(5, 'MediCare Plus', 'Healthcare', 600000, 750000, 'Miami', 'Florida', 'USA', 'Well-established medical practice with multiple locations.', 25, 12, 1000000, 83000, 40, 7, NULL),
(12, 'Backerei Woerner', 'Food & Beverage', 750000, 1000000, 'Jettingen', NULL, 'Germany', 'Delicious bakery with incredible family legacy.', 15, 250, 1000000, 111000, 42, 8, 'www.baeckerei-holger-woerner.de');

INSERT INTO BuyerProfile (user_id, city, state, country, title, industries, about, budget_range_lower, budget_range_higher, experience, timeline, size_preference, linkedin_url)
VALUES
(6, 'San Francisco', 'California', 'USA', 'Investor / Entrepreneur', ARRAY['Tech', 'SaaS'], 'Serial entreprenuer with 15+ years of experience building and scaling tech companies.', 500000, 2000000, 15.0, 6, 'Large', NULL),
(7, 'Austin', 'Texas', 'USA', 'Retail Buyer', ARRAY['Retail', 'Fashion'], 'Experienced retail operator looking to expand porfolio with established businesses.', 200000, 800000, 10.0, 12, 'Medium', NULL),
(8, 'Denver', 'Colorado', 'USA', 'Service Business Investor', ARRAY['Service', 'Cleaning'], 'Private investor seeking profitable service-based businesses with recurring revenue.', 300000, 1000000, 8.0, 3, 'Medium', NULL),
(9, 'Portland', 'Oregon', 'USA', 'Brewery Enthusiast', ARRAY['Food & Beverage'], 'Craft beer enthusiast looking to aquire established breweries or taprooms.', 400000, 1500000, 5.0, 9, 'Small', NULL),
(10, 'Miami', 'Florida', 'USA', 'Healthcare Investor', ARRAY['Healthcare'], 'Healthcare professional seeking to acquire medical practices and healthcare services.', 600000, 3000000, 12.0, 3, 'Small', NULL),
(11, 'Seattle', 'Washington', 'USA', 'Tech Acquirer', ARRAY['Tech'], 'Tech executive looking to acquire software companies and tehc-enabled services.', 750000, 5000000, 20.0, 3, 'Large', NULL);

INSERT INTO ProfileMatch (buyer_id, business_id, rating)
VALUES
(1, 1, 90),
(2, 2, 83),
(3, 3, 79),
(4, 4, 65),
(5, 5, 75);

