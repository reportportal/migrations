ALTER TABLE shareable_entity DROP CONSTRAINT shareable_entity_owner_fkey;
ALTER TABLE shareable_entity ALTER COLUMN owner DROP NOT NULL