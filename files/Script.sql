SELECT 
    ROUND((SUM(index_length) / SUM(data_length + index_length)) * 100, 2)
    	AS "Процент индексов от всех таблиц",
    CONCAT(ROUND(SUM(data_length) / 1024 / 1024, 2), ' MB') AS "Размер данных",
    CONCAT(ROUND(SUM(index_length) / 1024 / 1024, 2), ' MB') AS "Размер индексов",
    CONCAT(ROUND(SUM(data_length + index_length) / 1024 / 1024, 2), ' MB') AS "Общий размер данных"
FROM information_schema.TABLES
WHERE table_schema = 'sakila';
















