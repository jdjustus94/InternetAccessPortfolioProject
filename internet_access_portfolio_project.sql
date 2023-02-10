--Users Daily Internet Usage Time
SELECT UPPER(name) AS name, DATE_TRUNC('day', start_time) AS day, usage_time, 
SUM(usage_time) OVER(PARTITION BY DATE_TRUNC('day', start_time), name ORDER BY name ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS total_usage_time
FROM internet_access
ORDER BY day;
--User Time of Day Usage
WITH A AS
(SELECT name, start_time, 
(SELECT CASE WHEN DATE_TRUNC('hour', start_time)::time >= '00:00:00' 
AND DATE_TRUNC('hour', start_time)::time < '06:00:00' THEN 'night'
WHEN DATE_TRUNC('hour', start_time)::time >= '06:00:00'
AND DATE_TRUNC('hour', start_time)::time < '12:00:00' THEN 'morning' 
WHEN DATE_TRUNC('hour', start_time)::time >= '12:00:00'
AND DATE_TRUNC('hour', start_time):: time < '18:00:00' THEN 'afternoon'
WHEN DATE_TRUNC('hour', start_time)::time >= '18:00:00'
AND DATE_TRUNC('hour', start_time)::time < '23:59:59' THEN 'evening' END) AS time_of_day
FROM internet_access)

SELECT DISTINCT name, SUM((SELECT CASE WHEN time_of_day = 'night' THEN 1 ELSE 0 END)) AS night_use,
SUM((SELECT CASE WHEN time_of_day = 'morning' THEN 1 ELSE 0 END)) AS morning_use,
SUM((SELECT CASE WHEN time_of_day = 'afternoon' THEN 1 ELSE 0 END)) AS afternoon_use,
SUM((SELECT CASE WHEN time_of_day = 'evening' THEN 1 ELSE 0 END)) AS evening_use
FROM A
GROUP BY 1
ORDER BY 1;

--User Percentage of Session Breaks
SELECT name, ROUND((SUM(CASE WHEN session_break_reason = 'Lost-Service' THEN 1 ELSE 0 END)::numeric/COUNT(*)*100.0),2) AS lost_ser_perc,
ROUND((SUM(CASE WHEN session_break_reason = null THEN 1 ELSE 0 END)::NUMERIC/COUNT(*)*100.0),2) AS null_reason_perc,
ROUND((SUM(CASE WHEN session_break_reason = 'Idle-Timeout' THEN 1 ELSE 0 END)::NUMERIC/COUNT(*)*100.0),2) AS idle_timeout_perc,
ROUND((SUM(CASE WHEN session_break_reason = 'NAS-Reboot' THEN 1 ELSE 0 END)::NUMERIC/COUNT(*)*100.0),2) AS nas_reboot_perc,
ROUND((SUM(CASE WHEN session_break_reason = 'User-Request' THEN 1 ELSE 0 END)::NUMERIC/COUNT(*)*100.0),2) AS user_req_perc,
ROUND((SUM(CASE WHEN session_break_reason = 'Lost-Carrier' THEN 1 ELSE 0 END)::NUMERIC/COUNT(*)*100.0),2) AS lost_carrier_perc
FROM internet_access
GROUP BY 1
ORDER BY 1;

--User MAC address max and min upload/download speeds
SELECT DISTINCT name, mac_address, MAX(upload) AS max_upload, MAX(download) AS max_download, MIN(upload) AS min_upload,
MIN(download) AS min_download
FROM internet_access
GROUP BY 1,2
ORDER BY 1 ASC, max_upload DESC, max_download DESC;
