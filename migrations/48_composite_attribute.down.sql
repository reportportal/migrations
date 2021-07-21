UPDATE filter_condition
SET value           = REPLACE(value, ':', ''),
    search_criteria = 'attributeKey'
WHERE search_criteria = 'compositeAttribute' and value like '%:%';

UPDATE filter_condition
SET search_criteria = 'attributeValue'
WHERE search_criteria = 'compositeAttribute';