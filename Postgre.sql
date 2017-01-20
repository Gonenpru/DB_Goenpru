--
-- NOTE:
--
-- File paths need to be edited. Search for $$PATH$$ and
-- replace it with the path to the directory containing
-- the extracted data files.
--
--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'SQL_ASCII';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

DROP DATABASE gonenpru;
--
-- Name: gonenpru; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE gonenpru WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';


ALTER DATABASE gonenpru OWNER TO postgres;

\connect gonenpru

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'SQL_ASCII';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: airlinename(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION airlinename(plane_id integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
Declare 
	airId integer;
	airline_name text;
BEGIN

	
    airId = (SELECT airline_id from planes where id = plane_id);
    airline_name = (SELECT name from airlines where id = airId);
   
   	return airline_name;
    END;
    $$;


ALTER FUNCTION public.airlinename(plane_id integer) OWNER TO postgres;

--
-- Name: createairline(character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION createairline(name character varying, email character varying, pass character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
    id INTEGER;
BEGIN
    SELECT MAX(id) INTO id FROM airlines;
    id = id + 1;
    IF (NOT email ~ E'^[(a-z._)(\\d)]+\@[(a-z)(\\d)]+\\.[a-z]{2,}') THEN
        RAISE EXCEPTION 'ERROR: non-correct email format';
    END IF;
    INSERT INTO airlines 
    VALUES (id, name, email, pass);
    EXCEPTION WHEN unique_violation THEN
	RAISE EXCEPTION 'ERROR: existing ID';
    RETURN TRUE;
END $$;


ALTER FUNCTION public.createairline(name character varying, email character varying, pass character varying) OWNER TO postgres;

--
-- Name: gatename(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION gatename(gate_id integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
Declare 
	gate_name text;
BEGIN

    gate_name = (SELECT name from gates where id = gate_id);
   
   	  if (gate_name is null) then 
			raise exception 'The gate_id does not exist';
       	end if;

   	return gate_name;
    END;
    $$;


ALTER FUNCTION public.gatename(gate_id integer) OWNER TO postgres;

--
-- Name: getterminal(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION getterminal(plane integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
Declare 
	termid INTEGER;
BEGIN

	SELECT t.id into termid from Terminals t join Gates g on t.id = g.terminal_id join Flights f on f.gate_id = g.id
	where f.plane_id = plane;
      	
        if (termid is null) then 
			raise exception 'The flight that you are trying to get terminal does not exist';
       	end if;

   	return termid;
    END;
    $$;


ALTER FUNCTION public.getterminal(plane integer) OWNER TO postgres;

--
-- Name: notify_planemovements_change(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION notify_planemovements_change() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        PERFORM pg_notify('planemovements_notify',TG_TABLE_NAME || '>' ||row_to_json(NEW)); 
        RETURN NEW;
    END;
$$;


ALTER FUNCTION public.notify_planemovements_change() OWNER TO postgres;

--
-- Name: planeflights(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION planeflights(p_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
Declare 
BEGIN

   	return (SELECT count(*) from flights where plane_id = p_id);
    END;
    $$;


ALTER FUNCTION public.planeflights(p_id integer) OWNER TO postgres;

--
-- Name: planehours(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION planehours(p_id integer) RETURNS record
    LANGUAGE plpgsql
    AS $$
Declare 
BEGIN

   	return (SELECT duration from flights where plane_id = p_id);
    END;
    $$;


ALTER FUNCTION public.planehours(p_id integer) OWNER TO postgres;

--
-- Name: planename(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION planename(plane_id integer) RETURNS text
    LANGUAGE plpgsql
    AS $$

Declare 
	modId integer;
	plane_name text;
BEGIN

	
    modId = (SELECT plane_model_id from planes where id = plane_id);
    plane_name = (SELECT name from planemodels where id = modId);
    
       	if (plane_name is null) then 
		raise exception 'Error. Not Existing plane';
       end if;
   
   	return plane_name;
    END;
    $$;


ALTER FUNCTION public.planename(plane_id integer) OWNER TO postgres;

--
-- Name: routename(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION routename(route_id integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
Declare 
	ori text;
    arr text;
BEGIN

    ori = (SELECT origin from routes where id = route_id);
    arr = (SELECT arrival from routes where id = route_id);
   
   	return CONCAT(ori,'-' ,arr);
    END;
    $$;


ALTER FUNCTION public.routename(route_id integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: airlines; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE airlines (
    id integer NOT NULL,
    name character varying(45),
    email character varying(45),
    password character varying(64)
);


ALTER TABLE airlines OWNER TO postgres;

--
-- Name: airlines_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE airlines_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE airlines_id_seq OWNER TO postgres;

--
-- Name: airlines_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE airlines_id_seq OWNED BY airlines.id;


--
-- Name: baggages; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE baggages (
    id integer NOT NULL,
    name character varying(45),
    terminal_id integer NOT NULL
);


ALTER TABLE baggages OWNER TO postgres;

--
-- Name: baggages_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE baggages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE baggages_id_seq OWNER TO postgres;

--
-- Name: baggages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE baggages_id_seq OWNED BY baggages.id;


--
-- Name: controllers; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE controllers (
    id integer NOT NULL,
    name character varying(45),
    surname character varying(45),
    email character varying(64),
    password character varying(64)
);


ALTER TABLE controllers OWNER TO postgres;

--
-- Name: controllers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE controllers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE controllers_id_seq OWNER TO postgres;

--
-- Name: controllers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE controllers_id_seq OWNED BY controllers.id;


--
-- Name: employees; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE employees (
    id integer NOT NULL,
    name character varying(45),
    surname character varying(45),
    email character varying(45),
    password character varying(64)
);


ALTER TABLE employees OWNER TO postgres;

--
-- Name: employees_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE employees_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE employees_id_seq OWNER TO postgres;

--
-- Name: employees_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE employees_id_seq OWNED BY employees.id;


--
-- Name: flights; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE flights (
    id integer NOT NULL,
    date_departure timestamp without time zone,
    route_id integer NOT NULL,
    plane_id integer NOT NULL,
    gate_id integer NOT NULL,
    baggage_id integer NOT NULL,
    duration character varying(64),
    delay character varying(64)
);


ALTER TABLE flights OWNER TO postgres;

--
-- Name: flights_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE flights_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE flights_id_seq OWNER TO postgres;

--
-- Name: flights_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE flights_id_seq OWNED BY flights.id;


--
-- Name: gates; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE gates (
    id integer NOT NULL,
    name character varying(45),
    terminal_id integer NOT NULL
);


ALTER TABLE gates OWNER TO postgres;

--
-- Name: gates_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE gates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gates_id_seq OWNER TO postgres;

--
-- Name: gates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE gates_id_seq OWNED BY gates.id;


--
-- Name: lane_status; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE lane_status (
    id integer,
    name character varying,
    status integer
);


ALTER TABLE lane_status OWNER TO postgres;

--
-- Name: manufacturers; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE manufacturers (
    id integer NOT NULL,
    name character varying(45)
);


ALTER TABLE manufacturers OWNER TO postgres;

--
-- Name: manufacturers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE manufacturers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE manufacturers_id_seq OWNER TO postgres;

--
-- Name: manufacturers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE manufacturers_id_seq OWNED BY manufacturers.id;


--
-- Name: passengers; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE passengers (
    id integer NOT NULL,
    name character varying(45),
    surname character varying(45),
    email character varying(64),
    password character varying(64)
);


ALTER TABLE passengers OWNER TO postgres;

--
-- Name: passengers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE passengers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE passengers_id_seq OWNER TO postgres;

--
-- Name: passengers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE passengers_id_seq OWNED BY passengers.id;


--
-- Name: planemodels; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE planemodels (
    id integer NOT NULL,
    name character varying(45),
    max_passengers integer,
    manufacturer_id integer NOT NULL
);


ALTER TABLE planemodels OWNER TO postgres;

--
-- Name: plane_models_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE plane_models_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE plane_models_id_seq OWNER TO postgres;

--
-- Name: plane_models_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE plane_models_id_seq OWNED BY planemodels.id;


--
-- Name: planemovements; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE planemovements (
    id integer NOT NULL,
    posx double precision,
    posy double precision,
    plane_id integer NOT NULL,
    "out" integer
);


ALTER TABLE planemovements OWNER TO postgres;

--
-- Name: plane_movements_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE plane_movements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE plane_movements_id_seq OWNER TO postgres;

--
-- Name: plane_movements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE plane_movements_id_seq OWNED BY planemovements.id;


--
-- Name: plane_status; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE plane_status (
    id integer NOT NULL,
    name character varying(45)
);


ALTER TABLE plane_status OWNER TO postgres;

--
-- Name: plane_status_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE plane_status_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE plane_status_id_seq OWNER TO postgres;

--
-- Name: plane_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE plane_status_id_seq OWNED BY plane_status.id;


--
-- Name: planes; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE planes (
    id integer NOT NULL,
    plane_model_id integer NOT NULL,
    plane_status_id integer NOT NULL,
    airline_id integer NOT NULL
);


ALTER TABLE planes OWNER TO postgres;

--
-- Name: planes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE planes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE planes_id_seq OWNER TO postgres;

--
-- Name: planes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE planes_id_seq OWNED BY planes.id;


--
-- Name: routes; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE routes (
    id integer NOT NULL,
    origin character varying(45),
    arrival character varying(45),
    airline_id integer NOT NULL
);


ALTER TABLE routes OWNER TO postgres;

--
-- Name: routes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE routes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE routes_id_seq OWNER TO postgres;

--
-- Name: routes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE routes_id_seq OWNED BY routes.id;


--
-- Name: terminals; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE terminals (
    id integer NOT NULL,
    name character varying(45)
);


ALTER TABLE terminals OWNER TO postgres;

--
-- Name: terminals_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE terminals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE terminals_id_seq OWNER TO postgres;

--
-- Name: terminals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE terminals_id_seq OWNED BY terminals.id;


--
-- Name: tickets; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE tickets (
    id integer NOT NULL,
    code character varying(45),
    flight_id integer NOT NULL,
    passenger_id integer NOT NULL
);


ALTER TABLE tickets OWNER TO postgres;

--
-- Name: tickets_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE tickets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE tickets_id_seq OWNER TO postgres;

--
-- Name: tickets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE tickets_id_seq OWNED BY tickets.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY airlines ALTER COLUMN id SET DEFAULT nextval('airlines_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY baggages ALTER COLUMN id SET DEFAULT nextval('baggages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY controllers ALTER COLUMN id SET DEFAULT nextval('controllers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY employees ALTER COLUMN id SET DEFAULT nextval('employees_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY flights ALTER COLUMN id SET DEFAULT nextval('flights_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY gates ALTER COLUMN id SET DEFAULT nextval('gates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY manufacturers ALTER COLUMN id SET DEFAULT nextval('manufacturers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY passengers ALTER COLUMN id SET DEFAULT nextval('passengers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY plane_status ALTER COLUMN id SET DEFAULT nextval('plane_status_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY planemodels ALTER COLUMN id SET DEFAULT nextval('plane_models_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY planemovements ALTER COLUMN id SET DEFAULT nextval('plane_movements_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY planes ALTER COLUMN id SET DEFAULT nextval('planes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY routes ALTER COLUMN id SET DEFAULT nextval('routes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY terminals ALTER COLUMN id SET DEFAULT nextval('terminals_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tickets ALTER COLUMN id SET DEFAULT nextval('tickets_id_seq'::regclass);


--
-- Data for Name: airlines; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY airlines (id, name, email, password) FROM stdin;
\.
COPY airlines (id, name, email, password) FROM '$$PATH$$/2788.dat';

--
-- Name: airlines_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('airlines_id_seq', 1, false);


--
-- Data for Name: baggages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY baggages (id, name, terminal_id) FROM stdin;
\.
COPY baggages (id, name, terminal_id) FROM '$$PATH$$/2806.dat';

--
-- Name: baggages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('baggages_id_seq', 1, false);


--
-- Data for Name: controllers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY controllers (id, name, surname, email, password) FROM stdin;
\.
COPY controllers (id, name, surname, email, password) FROM '$$PATH$$/2786.dat';

--
-- Name: controllers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('controllers_id_seq', 1, false);


--
-- Data for Name: employees; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY employees (id, name, surname, email, password) FROM stdin;
\.
COPY employees (id, name, surname, email, password) FROM '$$PATH$$/2790.dat';

--
-- Name: employees_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('employees_id_seq', 1, false);


--
-- Data for Name: flights; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY flights (id, date_departure, route_id, plane_id, gate_id, baggage_id, duration, delay) FROM stdin;
\.
COPY flights (id, date_departure, route_id, plane_id, gate_id, baggage_id, duration, delay) FROM '$$PATH$$/2810.dat';

--
-- Name: flights_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('flights_id_seq', 6, true);


--
-- Data for Name: gates; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY gates (id, name, terminal_id) FROM stdin;
\.
COPY gates (id, name, terminal_id) FROM '$$PATH$$/2804.dat';

--
-- Name: gates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('gates_id_seq', 1, false);


--
-- Data for Name: lane_status; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY lane_status (id, name, status) FROM stdin;
\.
COPY lane_status (id, name, status) FROM '$$PATH$$/2813.dat';

--
-- Data for Name: manufacturers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY manufacturers (id, name) FROM stdin;
\.
COPY manufacturers (id, name) FROM '$$PATH$$/2792.dat';

--
-- Name: manufacturers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('manufacturers_id_seq', 1, false);


--
-- Data for Name: passengers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY passengers (id, name, surname, email, password) FROM stdin;
\.
COPY passengers (id, name, surname, email, password) FROM '$$PATH$$/2784.dat';

--
-- Name: passengers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('passengers_id_seq', 1, false);


--
-- Name: plane_models_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('plane_models_id_seq', 1, false);


--
-- Name: plane_movements_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('plane_movements_id_seq', 1, false);


--
-- Data for Name: plane_status; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY plane_status (id, name) FROM stdin;
\.
COPY plane_status (id, name) FROM '$$PATH$$/2796.dat';

--
-- Name: plane_status_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('plane_status_id_seq', 1, false);


--
-- Data for Name: planemodels; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY planemodels (id, name, max_passengers, manufacturer_id) FROM stdin;
\.
COPY planemodels (id, name, max_passengers, manufacturer_id) FROM '$$PATH$$/2794.dat';

--
-- Data for Name: planemovements; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY planemovements (id, posx, posy, plane_id, "out") FROM stdin;
\.
COPY planemovements (id, posx, posy, plane_id, "out") FROM '$$PATH$$/2800.dat';

--
-- Data for Name: planes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY planes (id, plane_model_id, plane_status_id, airline_id) FROM stdin;
\.
COPY planes (id, plane_model_id, plane_status_id, airline_id) FROM '$$PATH$$/2798.dat';

--
-- Name: planes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('planes_id_seq', 1, false);


--
-- Data for Name: routes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY routes (id, origin, arrival, airline_id) FROM stdin;
\.
COPY routes (id, origin, arrival, airline_id) FROM '$$PATH$$/2808.dat';

--
-- Name: routes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('routes_id_seq', 1, false);


--
-- Data for Name: terminals; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY terminals (id, name) FROM stdin;
\.
COPY terminals (id, name) FROM '$$PATH$$/2802.dat';

--
-- Name: terminals_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('terminals_id_seq', 1, false);


--
-- Data for Name: tickets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY tickets (id, code, flight_id, passenger_id) FROM stdin;
\.
COPY tickets (id, code, flight_id, passenger_id) FROM '$$PATH$$/2812.dat';

--
-- Name: tickets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('tickets_id_seq', 1, false);


--
-- Name: airlines_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY airlines
    ADD CONSTRAINT airlines_pkey PRIMARY KEY (id);


--
-- Name: baggages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY baggages
    ADD CONSTRAINT baggages_pkey PRIMARY KEY (id);


--
-- Name: controllers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY controllers
    ADD CONSTRAINT controllers_pkey PRIMARY KEY (id);


--
-- Name: employees_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (id);


--
-- Name: flights_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY flights
    ADD CONSTRAINT flights_pkey PRIMARY KEY (id);


--
-- Name: gates_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY gates
    ADD CONSTRAINT gates_pkey PRIMARY KEY (id);


--
-- Name: manufacturers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY manufacturers
    ADD CONSTRAINT manufacturers_pkey PRIMARY KEY (id);


--
-- Name: passengers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY passengers
    ADD CONSTRAINT passengers_pkey PRIMARY KEY (id);


--
-- Name: plane_models_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY planemodels
    ADD CONSTRAINT plane_models_pkey PRIMARY KEY (id);


--
-- Name: plane_movements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY planemovements
    ADD CONSTRAINT plane_movements_pkey PRIMARY KEY (id);


--
-- Name: plane_status_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY plane_status
    ADD CONSTRAINT plane_status_pkey PRIMARY KEY (id);


--
-- Name: planes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY planes
    ADD CONSTRAINT planes_pkey PRIMARY KEY (id);


--
-- Name: routes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY routes
    ADD CONSTRAINT routes_pkey PRIMARY KEY (id);


--
-- Name: terminals_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY terminals
    ADD CONSTRAINT terminals_pkey PRIMARY KEY (id);


--
-- Name: tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tickets
    ADD CONSTRAINT tickets_pkey PRIMARY KEY (id);


--
-- Name: fk_baggages_terminals1_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX fk_baggages_terminals1_idx ON baggages USING btree (terminal_id);


--
-- Name: fk_flights_baggages1_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX fk_flights_baggages1_idx ON flights USING btree (baggage_id);


--
-- Name: fk_flights_gates1_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX fk_flights_gates1_idx ON flights USING btree (gate_id);


--
-- Name: fk_flights_planes1_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX fk_flights_planes1_idx ON flights USING btree (plane_id);


--
-- Name: fk_flights_routes1_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX fk_flights_routes1_idx ON flights USING btree (route_id);


--
-- Name: fk_gates_terminals1_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX fk_gates_terminals1_idx ON gates USING btree (terminal_id);


--
-- Name: fk_plane_models_manufacturers_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX fk_plane_models_manufacturers_idx ON planemodels USING btree (manufacturer_id);


--
-- Name: fk_plane_movements_planes1_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX fk_plane_movements_planes1_idx ON planemovements USING btree (plane_id);


--
-- Name: fk_planes_airlines1_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX fk_planes_airlines1_idx ON planes USING btree (airline_id);


--
-- Name: fk_planes_plane_models1_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX fk_planes_plane_models1_idx ON planes USING btree (plane_model_id);


--
-- Name: fk_planes_plane_status1_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX fk_planes_plane_status1_idx ON planes USING btree (plane_status_id);


--
-- Name: fk_routes_airlines1_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX fk_routes_airlines1_idx ON routes USING btree (airline_id);


--
-- Name: fk_tickets_flights1_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX fk_tickets_flights1_idx ON tickets USING btree (flight_id);


--
-- Name: fk_tickets_passengers1_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX fk_tickets_passengers1_idx ON tickets USING btree (passenger_id);


--
-- Name: planemovements_change; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER planemovements_change AFTER INSERT OR UPDATE ON planemovements FOR EACH ROW EXECUTE PROCEDURE notify_planemovements_change();


--
-- Name: fk_baggages_terminals1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY baggages
    ADD CONSTRAINT fk_baggages_terminals1 FOREIGN KEY (terminal_id) REFERENCES terminals(id);


--
-- Name: fk_flights_baggages1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY flights
    ADD CONSTRAINT fk_flights_baggages1 FOREIGN KEY (baggage_id) REFERENCES baggages(id);


--
-- Name: fk_flights_gates1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY flights
    ADD CONSTRAINT fk_flights_gates1 FOREIGN KEY (gate_id) REFERENCES gates(id);


--
-- Name: fk_flights_planes1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY flights
    ADD CONSTRAINT fk_flights_planes1 FOREIGN KEY (plane_id) REFERENCES planes(id);


--
-- Name: fk_flights_routes1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY flights
    ADD CONSTRAINT fk_flights_routes1 FOREIGN KEY (route_id) REFERENCES routes(id);


--
-- Name: fk_gates_terminals1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY gates
    ADD CONSTRAINT fk_gates_terminals1 FOREIGN KEY (terminal_id) REFERENCES terminals(id);


--
-- Name: fk_plane_models_manufacturers; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY planemodels
    ADD CONSTRAINT fk_plane_models_manufacturers FOREIGN KEY (manufacturer_id) REFERENCES manufacturers(id);


--
-- Name: fk_plane_movements_planes1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY planemovements
    ADD CONSTRAINT fk_plane_movements_planes1 FOREIGN KEY (plane_id) REFERENCES planes(id);


--
-- Name: fk_planes_airlines1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY planes
    ADD CONSTRAINT fk_planes_airlines1 FOREIGN KEY (airline_id) REFERENCES airlines(id);


--
-- Name: fk_planes_plane_models1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY planes
    ADD CONSTRAINT fk_planes_plane_models1 FOREIGN KEY (plane_model_id) REFERENCES planemodels(id);


--
-- Name: fk_planes_plane_status1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY planes
    ADD CONSTRAINT fk_planes_plane_status1 FOREIGN KEY (plane_status_id) REFERENCES plane_status(id);


--
-- Name: fk_routes_airlines1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY routes
    ADD CONSTRAINT fk_routes_airlines1 FOREIGN KEY (airline_id) REFERENCES airlines(id);


--
-- Name: fk_tickets_flights1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tickets
    ADD CONSTRAINT fk_tickets_flights1 FOREIGN KEY (flight_id) REFERENCES flights(id);


--
-- Name: fk_tickets_passengers1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tickets
    ADD CONSTRAINT fk_tickets_passengers1 FOREIGN KEY (passenger_id) REFERENCES passengers(id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- Name: airlines; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE airlines FROM PUBLIC;
REVOKE ALL ON TABLE airlines FROM postgres;
GRANT ALL ON TABLE airlines TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE airlines TO controller;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE airlines TO airline;


--
-- Name: controllers; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE controllers FROM PUBLIC;
REVOKE ALL ON TABLE controllers FROM postgres;
GRANT ALL ON TABLE controllers TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE controllers TO controller;


--
-- Name: flights; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE flights FROM PUBLIC;
REVOKE ALL ON TABLE flights FROM postgres;
GRANT ALL ON TABLE flights TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE flights TO airline;
GRANT SELECT ON TABLE flights TO passenger;


--
-- Name: planemovements; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE planemovements FROM PUBLIC;
REVOKE ALL ON TABLE planemovements FROM postgres;
GRANT ALL ON TABLE planemovements TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE planemovements TO controller;


--
-- Name: planes; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE planes FROM PUBLIC;
REVOKE ALL ON TABLE planes FROM postgres;
GRANT ALL ON TABLE planes TO postgres;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE planes TO airline;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE planes TO controller;


--
-- PostgreSQL database dump complete
--
