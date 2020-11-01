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

SELECT url FROM movies where url LIKE '%the-lord-of-the-rings%';

-- Add TS vector
ALTER TABLE movies
ADD IF NOT EXISTS lexemestitle tsvector;

UPDATE movies
SET lexemestitle = to_tsvector(title);

-- Select movies with url The Lord of the Rings
SELECT url FROM movies
WHERE lexemestitle @@ to_tsquery('the-lord-of-the-rings');

ALTER TABLE movies
ADD IF NOT EXISTS rank float4;

UPDATE movies
SET rank = ts_rank(to_tsvector(title), plainto_tsquery(
(
SELECT title FROM movies WHERE url = 'the-lord-of-the-rings-the-return-of-the-king'
)
));

-- Create table with recommendations
CREATE TABLE IF NOT EXISTS recommendationsBasedonTitleFieldLOTR3 AS
SELECT url, rank FROM movies WHERE rank > 0 ORDER BY rank DESC LIMIT 50;

-- Copy recommendations into a csv file
\copy (SELECT * FROM recommendationsBasedonTitleFieldLOTR3) to '/home/pi/RSL/top50recommendationsLOTR3Title.csv' WITH csv;

















