-- Create extensions
CREATE EXTENSION pg_trgm;

-- Create function array to string immutable
CREATE OR REPLACE FUNCTION array_ts(arr TEXT[])
RETURNS TEXT IMMUTABLE LANGUAGE SQL AS $$
SELECT array_to_string(arr, ' ') $$;

-- Create table people
CREATE TABLE IF NOT EXISTS people (
    id UUID PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    nickname VARCHAR(32) UNIQUE NOT NULL,
    birth_date DATE NOT NULL,
    stack TEXT[]
);

-- Create search index
CREATE INDEX people_search_idx ON people 
USING GIST (array_ts(stack || ARRAY[name, nickname]) gist_trgm_ops);
