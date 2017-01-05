CREATE TABLE IF NOT EXISTS Passengers (
  id SERIAL,
  name VARCHAR(45) NULL,
  surname VARCHAR(45) NULL,
  email VARCHAR(64) NULL,
  password VARCHAR(64) NULL,
  PRIMARY KEY (id))

  CREATE TABLE IF NOT EXISTS Controllers (
  id SERIAL,
  name VARCHAR(45) NULL,
  surname VARCHAR(45) NULL,
  email VARCHAR(64) NULL,
  password VARCHAR(64) NULL,
  PRIMARY KEY (id))


  CREATE TABLE IF NOT EXISTS Airlines (
  id SERIAL,
  name VARCHAR(45) NULL,
  email VARCHAR(45) NULL,
  password VARCHAR(64) NULL,
  PRIMARY KEY (id))


  CREATE TABLE IF NOT EXISTS Employees (
  id SERIAL,
  name VARCHAR(45) NULL,
  surname VARCHAR(45) NULL,
  email VARCHAR(45) NULL,
  password VARCHAR(64) NULL,
  PRIMARY KEY (id))

  CREATE TABLE IF NOT EXISTS Manufacturers (
  id SERIAL,
  name VARCHAR(45) NULL,
  PRIMARY KEY (id))

CREATE TABLE IF NOT EXISTS Plane_Models (
  id SERIAL,
  name VARCHAR(45) NULL,
  max_passengers INT NULL,
  Manufacturer_id INT NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_Plane_Models_Manufacturers
    FOREIGN KEY (Manufacturer_id)
    REFERENCES Manufacturers (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
 ;

CREATE INDEX fk_Plane_Models_Manufacturers_idx ON Plane_Models (Manufacturer_id ASC);

CREATE TABLE IF NOT EXISTS Plane_Status (
  id SERIAL,
  name VARCHAR(45) NULL,
  PRIMARY KEY (id))


CREATE TABLE IF NOT EXISTS Planes (
  id SERIAL,
  Plane_Model_id INT NOT NULL,
  Plane_Status_id INT NOT NULL,
  Airline_id INT NOT NULL,
  PRIMARY KEY (id)
 ,
  CONSTRAINT fk_Planes_Plane_Models1
    FOREIGN KEY (Plane_Model_id)
    REFERENCES Plane_Models (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_Planes_Plane_Status1
    FOREIGN KEY (Plane_Status_id)
    REFERENCES Plane_Status (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_Planes_Airlines1
    FOREIGN KEY (Airline_id)
    REFERENCES Airlines (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
;

CREATE INDEX fk_Planes_Plane_Models1_idx ON Planes (Plane_Model_id ASC);
CREATE INDEX fk_Planes_Plane_Status1_idx ON Planes (Plane_Status_id ASC);
CREATE INDEX fk_Planes_Airlines1_idx ON Planes (Airline_id ASC);

CREATE TABLE IF NOT EXISTS Plane_Movements (
  id SERIAL,
  posX INT NULL,
  posY INT NULL,
  dirX INT NULL,
  dirY INT NULL,
  Plane_id INT NOT NULL,
  PRIMARY KEY (id)
 ,
  CONSTRAINT fk_Plane_Movements_Planes1
    FOREIGN KEY (Plane_id)
    REFERENCES Planes (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
 ;

CREATE INDEX fk_Plane_Movements_Planes1_idx ON Plane_Movements (Plane_id ASC);




CREATE TABLE IF NOT EXISTS Terminals (
  id SERIAL,
  name VARCHAR(45) NULL,
  PRIMARY KEY (id))



CREATE TABLE IF NOT EXISTS Gates (
  id SERIAL,
  name VARCHAR(45) NULL,
  Terminal_id INT NOT NULL,
  PRIMARY KEY (id)
 ,
  CONSTRAINT fk_Gates_Terminals1
    FOREIGN KEY (Terminal_id)
    REFERENCES Terminals (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
 ;

CREATE INDEX fk_Gates_Terminals1_idx ON Gates (Terminal_id ASC);

CREATE TABLE IF NOT EXISTS Baggages (
  id SERIAL,
  name VARCHAR(45) NULL,
  Terminal_id INT NOT NULL,
  PRIMARY KEY (id)
 ,
  CONSTRAINT fk_Baggages_Terminals1
    FOREIGN KEY (Terminal_id)
    REFERENCES Terminals (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
 ;

CREATE INDEX fk_Baggages_Terminals1_idx ON Baggages (Terminal_id ASC);

CREATE TABLE IF NOT EXISTS Routes (
  id SERIAL,
  detination VARCHAR(45) NULL,
  origin VARCHAR(45) NULL,
  departure VARCHAR(45) NULL,
  arrival VARCHAR(45) NULL,
  Airline_id INT NOT NULL,
  PRIMARY KEY (id)
 ,
  CONSTRAINT fk_Routes_Airlines1
    FOREIGN KEY (Airline_id)
    REFERENCES Airlines (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
 ;

CREATE INDEX fk_Routes_Airlines1_idx ON Routes (Airline_id ASC);

CREATE TABLE IF NOT EXISTS Flights (
  id SERIAL,
  duration INT NULL,
  delay INT NULL,
  date_departure DATE NULL,
  date_arrival DATE NULL,
  Route_id INT NOT NULL,
  Plane_id INT NOT NULL,
  Gate_id INT NOT NULL,
  Baggage_id INT NOT NULL,
  PRIMARY KEY (id)
 ,
  CONSTRAINT fk_Flights_Routes1
    FOREIGN KEY (Route_id)
    REFERENCES Routes (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_Flights_Planes1
    FOREIGN KEY (Plane_id)
    REFERENCES Planes (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_Flights_Gates1
    FOREIGN KEY (Gate_id)
    REFERENCES Gates (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_Flights_Baggages1
    FOREIGN KEY (Baggage_id)
    REFERENCES Baggages (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
 ;

CREATE INDEX fk_Flights_Routes1_idx ON Flights (Route_id ASC);
CREATE INDEX fk_Flights_Planes1_idx ON Flights (Plane_id ASC);
CREATE INDEX fk_Flights_Gates1_idx ON Flights (Gate_id ASC);
CREATE INDEX fk_Flights_Baggages1_idx ON Flights (Baggage_id ASC);


CREATE SEQUENCE gonenpru.Tickets_seq;

CREATE TABLE IF NOT EXISTS gonenpru.Tickets (
  id INT NOT NULL DEFAULT NEXTVAL ('gonenpru.Tickets_seq'),
  code VARCHAR(45) NULL,
  Flight_id INT NOT NULL,
  Passenger_id INT NOT NULL,
  PRIMARY KEY (id)
 ,
  CONSTRAINT fk_Tickets_Flights1
    FOREIGN KEY (Flight_id)
    REFERENCES gonenpru.Flights (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_Tickets_Passengers1
    FOREIGN KEY (Passenger_id)
    REFERENCES gonenpru.Passengers (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
 ;

CREATE INDEX fk_Tickets_Flights1_idx ON gonenpru.Tickets (Flight_id ASC);
CREATE INDEX fk_Tickets_Passengers1_idx ON gonenpru.Tickets (Passenger_id ASC);
