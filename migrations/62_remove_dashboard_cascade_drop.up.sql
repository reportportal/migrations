ALTER TABLE owned_entity DROP CONSTRAINT shareable_entity_owner_fkey;
ALTER TABLE owned_entity ALTER COLUMN owner DROP NOT NULL;