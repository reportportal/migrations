-- Removes the unit key of the stage trace events.
ALTER TABLE pipeline_stage_trace_event DROP COLUMN IF EXISTS unit_key;
