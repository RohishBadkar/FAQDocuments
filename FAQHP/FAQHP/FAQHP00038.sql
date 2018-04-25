select count(*) from (SELECT
  ccs.chem_substance_id     AS chemicalSubstanceId
 ,ccs.trade_name            AS chemicalTradeName
 ,ccs.CAS_reference         AS casReference
 ,ccs.is_pure               AS isPure
 ,ccs.max_conc              AS maxConc
 ,ccs.min_conc              AS minConc
 ,ccs.is_mix                AS isMix
 ,icpca.product_category_id AS productCategiryId
 ,ccs.is_deleted            AS isDeleted
 ,ccs.active                AS active
 ,NULL AS btddId             
 ,NULL AS productGroupId
 ,NULL AS productCategoryId
 ,NULL AS EN_Certified
 ,NULL AS ASTM_Certified
 ,NULL AS EN_Color
 ,NULL AS ASTM_Color
 ,NULL AS EN_btddLevel
 ,NULL AS ASTM_btddLevel
 ,NULL AS EN_btdd_level_id
 ,NULL AS ASTM_btdd_level_id
 ,NULL AS EN_Range
 ,NULL AS ASTM_Range
 ,NULL AS EN_Minutes
 ,NULL AS ASTM_Minutes
 ,NULL AS EN_RangeAndMinute
 ,NULL AS ASTM_RangeAndMinute
 ,NULL AS EN_Degradation_Scale
 ,NULL AS ASTM_Degradation_Scale
 ,NULL AS EN_Degradation_Desc
 ,NULL AS ASTM_Degradation_Desc
 ,NULL AS EN_Comments
 ,NULL AS ASTM_Comments
 FROM
  crms_chemical_substance  AS ccs
  INNER JOIN int_chemical_product_category_association AS icpca
    ON icpca.chem_substance_id = ccs.chem_substance_id
 WHERE
  ccs.is_deleted = 0 AND
  ccs.active = 'A' AND
  icpca.is_deleted = 0 AND
  ccs.is_approved = 1 AND
  ccs.chem_substance_id NOT IN
    (SELECT
      cbtdd.chem_substance_id
     FROM
      crms_btdd AS cbtdd
     WHERE
      cbtdd.product_group_id = 'db6365a3-68c4-11e7-b88c-000d3a173cc5'
     GROUP BY
      cbtdd.chem_substance_id)
 GROUP BY
  ccs.chem_substance_id
--   ORDER BY ccs.is_mix DESC,ccs.CAS_reference ASC,ccs.trade_name ASC)
UNION
(SELECT
  ccs.chem_substance_id                    AS chemicalSubstanceId
 ,ccs.trade_name                           AS chemicalTradeName
 ,ccs.CAS_reference                        AS casReference
 ,ccs.is_pure                              AS isPure
 ,ccs.max_conc                             AS maxConc
 ,ccs.min_conc                             AS minConc
 ,ccs.is_mix                               AS isMix
 ,icpca.product_category_id                AS productCategiryId
 ,ccs.is_deleted                           AS isDeleted
 ,ccs.active                               AS active
 ,cbtdd.btdd_id                            AS btddId
 ,cbtdd.product_group_id                   AS productGroupId
 ,cbtdd.product_category_id                AS productCategoryId
 ,GROUP_CONCAT(
    CASE
      WHEN (crmsstandard1.standard_id = 1) THEN cbtdd.is_certified
      ELSE NULL
    END)
    AS EN_Certified
 ,GROUP_CONCAT(
    CASE
      WHEN (crmsstandard2.standard_id = 2) THEN cbtdd.is_certified
      ELSE NULL
    END)
    AS ASTM_Certified
 ,GROUP_CONCAT(cbtddlevel1.op_color_code)  AS EN_Color
 ,GROUP_CONCAT(cbtddlevel2.op_color_code)  AS ASTM_Color
 ,GROUP_CONCAT(cbtddlevel1.level)          AS EN_btddLevel
 ,GROUP_CONCAT(cbtddlevel2.level)          AS ASTM_btddLevel
 ,GROUP_CONCAT(cbtddlevel1.btdd_level_id)  AS EN_btdd_level_id
 ,GROUP_CONCAT(cbtddlevel2.btdd_level_id)  AS ASTM_btdd_level_id
 ,GROUP_CONCAT(
    CASE
      WHEN (crmsstandard1.standard_id = 1) THEN cbtdd.btt_range
      ELSE NULL
    END)
    AS EN_Range
 ,GROUP_CONCAT(
    CASE
      WHEN (crmsstandard2.standard_id = 2) THEN cbtdd.btt_range
      ELSE NULL
    END)
    AS ASTM_Range
 ,GROUP_CONCAT(
    CASE
      WHEN (crmsstandard1.standard_id = 1) THEN cbtdd.bt_minutes
      ELSE NULL
    END)
    AS EN_Minutes
 ,GROUP_CONCAT(
    CASE
      WHEN (crmsstandard2.standard_id = 2) THEN cbtdd.bt_minutes
      ELSE NULL
    END)
    AS ASTM_Minutes
 ,GROUP_CONCAT(
    CASE
      WHEN (crmsstandard1.standard_id = 1 AND
            cbtdd.is_certified = 1)
      THEN
        concat(
          cbtdd.btt_range
         ,cbtdd.bt_minutes)
      WHEN (crmsstandard1.standard_id = 1 AND
            cbtdd.is_certified = 0)
      THEN
        cbtddlevel1.description
      ELSE
        NULL
    END)
    AS EN_RangeAndMinute
 ,GROUP_CONCAT(
    CASE
      WHEN (crmsstandard2.standard_id = 2 AND
            cbtdd.is_certified = 1)
      THEN
        concat(
          cbtdd.btt_range
         ,cbtdd.bt_minutes)
      WHEN (crmsstandard2.standard_id = 2 AND
            cbtdd.is_certified = 0)
      THEN
        cbtddlevel2.description
      ELSE
        NULL
    END)
    AS ASTM_RangeAndMinute
 ,GROUP_CONCAT(cdsi18n.degradation_scale)  AS EN_Degradation_Scale
 ,GROUP_CONCAT(cdsi18n2.degradation_scale) AS ASTM_Degradation_Scale
 ,GROUP_CONCAT(cdsi18n.description)        AS EN_Degradation_Desc
 ,GROUP_CONCAT(cdsi18n2.description)       AS ASTM_Degradation_Desc
 ,GROUP_CONCAT(
    CASE WHEN (crmsstandard1.standard_id = 1) THEN cbtdd.comment ELSE NULL END)
    AS EN_Comments
 ,GROUP_CONCAT(
    CASE WHEN (crmsstandard2.standard_id = 2) THEN cbtdd.comment ELSE NULL END)
    AS ASTM_Comments
 FROM
  crms_chemical_substance  AS ccs
  INNER JOIN int_chemical_product_category_association icpca
    ON icpca.chem_substance_id = ccs.chem_substance_id
  INNER JOIN crms_btdd cbtdd
    ON cbtdd.chem_substance_id = ccs.chem_substance_id AND
       cbtdd.product_group_id = 'db6365a3-68c4-11e7-b88c-000d3a173cc5'
  LEFT OUTER JOIN crms_standard AS crmsstandard1
    ON cbtdd.standard_id = crmsstandard1.standard_id AND
       crmsstandard1.standard_id = 1
  LEFT OUTER JOIN crms_standard AS crmsstandard2
    ON cbtdd.standard_id = crmsstandard2.standard_id AND
       crmsstandard2.standard_id = 2
  LEFT OUTER JOIN crms_btdd_level AS cbtddlevel1
    ON cbtdd.btdd_level_id = cbtddlevel1.btdd_level_id AND
       crmsstandard1.standard_id = 1
  LEFT OUTER JOIN crms_btdd_level AS cbtddlevel2
    ON cbtdd.btdd_level_id = cbtddlevel2.btdd_level_id AND
       crmsstandard2.standard_id = 2
  LEFT OUTER JOIN crms_degradation_i18n AS cdsi18n
    ON cbtdd.degradation_scale = cdsi18n.degradation_scale AND
       crmsstandard1.standard_id = 1
  LEFT OUTER JOIN crms_degradation_i18n AS cdsi18n2
    ON cbtdd.degradation_scale = cdsi18n2.degradation_scale AND
       crmsstandard2.standard_id = 2
 WHERE
  ccs.is_deleted = 0 AND
  ccs.active = 'A' AND
  icpca.is_deleted = 0 AND
  ccs.is_approved = 1
 GROUP BY
  ccs.chem_substance_id
 HAVING
  (EN_Certified IN (0) OR
   ASTM_Certified IN (0) OR
   EN_Certified IS NULL OR
   ASTM_Certified IS NULL)))as a 
  --  ORDER BY ccs.is_mix DESC,ccs.CAS_reference ASC,ccs.trade_name ASC
  -- ORDER BY ccs.is_mix DESC,ccs.CAS_reference ASC,ccs.trade_name ASC
 -- ORDER BY isMix DESC,casReference ASC, chemicalTradeName ASC limit 0,10;