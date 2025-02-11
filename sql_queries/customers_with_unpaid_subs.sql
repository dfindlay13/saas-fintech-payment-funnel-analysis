---Gathering customers with unpaid subs for outreach
WITH unpaid_subs AS (
SELECT
    s.customer_id,
    s.subscription_id,
    s.current_payment_status
FROM
    public.subscriptions s
    LEFT JOIN payment_status_log psl ON s.subscription_id = psl.subscription_id
WHERE
    psl.subscription_id IS NULL -- anti join
)

/*
Joining customer_ids with unpaid subs with their phone information, 
number of unpaid subs on their customer account, and a list of the unpaid subscription ids
*/ 

SELECT
    c.customer_id,
    c.customer_name,
    c.phone AS customer_phone,
    COUNT(us.subscription_id) AS num_unpaid_subs,
    LISTAGG(us.subscription_id, ', ') AS unpaid_sub_ids
FROM 
    public.customers c 
    INNER JOIN unpaid_subs us ON c.customer_id = us.customer_id 
GROUP BY
    1,2,3