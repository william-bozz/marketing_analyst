SELECT 
    'Campaña 1' AS campana, ROUND(100.0 * AVG(accepted_cmp1), 1) AS tasa_aceptacion FROM customers
UNION ALL
SELECT 
    'Campaña 2', ROUND(100.0 * AVG(accepted_cmp2), 1) FROM customers
UNION ALL
SELECT 
    'Campaña 3', ROUND(100.0 * AVG(accepted_cmp3), 1) FROM customers
UNION ALL
SELECT 
    'Campaña 4', ROUND(100.0 * AVG(accepted_cmp4), 1) FROM customers
UNION ALL
SELECT 
    'Campaña 5', ROUND(100.0 * AVG(accepted_cmp5), 1) FROM customers
UNION ALL
SELECT 
    'Campaña actual (Response)', ROUND(100.0 * AVG(response), 1) FROM customers
ORDER BY tasa_aceptacion DESC;

WITH rfm_scores AS (
    SELECT 
        id,
        NTILE(4) OVER (ORDER BY recency DESC) AS r_score,
        NTILE(4) OVER (ORDER BY (num_deals_purchases + num_web_purchases + num_catalog_purchases + num_store_purchases) ASC) AS f_score,
        NTILE(4) OVER (ORDER BY (mnt_wines + mnt_fruits + mnt_meat_products + mnt_fish_products + mnt_sweet_products + mnt_gold_prods) ASC) AS m_score
    FROM customers
),
rfm_segmentado AS (
    SELECT 
        id,
        CASE
            WHEN ROUND((r_score + f_score + m_score) / 3.0, 2) >= 3.34 THEN 'Campeón'
            WHEN ROUND((r_score + f_score + m_score) / 3.0, 2) >= 2.67 THEN 'Cliente leal'
            WHEN ROUND((r_score + f_score + m_score) / 3.0, 2) >= 2.0  THEN 'Necesita atención'
            WHEN ROUND((r_score + f_score + m_score) / 3.0, 2) >= 1.34 THEN 'En riesgo'
            ELSE 'Perdido'
        END AS segmento
    FROM rfm_scores
)
SELECT 
    r.segmento,
    COUNT(*) AS total_clientes,
    ROUND(100.0 * AVG(c.response), 1) AS tasa_aceptacion_campana_actual
FROM rfm_segmentado r
JOIN customers c ON r.id = c.id
GROUP BY r.segmento
ORDER BY tasa_aceptacion_campana_actual DESC;
