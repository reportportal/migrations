UPDATE integration_type
SET details = jsonb_set(details, '{details}', details->'details' ||
    jsonb_build_object(
        'fileId', details->'details'->'id',
        'fileName', details->'details'->'name',
        'id', name,
        'name', name
    )
)
WHERE details->'details' ? 'id' AND details->'details' ? 'name';