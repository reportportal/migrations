-- Step 1: Add the column if it does not exist (initially nullable)
ALTER TABLE launch
    ADD COLUMN IF NOT EXISTS organization_id BIGINT;

-- Step 2: Populate organization_id from project table
UPDATE launch
SET organization_id = project.organization_id
FROM project
WHERE launch.project_id = project.id;

-- Step 3: Set the column to NOT NULL (after data is populated)
ALTER TABLE launch
    ALTER COLUMN organization_id SET NOT NULL;

-- Step 4: Add the foreign key constraint
ALTER TABLE launch
    ADD CONSTRAINT fk_launch_organization
        FOREIGN KEY (organization_id)
            REFERENCES organization (id)
            ON DELETE CASCADE;

-- Step 5: Add index for performance optimization
CREATE INDEX IF NOT EXISTS idx_launch_organization_id
    ON launch (organization_id);
