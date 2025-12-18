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
('David', 'Chen', 'david@techstartsolutions.com', '5551234567', NULL, '$2b$10$vpAsWcoFQCXZEHWZHbM8GuANYEdqKpavJ4gBoL0RImvYjkirSzkSO', true, false),
('Isabella', 'Moore', 'isabella@bellaboutique.com', '5552345678', NULL, '$2b$10$PtA9rvv.udnLQcPm8G6xt.qvH7tmOOrLGKPCnqpBLaUrBn7YXeRE.', true, false),
('Miguel', 'Alvarez', 'miguel@greenclean.co', '5553456789', NULL, '$2b$10$CaFz8ohogUeSxzJTH5epSOWt/U4c9Ji/3QuXT3DR36yTkjCt1T.ea', true, false),
('Sam', 'Patel', 'sam@craftbrewco.com', '5554567890', NULL, '$2b$10$3/KdperLAjwmjCSm863d5OSXbscXXUiadpYtXkMJpAzOtaHU.3pt6', true, false),
('Priya', 'Sharma', 'priya@medicarplus.com', '5555678901', NULL, '$2b$10$X9O.VmNE2HFlKHK40or/DeMr88ZJnM3K7O7tmH5F.X1XGxROVZly6', true, false),
--Buyers
('Khaled', 'Nguyen', 'khaled.nguyen@example.com', '5556789012', 'https://i1.sndcdn.com/artworks-nYQ1oTddy6X6wwWs-x7O5qg-t500x500.jpg', '$2b$10$7zA4YEaCQQD0AFsDUdrS7.EBE997T/vqTwbEhIt367NJuR7Sjg7w.', true, false),
('Miriam', 'Reyes', 'miriam.reyes@example.com', '1555768901', 'https://pbs.twimg.com/profile_images/1940066429899886592/MdFIytQ8_400x400.jpg', '$2b$10$uxToYIMLW37czzlvjyHnOetIeK85FL86Lk/AoywlaDKoNhZ1GCYem', true, false),
('Bobby', 'Ortiz', 'bobby.ortiz@example.com', '5557890123', 'https://scottdavidbrown.wordpress.com/wp-content/uploads/2013/01/haa_0004.jpg?w=924', '$2b$10$ja2sbQpo1nPXmUG0liM9S.4rdF2.aQFu9RuZQpP6TJH1UOrlKUr8a', true, false),
('Mickey', 'Turner', 'mickey.turner@example.com', '5558901234', 'https://cdn.miiwiki.org/8/85/Default_Male_Mii.png', '$2b$10$HCYmS4YaL8dVxsuVT5ruLOZnS8hPzPhgCG6tO8NbqyLYrO9bWZ5GC', true, false),
('Sandra', 'Lopez', 'sandra.lopez@example.com', '5559012345', 'https://cdn.miiwiki.org/2/2b/Default_Female_Mii.png', '$2b$10$qF8AFT3zjTZcnoLl7bXUaO01pqsEWLTBNB3tyN.k21J3DI/BfeTly', true, false),
('Alex', 'Kim', 'alex.kim@example.de', '5550123456', 'https://cdn.miiwiki.org/3/3c/WSC_Millie.png', '$2b$10$CIHKYjaIhOX8ArII.GiMReb13Sei/IC2gyL/8pWB7N5EHXi1/emhy', true, false),
--Special
('Holger', 'Woerner', 'Holger.Woerner@bakery.com', '491635551584', NULL, '$2b$10$1JensYMoauwfpGJ/SRan0e7W2lFFaBhsGlKkpvv/1CVYKHWmAyZ8q', true, false),
('Lukas', 'Müller', 'lukas.mueller@example.de', '491635551584', 'https://cdn.miiwiki.org/a/ad/WS_Guest_B.png', '$2b$10$cCGeYtZu3sacPx5wx0Mq1eROsn0vla.AW0sEnOb3uDDonmL5Zzu9.', true, false);

INSERT INTO BusinessListing (owner_id, name, industry, asking_price_lower_bound, asking_price_upper_bound, city, state, country, description, employees, years_in_operation, annual_revenue, monthly_revenue, profit_margin, timeline, website, image_url)
VALUES
(1, 'TechStart Solutions', 'Tech', 250000, 300000, 'San Francisco', 'California', 'USA', 'Profitable SaaS company with recurring revenue and growing customer base.', 8, 5, 500000, 42000, 35, 3, 'www.techstartsolutions.com', 'https://cybercraftinc.com/wp-content/uploads/2019/06/pexels-fauxels-3183150-1-scaled.webp'),
(2, 'Bella''s Boutique', 'Retail', 150000, 200000, 'Austin', 'Texas', 'USA', 'Established women''s clothing boutique in prime downtown location with loyal customer base.', 3, 7, 250000, 21000, 20, 5, NULL, 'https://assets.simpleviewinc.com/simpleview/image/upload/crm/marblefallstx/trendyb_2349D3D3-C7F4-034B-0DDAA4221E96B06C-2349cc950889e0e_234a0708-0d79-3c23-df2be3bd2d89270e.jpg'),
(3, 'Green Clean Services', 'Service', 80000, 120000, 'Denver', 'Colorado', 'USA', 'Eco-friendly cleaning service with commercial and residential clients.', 12, 4, 300000, 25000, 28, 12, NULL, 'https://cdn.prod.website-files.com/60ff934f6ded2d17563ab9dd/61392e6b85cca9544875c7d2_shutterstock_589490129.jpeg'),
(4, 'Craft Brewery Co.', 'Food & Beverage', 400000, 500000, 'Portland', 'Oregon', 'USA', 'Popular local brewery with taproom and distribution network.', 15, 6, 600000, 50000, 32, 9, NULL, 'https://beermaverick.com/wp-content/uploads/2021/02/EmptyTaproomFeb2020.jpg'),
(5, 'MediCare Plus', 'Healthcare', 600000, 750000, 'Miami', 'Florida', 'USA', 'Well-established medical practice with multiple locations.', 25, 12, 1000000, 83000, 40, 7, NULL, 'https://media.istockphoto.com/id/181553727/photo/outpatient-surgery-center.jpg?s=612x612&w=0&k=20&c=TSOFoFo6VWkBLtmvTgcsngxYmn3I677ilQxhoAbzfnE='),
(12, 'Backerei Woerner', 'Food & Beverage', 750000, 1000000, 'Jettingen', NULL, 'Germany', 'Delicious bakery with incredible family legacy.', 15, 250, 1000000, 111000, 42, 8, 'www.baeckerei-holger-woerner.de', 'https://www.baeckerei-holger-woerner.de/s/cc_images/cache_2479764142.png?t=1748448406');

INSERT INTO BuyerProfile (user_id, city, state, country, title, industries, about, budget_range_lower, budget_range_higher, experience, timeline, size_preference, linkedin_url)
VALUES
(6, 'San Francisco', 'California', 'USA', 'Investor / Entrepreneur', ARRAY['Tech', 'SaaS'], 'Serial entreprenuer with 15+ years of experience building and scaling tech companies.', 500000, 2000000, 15.0, 6, 'Large', NULL),
(7, 'Austin', 'Texas', 'USA', 'Retail Buyer', ARRAY['Retail', 'Fashion'], 'Experienced retail operator looking to expand porfolio with established businesses.', 200000, 800000, 10.0, 12, 'Medium', NULL),
(8, 'Denver', 'Colorado', 'USA', 'Service Business Investor', ARRAY['Service', 'Cleaning'], 'Private investor seeking profitable service-based businesses with recurring revenue.', 300000, 1000000, 8.0, 3, 'Medium', NULL),
(9, 'Portland', 'Oregon', 'USA', 'Brewery Enthusiast', ARRAY['Food & Beverage'], 'Craft beer enthusiast looking to aquire established breweries or taprooms.', 400000, 1500000, 5.0, 9, 'Small', NULL),
(10, 'Miami', 'Florida', 'USA', 'Healthcare Investor', ARRAY['Healthcare'], 'Healthcare professional seeking to acquire medical practices and healthcare services.', 600000, 3000000, 12.0, 3, 'Small', NULL),
(11, 'Seattle', 'Washington', 'USA', 'Tech Acquirer', ARRAY['Tech'], 'Tech executive looking to acquire software companies and tehc-enabled services.', 750000, 5000000, 20.0, 3, 'Large', NULL),
(13, 'Jettingen', NULL, 'Germany', 'Bakery Buyer / Apprentice Owner', ARRAY['Food & Beverage','Bakery'], 'Young baker with family background in artisan baking and experience managing small bakery operations.', 700000, 1200000, 6.0, 8, 'Small', NULL);

INSERT INTO ProfileMatch (buyer_id, business_id, rating)
VALUES
(1, 1, 90),
(2, 2, 83),
(3, 3, 79),
(4, 4, 65),
(5, 5, 75),
(7, 6, 75);

