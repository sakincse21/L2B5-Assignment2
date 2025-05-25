create table rangers(
    ranger_id serial PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    region VARCHAR(50) NOT NULL
);

create table species(
    species_id serial PRIMARY KEY,
    common_name VARCHAR(50) NOT NULL,
    scientific_name VARCHAR(50) NOT NULL,
    discovery_date DATE NOT NULL,
    conservation_status VARCHAR(50) NOT NULL
);

create table sightings(
    sighting_id SERIAL PRIMARY KEY,
    ranger_id int REFERENCES rangers(ranger_id),
    species_id int REFERENCES species(species_id),
    sighting_time TIMESTAMP,
    location VARCHAR(50),
    notes VARCHAR(80)
);

INSERT INTO rangers (ranger_id, name, region) VALUES
(1, 'Alice Green', 'Northern Hills'),
(2, 'Bob White', 'River Delta'),
(3, 'Carol King', 'Mountain Range');

INSERT INTO species (species_id, common_name, scientific_name, discovery_date, conservation_status) VALUES
(1, 'Snow Leopard', 'Panthera uncia', '1775-01-01', 'Endangered'),
(2, 'Bengal Tiger', 'Panthera tigris tigris', '1758-01-01', 'Endangered'),
(3, 'Red Panda', 'Ailurus fulgens', '1825-01-01', 'Vulnerable'),
(4, 'Asiatic Elephant', 'Elephas maximus indicus', '1758-01-01', 'Endangered');

INSERT INTO sightings (sighting_id, species_id, ranger_id, location, sighting_time, notes) VALUES
(1, 1, 1, 'Peak Ridge', '2024-05-10 07:45:00', 'Camera trap image captured'),
(2, 2, 2, 'Bankwood Area', '2024-05-12 16:20:00', 'Juvenile seen'),
(3, 3, 3, 'Bamboo Grove East', '2024-05-15 09:10:00', 'Feeding observed'),
(4, 1, 2, 'Snowfall Pass', '2024-05-18 18:30:00', NULL);


select * from rangers;
select * from species;
select * from sightings;



-- Problem 1
INSERT into rangers(name, region) VALUES('Derek Fox', 'Coastal Plains');

-- got "duplicate key value violates unique constraint" error 
-- to fix the error below code to run at first
SELECT setval(pg_get_serial_sequence('rangers', 'ranger_id'), (SELECT MAX(ranger_id) FROM rangers) + 1);
-- source: https://stackoverflow.com/questions/4448340/postgresql-duplicate-key-violates-unique-constraint


-- Problem 2
select count(*) as unique_species_count  from (select species_id from sightings GROUP BY species_id);

-- Problem 3
select * from sightings where location LIKE '%Pass%';

-- Problem 4
select r.name, count(*) from sightings s join rangers r on r.ranger_id=s.ranger_id GROUP BY r.name ORDER BY r.name ASC;

-- Problem 5
select  common_name from species where species_id not in (select species_id from sightings);

-- Problem 6
select sp.common_name, st.sighting_time, r.name from species sp join sightings st on st.species_id=sp.species_id join rangers r on r.ranger_id = st.ranger_id order by st.sighting_time DESC limit 2 ;

-- Problem 7
update species
    set conservation_status='Historic' where extract(year from discovery_date) < 1800;

-- Problem 8
create or REPLACE function timeOfDay(p_time TIMESTAMP)
returns VARCHAR(20)
AS
$$
    BEGIN
    IF (extract(hour from p_time)<12) THEN return 'Morning';
    ELSIF (extract(hour from p_time)>=12 and extract(hour from p_time)<=17) THEN return 'Afternoon';
    ELSE return 'Evening';
    END IF;
    END;
$$ LANGUAGE PLPGSQL;

select st.sighting_id, timeOfDay(st.sighting_time) as time_of_day from sightings st;

-- Problem 9
delete from rangers where ranger_id not in (select ranger_id from sightings );

