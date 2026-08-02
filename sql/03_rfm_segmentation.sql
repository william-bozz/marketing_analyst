WITH rfm_scores AS (
    SELECT 
        id,
        NTILE(4) OVER (ORDER BY recency DESC) AS r_score,
        NTILE(4) OVER (ORDER BY (num_deals_purchases + num_web_purchases + num_catalog_purchases + num_store_purchases) ASC) AS f_score,
        NTILE(4) OVER (ORDER BY (mnt_wines + mnt_fruits + mnt_meat_products + mnt_fish_products + mnt_sweet_products + mnt_gold_prods) ASC) AS m_score
    FROM customers
),
rfm_final AS (
    SELECT 
        id,
        ROUND((r_score + f_score + m_score) / 3.0, 2) AS rfm_promedio
    FROM rfm_scores
),
rfm_segmentado AS (
    SELECT 
        id,
        rfm_promedio,
        CASE
            WHEN rfm_promedio >= 3.34 THEN 'Campeón'
            WHEN rfm_promedio >= 2.67 THEN 'Cliente leal'
            WHEN rfm_promedio >= 2.0  THEN 'Necesita atención'
            WHEN rfm_promedio >= 1.34 THEN 'En riesgo'
            ELSE 'Perdido'
        END AS segmento
    FROM rfm_final
)
SELECT 
    segmento,
    COUNT(*) AS total_clientes,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS porcentaje
FROM rfm_segmentado
GROUP BY segmento
ORDER BY total_clientes DESC;
