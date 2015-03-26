-- Create schema
CREATE SCHEMA IF NOT EXISTS kls AUTHORIZATION stefan;
-- Make schema usable for user gisuser
GRANT USAGE ON SCHEMA kls TO gisuser;
GRANT SELECT ON ALL TABLES IN SCHEMA kls TO gisuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA kls GRANT SELECT ON TABLES TO gisuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA kls GRANT INSERT ON TABLES TO gisuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA kls GRANT DELETE ON TABLES TO gisuser;

-- -- Empty schema in order to recreate DB
DROP TABLE IF EXISTS kls.p_artsobservasjon;
DROP TABLE IF EXISTS kls.p_kls_lokalitet;
DROP TABLE IF EXISTS kls.p_lokalitet;
DROP TABLE IF EXISTS kls.l_artsliste;
DROP TABLE IF EXISTS kls.l_veg_cover;
DROP TABLE IF EXISTS kls.l_litter_humus;
DROP TABLE IF EXISTS kls.l_soil;
DROP TABLE IF EXISTS kls.l_slope;
DROP TABLE IF EXISTS kls.l_collectingmethod;
DROP TABLE IF EXISTS kls.l_preparationtype;
DROP TABLE IF EXISTS kls.l_sex;
DROP TABLE IF EXISTS kls.l_basisofrecord;
 
 
-- Create lookup tables and fill them with data
CREATE TABLE kls.l_basisofrecord	(
basisofrecord	varchar(25) UNIQUE NOT NULL CONSTRAINT kls_l_basisofrecord_pkey PRIMARY KEY);
INSERT INTO kls.l_basisofrecord VALUES ('specimen'), ('fossil'), ('observation'), ('living organism'), ('still image'), ('sound recording'), ('moving image');

CREATE TABLE kls.l_sex	(
sex	varchar(25) UNIQUE NOT NULL CONSTRAINT kls_l_sex_pkey PRIMARY KEY);
INSERT INTO kls.l_sex VALUES ('male'), ('female'), ('hermaphrodite'), ('gynandromorph'), ('not recorded'), ('indeterminate'), ('transitional');

CREATE TABLE kls.l_preparationtype	(
preparationtype	varchar(25) UNIQUE NOT NULL CONSTRAINT kls_l_preparationtype_pkey PRIMARY KEY);
INSERT INTO kls.l_preparationtype VALUES ('Fluid'), ('Pinned'), ('Slide'), ('Dry in tube'), ('Herbarium');
	
CREATE TABLE kls.l_collectingmethod	(
collectingmethod	varchar(25) UNIQUE NOT NULL CONSTRAINT kls_l_collectingmethod_pkey PRIMARY KEY);
INSERT INTO kls.l_collectingmethod VALUES ('netted'), ('light trap'), ('light catch'), ('UV light trap'), ('barber trap'), ('malaise trap'), ('pheromone trap'), 
('interception trap'), ('yellow pan trap'), ('bait trap'), ('hand picking'), ('rearing'), ('mist net'), ('bottom trawl'), ('grap sampler'), ('kick sampler'), 
('tube sampler'), ('plankton net'), ('plankton trap');

CREATE TABLE kls.l_slope(	
slope	smallint UNIQUE NOT NULL CONSTRAINT kls_l_slope_pkey PRIMARY KEY,
beskrivelse	varchar(25));
INSERT INTO kls.l_slope VALUES (1, 'flat'), (2, 'slightly sloping'), (3, 'moderate slope'), (4, 'steep slope');	
	
CREATE TABLE kls.l_soil	(
soil	smallint UNIQUE NOT NULL CONSTRAINT kls_l_soil_pkey PRIMARY KEY,
beskrivelse	varchar(50));
INSERT INTO kls.l_soil VALUES (1, 'mull soil'), (2, 'mixed mull/mineralic soil'), (3, 'mineralic soil (shale/limestone gravel)');	

CREATE TABLE kls.l_litter_humus	(
litter_humus	smallint UNIQUE NOT NULL CONSTRAINT kls_l_litter_humus_pkey PRIMARY KEY,
beskrivelse	varchar(50));
INSERT INTO kls.l_litter_humus VALUES (1, 'no litter layer'), (2, 'very thin/patchy litter layer'), (3, 'thick');	
	
CREATE TABLE kls.l_veg_cover	(
veg_cover	smallint UNIQUE NOT NULL CONSTRAINT kls_l_veg_cover_pkey PRIMARY KEY,
beskrivelse	varchar(25));
INSERT INTO kls.l_veg_cover VALUES (1, 'no veg.'), (2, 'sparse'), (3, 'medium dense'), (4, 'dense/abundant');	

-- Get official species list from Artsdatababnken
--Check hovedstatus and bistatus (to be put in WhERE clause probably)
CREATE OR REPLACE VIEW kls.l_artsliste AS SELECT DISTINCT ON (scientificname) * FROM (SELECT
*, slekt AS scientificname FROM lookup_tables.species_names_artsdatabanken_fungi WHERE slekt IS NOT NULL AND art IS NULL AND underart IS NULL AND varietet IS NULL AND form IS NULL UNION ALL SELECT 
*, slekt || ' ' || art FROM lookup_tables.species_names_artsdatabanken_fungi WHERE slekt IS NOT NULL AND art IS NOT NULL AND underart IS NULL AND varietet IS NULL AND form IS NULL UNION ALL SELECT 
*, slekt || ' ' || art || ' var. ' || varietet FROM lookup_tables.species_names_artsdatabanken_fungi WHERE slekt IS NOT NULL AND art IS NOT NULL AND underart IS NULL AND varietet IS NOT NULL AND form IS NULL UNION ALL SELECT 
*, slekt || ' ' || art || ' f. ' || form FROM lookup_tables.species_names_artsdatabanken_fungi WHERE slekt IS NOT NULL AND art IS NOT NULL AND underart IS NULL AND form IS NOT NULL AND varietet IS NULL UNION ALL SELECT 
*, slekt || ' ' || art || ' var. ' || varietet || ' f. ' || form FROM lookup_tables.species_names_artsdatabanken_fungi WHERE slekt IS NOT NULL AND art IS NOT NULL AND underart IS NULL AND form IS NOT NULL AND varietet IS NOT NULL UNION ALL SELECT 
*, slekt || ' ' || art || ' ssp. ' || underart FROM lookup_tables.species_names_artsdatabanken_fungi WHERE slekt IS NOT NULL AND art IS NOT NULL AND underart IS NOT NULL AND varietet IS NULL AND form IS NULL UNION ALL SELECT 
*, slekt || ' ' || art || ' ssp. ' || underart || ' var. ' || varietet FROM lookup_tables.species_names_artsdatabanken_fungi WHERE slekt IS NOT NULL AND art IS NOT NULL AND underart IS NOT NULL AND varietet IS NOT NULL AND form IS NULL UNION ALL SELECT 
*, slekt || ' ' || art || ' ssp. ' || underart || ' f. ' || form FROM lookup_tables.species_names_artsdatabanken_fungi WHERE slekt IS NOT NULL AND art IS NOT NULL AND underart IS NOT NULL AND form IS NOT NULL AND varietet IS NULL UNION ALL SELECT 
*, slekt || ' ' || art || ' ssp. ' || underart || ' var. ' || varietet || ' f. ' || form FROM lookup_tables.species_names_artsdatabanken_fungi WHERE slekt IS NOT NULL AND art IS NOT NULL AND underart IS NOT NULL AND form IS NOT NULL AND varietet IS NOT NULL) AS a

-- Create primary tables with references to lookup tables
CREATE TABLE kls.p_lokalitet(	
datecollected	timestamp,
fieldnumber	varchar(12),
locality	varchar(350),
habitat	varchar(120),
substrat	varchar(120),
polygonid	serial UNIQUE NOT NULL CONSTRAINT kls_lokalitet_pkey PRIMARY KEY,
geom	geometry(Polygon,25833),
reduceprecision	smallint,
datelastmodified	date);

CREATE TABLE kls.p_kls_lokalitet(
polygonid integer UNIQUE NOT NULL CONSTRAINT kls_p_kls_lokalitet_pkey PRIMARY KEY REFERENCES kls.p_lokalitet (polygonid) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE,
individuals	integer,
frb_no	integer,
r_fairy_ring	boolean,
slope	smallint REFERENCES kls.l_slope (slope) MATCH SIMPLE ON UPDATE CASCADE ON DELETE NO ACTION,
soil	smallint REFERENCES kls.l_soil (soil) MATCH SIMPLE ON UPDATE CASCADE ON DELETE NO ACTION,
litter_humus	smallint REFERENCES kls.l_litter_humus (litter_humus) MATCH SIMPLE ON UPDATE CASCADE ON DELETE NO ACTION,
veg_cover	smallint REFERENCES kls.l_veg_cover (veg_cover) MATCH SIMPLE ON UPDATE CASCADE ON DELETE NO ACTION,
Tilia_indiv	smallint,
Corylus_indiv	smallint);

CREATE TABLE kls.p_artsobservasjon(	
datelastmodified	date,
collectioncode	varchar(10),
catalognumber	serial UNIQUE NOT NULL,
fk_latinsknavnid	integer REFERENCES lookup_tables.species_names_artsdatabanken_fungi (pk_latinsknavnid) MATCH SIMPLE ON UPDATE CASCADE ON DELETE NO ACTION,
basisofrecord	varchar(18),
identifiedby	varchar(100),
typestatus	varchar(12),
collectornumber	varchar(36),
collector	varchar(120),
sex	varchar(25) REFERENCES kls.l_sex (sex) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION,
preparationtype	varchar(25) REFERENCES kls.l_preparationtype (preparationtype) MATCH SIMPLE ON UPDATE CASCADE ON DELETE NO ACTION,
individualcount	integer,
previouscatalognumber	varchar(100),
relationshiptype	varchar(100),
relatedcatalogitem	varchar(100),
notes	varchar(120),
collectingmethod	varchar(25) REFERENCES kls.l_collectingmethod (collectingmethod) MATCH SIMPLE ON UPDATE CASCADE ON DELETE NO ACTION,
identificationprecision	boolean,
oekologi	varchar(120),
relativeabundance	integer CHECK (relativeabundance >=0 AND relativeabundance <= 100),
antropokor	boolean,
url	varchar(100),
dateidentified	date,
polygonid	integer REFERENCES kls.p_lokalitet (polygonid) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT kls_l_artsobservasjon_pkey PRIMARY KEY (polygonid, fk_latinsknavnid));

--Give access to sequences
GRANT USAGE, SELECT ON SEQUENCE kls.p_artsobservasjon_catalognumber_seq TO gisuser;
GRANT USAGE, SELECT ON SEQUENCE kls.p_lokalitet_polygonid_seq TO gisuser;

--Default values
