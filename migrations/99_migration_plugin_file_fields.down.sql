UPDATE integration_type
SET details = jsonb_set(details, '{details}', details->'details' ||
    jsonb_build_object(
        'id', details->'details'->'fileId',
        'name', details->'details'->'fileName'
    )
)
WHERE details->'details' ? 'fileId' AND details->'details' ? 'fileName';

UPDATE integration_type
SET details = jsonb_set(details, '{details}', (details->'details') - 'fileId' - 'fileName')
WHERE details->'details' ? 'fileId' AND details->'details' ? 'fileName';