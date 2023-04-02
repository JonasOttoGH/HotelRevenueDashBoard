-- List of tables from hotel data
dbo.hotel_2018
dbo.hotel_2019
dbo.hotel_2020
dbo.market_segment
dbo.meal_cost

-- Using UNION to merge all the table data together
-- Check data
DROP TABLE IF EXISTS hotel_data
SELECT * INTO hotel_data from
( SELECT *
	FROM dbo.hotel_2018
	UNION ALL
	SELECT *
	FROM dbo.hotel_2019
	UNION ALL
	SELECT * 
	FROM dbo.hotel_2020
	) as hoteldata

SELECT *
FROM hotel_data

-- Found that many customers paid nothing for their ‘adr’ (amount daily rate), data to be checked for an explanation
 
SELECT DISTINCT adr, COUNT(adr) as amount_of_adr
FROM hotel_data
GROUP BY adr
ORDER BY adr DESC

SELECT adr
FROM hotel_data
WHERE adr <= 0

-- These customers where not complementary customers that 'market_segment' table states an 100% discount
-- Finding that customers also did not cancel in ‘is cancelled’ column
-- Finding other fields with NULL values, proceed to DELETE

DELETE FROM hotel_data 
WHERE adr <= 0

-- Creating column 'total_stay' for the total time spent at hotel

ALTER TABLE hotel_data
ADD total_stay integer;

UPDATE hotel_data
  SET total_stay = (hd.stays_in_week_nights + hd.stays_in_weekend_nights)
  FROM hotel_data hd

-- Alter 'hotel_data' table to include column for total amount of money a customer spent per stay
-- As percent discount from the 'market_segment' table have already been applied to the average daily rate there is no need to join the tables and calculate

ALTER TABLE hotel_data
ADD total_customer_revenue integer;

Update hotel_data
  SET total_customer_revenue = total_stay * adr

--Creating column 'customer_meal_cost' for the total meal cost per booking

ALTER TABLE hotel_data
ADD customer_meal_cost integer;

UPDATE hotel_data
  SET customer_meal_cost = ((hd.total_stay)*hd.adults)*mc.cost
  FROM hotel_data hd
  JOIN meal_cost mc
  ON hd.meal = mc.meal

-- Creating column 'party_size' for the total party size

ALTER TABLE hotel_data
ADD party_size integer;

UPDATE hotel_data
  SET party_size = (adults + children + babies)
  FROM hotel_data 

-- Creating column 'date' to standarise the date

ALTER TABLE hotel_data
  ADD reservation_date Date;

UPDATE hotel_data
SET reservation_date = Convert (Date, reservation_status_date)

-- Checking to see if any other factors affects the adr (average daily rate)
SELECT *
FROM hotel_data
Where stays_in_weekend_nights = '0' 
	and stays_in_week_nights = '2' 
	and distribution_channel = 'TA/TO' 
	and assigned_room_type = 'A'
	and adults	 = '2'
	and children = '0'

-- Double checking columns that may be unnecessary to keep

SELECT DISTINCT deposit_type
FROM hotel_data;

SELECT DISTINCT is_canceled
FROM hotel_data;

SELECT DISTINCT company
FROM hotel_data;

-- Dropping all non necessary columns so that only useful data for later visualisation is kept

ALTER TABLE hotel_data
DROP COLUMN is_canceled,
		lead_time,
		previous_cancellations,
		previous_bookings_not_canceled,
		booking_changes,
		deposit_type,
		company,
		days_in_waiting_list

-- View final data set and double check columns

SELECT *
FROM hotel_data
