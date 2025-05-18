CREATE TABLE IF NOT EXISTS `hotrod_logs` (
  `greptime_timestamp` TIMESTAMP(9) NOT NULL,
  `caller` STRING NULL,
  `file` STRING NULL,
  `host` STRING NULL,
  `level` STRING NULL,
  `msg` STRING FULLTEXT INDEX WITH (
    backend = 'bloom',
    analyzer = 'Chinese',
    case_sensitive = 'false'
  ),
  `source_type` STRING NULL,
  `timestamp` STRING NULL,
  `ts` DOUBLE NULL,
  `address` STRING NULL,
  `service` STRING NULL,
  `type` STRING NULL,
  TIME INDEX (`greptime_timestamp`)
)
ENGINE=mito
WITH(
  append_mode = 'true'
)

