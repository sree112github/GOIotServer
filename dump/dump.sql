--
-- PostgreSQL database dump
--

-- Dumped from database version 17.5
-- Dumped by pg_dump version 17.5

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: action; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.action AS ENUM (
    'publish',
    'subscribe',
    'all'
);


ALTER TYPE public.action OWNER TO postgres;

--
-- Name: permission; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.permission AS ENUM (
    'allow',
    'deny'
);


ALTER TYPE public.permission OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: companies; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.companies (
    company_id uuid DEFAULT gen_random_uuid() NOT NULL,
    company_name text NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.companies OWNER TO postgres;

--
-- Name: device_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.device_data (
    data_id bigint NOT NULL,
    device_id uuid NOT NULL,
    metrics jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.device_data OWNER TO postgres;

--
-- Name: device_data_data_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.device_data_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.device_data_data_id_seq OWNER TO postgres;

--
-- Name: device_data_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.device_data_data_id_seq OWNED BY public.device_data.data_id;


--
-- Name: devices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.devices (
    device_id uuid DEFAULT gen_random_uuid() NOT NULL,
    machine_id uuid NOT NULL,
    name text NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.devices OWNER TO postgres;

--
-- Name: machines; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.machines (
    machine_id uuid DEFAULT gen_random_uuid() NOT NULL,
    plant_id uuid NOT NULL,
    machine_name text NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.machines OWNER TO postgres;

--
-- Name: mqtt_acl; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mqtt_acl (
    id integer NOT NULL,
    ipaddress character varying(60) DEFAULT ''::character varying NOT NULL,
    username character varying(255) DEFAULT ''::character varying NOT NULL,
    clientid character varying(255) DEFAULT ''::character varying NOT NULL,
    action public.action,
    permission public.permission,
    topic character varying(255) NOT NULL
);


ALTER TABLE public.mqtt_acl OWNER TO postgres;

--
-- Name: mqtt_acl_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.mqtt_acl_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.mqtt_acl_id_seq OWNER TO postgres;

--
-- Name: mqtt_acl_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.mqtt_acl_id_seq OWNED BY public.mqtt_acl.id;


--
-- Name: mqtt_telemetry; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mqtt_telemetry (
    id integer NOT NULL,
    client_id text NOT NULL,
    username text,
    topic text NOT NULL,
    payload jsonb NOT NULL,
    "timestamp" bigint
);


ALTER TABLE public.mqtt_telemetry OWNER TO postgres;

--
-- Name: mqtt_telemetry_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.mqtt_telemetry_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.mqtt_telemetry_id_seq OWNER TO postgres;

--
-- Name: mqtt_telemetry_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.mqtt_telemetry_id_seq OWNED BY public.mqtt_telemetry.id;


--
-- Name: mqtt_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mqtt_user (
    id integer NOT NULL,
    username character varying(100) NOT NULL,
    password_hash character varying(255) NOT NULL,
    salt character varying(255) NOT NULL
);


ALTER TABLE public.mqtt_user OWNER TO postgres;

--
-- Name: mqtt_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.mqtt_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.mqtt_user_id_seq OWNER TO postgres;

--
-- Name: mqtt_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.mqtt_user_id_seq OWNED BY public.mqtt_user.id;


--
-- Name: plants; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.plants (
    plant_id uuid DEFAULT gen_random_uuid() NOT NULL,
    company_id uuid NOT NULL,
    plant_name text NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.plants OWNER TO postgres;

--
-- Name: proto_descriptors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.proto_descriptors (
    proto_name text NOT NULL,
    descriptor bytea NOT NULL
);


ALTER TABLE public.proto_descriptors OWNER TO postgres;

--
-- Name: telemetry; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.telemetry (
    id bigint NOT NULL,
    device_id text NOT NULL,
    payload jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.telemetry OWNER TO postgres;

--
-- Name: telemetry_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.telemetry_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.telemetry_id_seq OWNER TO postgres;

--
-- Name: telemetry_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.telemetry_id_seq OWNED BY public.telemetry.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    user_id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    email text NOT NULL,
    password text NOT NULL,
    scope text DEFAULT 'pending'::text NOT NULL,
    company_id uuid,
    plant_id uuid,
    machine_id uuid,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT chk_user_scope_ownership CHECK ((((scope = 'super_admin'::text) AND (company_id IS NULL) AND (plant_id IS NULL) AND (machine_id IS NULL)) OR ((scope = 'company_admin'::text) AND (company_id IS NOT NULL) AND (plant_id IS NULL) AND (machine_id IS NULL)) OR ((scope = 'plant_admin'::text) AND (company_id IS NOT NULL) AND (plant_id IS NOT NULL) AND (machine_id IS NULL)) OR ((scope = 'machine_user'::text) AND (company_id IS NOT NULL) AND (plant_id IS NOT NULL) AND (machine_id IS NOT NULL)) OR (scope = 'pending'::text))),
    CONSTRAINT users_scope_check CHECK ((scope = ANY (ARRAY['super_admin'::text, 'company_admin'::text, 'plant_admin'::text, 'machine_user'::text, 'pending'::text])))
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: device_data data_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device_data ALTER COLUMN data_id SET DEFAULT nextval('public.device_data_data_id_seq'::regclass);


--
-- Name: mqtt_acl id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mqtt_acl ALTER COLUMN id SET DEFAULT nextval('public.mqtt_acl_id_seq'::regclass);


--
-- Name: mqtt_telemetry id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mqtt_telemetry ALTER COLUMN id SET DEFAULT nextval('public.mqtt_telemetry_id_seq'::regclass);


--
-- Name: mqtt_user id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mqtt_user ALTER COLUMN id SET DEFAULT nextval('public.mqtt_user_id_seq'::regclass);


--
-- Name: telemetry id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.telemetry ALTER COLUMN id SET DEFAULT nextval('public.telemetry_id_seq'::regclass);


--
-- Data for Name: companies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.companies (company_id, company_name, created_at) FROM stdin;
48965d9c-8e07-47bb-af10-9e9549e5d0fe	Company 1	2025-09-02 21:02:01.769638+05:30
8a3869bd-e030-4d25-a27b-257dc745090b	Company 2	2025-09-02 21:02:09.190022+05:30
\.


--
-- Data for Name: device_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.device_data (data_id, device_id, metrics, created_at) FROM stdin;
\.


--
-- Data for Name: devices; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.devices (device_id, machine_id, name, created_at) FROM stdin;
4f114eca-db7a-454a-a0c5-12cfb792a23d	addf61a6-3488-43e4-9f0a-1360ac22c3c9	Device1	2025-09-06 21:50:30.857113+05:30
c8d49296-7062-4cb3-b82b-885a2d690fbe	eb771390-c551-4643-96c9-54af66f44ad6	Device1	2025-09-06 21:51:55.701284+05:30
dad36955-7922-4fde-b23f-0a27ce48187b	eb771390-c551-4643-96c9-54af66f44ad6	Device3	2025-09-06 21:52:02.560433+05:30
\.


--
-- Data for Name: machines; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.machines (machine_id, plant_id, machine_name, created_at) FROM stdin;
addf61a6-3488-43e4-9f0a-1360ac22c3c9	2f01a6c9-0598-48ec-b60b-01e378097c18	maachine1	2025-09-06 21:48:00.252231+05:30
4b330cc8-cad2-4dff-b698-5ffc515fba8b	2f01a6c9-0598-48ec-b60b-01e378097c18	maachine2	2025-09-06 21:51:36.042763+05:30
eb771390-c551-4643-96c9-54af66f44ad6	2f01a6c9-0598-48ec-b60b-01e378097c18	maachine3	2025-09-06 21:51:41.049451+05:30
\.


--
-- Data for Name: mqtt_acl; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mqtt_acl (id, ipaddress, username, clientid, action, permission, topic) FROM stdin;
2		testuser	unauthorized_client	all	deny	sensors/#
3		authorized_user	client_ok	all	allow	sensors/#
1		sreekuttan	client1	publish	allow	sensors/alice1
\.


--
-- Data for Name: mqtt_telemetry; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mqtt_telemetry (id, client_id, username, topic, payload, "timestamp") FROM stdin;
\.


--
-- Data for Name: mqtt_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mqtt_user (id, username, password_hash, salt) FROM stdin;
3	alice	device123	random_salt_123
\.


--
-- Data for Name: plants; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.plants (plant_id, company_id, plant_name, created_at) FROM stdin;
2f01a6c9-0598-48ec-b60b-01e378097c18	48965d9c-8e07-47bb-af10-9e9549e5d0fe	Plant 1	2025-09-02 21:03:15.062779+05:30
6e462641-0379-4e5f-8508-8d794a8dbc0f	48965d9c-8e07-47bb-af10-9e9549e5d0fe	Plant 2	2025-09-02 21:03:45.886751+05:30
5ede528b-6c4b-4cd1-a7be-4eebcd597c62	8a3869bd-e030-4d25-a27b-257dc745090b	Plant 1	2025-09-02 21:04:04.747296+05:30
ce79f868-e9c4-42c2-8d50-1bc57570b25f	8a3869bd-e030-4d25-a27b-257dc745090b	Plant 2	2025-09-02 21:04:09.928351+05:30
1e70c905-ff37-4a8b-a371-712bf131a3ee	48965d9c-8e07-47bb-af10-9e9549e5d0fe	Plant 3	2025-09-21 16:21:45.581273+05:30
a24807af-f0ff-4f15-b172-91fa633e0834	48965d9c-8e07-47bb-af10-9e9549e5d0fe	Plant 4	2025-09-21 16:22:17.507666+05:30
559e0643-90a6-41ca-adb4-7b14cbfba82c	48965d9c-8e07-47bb-af10-9e9549e5d0fe	Plant 5	2025-09-21 23:11:03.1127+05:30
b772a076-8ed9-40ea-bdfc-fd8993a48fc9	48965d9c-8e07-47bb-af10-9e9549e5d0fe	Plant 6	2025-09-21 23:12:06.98768+05:30
7b017a26-ff6a-4f45-a982-fdaa0236a70b	48965d9c-8e07-47bb-af10-9e9549e5d0fe	Plant 7	2025-09-21 23:25:09.567159+05:30
\.


--
-- Data for Name: proto_descriptors; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.proto_descriptors (proto_name, descriptor) FROM stdin;
AlertPayload	\\x0a1d696e7465726e616c2f70726f746f2f61712f616c6572742e70726f746f120261712289010a0c416c6572745061796c6f6164121d0a0a616c6572745f747970651801200128095209616c6572745479706512200a0b6465736372697074696f6e180220012809520b6465736372697074696f6e121c0a0974696d657374616d70180320012803520974696d657374616d70121a0a08736576657269747918042001280552087365766572697479421f5a1d496f7450726f746f2f696e7465726e616c2f70726f746f2f61713b6171620670726f746f33
SensorPayload	\\x0a1e696e7465726e616c2f70726f746f2f61712f73656e736f722e70726f746f1202617122a9020a0d53656e736f725061796c6f616412170a07706172616d5f311801200128015206706172616d3112170a07706172616d5f321802200128015206706172616d3212170a07706172616d5f331803200128015206706172616d3312170a07706172616d5f341804200128015206706172616d3412170a07706172616d5f351805200128015206706172616d3512170a07706172616d5f361806200128015206706172616d3612170a07706172616d5f371807200128015206706172616d3712170a07706172616d5f381808200128015206706172616d3812170a07706172616d5f391809200128015206706172616d3912190a08706172616d5f3130180a200128015207706172616d3130121c0a0974696d657374616d70180b20012803520974696d657374616d70421f5a1d496f7450726f746f2f696e7465726e616c2f70726f746f2f61713b6171620670726f746f33
\.


--
-- Data for Name: telemetry; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.telemetry (id, device_id, payload, created_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (user_id, name, email, password, scope, company_id, plant_id, machine_id, created_at) FROM stdin;
a8277435-91b3-4596-8c9c-258ce730c087	Super Admin	superadmin@gmail.com	$2a$06$.mfCctskU9XWcypEosrPOe1gfY4nck.4Xbg0khHiNKxZJnXalC60q	super_admin	\N	\N	\N	2025-09-01 23:24:06.586516+05:30
4f61503b-7845-430f-ac8e-bd920eacdcd8	companyadmin1	companyadmin1@gmail.com	$2a$10$3a3Kh61c4yHP8HZkaiQCxOZ6sudqGwjlZJQyq4vRJgtTZW13bjDde	company_admin	48965d9c-8e07-47bb-af10-9e9549e5d0fe	\N	\N	2025-09-01 23:25:24.299679+05:30
117caed3-081a-4b10-b94e-7f2bb36d5486	plantadmin1	plantadmin1@gmail.com	$2a$10$wstd9/Cs0U5hqYLq3TfGF.qslCKTHJ3MTyD1w9ak5vloWGrydPlwG	plant_admin	48965d9c-8e07-47bb-af10-9e9549e5d0fe	2f01a6c9-0598-48ec-b60b-01e378097c18	\N	2025-09-01 23:26:12.690273+05:30
426d9889-fb75-4db6-9521-43bbdee4ddb5	plantadmin2	plantadmin2@gmail.com	$2a$10$cO6EGKWiK8yx1B1cJNsMFOUHRrl2hnDSoL1EMHWCRhBS9vbCmR/9y	plant_admin	48965d9c-8e07-47bb-af10-9e9549e5d0fe	5ede528b-6c4b-4cd1-a7be-4eebcd597c62	\N	2025-09-01 23:26:23.181106+05:30
f19e8479-9462-4c4b-ab32-d62d27ccfb22	machineadmin1	machineadmin1@gmail.com	$2a$10$HkcScx.9tMrhc2ni7wHKy.oizFTQeXp3JjdnKFXTZRiWwVF0ntIae	machine_user	48965d9c-8e07-47bb-af10-9e9549e5d0fe	2f01a6c9-0598-48ec-b60b-01e378097c18	addf61a6-3488-43e4-9f0a-1360ac22c3c9	2025-09-01 23:27:03.300082+05:30
bd1d4dd5-c54e-43c6-adef-0ca81896b44e	companyadmin2	companyadmin2@gmail.com	$2a$10$8TEDSPbG8sddnSPbcefEMOOv60RyYaJ1MVC4uusU0sbZeFzYaYyuC	plant_admin	8a3869bd-e030-4d25-a27b-257dc745090b	5ede528b-6c4b-4cd1-a7be-4eebcd597c62	\N	2025-09-01 23:25:37.975574+05:30
b663be11-c01a-4af1-b395-a2a17e2337cf	machineadmin2	machineadmin2@gmail.com	$2a$10$XeT1LuF3U5BmQC2Mn3uIkeSqn0axB17Qp9sMfSrK9u8Rxnm60IQBS	plant_admin	8a3869bd-e030-4d25-a27b-257dc745090b	5ede528b-6c4b-4cd1-a7be-4eebcd597c62	\N	2025-09-01 23:27:13.546041+05:30
d5e1b4a2-2c20-460a-a2e6-76cc408aa946	machineadmin3	machineadmin3@gmail.com	$2a$10$yWgBL8chgL0IO9DUU2hkd.YqOH.KuQ7njn6wsd6zfZOsP8YeBTsKq	pending	\N	\N	\N	2025-09-29 12:53:51.560356+05:30
\.


--
-- Name: device_data_data_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.device_data_data_id_seq', 3, true);


--
-- Name: mqtt_acl_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.mqtt_acl_id_seq', 3, true);


--
-- Name: mqtt_telemetry_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.mqtt_telemetry_id_seq', 1651531, true);


--
-- Name: mqtt_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.mqtt_user_id_seq', 3, true);


--
-- Name: telemetry_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.telemetry_id_seq', 1741979, true);


--
-- Name: companies companies_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (company_id);


--
-- Name: device_data device_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device_data
    ADD CONSTRAINT device_data_pkey PRIMARY KEY (data_id);


--
-- Name: devices devices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_pkey PRIMARY KEY (device_id);


--
-- Name: machines machines_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.machines
    ADD CONSTRAINT machines_pkey PRIMARY KEY (machine_id);


--
-- Name: mqtt_acl mqtt_acl_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mqtt_acl
    ADD CONSTRAINT mqtt_acl_pkey PRIMARY KEY (id);


--
-- Name: mqtt_telemetry mqtt_telemetry_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mqtt_telemetry
    ADD CONSTRAINT mqtt_telemetry_pkey PRIMARY KEY (id);


--
-- Name: mqtt_user mqtt_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mqtt_user
    ADD CONSTRAINT mqtt_user_pkey PRIMARY KEY (id);


--
-- Name: mqtt_user mqtt_user_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mqtt_user
    ADD CONSTRAINT mqtt_user_username_key UNIQUE (username);


--
-- Name: plants plants_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plants
    ADD CONSTRAINT plants_pkey PRIMARY KEY (plant_id);


--
-- Name: proto_descriptors proto_descriptors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proto_descriptors
    ADD CONSTRAINT proto_descriptors_pkey PRIMARY KEY (proto_name);


--
-- Name: telemetry telemetry_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.telemetry
    ADD CONSTRAINT telemetry_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: idx_telemetry_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_telemetry_created_at ON public.telemetry USING btree (created_at);


--
-- Name: idx_telemetry_device_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_telemetry_device_id ON public.telemetry USING btree (device_id);


--
-- Name: idx_telemetry_payload_gin; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_telemetry_payload_gin ON public.telemetry USING gin (payload);


--
-- Name: device_data fk_devicedata_device; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device_data
    ADD CONSTRAINT fk_devicedata_device FOREIGN KEY (device_id) REFERENCES public.devices(device_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: devices fk_devices_machine; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT fk_devices_machine FOREIGN KEY (machine_id) REFERENCES public.machines(machine_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: machines fk_machines_plant; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.machines
    ADD CONSTRAINT fk_machines_plant FOREIGN KEY (plant_id) REFERENCES public.plants(plant_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: plants fk_plants_company; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plants
    ADD CONSTRAINT fk_plants_company FOREIGN KEY (company_id) REFERENCES public.companies(company_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: users fk_users_company; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_users_company FOREIGN KEY (company_id) REFERENCES public.companies(company_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: users fk_users_machine; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_users_machine FOREIGN KEY (machine_id) REFERENCES public.machines(machine_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: users fk_users_plant; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_users_plant FOREIGN KEY (plant_id) REFERENCES public.plants(plant_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

