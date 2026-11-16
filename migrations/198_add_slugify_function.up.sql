-- Create slugify function for migration purposes
CREATE EXTENSION IF NOT EXISTS "unaccent";

CREATE OR REPLACE FUNCTION slugify("value" TEXT, allow_underscore boolean)
    RETURNS TEXT AS
$$
WITH "unaccented" AS (SELECT unaccent("value") AS "value"),
     "lowercase" AS (SELECT lower("value") AS "value" FROM "unaccented"),
     "hyphenated" AS (SELECT regexp_replace("value",
                                            CASE
                                                WHEN allow_underscore THEN '[^a-z0-9\\-_]+'
                                                ELSE '[^a-z0-9\\-]+'
                                                END,
                                            '-',
                                            'gi') AS "value"
                      FROM "lowercase"),
     "trimmed"
         AS (SELECT regexp_replace(regexp_replace("value", '\\-+$', ''), '^\\-', '') AS "value"
             FROM "hyphenated")
SELECT "value"
FROM "trimmed";
$$ LANGUAGE SQL STRICT IMMUTABLE;
