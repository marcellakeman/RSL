-- This code is written by Marcel Lakeman 500694128

pwd
ls
mkdir RSL
cd RSL
psql test

-- Create table
CREATE TABLE movies(
url text,
title text,
ReleaseDate text,
Distributor text,
Starring text,
Summary text,
Director text,
Genre text,
Rating text,
Runtime text,
Userscore text,
Metascore text,
scoreCounts text
);

-- Copy data
\copy movies FROM '/home/pi/RSL/moviesFromMetacritic.csv' delimiter ';' csv header;

SELECT * FROM movies where url='interstellar';

-- Add TS vector
ALTER TABLE movies
ADD lexemesStarring tsvector;

UPDATE movies
SET lexemesStarring = to_tsvector(Starring);

-- Select movies with Matthew Mcconaughey
SELECT url FROM movies
WHERE lexemesStarring @@ to_tsquery('mcconaughey');

ALTER TABLE movies
ADD rank float4;

-- Select Actors from interstellar
UPDATE movies
SET rank = ts_rank(to_tsvector(Starring), plainto_tsquery(
(
SELECT Starring FROM movies WHERE url='interstellar'
)
));

-- Create table with recommendations
CREATE TABLE IF NOT EXISTS recommendationsBasedonStarringFieldInterstellar AS
SELECT url, rank FROM movies WHERE rank > 0.001 ORDER BY rank DESC LIMIT 50;

-- Copy recommendations into a csv file
\copy (SELECT * FROM recommendationsBasedonStarringFieldInterstellar) to '/home/pi/RSL/top50recommendationsInterstellarStarring.csv' WITH csv;

















