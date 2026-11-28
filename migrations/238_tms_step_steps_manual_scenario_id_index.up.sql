-- ============================================================================
-- TMS STEP SCENARIO INDEX
-- ============================================================================
-- Steps are read by their scenario: test case details, and the search of test cases by
-- instructions and expected result (EPMRPP-123497), which looks up the steps of every
-- test case of the list. Without this index each lookup scans the whole tms_step table.

CREATE INDEX IF NOT EXISTS idx_tms_step_steps_manual_scenario_id ON tms_step (steps_manual_scenario_id);
