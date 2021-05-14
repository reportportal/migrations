DROP PROCEDURE IF EXISTS fill_attachment_creation_date();
ALTER TABLE attachment DROP COLUMN creation_date;
