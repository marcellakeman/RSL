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
ADD lexemesSummary tsvector;

UPDATE movies
SET lexemesSummary = to_tsvector(Summary);

-- Select movies with url Interstellar
SELECT url FROM movies
WHERE lexemesSummary @@ to_tsquery('interstellar');

ALTER TABLE movies
ADD rank float4;

UPDATE movies
SET rank = ts_rank(to_tsvector(Summary), plainto_tsquery(
(
SELECT Summary FROM movies WHERE url='interstellar'
)
));

-- Create table with recommendations
CREATE TABLE IF NOT EXISTS recommendationsBasedonSummaryFieldInterstellar AS
SELECT url, rank FROM movies WHERE rank > 0.6 ORDER BY rank DESC LIMIT 50;

-- Copy recommendations into a csv file
\copy (SELECT * FROM recommendationsBasedonSummaryFieldInterstellar) to '/home/pi/RSL/top50recommendationsInterstellarSummary.csv' WITH csv;

















