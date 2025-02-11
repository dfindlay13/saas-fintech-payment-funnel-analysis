-- Determining max status reached by each subscription
WITH max_status_reached AS (
SELECT
    psl.subscription_id,
    MAX(psl.status_id) AS max_payment_status
FROM
    payment_status_log psl
GROUP BY
    1
ORDER BY
    max_payment_status
)
-- Assigning a funnel status to each subscription based on the following conditions
, funnel_stages AS (
SELECT
    s.subscription_id,
    s.current_payment_status,
    msr.max_payment_status,
    CASE
        WHEN max_payment_status = 1 THEN 'Payment Widget Opened'
        WHEN max_payment_status = 2 THEN 'Payment Entered'
        WHEN max_payment_status = 3 AND current_payment_status = 0 THEN 'User Error with Payment Submission'
        WHEN max_payment_status = 3 AND current_payment_status !=0 THEN 'Payment Submitted'
        WHEN max_payment_status = 4 AND current_payment_status = 0 THEN 'Vendor Payment Processing Error'
        WHEN max_payment_status = 4 AND current_payment_status != 0 THEN 'Payment Sucess with Vendor'
        WHEN max_payment_status = 5 THEN 'Completed Payment'
        WHEN max_payment_status IS NULL THEN 'Process Not Started'
        END AS payment_funnel_stage
FROM
    subscriptions s
    LEFT JOIN max_status_reached msr ON s.subscription_id = msr.subscription_id
)
-- Looking at number of subscriptions by each assigned status to determine areas of fiction and drop off
SELECT
    payment_funnel_stage,
    COUNT(*) AS num_subs,
    (SELECT COUNT(*) FROM subscriptions) AS total_subs, 
    ROUND((num_subs / total_subs) * 100.00, 2) AS pct_of_total_subs
FROM
    funnel_stages
GROUP BY
    1
ORDER BY
    2