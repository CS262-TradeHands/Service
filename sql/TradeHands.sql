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
    phone INT,
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
    location VARCHAR(100),
    image_url VARCHAR(255),
    asking_price_range VARCHAR(100),
    description TEXT,
    employees INT,
    years_in_operation INT,
    annual_revenue VARCHAR(100),
    monthly_revenue VARCHAR(100),
    profit_margin VARCHAR(50),
    timeline VARCHAR(100),
    website VARCHAR(255),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Buyers
CREATE TABLE BuyerProfile (
    buyer_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES AppUser(user_id) ON DELETE SET NULL,
    buyer_type VARCHAR(50),
    title VARCHAR(50),
    about TEXT,
    experience VARCHAR(50),
    budget_range VARCHAR(100),
    location VARCHAR(100),
    industries VARCHAR(100)[],
    size_preference VARCHAR(100),
    timeline VARCHAR(100),
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

INSERT INTO AppUser (first_name, last_name, email, phone, password_hash, verified, private) VALUES
--Owners
('David', 'Chen', 'david@techstartsolutions.com', 5551234567, 'hash1', true, false),
('Isabella', 'Moore', 'isabella@bellaboutique.com', 5552345678, 'hash2', true, false),
('Miguel', 'Alvarez', 'miguel@greenclean.co', 5553456789, 'hash3', true, false),
('Sam', 'Patel', 'sam@craftbrewco.com', 5554567890, 'hash4', true, false),
('Dr. Priya', 'Sharma', 'priya@medicarplus.com', 5555678901, 'hash5', true, false),
--Buyers
('Khaled', 'Nguyen', 'khaled.nguyen@example.com', 5556789012, 'hash6', true, false),
('Miriam', 'Reyes', 'miriam.reyes@example.com', 1555768901, 'hash7', true, false),
('Bobby', 'Ortiz', 'bobby.ortiz@example.com', 5557890123, 'hash8', true, false),
('Mickey', 'Turner', 'mickey.turner@example.com', 5558901234, 'hash9', true, false),
('Sandra', 'Lopez', 'sandra.lopez@example.com', 5559012345, 'hash10', true, false),
('Alex', 'Kim', 'alex.kim@example.com', 5550123456, 'hash11', true, false),
--Special
('Holger', 'Woerner', 'Holger.Woerner@bakery.com', 491635551584, 'hash12', true, false);

INSERT INTO BusinessListing (owner_id, name, industry, asking_price_range, location, description, employees, years_in_operation, annual_revenue, monthly_revenue, profit_margin, website)
VALUES
(1, 'TechStart Solutions', 'Tech', '$250,000 - $300,000', 'San Francisco, CA', 'Profitable SaaS company with recurring revenue and growing customer base.', 8, 5, '$500,000', '$42,000', '35%', 'www.techstartsolutions.com'),
(2, 'Bella''s Boutique', 'Retail', '$150,000 - $200,000', 'Austin, TX', 'Established women''s clothing boutique in prime downtown location with loyal customer base.', 3, 7, '$250,000', '$21,000', '20%', NULL),
(3, 'Green Clean Services', 'Service', '$80,000 - $120,000', 'Denver, CO', 'Eco-friendly cleaning service with commercial and residential clients.', 12, 4, '$300,000', '$25,000', '28%', NULL),
(4, 'Craft Brewery Co.', 'Food & Beverage', '$400,000 - $500,000', 'Portland, OR', 'Popular local brewery with taproom and distribution network.', 15, 6, '$600,000', '$50,000', '32%', NULL),
(5, 'MediCare Plus', 'Healthcare', '$600,000 - $750,000', 'Miami, FL', 'Well-established medical practice with multiple locations.', 25, 12, '$1,000,000', '$83,000', '40%', NULL),
(12, 'Backerei Woerner', 'Food & Beverage', '$750,000 - $1,000,000', 'Jettingen, Germany', 'Delicious bakery with incredible family legacy.', 15, 250, '$1,000,000', '$111,000', '42%', 'www.baeckerei-holger-woerner.de');

INSERT INTO BuyerProfile (user_id, location, buyer_type, title, industries, about, budget_range, experience, timeline)
VALUES
(6, 'San Francisco, CA', 'Individual Buyer', 'Investor / Entrepreneur', ARRAY['Tech', 'SaaS'], 'Serial entreprenuer with 15+ years of experience building and scaling tech companies.', '$500K-$2M', '15+ years', '3-6 months'),
(7, 'Austin, TX', 'Individual Buyer', 'Retail Buyer', ARRAY['Retail', 'Fashion'], 'Experienced retail operator looking to expand porfolio with established businesses.', '200K-800K', '10 years', 'Flexible'),
(8, 'Denver, CO', 'Individual Buyer', 'Service Business Investor', ARRAY['Service', 'Cleaning'], 'Private investor seeking profitable service-based businesses with recurring revenue.', '300K-$1M', '8 years', 'Active'),
(9, 'Portland, OR', 'Individual Buyer', 'Brewery Enthusiast', ARRAY['Food & Beverage'], 'Craft beer enthusiast looking to aquire established breweries or taprooms.', '$400K-$1.5M', '5 years', '6-12 months'),
(10, 'Miami, FL', 'Individual Buyer', 'Healthcare Investor', ARRAY['Healthcare'], 'Healthcare professional seeking to acquire medical practices and healthcare services.', '$600K-$3M', '12 years', 'Active'),
(11, 'Seattle, WA', 'Strategic Acquirer', 'Tech Acquirer', ARRAY['Tech'], 'Tech executive looking to acquire software companies and tehc-enabled services.', '$750K-$5M', '20 years', 'Active');

INSERT INTO ProfileMatch (buyer_id, business_id, rating)
VALUES
(1, 1, 90),
(2, 2, 83),
(3, 3, 79),
(4, 4, 65),
(5, 5, 75);

