--
-- PostgreSQL database dump

-- Dumped from database version 9.0.3
-- Dumped by pg_dump version 9.0.1
-- Started on 2011-04-15 17:40:37

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- TOC entry 317 (class 2612 OID 11574)
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: postgres
--

CREATE OR REPLACE PROCEDURAL LANGUAGE plpgsql;


ALTER PROCEDURAL LANGUAGE plpgsql OWNER TO postgres;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 1514 (class 1259 OID 93114)
-- Dependencies: 1795 5
-- Name: parts; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE parts (
    id integer NOT NULL,
    trans_id integer,
    transname text,
    connstr text NOT NULL,
    state text,
    CONSTRAINT parts_state_check CHECK ((state = ANY (ARRAY['NONE'::text, 'PREPARED'::text, 'COMMITED'::text])))
);


ALTER TABLE public.parts OWNER TO postgres;

--
-- TOC entry 1513 (class 1259 OID 93112)
-- Dependencies: 1514 5
-- Name: parts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE parts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.parts_id_seq OWNER TO postgres;

--
-- TOC entry 1814 (class 0 OID 0)
-- Dependencies: 1513
-- Name: parts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE parts_id_seq OWNED BY parts.id;


--
-- TOC entry 1815 (class 0 OID 0)
-- Dependencies: 1513
-- Name: parts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('parts_id_seq', 84, true);


--
-- TOC entry 1510 (class 1259 OID 93067)
-- Dependencies: 5
-- Name: tm; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE tm (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE public.tm OWNER TO postgres;

--
-- TOC entry 1509 (class 1259 OID 93065)
-- Dependencies: 5 1510
-- Name: tm_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE tm_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tm_id_seq OWNER TO postgres;

--
-- TOC entry 1816 (class 0 OID 0)
-- Dependencies: 1509
-- Name: tm_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE tm_id_seq OWNED BY tm.id;


--
-- TOC entry 1817 (class 0 OID 0)
-- Dependencies: 1509
-- Name: tm_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('tm_id_seq', 1, true);


--
-- TOC entry 1512 (class 1259 OID 93078)
-- Dependencies: 5
-- Name: trans; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE trans (
    id integer NOT NULL,
    tm_id integer,
    name text NOT NULL
);


ALTER TABLE public.trans OWNER TO postgres;

--
-- TOC entry 1511 (class 1259 OID 93076)
-- Dependencies: 5 1512
-- Name: trans_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE trans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.trans_id_seq OWNER TO postgres;

--
-- TOC entry 1818 (class 0 OID 0)
-- Dependencies: 1511
-- Name: trans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE trans_id_seq OWNED BY trans.id;


--
-- TOC entry 1819 (class 0 OID 0)
-- Dependencies: 1511
-- Name: trans_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('trans_id_seq', 45, true);


--
-- TOC entry 1794 (class 2604 OID 93117)
-- Dependencies: 1514 1513 1514
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE parts ALTER COLUMN id SET DEFAULT nextval('parts_id_seq'::regclass);


--
-- TOC entry 1792 (class 2604 OID 93070)
-- Dependencies: 1510 1509 1510
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE tm ALTER COLUMN id SET DEFAULT nextval('tm_id_seq'::regclass);


--
-- TOC entry 1793 (class 2604 OID 93081)
-- Dependencies: 1511 1512 1512
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE trans ALTER COLUMN id SET DEFAULT nextval('trans_id_seq'::regclass);


--
-- TOC entry 1808 (class 0 OID 93114)
-- Dependencies: 1514
-- Data for Name: parts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY parts (id, trans_id, transname, connstr, state) FROM stdin;
\.


--
-- TOC entry 1806 (class 0 OID 93067)
-- Dependencies: 1510
-- Data for Name: tm; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY tm (id, name) FROM stdin;
1	test
\.


--
-- TOC entry 1807 (class 0 OID 93078)
-- Dependencies: 1512
-- Data for Name: trans; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY trans (id, tm_id, name) FROM stdin;
\.


--
-- TOC entry 1803 (class 2606 OID 93123)
-- Dependencies: 1514 1514
-- Name: parts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY parts
    ADD CONSTRAINT parts_pkey PRIMARY KEY (id);


--
-- TOC entry 1797 (class 2606 OID 93075)
-- Dependencies: 1510 1510
-- Name: tm_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tm
    ADD CONSTRAINT tm_pkey PRIMARY KEY (id);


--
-- TOC entry 1799 (class 2606 OID 93088)
-- Dependencies: 1512 1512
-- Name: trans_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY trans
    ADD CONSTRAINT trans_name_key UNIQUE (name);


--
-- TOC entry 1801 (class 2606 OID 93086)
-- Dependencies: 1512 1512
-- Name: trans_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY trans
    ADD CONSTRAINT trans_pkey PRIMARY KEY (id);


--
-- TOC entry 1805 (class 2606 OID 93124)
-- Dependencies: 1800 1512 1514
-- Name: parts_trans_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY parts
    ADD CONSTRAINT parts_trans_id_fkey FOREIGN KEY (trans_id) REFERENCES trans(id);


--
-- TOC entry 1804 (class 2606 OID 93089)
-- Dependencies: 1510 1796 1512
-- Name: trans_tm_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY trans
    ADD CONSTRAINT trans_tm_id_fkey FOREIGN KEY (tm_id) REFERENCES tm(id);


--
-- TOC entry 1813 (class 0 OID 0)
-- Dependencies: 5
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2011-04-15 17:40:38

--
-- PostgreSQL database dump complete
--

