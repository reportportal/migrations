ALTER TABLE sender_case
    ADD rule_name TEXT;

UPDATE sender_case SET rule_name = 'rule #' || id;

CREATE UNIQUE INDEX sender_case_rule_name_uindex
    ON sender_case (rule_name);

