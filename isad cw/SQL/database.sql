CREATE TABLE Customer
(
	CustomerID INT AUTO_INCREMENT UNIQUE NOT NULL,
	CustomerFirstName VARCHAR(20) NOT NULL,
	CustomerLastName VARCHAR(20) NOT NULL,
	CustomerEmail VARCHAR(50) UNIQUE NOT NULL,
	CustomerPassword VARCHAR(255) NOT NULL,
	CustomerAddress1 VARCHAR(100) NOT NULL,
	CustomerAddress2 VARCHAR(100) NOT NULL,
	CustomerPostcode VARCHAR(10) NOT NULL,
	CONSTRAINT pk_Customer PRIMARY KEY (CustomerId)
);

CREATE TABLE Airport
(
	AirportCode VARCHAR(40) UNIQUE NOT NULL,
	AirportName VARCHAR(40) NOT NULL,	
	AirportCountry DATE  NOT NULL,
	AirportLatitude FLOAT NOT NULL,
    AirportLongitude FLOAT NOT NULL,
	CONSTRAINT pk_Airport PRIMARY KEY (AirportCode)
);

INSERT INTO Airport (AirportCode, AirportName, AirportCountry, AirportLatitude, AirportLongitude)
VALUES
('alberto(JFK)', 'John F. Kennedy ', '2020-01-12', '2020-01-12', -73.7781),
('arydoo (LDN)', 'salvaaador garcia', '2020-01-12', '2020-01-12', -0.4543),
('sherrey (CWE)', 'sherrey hills', '2020-01-12', '2020-01-12', 30.9154),
('Fraanck (FRA)', 'Frank gaaston', '2020-01-12','2020-01-12', 8.57056),
('Parar (CDG)', 'parar monalisa', '2020-01-12','2020-01-12', 2.5477),
('Alicant (ALC)', 'Alicant albert', '2020-01-12', '2020-01-12', -0.5572),
('Romeo (FCO)', 'romeo delor', '2020-01-12', '2020-01-12', 12.2462),
('Zur (ZRH)', 'Zura leana', '2020-01-12', '2020-01-12', 8.5492);

CREATE TABLE FlightPlan
(
	FlightPlanID INT AUTO_INCREMENT UNIQUE NOT NULL,
	FlightPlanCode VARCHAR(10) UNIQUE NOT NULL,
	FlightPlanOrigin VARCHAR(20) NOT NULL,
	FlightPlanDestination VARCHAR(20) NOT NULL,
	FlightPlanDistance INT,
	CONSTRAINT pk_FlightPlan PRIMARY KEY (FlightPlanID)
);

-- delete bookings, journeys and flightplans first before changing table
ALTER TABLE FlightPlan
ADD CONSTRAINT fk_FlightPlan_FlightPlanOrigin FOREIGN KEY (FlightPlanOrigin) REFERENCES Airport(AirportCode),
ADD CONSTRAINT fk_FlightPlan_FlightPlanDestination FOREIGN KEY (FlightPlanDestination) REFERENCES Airport(AirportCode);

INSERT INTO FlightPlan(FlightPlanCode,FlightPlanOrigin,FlightPlanDestination)
VALUES('LN123','London (LDN)','11:00'),('ES456','Cairo (CWE)','11:00');

CREATE TABLE Journey
(
	JourneyId INT AUTO_INCREMENT NOT NULL,
	JourneyDate DATE NOT NULL,
	JourneyDepartureTime VARCHAR(20) NOT NULL,
	JourneyArrivalTime VARCHAR(40) NOT NULL,
	JourneyAvailableSeats INT NOT NULL,
	JourneyPrice DECIMAL(6,2) NOT NULL,
	FlightPlanID INT NOT NULL,
	CONSTRAINT fk_Journey_FlightPlanID FOREIGN KEY (FlightPlanID) REFERENCES FlightPlan(FlightPlanID),
	CONSTRAINT pk_Journey PRIMARY KEY (JourneyId)
);

INSERT INTO Journey(JourneyDate,JourneyDepartureTime,JourneyArrivalTime,JourneyAvailableSeats,JourneyPrice,FlightPlanID)
VALUES('2020-01-12','11:00','add notes',100,200.00,1),('2020-01-14','10:00','add notes',50,300.00,2),
('2020-05-10','8:00','add notes',100,150.00,1),('2020-07-04','14:00','add notes',50,400.00,2);

CREATE TABLE Booking
(
	BookingID INT AUTO_INCREMENT NOT NULL,
	BookingStatus VARCHAR(10) NOT NULL DEFAULT 'booked' CHECK (BookingStatus IN('booked','cancelled','confirmed')),
	JourneyID INT NOT NULL,
	CustomerID INT NOT NULL,
	CONSTRAINT fk_Booking_JourneyID FOREIGN KEY (JourneyID) REFERENCES Journey(JourneyID),
	CONSTRAINT fk_Booking_CustomerID FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
	CONSTRAINT pk_Booking PRIMARY KEY (BookingID)
);

CREATE TABLE AuditLog
(
	AuditLogID INT AUTO_INCREMENT NOT NULL,
	AuditLogTimeStamp DATETIME default current_timestamp NOT NULL,
	AuditLogRecord VARCHAR(255) NOT NULL,
	CONSTRAINT pk_AuditLog PRIMARY KEY (AuditLogID)
);

CREATE TABLE HCIFeedback
(
	HCIFeedbackID INT AUTO_INCREMENT UNIQUE NOT NULL,
	HCIFeedbackTimeStamp DATETIME default current_timestamp NOT NULL,
	HCIFeedbackName VARCHAR(50),
	HCIFeedbackRecord VARCHAR(10000) NOT NULL,
	CONSTRAINT pk_HCIFeedback PRIMARY KEY (HCIFeedbackID)
)

-- view all available flights
CREATE VIEW vw_availableFlights AS
SELECT FlightPlanOrigin,FlightPlanDestination,JourneyDate,JourneyDepartureTime,JourneyArrivalTime,JourneyAvailableSeats,FlightPlanCode,JourneyID,JourneyPrice,DATE_FORMAT(JourneyDate, '%d/%m/%Y') AS JourneyDateFormatted
FROM FlightPlan,Journey
WHERE FlightPlan.FlightPlanID = Journey.FlightPlanID
AND JourneyAvailableSeats > 0
AND JourneyDate >= CURRENT_DATE()

-- view origin airports
CREATE VIEW vw_originAirports AS
SELECT FlightPlanOrigin
FROM FlightPlan

-- view destination airports
CREATE VIEW vw_destinationAirports AS
SELECT FlightPlanDestination
FROM FlightPlan

-- view flightplan codes
CREATE VIEW vw_flightPlanCodes AS
SELECT FlightPlanCode
FROM FlightPlan

-- view all flight plans
CREATE VIEW vw_flightPlans AS
SELECT FlightPlanOrigin,FlightPlanDestination,FlightPlanCode,FlightPlanDistance
FROM FlightPlan

-- view audit log records
CREATE VIEW vw_auditLogRecords AS
SELECT AuditLogID,AuditLogTimeStamp,AuditLogRecord
FROM AuditLog

-- view airports
CREATE VIEW vw_airports AS
SELECT AirportCode, AirportName, AirportLatitude, AirportLongitude,DATE_FORMAT(AirportCountry, '%d/%m/%Y') AS AirportCountryFormatted
FROM Airport

-- view airport codes
CREATE VIEW vw_airportCodes AS
SELECT AirportCode
FROM Airport

-- book a journey, returns bookingID, if no seats left returns bookingID = 0
DELIMITER //

CREATE PROCEDURE pr_bookFlight(p_customerID INT, p_journeyID INT, OUT p_bookingID INT)
BEGIN
	DECLARE v_journeyAvailableSeats INT;
	SELECT JourneyAvailableSeats INTO v_journeyAvailableSeats FROM Journey WHERE JourneyID = p_journeyID;
	IF v_journeyAvailableSeats > 0
	THEN
		INSERT INTO Booking(CustomerID,JourneyID)
		VALUES(p_customerID, p_journeyID);
		SET p_bookingID = @@IDENTITY;
	ELSE
		SET p_bookingID = 0;
	END IF;
END;

//

DELIMITER ;

-- pay for and confirm a flight
DELIMITER //

CREATE PROCEDURE pr_confirmFlight(p_bookingID INT)
BEGIN
	UPDATE Booking
	SET BookingStatus = 'confirmed'
	WHERE BookingID = p_bookingID;
END;

//

DELIMITER ;

-- procedure takes customerID and returns all confirmed bookings
DELIMITER //

CREATE PROCEDURE pr_confirmedBookings(p_customerID INT)
BEGIN
	SELECT FlightPlanCode, FlightPlanOrigin, FlightPlanDestination, JourneyDepartureTime, JourneyArrivalTime, JourneyDate, BookingID,DATE_FORMAT(JourneyDate, '%d/%m/%Y') AS JourneyDateFormatted
	FROM FlightPlan, Journey, Booking
	WHERE FlightPlan.FlightPlanID = Journey.FlightPlanID
	AND Journey.JourneyID = Booking.JourneyID
	AND Booking.CustomerID = p_customerID
	AND JourneyDate >= CURRENT_DATE()
	AND Booking.BookingStatus = 'confirmed';
END;

//

DELIMITER ;

-- procedure takes email and returns hashed password and customerId, if no matching email returns customerId = 0
DELIMITER //

CREATE PROCEDURE pr_customerLogin (p_email VARCHAR(50),OUT p_hashedPassword VARCHAR(100),OUT p_customerId INT,OUT p_customerFirstName VARCHAR(20),OUT p_customerLastName VARCHAR(20))
BEGIN
	SELECT customerId INTO p_customerId FROM Customer WHERE customerEmail = p_email;
	SELECT CustomerPassword INTO p_hashedPassword FROM Customer WHERE customerEmail = p_email;
	SELECT CustomerFirstName INTO p_customerFirstName FROM Customer WHERE customerEmail = p_email;
	SELECT CustomerLastName INTO p_customerLastName FROM Customer WHERE customerEmail = p_email;
	IF NOT EXISTS (SELECT customerId FROM Customer WHERE customerEmail = p_email)
	THEN
		SET p_customerId = 0;
	END IF;
END;

//

DELIMITER ;

-- procedure takes email, firstName, lastName, hashedPassword; return results = 'registered' or 'already registered'
DELIMITER //

CREATE PROCEDURE pr_registerCustomer(p_email VARCHAR(50),p_firstName VARCHAR(20),p_lastName VARCHAR(20),p_hashedPassword VARCHAR(100),p_address1 VARCHAR(100),p_address2 VARCHAR(100),p_postcode VARCHAR(10),OUT p_results VARCHAR(20))
BEGIN
	IF EXISTS (SELECT CustomerEmail FROM Customer WHERE CustomerEmail = p_email)
	THEN
		SET p_results = 'already registered';
	ELSE
		INSERT INTO Customer(CustomerEmail,CustomerFirstName,CustomerLastName,CustomerPassword,CustomerAddress1,CustomerAddress2,CustomerPostcode)
		VALUES(p_email,p_firstName,p_lastName,p_hashedPassword,p_address1,p_address2,p_postcode);
		SET p_results = 'registered';
	END IF;
END;

//

DELIMITER ;

-- procedure takes origin, destination, date returns flights
DELIMITER //

CREATE PROCEDURE pr_searchFlights(p_origin VARCHAR(20),p_destination VARCHAR(20),p_date DATE)
BEGIN
	IF p_date < CURRENT_DATE()
	THEN
		SET p_date = CURRENT_DATE();
	END IF;
	SELECT FlightPlanCode, FlightPlanOrigin, FlightPlanDestination, JourneyDate, JourneyID,DATE_FORMAT(JourneyDate, '%d/%m/%Y') AS JourneyDateFormatted
	FROM FlightPlan, Journey
	WHERE FlightPlan.FlightPlanID = Journey.FlightPlanID
	AND FlightPlanOrigin = p_origin
	AND FlightPlanDestination = p_destination
	AND JourneyAvailableSeats > 0
	AND JourneyDate = p_date;
END;

//

DELIMITER ;

-- procedure takes booking and sets it's status to cancelled
DELIMITER //

Create PROCEDURE pr_cancelBooking (p_bookingID INT)
BEGIN
	UPDATE Booking
	SET BookingStatus = 'cancelled'
	WHERE BookingID = p_bookingID;
END;

//

DELIMITER ;

-- procedure takes customerID and returns all bookings
DELIMITER //

CREATE PROCEDURE pr_bookings(p_customerID INT)
BEGIN
	SELECT FlightPlanCode, FlightPlanOrigin, FlightPlanDestination, JourneyDepartureTime, JourneyArrivalTime, JourneyDate, BookingID, DATE_FORMAT(JourneyDate, '%d/%m/%Y') AS JourneyDateFormatted
	FROM FlightPlan, Journey, Booking
	WHERE FlightPlan.FlightPlanID = Journey.FlightPlanID
	AND Journey.JourneyID = Booking.JourneyID
	AND Booking.CustomerID = p_customerID
	AND JourneyDate >= CURRENT_DATE()
	AND Booking.BookingStatus = 'booked';
END;

//

DELIMITER ;

-- procedure for adding a flight
DELIMITER //

CREATE PROCEDURE pr_addFlightPlan(p_flightPlanCode VARCHAR(10), p_flightPlanOrigin VARCHAR(20), p_flightPlanDestination VARCHAR(20))
BEGIN
	INSERT INTO FlightPlan(FlightPlanCode,FlightPlanOrigin,FlightPlanDestination)
	VALUES (p_flightPlanCode,p_flightPlanOrigin,p_flightPlanDestination);
END;

//

DELIMITER ;

-- procedure for adding a journey
DELIMITER //

CREATE PROCEDURE pr_addJourney(p_code VARCHAR(10),p_date DATE,p_departureTime VARCHAR(20),p_arrivalTime VARCHAR(40),p_availableSeats INT,p_price DECIMAL(6,2))
BEGIN
	DECLARE v_flightPlanID INT;
	SELECT FlightPlanID INTO v_flightPlanID FROM FlightPlan WHERE FlightPlanCode = p_code;
	INSERT INTO Journey(JourneyDate,JourneyDepartureTime,JourneyArrivalTime,JourneyAvailableSeats,JourneyPrice,FlightPlanID)
	VALUES(p_date,p_departureTime,p_arrivalTime,p_availableSeats,p_price,v_flightPlanID);
END;

//

DELIMITER ;

-- add an entry to the audit log
DELIMITER //

CREATE PROCEDURE pr_addAuditLogRecord(p_record VARCHAR(255))
BEGIN
	INSERT INTO AuditLog(AuditLogRecord)
	VALUES (p_record);
END;

//

DELIMITER ;

-- procedure for deleting a customer
DELIMITER //

CREATE PROCEDURE pr_deleteCustomer(p_customerID INT)
BEGIN
	UPDATE Customer
	SET CustomerFirstName = 'deleted', CustomerLastName = 'deleted', CustomerPassword = 'deleted', CustomerAddress1 = 'deleted', CustomerAddress2 = 'deleted', CustomerPostcode = 'deleted'
	WHERE CustomerID = p_customerID;
END;

//

DELIMITER ;

-- add an airport
DELIMITER //

CREATE PROCEDURE pr_addAirport(p_code VARCHAR(40),p_name VARCHAR(40), p_country DATE,p_lat FLOAT ,p_long FLOAT)
BEGIN
	INSERT INTO Airport(AirportCode,AirportName,AirportCountry,AirportLatitude,AirportLongitude)
	VALUES(p_code,p_name,p_country,p_lat,p_long);
END;

//

DELIMITER ;

-- add feedback
DELIMITER //

CREATE PROCEDURE pr_addFeedback(p_name VARCHAR(50), p_record VARCHAR(10000))
BEGIN
	INSERT INTO HCIFeedback (HCIFeedbackName,HCIFeedbackRecord)
	VALUES(p_name,p_record);
END;

//

DELIMITER ;

-- add flight plan distance
DELIMITER //

CREATE PROCEDURE pr_addFlightPlanPlusDistance (p_flightPlanCode VARCHAR(10), p_flightPlanOrigin VARCHAR(20), p_flightPlanDestination VARCHAR(20), p_flightPlanDistance INT)
BEGIN
	INSERT INTO FlightPlan(FlightPlanCode,FlightPlanOrigin,FlightPlanDestination,FlightPlanDistance)
	VALUES(p_flightPlanCode,p_flightPlanOrigin,p_flightPlanDestination, p_flightPlanDistance);
END;

//

DELIMITER ;

-- get latitude and longitude from an airport code
DELIMITER //

CREATE PROCEDURE pr_getLatLong (p_AirportCode VARCHAR(20))
BEGIN
	SELECT AirportLatitude, AirportLongitude FROM vw_airports WHERE AirportCode = p_AirportCode;
END;

//

DELIMITER ;