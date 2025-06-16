-- migrate:up
CREATE SEQUENCE IF NOT EXISTS _sequence_serial_seq
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    NO CYCLE;

-- migrate:down
DROP SEQUENCE IF EXISTS _sequence_serial_seq;



