-- This code is written by Marcel Lakeman 500694128

-- pwd
-- ls
-- mkdir RSL
-- cd RSL
-- psql test

-- Create table
CREATE TABLE IF NOT EXISTS movies(
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

SELECT * FROM movies where url='the-lord-of-the-rings-the-return-of-the-king';

-- Add TS vector
ALTER TABLE movies
ADD IF NOT EXISTS lexemesStarring tsvector;

UPDATE movies
SET lexemesStarring = to_tsvector(Starring);

-- Select movies with Ian Mckellen
SELECT url FROM movies
WHERE lexemesStarring @@ to_tsquery('mckellen');

ALTER TABLE movies
ADD IF NOT EXISTS rank float4;

-- Select Actors from LOTR
UPDATE movies
SET rank = ts_rank(to_tsvector(Starring), plainto_tsquery(
(
SELECT Starring FROM movies WHERE url='the-lord-of-the-rings-the-return-of-the-king'
)
));

-- Create table with recommendations
CREATE TABLE IF NOT EXISTS recommendationsBasedonStarringFieldLOTR AS
SELECT url, rank FROM movies WHERE rank > 0 ORDER BY rank DESC LIMIT 50;

-- Copy recommendations into a csv file
\copy (SELECT * FROM recommendationsBasedonStarringFieldLOTR) to '/home/pi/RSL/top50recommendationsLOTRStarring.csv' WITH csv;

















