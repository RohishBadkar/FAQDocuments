SELECT
 *
FROM
 ((SELECT
    chemDetails.chemicalSubstanceId AS chemicalSubstanceId
   ,chemDetails.chemicalTradeName   AS chemicalTradeName
   ,chemDetails.casReference        AS casReference
   ,chemDetails.isPure              AS isPure
   ,chemDetails.maxConc             AS maxConc
   ,chemDetails.minConc             AS minConc
   ,chemDetails.isMix               AS isMix
   ,chemDetails.productCategiryId   AS productCategiryId
   ,chemDetails.isDeleted           AS isDeleted
   ,chemDetails.active              AS active
   ,NULL                            AS btddId
   ,NULL                            AS productGroupId
   ,NULL                            AS productCategoryId
   ,NULL                            AS EN_Certified
   ,NULL                            AS ASTM_Certified
   ,NULL                            AS EN_Color
   ,NULL                            AS ASTM_Color
   ,NULL                            AS EN_btddLevel
   ,NULL                            AS ASTM_btddLevel
   ,NULL                            AS EN_btdd_level_id
   ,NULL                            AS ASTM_btdd_level_id
   ,NULL                            AS EN_Range
   ,NULL                            AS ASTM_Range
   ,NULL                            AS EN_Minutes
   ,NULL                            AS ASTM_Minutes
   ,NULL                            AS EN_RangeAndMinute
   ,NULL                            AS ASTM_RangeAndMinute
   ,NULL                            AS EN_Degradation_Scale
   ,NULL                            AS ASTM_Degradation_Scale
   ,NULL                            AS EN_Degradation_Desc
   ,NULL                            AS ASTM_Degradation_Desc
   ,NULL                            AS EN_Comments
   ,NULL                            AS ASTM_Comments
   FROM
    (SELECT
      ccs.chem_substance_id     AS chemicalSubstanceId
     ,ccsi18n.trade_name        AS chemicalTradeName
     ,ccs.CAS_reference         AS casReference
     ,ccs.is_pure               AS isPure
     ,ccs.max_conc              AS maxConc
     ,ccs.min_conc              AS minConc
     ,ccs.is_mix                AS isMix
     ,icpca.product_category_id AS productCategiryId
     ,ccs.is_deleted            AS isDeleted
     ,ccs.active                AS active
     ,icpca.is_deleted          AS icpcaIsDeleted
     ,ccsi18n.language_id       AS languageId
     ,ccs.is_approved           AS isApproved
     FROM
      crms_chemical_substance  AS ccs
      INNER JOIN int_chemical_product_category_association AS icpca
        ON icpca.chem_substance_id = ccs.chem_substance_id
      INNER JOIN crms_chemical_substance_i18n AS ccsi18n
        ON ccsi18n.chem_substance_id = ccs.chem_substance_id) AS chemDetails
   WHERE
    chemDetails.isDeleted = 0 AND
    chemDetails.active = 'A' AND
    chemDetails.icpcaIsDeleted = 0 AND
    chemDetails.isApproved = 1 AND
    chemDetails.languageId = 1 AND
    chemDetails.chemicalSubstanceId NOT IN
      (SELECT
        cbtdd.chem_substance_id
       FROM
        crms_btdd AS cbtdd
       WHERE
        cbtdd.product_group_id = 'db6365a3-68c4-11e7-b88c-000d3a173cc5')
   GROUP BY
    chemDetails.chemicalSubstanceId
   ORDER BY
    isMix DESC
   ,casReference ASC
   ,chemicalTradeName ASC
   LIMIT
    10, 10)
  UNION
  SELECT
   chemDetails.chemicalSubstanceId          AS chemicalSubstanceId
  ,chemDetails.chemicalTradeName            AS chemicalTradeName
  ,chemDetails.casReference                 AS casReference
  ,chemDetails.isPure                       AS isPure
  ,chemDetails.maxConc                      AS maxConc
  ,chemDetails.minConc                      AS minConc
  ,chemDetails.isMix                        AS isMix
  ,chemDetails.productCategiryId            AS productCategiryId
  ,chemDetails.isDeleted                    AS isDeleted
  ,chemDetails.active                       AS active
  ,chemDetails.btddId                       AS btddId
  ,chemDetails.productGroupId               AS productGroupId
  ,chemDetails.productCategoryId            AS productCategoryId
  ,GROUP_CONCAT(
     CASE
       WHEN (crmsstandard1.standard_id = 1) THEN chemDetails.isCertified
       ELSE NULL
     END)
     AS EN_Certified
  ,GROUP_CONCAT(
     CASE
       WHEN (crmsstandard2.standard_id = 2) THEN chemDetails.isCertified
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
       WHEN (crmsstandard1.standard_id = 1) THEN chemDetails.bttRange
       ELSE NULL
     END)
     AS EN_Range
  ,GROUP_CONCAT(
     CASE
       WHEN (crmsstandard2.standard_id = 2) THEN chemDetails.bttRange
       ELSE NULL
     END)
     AS ASTM_Range
  ,GROUP_CONCAT(
     CASE
       WHEN (crmsstandard1.standard_id = 1) THEN chemDetails.btMinutes
       ELSE NULL
     END)
     AS EN_Minutes
  ,GROUP_CONCAT(
     CASE
       WHEN (crmsstandard2.standard_id = 2) THEN chemDetails.btMinutes
       ELSE NULL
     END)
     AS ASTM_Minutes
  ,GROUP_CONCAT(
     CASE
       WHEN (crmsstandard1.standard_id = 1 AND
             chemDetails.isCertified = 1)
       THEN
         concat(
           chemDetails.bttRange
          ,chemDetails.btMinutes)
       WHEN (crmsstandard1.standard_id = 1 AND
             chemDetails.isCertified = 0)
       THEN
         cbtddlevel1.description
       ELSE
         NULL
     END)
     AS EN_RangeAndMinute
  ,GROUP_CONCAT(
     CASE
       WHEN (crmsstandard2.standard_id = 2 AND
             chemDetails.isCertified = 1)
       THEN
         concat(
           chemDetails.bttRange
          ,chemDetails.btMinutes)
       WHEN (crmsstandard2.standard_id = 2 AND
             chemDetails.isCertified = 0)
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
     CASE
       WHEN (crmsstandard1.standard_id = 1) THEN chemDetails.comment
       ELSE NULL
     END)
     AS EN_Comments
  ,GROUP_CONCAT(
     CASE
       WHEN (crmsstandard2.standard_id = 2) THEN chemDetails.comment
       ELSE NULL
     END)
     AS ASTM_Comments
  FROM
   (SELECT
     ccs.chem_substance_id     AS chemicalSubstanceId
    ,ccsi18n.trade_name        AS chemicalTradeName
    ,ccs.max_conc              AS maxConc
    ,ccs.CAS_reference         AS casReference
    ,ccs.is_pure               AS isPure
    ,ccs.min_conc              AS minConc
    ,ccs.is_mix                AS isMix
    ,icpca.product_category_id AS productCategiryId
    ,ccs.is_deleted            AS isDeleted
    ,icpca.is_deleted          AS icpcaIsDeleted
    ,ccs.active                AS active
    ,cbtdd.btdd_id             AS btddId
    ,cbtdd.product_group_id    AS productGroupId
    ,cbtdd.btdd_level_id       AS btddLevelId
    ,cbtdd.standard_id         AS standardId
    ,cbtdd.degradation_scale   AS degradationScale
    ,cbtdd.product_category_id AS productCategoryId
    ,cbtdd.is_certified        AS isCertified
    ,cbtdd.btt_range           AS bttRange
    ,cbtdd.bt_minutes          AS btMinutes
    ,cbtdd.comment             AS comment
    ,ccsi18n.language_id       AS languageId
    ,ccs.is_approved           AS isApproved
    FROM
     crms_chemical_substance  AS ccs
     INNER JOIN int_chemical_product_category_association AS icpca
       ON icpca.chem_substance_id = ccs.chem_substance_id
     INNER JOIN crms_chemical_substance_i18n AS ccsi18n
       ON ccsi18n.chem_substance_id = ccs.chem_substance_id
     INNER JOIN crms_btdd cbtdd
       ON cbtdd.chem_substance_id = ccs.chem_substance_id AND
          cbtdd.product_group_id = 'db6365a3-68c4-11e7-b88c-000d3a173cc5'
    WHERE
     ccs.is_deleted = 0 AND
     ccs.active = 'A' AND
     icpca.is_deleted = 0 AND
     ccs.is_approved = 1 AND
     ccsi18n.language_id = 1
    GROUP BY
     ccs.chem_substance_id
    ORDER BY
     isMix DESC
    ,casReference ASC
    ,chemicalTradeName ASC
    LIMIT
     10, 10) AS chemDetails
   LEFT OUTER JOIN crms_standard AS crmsstandard1
     ON chemDetails.standardId = crmsstandard1.standard_id AND
        crmsstandard1.standard_id = 1
   LEFT OUTER JOIN crms_standard AS crmsstandard2
     ON chemDetails.standardId = crmsstandard2.standard_id AND
        crmsstandard2.standard_id = 2
   LEFT OUTER JOIN crms_btdd_level AS cbtddlevel1
     ON chemDetails.btddLevelId = cbtddlevel1.btdd_level_id AND
        crmsstandard1.standard_id = 1
   LEFT OUTER JOIN crms_btdd_level AS cbtddlevel2
     ON chemDetails.btddLevelId = cbtddlevel2.btdd_level_id AND
        crmsstandard2.standard_id = 2
   LEFT OUTER JOIN crms_degradation_i18n AS cdsi18n
     ON chemDetails.degradationScale = cdsi18n.degradation_scale AND
        crmsstandard1.standard_id = 1
   LEFT OUTER JOIN crms_degradation_i18n AS cdsi18n2
     ON chemDetails.degradationScale = cdsi18n2.degradation_scale AND
        crmsstandard2.standard_id = 2
  GROUP BY
   chemDetails.chemicalSubstanceId
  HAVING
   (EN_Certified IN (0
                    ,1) OR
    ASTM_Certified IN (0
                      ,1)) OR
   (EN_Certified IS NULL AND
    ASTM_Certified IS NULL)) AS recordsData
ORDER BY
 isMix DESC
,casReference ASC
,chemicalTradeName ASC
LIMIT
 10, 10