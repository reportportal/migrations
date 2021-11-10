CREATE OR REPLACE FUNCTION migrate_bug_trend_fields() RETURNS VOID AS
$$
DECLARE
    widget_id BIGINT;
BEGIN

    DELETE FROM content_field WHERE id IN (SELECT id FROM widget WHERE widget_type = 'bugTrend');

    FOR widget_id IN
        (SELECT id
         FROM widget
         WHERE widget_type = 'bugTrend')
        LOOP
            INSERT INTO content_field (id, field) VALUES (widget_id, 'statistics$defects$automation_bug$total');
            INSERT INTO content_field (id, field) VALUES (widget_id, 'statistics$defects$product_bug$total');
            INSERT INTO content_field (id, field) VALUES (widget_id, 'statistics$defects$system_issue$total');
            INSERT INTO content_field (id, field) VALUES (widget_id, 'statistics$defects$to_investigate$total');
            INSERT INTO content_field (id, field) VALUES (widget_id, 'statistics$defects$no_defect$total');
        END LOOP;
END;
$$
    LANGUAGE plpgsql;

SELECT migrate_bug_trend_fields();

DROP FUNCTION IF EXISTS migrate_bug_trend_fields();