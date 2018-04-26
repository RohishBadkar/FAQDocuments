DROP PROCEDURE IF EXISTS integration_db_20180322.search_by_products_chemicalListingGrid;
CREATE PROCEDURE integration_db_20180322.`search_by_products_chemicalListingGrid`(casReference VARCHAR(100), chemicalTradeName VARCHAR(100),languageId INT
, productGroupId varchar(50), certificationValue VARCHAR(50),chemicalType VARCHAR(50),selectedChemSubstanceId longtext
,minConc FLOAT(20),maxConc FLOAT(20),forCount INT,limitFrom INT ,limitTo INT,sortIndex VARCHAR(100),sortOrder VARCHAR(20))
BEGIN 
	
SET @groupByString = CONCAT(" GROUP BY ccs.chem_substance_id ");

SET @chemSelectString = CONCAT(" SELECT ccs.chem_substance_id AS chemicalSubstanceId, ccsi18n.trade_name AS chemicalTradeName, ccs.CAS_reference AS casReference "
          " ,ccs.is_pure AS isPure, ccs.max_conc AS maxConc, ccs.min_conc AS minConc, ccs.is_mix AS isMix "
          " ,icpca.product_category_id AS productCategiryId,ccs.is_deleted AS isDeleted, ccs.active AS active "
          " ,NULL AS btddId, NULL AS productGroupId, NULL AS productCategoryId, NULL AS EN_Certified,NULL AS ASTM_Certified "
          " ,NULL AS EN_Color, NULL AS ASTM_Color, NULL AS EN_btddLevel, NULL AS ASTM_btddLevel, NULL AS EN_btdd_level_id "
          " ,NULL AS ASTM_btdd_level_id, NULL AS EN_Range, NULL AS ASTM_Range, NULL AS EN_Minutes "
          " ,NULL AS ASTM_Minutes, NULL AS EN_RangeAndMinute, NULL AS ASTM_RangeAndMinute "
          " ,NULL AS EN_Degradation_Scale, NULL AS ASTM_Degradation_Scale, NULL AS EN_Degradation_Desc "
          " ,NULL AS ASTM_Degradation_Desc, NULL AS EN_Comments, NULL AS ASTM_Comments ") ;
SET @chemFromString = CONCAT(" FROM crms_chemical_substance AS ccs ");
SET @chemFromString = CONCAT(@chemFromString," INNER JOIN int_chemical_product_category_association AS icpca ON icpca.chem_substance_id = ccs.chem_substance_id ");
SET @chemFromString = CONCAT(@chemFromString," INNER JOIN crms_chemical_substance_i18n AS ccsi18n ON ccsi18n.chem_substance_id = ccs.chem_substance_id ");

SET @chemWhereString = CONCAT(" WHERE ccs.is_deleted = 0 AND ccs.active = 'A' AND icpca.is_deleted = 0 AND ccs.is_approved = 1 AND ccsi18n.language_id =" ,languageId, " ");

IF NOT chemicalType IS NULL THEN
  SET @chemWhereString = CONCAT(@chemWhereString," AND ccs.is_mix = ",chemicalType);
END IF;

IF NOT selectedChemSubstanceId IS NULL AND NOT selectedChemSubstanceId = "null" THEN
   SET @chemWhereString = CONCAT(@chemWhereString," AND ccs.chem_substance_id IN (",selectedChemSubstanceId,") ");
  ELSE IF selectedChemSubstanceId = "" THEN
    SET @chemWhereString = CONCAT(@chemWhereString," AND ccs.chem_substance_id = '' ");
  END IF;
END IF;

IF NOT casReference IS NULL THEN
  SET @chemWhereString = CONCAT(@chemWhereString," AND ccs.CAS_reference LIKE "'''%',casReference,'%''');
END IF;

IF NOT chemicalTradeName IS NULL THEN
  SET @tradeName = REPLACE(chemicalTradeName,"'","''");
  SET @tradeName = REPLACE(@tradeName,"%","\%");
  SET @tradeName = REPLACE(@tradeName,"_","\_");
  SET @chemWhereString = CONCAT(@chemWhereString," AND ccsi18n.trade_name LIKE "'''%',@tradeName,'%''');
END IF;

IF NOT maxConc IS NULL THEN
  SET @chemWhereString = CONCAT(@chemWhereString," AND ccs.max_conc <= ",maxConc," ");
END IF;

IF NOT minConc IS NULL THEN
  SET @chemWhereString = CONCAT(@chemWhereString," AND ccs.min_conc >= ",minConc," ");
END IF;

IF NOT productGroupId IS NULL AND NOT productGroupId = "null" AND NOT productGroupId = "" THEN
  IF NOT certificationValue = "0,1" OR NOT forCount = 1 THEN
    SET @chemWhereString = CONCAT(@chemWhereString," AND ccs.chem_substance_id NOT IN(SELECT cbtdd.chem_substance_id FROM crms_btdd AS cbtdd ");
    SET @chemWhereString = CONCAT(@chemWhereString," WHERE cbtdd.product_group_id = '",productGroupId,"'",@groupByString," ) ");
  END IF;
END IF;

SET @chemWhereString = CONCAT(@chemWhereString,@groupByString);


SET @selectString= CONCAT(" SELECT ccs.chem_substance_id AS chemicalSubstanceId,ccsi18n.trade_name AS chemicalTradeName,ccs.CAS_reference AS casReference,ccs.is_pure AS isPure"
                          ", ccs.max_conc AS maxConc, ccs.min_conc AS minConc, ccs.is_mix AS isMix,icpca.product_category_id AS productCategiryId,ccs.is_deleted AS isDeleted, ccs.active AS active  ");
                                     
IF NOT productGroupId IS NULL AND NOT productGroupId = "null" AND NOT productGroupId = "" THEN
    SET @selectString = CONCAT(@selectString,", cbtdd.btdd_id as btddId, cbtdd.product_group_id as productGroupId, cbtdd.product_category_id as productCategoryId ");
    SET @selectString = CONCAT(@selectString,", GROUP_CONCAT(CASE WHEN (crmsstandard1.standard_id = 1) THEN cbtdd.is_certified ELSE NULL END)AS EN_Certified ");
    SET @selectString = CONCAT(@selectString,", GROUP_CONCAT(CASE WHEN (crmsstandard2.standard_id = 2) THEN cbtdd.is_certified ELSE NULL END)AS ASTM_Certified ");
    SET @selectString = CONCAT(@selectString,", GROUP_CONCAT(cbtddlevel1.op_color_code) AS EN_Color, GROUP_CONCAT(cbtddlevel2.op_color_code) AS ASTM_Color ");
    SET @selectString = CONCAT(@selectString,", GROUP_CONCAT(cbtddlevel1.level) AS EN_btddLevel, GROUP_CONCAT(cbtddlevel2.level) AS ASTM_btddLevel ");
    SET @selectString = CONCAT(@selectString,", GROUP_CONCAT(cbtddlevel1.btdd_level_id) AS EN_btdd_level_id ");
    SET @selectString = CONCAT(@selectString,", GROUP_CONCAT(cbtddlevel2.btdd_level_id) AS ASTM_btdd_level_id ");
    SET @selectString = CONCAT(@selectString,", GROUP_CONCAT( CASE WHEN (crmsstandard1.standard_id = 1) THEN cbtdd.btt_range ELSE NULL END) AS EN_Range ");
    SET @selectString = CONCAT(@selectString,", GROUP_CONCAT( CASE WHEN (crmsstandard2.standard_id = 2) THEN cbtdd.btt_range ELSE NULL END) AS ASTM_Range ");
    SET @selectString = CONCAT(@selectString,", GROUP_CONCAT( CASE WHEN (crmsstandard1.standard_id = 1) THEN cbtdd.bt_minutes ELSE NULL END) AS EN_Minutes ");
    SET @selectString = CONCAT(@selectString,", GROUP_CONCAT( CASE WHEN (crmsstandard2.standard_id = 2) THEN cbtdd.bt_minutes ELSE NULL END) AS ASTM_Minutes ");
    SET @selectString = CONCAT(@selectString,', GROUP_CONCAT(CASE WHEN ( crmsstandard1.standard_id = 1 and cbtdd.is_certified = 1 ) THEN concat (cbtdd.btt_range, cbtdd.bt_minutes ) ');
    SET @selectString = CONCAT(@selectString,'  WHEN (crmsstandard1.standard_id = 1 and cbtdd.is_certified = 0) THEN cbtddlevel1.description Else null END) AS EN_RangeAndMinute ');
    SET @selectString = CONCAT(@selectString,', GROUP_CONCAT(CASE WHEN ( crmsstandard2.standard_id = 2 and cbtdd.is_certified = 1 ) THEN concat (cbtdd.btt_range, cbtdd.bt_minutes ) ');
    SET @selectString = CONCAT(@selectString,'  WHEN (crmsstandard2.standard_id = 2 and cbtdd.is_certified = 0) THEN cbtddlevel2.description Else null END) AS ASTM_RangeAndMinute ');
    SET @selectString = CONCAT(@selectString,", GROUP_CONCAT(cdsi18n.degradation_scale) AS EN_Degradation_Scale, GROUP_CONCAT(cdsi18n2.degradation_scale) AS ASTM_Degradation_Scale ");
    SET @selectString = CONCAT(@selectString,", GROUP_CONCAT(cdsi18n.description) AS EN_Degradation_Desc, GROUP_CONCAT(cdsi18n2.description) AS ASTM_Degradation_Desc ");
    SET @selectString = CONCAT(@selectString,", GROUP_CONCAT(CASE WHEN (crmsstandard1.standard_id =1) THEN cbtdd.comment ELSE NULL END) AS EN_Comments ");
    SET @selectString = CONCAT(@selectString,", GROUP_CONCAT(CASE WHEN (crmsstandard2.standard_id =2) THEN cbtdd.comment ELSE NULL END) AS ASTM_Comments " );
END IF;

SET @fromString = CONCAT(" FROM crms_chemical_substance AS ccs INNER JOIN int_chemical_product_category_association AS icpca ON icpca.chem_substance_id = ccs.chem_substance_id ");
SET @fromString = CONCAT(@fromString," INNER JOIN crms_chemical_substance_i18n AS ccsi18n ON ccsi18n.chem_substance_id = ccs.chem_substance_id ");

IF NOT productGroupId IS NULL AND NOT productGroupId = "null" AND NOT productGroupId = "" THEN
    SET @fromString = CONCAT(@fromString," INNER JOIN crms_btdd cbtdd ON cbtdd.chem_substance_id = ccs.chem_substance_id AND cbtdd.product_group_id = '",productGroupId,"'");
    SET @fromString = CONCAT(@fromString," LEFT OUTER JOIN crms_standard AS crmsstandard1 ON cbtdd.standard_id = crmsstandard1.standard_id AND crmsstandard1.standard_id = 1 ");
    SET @fromString = CONCAT(@fromString," LEFT OUTER JOIN crms_standard AS crmsstandard2 ON cbtdd.standard_id = crmsstandard2.standard_id AND crmsstandard2.standard_id = 2 ");
    SET @fromString = CONCAT(@fromString," LEFT OUTER JOIN crms_btdd_level AS cbtddlevel1 ON cbtdd.btdd_level_id = cbtddlevel1.btdd_level_id AND crmsstandard1.standard_id = 1 ");
    SET @fromString = CONCAT(@fromString," LEFT OUTER JOIN crms_btdd_level AS cbtddlevel2 ON cbtdd.btdd_level_id = cbtddlevel2.btdd_level_id AND crmsstandard2.standard_id = 2 ");
    SET @fromString = CONCAT(@fromString," LEFT OUTER JOIN crms_degradation_i18n AS cdsi18n ON cbtdd.degradation_scale = cdsi18n.degradation_scale  AND crmsstandard1.standard_id = 1 ");
    SET @fromString = CONCAT(@fromString," LEFT OUTER JOIN crms_degradation_i18n AS cdsi18n2 ON cbtdd.degradation_scale = cdsi18n2.degradation_scale AND crmsstandard2.standard_id = 2 ");
END IF;

SET @whereString = CONCAT(" WHERE ccs.is_deleted = 0 AND ccs.active = 'A' AND icpca.is_deleted = 0 AND ccs.is_approved = 1 AND ccsi18n.language_id =" ,languageId, " ");

IF NOT chemicalType IS NULL THEN
  SET @whereString = CONCAT(@whereString," AND ccs.is_mix = ",chemicalType);
END IF;

IF NOT selectedChemSubstanceId IS NULL AND NOT selectedChemSubstanceId = "null" THEN
   SET @whereString = CONCAT(@whereString," AND ccs.chem_substance_id IN (",selectedChemSubstanceId,") ");
  ELSE IF selectedChemSubstanceId = "" THEN
    SET @whereString = CONCAT(@whereString," AND ccs.chem_substance_id = '' ");
  END IF;
END IF;
 insert into test (procedure_name,query) values('ab',selectedChemSubstanceId);

IF NOT casReference IS NULL THEN
  SET @whereString = CONCAT(@whereString," AND ccs.CAS_reference LIKE "'''%',casReference,'%''');
END IF;

IF NOT chemicalTradeName IS NULL THEN
  SET @tradeName = REPLACE(chemicalTradeName,"'","''");
  SET @tradeName = REPLACE(@tradeName,"%","\%");
  SET @tradeName = REPLACE(@tradeName,"_","\_");
  SET @whereString = CONCAT(@whereString," AND ccsi18n.trade_name LIKE "'''%',@tradeName,'%''');
END IF;

IF NOT maxConc IS NULL THEN
  SET @whereString = CONCAT(@whereString," AND ccs.max_conc <= ",maxConc," ");
END IF;

IF NOT minConc IS NULL THEN
  SET @whereString = CONCAT(@whereString," AND ccs.min_conc >= ",minConc," ");
END IF;

IF NOT certificationValue IS NULL AND NOT certificationValue = "null" AND NOT certificationValue = "" THEN  
 SET @groupByString = CONCAT(@groupByString, " HAVING  (EN_Certified IN(",certificationValue,") OR ASTM_Certified IN(",certificationValue,")) OR (EN_Certified IS NULL AND ASTM_Certified IS NULL)") ;
END IF;

IF NOT sortIndex IS NULL AND NOT sortOrder IS NULL  THEN
	SET @orderByString = CONCAT(" ORDER BY ",CONCAT(sortIndex, " ",sortOrder)," ");
ELSE
	SET @orderByString = CONCAT(" ORDER BY isMix DESC , casReference ASC, chemicalTradeName ASC ");
END IF;

IF NOT limitFrom IS NULL AND NOT limitTo IS NULL THEN
  SET @limitString = CONCAT(" LIMIT ",CONCAT(limitFrom, "," ,limitTo)); 
END IF;
  
IF NOT certificationValue IS NULL AND NOT certificationValue = "null" AND NOT certificationValue = "" THEN 
  IF forCount=1 THEN
    IF certificationValue = "0,1" THEN 
      SET @queryString=CONCAT("SELECT COUNT(*) FROM(",@chemSelectString,@chemFromString,@chemWhereString," )AS cnt ");
    ELSE
      SET @queryString=CONCAT("SELECT COUNT(*) FROM(",@chemSelectString,@chemFromString,@chemWhereString," UNION "
      ,@selectString,@fromString,@whereString,@groupByString, " )AS cnt ");
    END IF;
  ELSE
   SET @queryString=CONCAT("SELECT * FROM(",@chemSelectString,@chemFromString,@chemWhereString," UNION "
   ,@selectString,@fromString,@whereString,@groupByString, " )AS recordsData ",@orderByString,@limitString);  END IF;
 ELSE 
  IF forCount=1 THEN
    SET @queryString=CONCAT("SELECT COUNT(*) FROM(",@chemSelectString,@chemFromString,@chemWhereString," )AS cnt ");
  ELSE
    SET @queryString=CONCAT(@chemSelectString,@chemFromString,@chemWhereString,@orderByString,@limitString); 
  END IF;
END IF;

 insert into test (procedure_name,query) values('search_by_products_chemicalListingGrid',@queryString);

PREPARE stmt FROM @queryString;
EXECUTE stmt; 
DEALLOCATE PREPARE stmt;
  
END;
