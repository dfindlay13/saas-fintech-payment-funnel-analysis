-- Data Familiarization with payment status logs and status definitions
SELECT
    *
FROM
    payment_status_log psl
    INNER JOIN payment_status_definitions psd ON psl.status_id = psd.status_id
ORDER BY
    subscription_id, movement_date