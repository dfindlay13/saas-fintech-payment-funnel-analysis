-- Data Familiarization / EDA - Looking at singular subscription and payment funnel flow
SELECT
    *
FROM
    payment_status_log psl
    INNER JOIN payment_status_definitions psd ON psl.status_id = psd.status_id
WHERE
    subscription_id = '38499' -- Example of an error happening with vendor - payment status max is 4 and then at 0
ORDER BY
    subscription_id, movement_date