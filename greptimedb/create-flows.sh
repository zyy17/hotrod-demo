# Calculate total requests, error requests, and average latency for each Service in 1m time window.
mysql -h greptimedb -P 4002 -e "CREATE TABLE IF NOT EXISTS \`__otel_traces_services_red_metrics_1m\` (\
  \`service_name\` STRING NULL,\
  \`total_count\` BIGINT NULL,\
  \`error_count\` BIGINT NULL,\
  \`avg_latency_nano\` DOUBLE NULL,\
  \`time_window_1m\` TIMESTAMP time index,\
  \`update_at\` TIMESTAMP NULL,\
  PRIMARY KEY (\`service_name\`)\
);"

# Create Flow to calculate __otel_traces_services_red_metrics_1m based on opentelemetry_traces.
mysql -h greptimedb -P 4002 -e "CREATE FLOW IF NOT EXISTS \`__otel_traces_services_red_metrics_1m_aggregation\` \
SINK TO \`__otel_traces_services_red_metrics_1m\` \
COMMENT 'Calculate RED metrics for each service in 1 minute time window.' \
AS \
SELECT \
    \`service_name\`, \
    count(*) as \`total_count\`, \
    sum(case when \`span_status_code\` = 'STATUS_CODE_ERROR' then 1 else 0 end) as \`error_count\`, \
    avg(\`duration_nano\`) as \`avg_latency_nano\`, \
    date_bin('1 minutes'::INTERVAL, \`timestamp\`, '2025-05-17 00:00:00') as \`time_window_1m\` \
FROM \`opentelemetry_traces\` \
GROUP BY \`service_name\`, \`time_window_1m\`;"

# Calculate total requests, error requests, and average latency for each Service in 1h time window.
mysql -h greptimedb -P 4002 -e "CREATE TABLE IF NOT EXISTS \`__otel_traces_services_red_metrics_1h\` (\
  \`service_name\` STRING NULL,\
  \`total_count\` BIGINT NULL,\
  \`error_count\` BIGINT NULL,\
  \`avg_latency_nano\` DOUBLE NULL,\
  \`time_window_1h\` TIMESTAMP time index,\
  \`update_at\` TIMESTAMP NULL,\
  PRIMARY KEY (\`service_name\`)\
);"

# Create Flow to calculate __otel_traces_services_red_metrics_1h based on __otel_traces_services_red_metrics_1m.
mysql -h greptimedb -P 4002 -e "CREATE FLOW IF NOT EXISTS \`__otel_traces_services_red_metrics_1h_aggregation\` \
SINK TO \`__otel_traces_services_red_metrics_1h\` \
COMMENT 'Calculate RED metrics for each service in 1 hour time window.' \
AS \
SELECT \
    \`service_name\`, \
    sum(\`total_count\`) as \`total_count\`, \
    sum(\`error_count\`) as \`error_count\`, \
    avg(\`avg_latency_nano\`) as \`avg_latency_nano\`, \
    date_bin('1 hour'::INTERVAL, \`time_window_1m\`, '2025-05-17 00:00:00') as \`time_window_1h\` \
FROM \`__otel_traces_services_red_metrics_1m\` \
GROUP BY \`service_name\`, \`time_window_1h\`;"

# Calculate total requests, error requests, and average latency for each Span in 1m time window.
mysql -h greptimedb -P 4002 -e "CREATE TABLE IF NOT EXISTS \`__otel_traces_spans_red_metrics_1m\` (\
  \`service_name\` STRING NULL,\
  \`span_name\` STRING NULL,\
  \`span_kind\` STRING NULL,\
  \`total_count\` BIGINT NULL,\
  \`error_count\` BIGINT NULL,\
  \`avg_latency_nano\` DOUBLE NULL,\
  \`time_window_1m\` TIMESTAMP time index,\
  \`update_at\` TIMESTAMP NULL,\
  PRIMARY KEY (\`service_name\`)\
);"

# Create Flow to calculate __otel_traces_spans_red_metrics_1m based on opentelemetry_traces.
mysql -h greptimedb -P 4002 -e "CREATE FLOW IF NOT EXISTS \`__otel_traces_spans_red_metrics_1m_aggregation\` \
SINK TO \`__otel_traces_spans_red_metrics_1m\` \
COMMENT 'Calculate RED metrics for each span in 1 minute time window.' \
AS \
SELECT \
    \`service_name\`, \
    \`span_name\`, \
    \`span_kind\`, \
    count(*) as \`total_count\`, \
    sum(case when \`span_status_code\` = 'STATUS_CODE_ERROR' then 1 else 0 end) as \`error_count\`, \
    avg(\`duration_nano\`) as \`avg_latency_nano\`, \
    date_bin('1 minutes'::INTERVAL, \`timestamp\`, '2025-05-17 00:00:00') as \`time_window_1m\` \
FROM \`opentelemetry_traces\` \
GROUP BY \`service_name\`, \`span_name\`, \`span_kind\`, \`time_window_1m\`;"

# Calculate total requests, error requests, and average latency for each Span in 1h time window.
mysql -h greptimedb -P 4002 -e "CREATE TABLE IF NOT EXISTS \`__otel_traces_spans_red_metrics_1h\` (\
  \`service_name\` STRING NULL,\
  \`span_name\` STRING NULL,\
  \`span_kind\` STRING NULL,\
  \`total_count\` BIGINT NULL,\
  \`error_count\` BIGINT NULL,\
  \`avg_latency_nano\` DOUBLE NULL,\
  \`time_window_1h\` TIMESTAMP time index,\
  \`update_at\` TIMESTAMP NULL,\
  PRIMARY KEY (\`service_name\`)\
);"

# Create Flow to calculate __otel_traces_spans_red_metrics_1h based on __otel_traces_spans_red_metrics_1m.
mysql -h greptimedb -P 4002 -e "CREATE FLOW IF NOT EXISTS \`__otel_traces_spans_red_metrics_1h_aggregation\` \
SINK TO \`__otel_traces_spans_red_metrics_1h\` \
COMMENT 'Calculate RED metrics for each span in 1 hour time window.' \
AS \
SELECT \
    \`service_name\`, \
    \`span_name\`, \
    \`span_kind\`, \
    sum(\`total_count\`) as \`total_count\`, \
    sum(\`error_count\`) as \`error_count\`, \
    avg(\`avg_latency_nano\`) as \`avg_latency_nano\`, \
    date_bin('1 hour'::INTERVAL, \`time_window_1m\`, '2025-05-17 00:00:00') as \`time_window_1h\` \
FROM \`__otel_traces_spans_red_metrics_1m\` \
GROUP BY \`service_name\`, \`span_name\`, \`span_kind\`, \`time_window_1h\`;"

# Aggregate dependencies between Services.
mysql -h greptimedb -P 4002 -e "CREATE TABLE IF NOT EXISTS \`__otel_traces_dependencies_1h\` (\
  \`parent_service\` STRING NULL,\
  \`child_service\` STRING NULL,\
  \`call_count\` BIGINT NULL,\
  \`time_window_1h\` TIMESTAMP time index,\
  \`update_at\` TIMESTAMP NULL,\
  PRIMARY KEY (\`parent_service\`, \`child_service\`)\
);"

# Create Flow to calculate traces_dependencies_1h.
mysql -h greptimedb -P 4002 -e "CREATE FLOW IF NOT EXISTS \`__otel_traces_dependencies_1h_aggregation\` \
SINK TO \`__otel_traces_dependencies_1h\` \
COMMENT 'Calculate dependencies between services in 1 hour time window.' \
AS \
SELECT \
    \`parent\`.\`service_name\` AS \`parent_service\`, \
    \`child\`.\`service_name\` AS \`child_service\`, \
    COUNT(*) AS \`call_count\`, \
    date_bin('1 hour'::INTERVAL, \`parent\`.\`timestamp\`, '2025-05-17 00:00:00') as \`time_window_1h\` \
FROM \`opentelemetry_traces\` AS \`child\` \
JOIN \`opentelemetry_traces\` AS \`parent\` ON \`child\`.\`parent_span_id\` = \`parent\`.\`span_id\` \
WHERE \`parent\`.\`service_name\` != \`child\`.\`service_name\` \
GROUP BY \`parent_service\`, \`child_service\`, \`time_window_1h\`;"
