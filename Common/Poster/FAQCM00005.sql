SELECT
   ccs.chem_substance_id                   AS chemicalSubstanceId
  ,ccs.trade_name                          AS chemicalTradeName
  ,ccs.CAS_reference                       AS casReference
  ,ccs.is_pure                             AS isPure
  ,ccs.min_conc                            AS minConc
  ,max_conc                                AS maxConc
  ,is_mix                                  AS isMix
  ,is_bp_chemical                          AS isBpChemical
  ,cbtdd.btdd_id                           AS btddId
  ,cbtdd.product_group_id                  AS productGroupId
  ,cbtdd.product_category_id               AS productCategoryId
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
  ,GROUP_CONCAT(cbtddlevel1.op_color_code) AS EN_Color
  ,GROUP_CONCAT(cbtddlevel2.op_color_code) AS ASTM_Color
  ,GROUP_CONCAT(cbtddlevel1.btdd_level_id) AS EN_btddLevel
  ,GROUP_CONCAT(cbtddlevel2.btdd_level_id) AS ASTM_btddLevel
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
  ,GROUP_CONCAT(cdsi18n.description)       AS EN_Degradation
  ,GROUP_CONCAT(cdsi18n2.description)      AS ASTM_Degradation
  ,GROUP_CONCAT(
     CASE WHEN (crmsstandard1.standard_id = 1) THEN cbtdd.comment ELSE NULL END)
     AS EN_Comments
  ,GROUP_CONCAT(
     CASE WHEN (crmsstandard2.standard_id = 2) THEN cbtdd.comment ELSE NULL END)
     AS ASTM_Comments
  FROM
   crms_chemical_substance  ccs
   LEFT JOIN crms_btdd cbtdd
     ON cbtdd.chem_substance_id = ccs.chem_substance_id AND
        cbtdd.product_group_id = 'db6365a3-68c4-11e7-b88c-000d3a173cc5' AND
        cbtdd.product_category_id = 2  
   LEFT JOIN crms_standard AS crmsstandard1
     ON cbtdd.standard_id = crmsstandard1.standard_id AND
        crmsstandard1.standard_id = 1
   LEFT JOIN crms_standard AS crmsstandard2
     ON cbtdd.standard_id = crmsstandard2.standard_id AND
        crmsstandard2.standard_id = 2
   LEFT JOIN crms_btdd_level AS cbtddlevel1
     ON cbtdd.btdd_level_id = cbtddlevel1.btdd_level_id AND
        crmsstandard1.standard_id = 1
   LEFT JOIN crms_btdd_level AS cbtddlevel2
     ON cbtdd.btdd_level_id = cbtddlevel2.btdd_level_id AND
        crmsstandard2.standard_id = 2
   LEFT JOIN crms_degradation_i18n AS cdsi18n
     ON cbtdd.degradation_scale = cdsi18n.degradation_scale AND
        crmsstandard1.standard_id = 1
   LEFT JOIN crms_degradation_i18n AS cdsi18n2
     ON cbtdd.degradation_scale = cdsi18n2.degradation_scale AND
        crmsstandard2.standard_id = 2
  WHERE
   ccs.is_deleted = 0 AND
   ccs.active = 'A'
  GROUP BY
   ccs.chem_substance_id;
   
   
   
   call search_by_products_bpChemicalListingGrid(null, null, 'db63c4fa-68c4-11e7-b88c-000d3a173cc5', 1,
0, 10, null, 'asc')