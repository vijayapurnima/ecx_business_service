
CREATE EXTENSION IF NOT EXISTS pgcrypto;

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';

CREATE TABLE case_studies (
    id bigint NOT NULL,
    profile_id bigint,
    title character varying,
    duration character varying,
    summary character varying,
    background character varying,
    aim character varying,
    approach character varying,
    outcome character varying,
    image_id integer,
    client_name character varying,
    phone character varying,
    client_email character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    key_challenges character varying,
    contact_email character varying
);

CREATE SEQUENCE case_studies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE case_studies_id_seq OWNED BY case_studies.id;

CREATE TABLE categories (
    id bigint NOT NULL,
    title character varying,
    parent_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE SEQUENCE categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE categories_id_seq OWNED BY categories.id;

CREATE TABLE certificate_types (
    id bigint NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE SEQUENCE certificate_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE certificate_types_id_seq OWNED BY certificate_types.id;

CREATE TABLE certifications (
    id bigint NOT NULL,
    profile_id bigint,
    certificate_type_id bigint,
    expiry_date date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE SEQUENCE certifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE certifications_id_seq OWNED BY certifications.id;

CREATE TABLE countries (
    id bigint NOT NULL,
    code character varying,
    name character varying,
    identifier_name character varying,
    mask character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    "default" boolean,
    identifier_expansion character varying
);

CREATE SEQUENCE countries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE countries_id_seq OWNED BY countries.id;

CREATE TABLE country_identifiers (
    id bigint NOT NULL,
    identifier character varying,
    country_id bigint,
    profile_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE SEQUENCE country_identifiers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE country_identifiers_id_seq OWNED BY country_identifiers.id;

CREATE TABLE delayed_jobs (
    id bigint NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    handler text NOT NULL,
    last_error text,
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by character varying,
    queue character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);

CREATE SEQUENCE delayed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE delayed_jobs_id_seq OWNED BY delayed_jobs.id;

CREATE TABLE group_levels (
    id bigint NOT NULL,
    group_id bigint,
    level character varying,
    priority integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE SEQUENCE group_levels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE group_levels_id_seq OWNED BY group_levels.id;

CREATE TABLE groups (
    id bigint NOT NULL,
    name character varying,
    expansion character varying,
    logo_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE SEQUENCE groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE groups_id_seq OWNED BY groups.id;

CREATE TABLE insurance_coverages (
    id bigint NOT NULL,
    profile_id bigint,
    insurance_id bigint,
    field_values character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE SEQUENCE insurance_coverages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE insurance_coverages_id_seq OWNED BY insurance_coverages.id;

CREATE TABLE insurances (
    id bigint NOT NULL,
    name character varying,
    fields character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE SEQUENCE insurances_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE insurances_id_seq OWNED BY insurances.id;

CREATE TABLE locations (
    id bigint NOT NULL,
    profile_id bigint,
    address character varying,
    location_type character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    latitude double precision,
    longitude double precision
);

CREATE SEQUENCE locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE locations_id_seq OWNED BY locations.id;

CREATE TABLE product_services (
    id bigint NOT NULL,
    profile_id bigint,
    name character varying,
    product_type character varying,
    description character varying,
    status character varying,
    promo_video character varying,
    promo_image_id integer,
    promo_link character varying,
    document_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE SEQUENCE product_services_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE product_services_id_seq OWNED BY product_services.id;

CREATE TABLE profile_billings (
    id bigint NOT NULL,
    profile_id bigint,
    address jsonb,
    name character varying,
    billing_email character varying,
    email_verified boolean DEFAULT false,
    verification_code character varying,
    code_created_at timestamp without time zone,
    currency character varying DEFAULT 'AUD'::character varying,
    phone character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE SEQUENCE profile_billings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE profile_billings_id_seq OWNED BY profile_billings.id;

CREATE TABLE profile_groups (
    id bigint NOT NULL,
    profile_id bigint,
    group_id bigint,
    group_level_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE SEQUENCE profile_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE profile_groups_id_seq OWNED BY profile_groups.id;

CREATE TABLE profiles (
    id bigint NOT NULL,
    abn character varying,
    trading_name character varying,
    abr_name character varying,
    registration_contact character varying DEFAULT 'Business Administrator'::character varying,
    description character varying,
    year_founded character varying,
    size character varying,
    website character varying,
    ownership_type character varying,
    atsi_owned boolean DEFAULT false,
    atsi_operated boolean DEFAULT false,
    market_alignment character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    status character varying,
    logo_id integer,
    capability_statement_id integer,
    need_update boolean DEFAULT true,
    disability_enterprise boolean,
    public_profile boolean DEFAULT false,
    public_profile_path character varying,
    account_owner_id integer,
    primary_contact_id integer
);

CREATE SEQUENCE profiles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE profiles_id_seq OWNED BY profiles.id;

CREATE TABLE tags (
    id bigint NOT NULL,
    profile_id bigint,
    category_id bigint
);

CREATE SEQUENCE tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE tags_id_seq OWNED BY tags.id;

CREATE TABLE taxonomies (
    id bigint NOT NULL,
    group_name character varying,
    parent character varying,
    key character varying,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE SEQUENCE taxonomies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE taxonomies_id_seq OWNED BY taxonomies.id;

CREATE TABLE taxonomy_links (
    id bigint NOT NULL,
    taxonomy_id bigint,
    owner_type character varying,
    owner_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE SEQUENCE taxonomy_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE taxonomy_links_id_seq OWNED BY taxonomy_links.id;

ALTER TABLE ONLY case_studies ALTER COLUMN id SET DEFAULT nextval('case_studies_id_seq'::regclass);

ALTER TABLE ONLY categories ALTER COLUMN id SET DEFAULT nextval('categories_id_seq'::regclass);

ALTER TABLE ONLY certificate_types ALTER COLUMN id SET DEFAULT nextval('certificate_types_id_seq'::regclass);

ALTER TABLE ONLY certifications ALTER COLUMN id SET DEFAULT nextval('certifications_id_seq'::regclass);

ALTER TABLE ONLY countries ALTER COLUMN id SET DEFAULT nextval('countries_id_seq'::regclass);

ALTER TABLE ONLY country_identifiers ALTER COLUMN id SET DEFAULT nextval('country_identifiers_id_seq'::regclass);

ALTER TABLE ONLY delayed_jobs ALTER COLUMN id SET DEFAULT nextval('delayed_jobs_id_seq'::regclass);

ALTER TABLE ONLY group_levels ALTER COLUMN id SET DEFAULT nextval('group_levels_id_seq'::regclass);

ALTER TABLE ONLY groups ALTER COLUMN id SET DEFAULT nextval('groups_id_seq'::regclass);

ALTER TABLE ONLY insurance_coverages ALTER COLUMN id SET DEFAULT nextval('insurance_coverages_id_seq'::regclass);

ALTER TABLE ONLY insurances ALTER COLUMN id SET DEFAULT nextval('insurances_id_seq'::regclass);

ALTER TABLE ONLY locations ALTER COLUMN id SET DEFAULT nextval('locations_id_seq'::regclass);

ALTER TABLE ONLY product_services ALTER COLUMN id SET DEFAULT nextval('product_services_id_seq'::regclass);

ALTER TABLE ONLY profile_billings ALTER COLUMN id SET DEFAULT nextval('profile_billings_id_seq'::regclass);

ALTER TABLE ONLY profile_groups ALTER COLUMN id SET DEFAULT nextval('profile_groups_id_seq'::regclass);

ALTER TABLE ONLY profiles ALTER COLUMN id SET DEFAULT nextval('profiles_id_seq'::regclass);

ALTER TABLE ONLY tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);

ALTER TABLE ONLY taxonomies ALTER COLUMN id SET DEFAULT nextval('taxonomies_id_seq'::regclass);

ALTER TABLE ONLY taxonomy_links ALTER COLUMN id SET DEFAULT nextval('taxonomy_links_id_seq'::regclass);

ALTER TABLE ONLY case_studies
    ADD CONSTRAINT case_studies_pkey PRIMARY KEY (id);

ALTER TABLE ONLY categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);

ALTER TABLE ONLY certificate_types
    ADD CONSTRAINT certificate_types_pkey PRIMARY KEY (id);

ALTER TABLE ONLY certifications
    ADD CONSTRAINT certifications_pkey PRIMARY KEY (id);

ALTER TABLE ONLY countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);

ALTER TABLE ONLY country_identifiers
    ADD CONSTRAINT country_identifiers_pkey PRIMARY KEY (id);

ALTER TABLE ONLY delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);

ALTER TABLE ONLY group_levels
    ADD CONSTRAINT group_levels_pkey PRIMARY KEY (id);

ALTER TABLE ONLY groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);

ALTER TABLE ONLY insurance_coverages
    ADD CONSTRAINT insurance_coverages_pkey PRIMARY KEY (id);

ALTER TABLE ONLY insurances
    ADD CONSTRAINT insurances_pkey PRIMARY KEY (id);

ALTER TABLE ONLY locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);

ALTER TABLE ONLY product_services
    ADD CONSTRAINT product_services_pkey PRIMARY KEY (id);

ALTER TABLE ONLY profile_billings
    ADD CONSTRAINT profile_billings_pkey PRIMARY KEY (id);

ALTER TABLE ONLY profile_groups
    ADD CONSTRAINT profile_groups_pkey PRIMARY KEY (id);

ALTER TABLE ONLY profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);

ALTER TABLE ONLY taxonomies
    ADD CONSTRAINT taxonomies_pkey PRIMARY KEY (id);

ALTER TABLE ONLY taxonomy_links
    ADD CONSTRAINT taxonomy_links_pkey PRIMARY KEY (id);

CREATE INDEX delayed_jobs_priority ON delayed_jobs USING btree (priority, run_at);

CREATE INDEX index_case_studies_on_profile_id ON case_studies USING btree (profile_id);

CREATE INDEX index_categories_on_parent_id ON categories USING btree (parent_id);

CREATE INDEX index_certifications_on_certificate_type_id ON certifications USING btree (certificate_type_id);

CREATE INDEX index_certifications_on_profile_id ON certifications USING btree (profile_id);

CREATE INDEX index_country_identifiers_on_country_id ON country_identifiers USING btree (country_id);

CREATE INDEX index_country_identifiers_on_profile_id ON country_identifiers USING btree (profile_id);

CREATE INDEX index_group_levels_on_group_id ON group_levels USING btree (group_id);

CREATE INDEX index_insurance_coverages_on_insurance_id ON insurance_coverages USING btree (insurance_id);

CREATE INDEX index_insurance_coverages_on_profile_id ON insurance_coverages USING btree (profile_id);

CREATE INDEX index_locations_on_profile_id ON locations USING btree (profile_id);

CREATE INDEX index_product_services_on_profile_id ON product_services USING btree (profile_id);

CREATE INDEX index_profile_billings_on_profile_id ON profile_billings USING btree (profile_id);

CREATE INDEX index_profile_groups_on_group_id ON profile_groups USING btree (group_id);

CREATE INDEX index_profile_groups_on_group_level_id ON profile_groups USING btree (group_level_id);

CREATE INDEX index_profile_groups_on_profile_id ON profile_groups USING btree (profile_id);

CREATE INDEX index_profiles_on_abn ON profiles USING btree (abn);

CREATE INDEX index_tags_on_category_id ON tags USING btree (category_id);

CREATE INDEX index_tags_on_profile_id ON tags USING btree (profile_id);

CREATE INDEX index_taxonomies_on_group_name ON taxonomies USING btree (group_name);

CREATE INDEX index_taxonomies_on_key ON taxonomies USING btree (key);

CREATE INDEX index_taxonomies_on_parent ON taxonomies USING btree (parent);

CREATE INDEX index_taxonomy_links_on_owner_type_and_owner_id ON taxonomy_links USING btree (owner_type, owner_id);

CREATE INDEX index_taxonomy_links_on_taxonomy_id ON taxonomy_links USING btree (taxonomy_id);

ALTER TABLE ONLY country_identifiers
    ADD CONSTRAINT fk_rails_08ac4b5a7a FOREIGN KEY (country_id) REFERENCES countries(id);

ALTER TABLE ONLY certifications
    ADD CONSTRAINT fk_rails_591d29d52c FOREIGN KEY (profile_id) REFERENCES profiles(id);

ALTER TABLE ONLY tags
    ADD CONSTRAINT fk_rails_5d750c0ce0 FOREIGN KEY (profile_id) REFERENCES profiles(id);

ALTER TABLE ONLY group_levels
    ADD CONSTRAINT fk_rails_76f2126240 FOREIGN KEY (group_id) REFERENCES groups(id);

ALTER TABLE ONLY profile_groups
    ADD CONSTRAINT fk_rails_8b45bab50f FOREIGN KEY (profile_id) REFERENCES profiles(id);

ALTER TABLE ONLY insurance_coverages
    ADD CONSTRAINT fk_rails_916e658405 FOREIGN KEY (insurance_id) REFERENCES insurances(id);

ALTER TABLE ONLY certifications
    ADD CONSTRAINT fk_rails_9aef131a45 FOREIGN KEY (certificate_type_id) REFERENCES certificate_types(id);

ALTER TABLE ONLY taxonomy_links
    ADD CONSTRAINT fk_rails_a0b0a30fd5 FOREIGN KEY (taxonomy_id) REFERENCES taxonomies(id);

ALTER TABLE ONLY profile_groups
    ADD CONSTRAINT fk_rails_b3a00f4fa6 FOREIGN KEY (group_level_id) REFERENCES group_levels(id);

ALTER TABLE ONLY case_studies
    ADD CONSTRAINT fk_rails_bac738dbca FOREIGN KEY (profile_id) REFERENCES profiles(id);

ALTER TABLE ONLY product_services
    ADD CONSTRAINT fk_rails_c44d8d34b8 FOREIGN KEY (profile_id) REFERENCES profiles(id);

ALTER TABLE ONLY profile_groups
    ADD CONSTRAINT fk_rails_d384194695 FOREIGN KEY (group_id) REFERENCES groups(id);

ALTER TABLE ONLY insurance_coverages
    ADD CONSTRAINT fk_rails_da073ac793 FOREIGN KEY (profile_id) REFERENCES profiles(id);

ALTER TABLE ONLY country_identifiers
    ADD CONSTRAINT fk_rails_ee4215fe09 FOREIGN KEY (profile_id) REFERENCES profiles(id);

ALTER TABLE ONLY profile_billings
    ADD CONSTRAINT fk_rails_f1684493f5 FOREIGN KEY (profile_id) REFERENCES profiles(id);

