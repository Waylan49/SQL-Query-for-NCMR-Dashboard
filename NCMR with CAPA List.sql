SELECT f.SOURCE_FIELD_ID AS NCMR_ID
      ,CONCAT('https://stanleybd.etq.com/prod/rel/#?ext$cmd=document&module=NCMR&form=NCMR_DOCUMENT&document=', f.SOURCE_FIELD_ID, '&originalDocId=', f.SOURCE_FIELD_ID) AS NCMR_Link
	  ,CASE WHEN FORM_DISPLAY_NAME = 'Corrective Action' THEN CONCAT('CORRACT_ID_', F.FIELD_VALUE)
	        WHEN FORM_DISPLAY_NAME = 'SCAR' THEN CONCAT('SCAR_ID_', F.FIELD_VALUE)
			ELSE NULL END AS CA_ID_1
FROM
(
SELECT [SOURCE_FORM_DISPLAY_NAME]
      ,[SOURCE_FIELD_ID] 
      ,[FORM_DISPLAY_NAME]
      ,[FIELD_VALUE]
  FROM [StanleyBDQDL].[ODT].[DOCUMENT_LINK_SOURCE]
  WHERE SOURCE_FORM_DISPLAY_NAME = 'Nonconforming Material' AND FORM_DISPLAY_NAME IN ('Corrective Action', 'SCAR')
UNION
SELECT a.SOURCE_FORM_DISPLAY_NAME
      ,a.SOURCE_FIELD_ID
	  ,b.FORM_DISPLAY_NAME
	  ,b.FIELD_VALUE
FROM
(
SELECT [SOURCE_FORM_DISPLAY_NAME]
      ,[SOURCE_FIELD_ID] 
      ,[FORM_DISPLAY_NAME]
      ,[FIELD_VALUE]
  FROM [StanleyBDQDL].[ODT].[DOCUMENT_LINK_SOURCE]
  WHERE SOURCE_FORM_DISPLAY_NAME = 'Nonconforming Material' AND FORM_DISPLAY_NAME = 'Corrective Action Determination'
) a
LEFT JOIN
(
SELECT [SOURCE_FORM_DISPLAY_NAME]
      ,[SOURCE_FIELD_ID] 
      ,[FORM_DISPLAY_NAME]
      ,[FIELD_VALUE]
  FROM [StanleyBDQDL].[ODT].[DOCUMENT_LINK_SOURCE]
  WHERE SOURCE_FORM_DISPLAY_NAME = 'Corrective Action Determination'
) b
 ON a.FIELD_VALUE = b.SOURCE_FIELD_ID
) f
WHERE f.FORM_DISPLAY_NAME IS NOT NULL