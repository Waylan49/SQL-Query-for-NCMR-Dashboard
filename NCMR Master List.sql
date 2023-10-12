SELECT a.NCMR_ID,
     CONCAT('https://stanleybd.etq.com/prod/rel/#?ext$cmd=document&module=NCMR&form=NCMR_DOCUMENT&document=', a.NCMR_ID, '&originalDocId=', a.NCMR_ID) AS Link,
	   CAST(a.ETQ_CREATED_DATE AS DATE) AS Created_Date,
	   CAST(a.ETQ_DUE_DATE AS DATE) AS Due_Date,
	   CASE WHEN ETQ_CURRENT_PHASE = 'Voided' THEN CAST(a.ETQ_MODIFIED_DATE AS DATE)
	        WHEN ETQ_CURRENT_PHASE = 'Closed' THEN CAST(a.ETQ_COMPLETED_DATE AS DATE)
			ELSE NULL END AS Completed_Date,
	   a.ETQ_MODIFIED_DATE,
	   CASE WHEN ETQ_CURRENT_PHASE = 'Closed'THEN 'Closed'
	        WHEN ETQ_CURRENT_PHASE = 'Voided' THEN 'Voided'
	        ELSE 'Open' END AS Status,
	   CASE WHEN ETQ_CURRENT_PHASE = 'Closed' THEN DATEDIFF(day, ETQ_CREATED_DATE, ETQ_COMPLETED_DATE)
	   ELSE NULL END AS 'Days to close',
	   CASE WHEN ETQ_COMPLETED_DATE IS NULL THEN DATEDIFF(day, ETQ_CREATED_DATE, CURRENT_TIMESTAMP)
	        ELSE NULL END AS Aging_Days,
	   CASE WHEN ETQ_COMPLETED_DATE IS NULL THEN DATEDIFF(day, ETQ_DUE_DATE, CURRENT_TIMESTAMP)
	        ELSE NULL END AS Overdue_Days,
	   CASE WHEN ETQ_CURRENT_PHASE = 'Closed' THEN 'Closed'
	        WHEN ETQ_CURRENT_PHASE = 'Voided' THEN 'Voided'
	        WHEN ETQ_CURRENT_PHASE != 'Closed' AND ETQ_CURRENT_PHASE != 'Voided' AND DATEDIFF(day, ETQ_DUE_DATE, CURRENT_TIMESTAMP) > 0 THEN 'Overdue'
			WHEN ETQ_CURRENT_PHASE != 'Closed' AND ETQ_CURRENT_PHASE != 'Voided' AND DATEDIFF(day, ETQ_DUE_DATE, CURRENT_TIMESTAMP) = 0 THEN 'Due Today'
			WHEN ETQ_CURRENT_PHASE != 'Closed' AND ETQ_CURRENT_PHASE != 'Voided' AND DATEDIFF(day, ETQ_DUE_DATE, CURRENT_TIMESTAMP) < 0 THEN 'Not Overdue'
			ELSE NULL END AS Overdue,
			CASE WHEN ETQ_CURRENT_PHASE != 'Closed' AND ETQ_CURRENT_PHASE != 'Voided' AND DATEDIFF(day, ETQ_DUE_DATE, CURRENT_TIMESTAMP) >= -5 
			AND DATEDIFF(day, ETQ_DUE_DATE, CURRENT_TIMESTAMP) <= 0 THEN 'Y'
			ELSE 'N' END AS Due_Within_5_Days,
       CASE WHEN ETQ_CURRENT_PHASE = 'Closed' THEN 'Closed'
	        WHEN ETQ_CURRENT_PHASE = 'Voided' THEN 'Voided'
	        WHEN ETQ_CURRENT_PHASE != 'Closed' AND ETQ_CURRENT_PHASE != 'Voided' AND DATEDIFF(day, ETQ_DUE_DATE, CURRENT_TIMESTAMP) >= 30 THEN 'Overdue +30 Days'
			ELSE NULL END AS Overdue_30_Days,
	   a.ETQ_CURRENT_PHASE AS ETQ_Current_Phase,
	   CASE WHEN ETQ_CURRENT_PHASE = 'Identification' THEN '1. Identification'
			WHEN ETQ_CURRENT_PHASE = 'MRB / Disposition' THEN '2. MRB / Disposition'
		    WHEN ETQ_CURRENT_PHASE = 'Closed' THEN '3. Closed'
			WHEN ETQ_CURRENT_PHASE = 'Voided' THEN 'Voided'
			WHEN ETQ_CURRENT_PHASE = '' OR ETQ_CURRENT_PHASE IS NULL THEN 'Not Defined'
			ELSE NULL END AS Current_Phase,
	   a.ETQ_NUMBER AS NCMR_Number,
	   a.NCMR_INITIATOR AS Initiator,
	   a.SAP_ISSUED_BY_P AS Issued_by,
	   a.SBD_NC_IS_CAPA_REQUIRED_P AS CAPA_Required,
	   a.SBD_NC_NO_CAPA_JUSTIFICATION_P AS No_CAPA_Justification,
	   a.SBD_NC_NCMR_IS_SCAR_REQUIRED_P AS SCAR_Required,
       a.SBD_NC_NCMR_SCAR_JUSTIFICATION_P AS No_SCAR_Justification,
	   a.SBD_NC_MANUF_LOCATION_P AS Manufactured_Location,
	   CASE WHEN a.SBD_NC_NCMR_TYPE_P IS NOT NULL THEN a.SBD_NC_NCMR_TYPE_P
	        WHEN a.SBD_NC_NCMR_TYPE_P = '' OR a.SBD_NC_NCMR_TYPE_P IS NULL THEN 'Not Selected'
			ELSE NULL END AS NCMR_Type,
	   CASE WHEN a.SBD_NC_ORIGIN_P IS NOT NULL AND a.SBD_NC_ORIGIN_P != '' THEN a.SBD_NC_ORIGIN_P
	        WHEN a.SBD_NC_ORIGIN_P IS NULL OR a.SBD_NC_ORIGIN_P = '' THEN 'Not Selected'
			ELSE NULL END AS Origin, 
	   CASE WHEN a.SBD_NC_ORIGIN_P = 'Conformance Testing' THEN 'Leading'
			WHEN a.SBD_NC_ORIGIN_P = 'Cust. Feedback' THEN 'Lagging'
			WHEN a.SBD_NC_ORIGIN_P = 'Development' THEN 'Leading'
			WHEN a.SBD_NC_ORIGIN_P = 'Dist. Center (DC)' THEN 'Lagging'
			WHEN a.SBD_NC_ORIGIN_P = 'Final Audit (FSA)' THEN 'Leading'
			WHEN a.SBD_NC_ORIGIN_P = 'First Article' THEN 'Leading'
			WHEN a.SBD_NC_ORIGIN_P = 'In-Process Audit/Inspection' THEN 'Leading'
			WHEN a.SBD_NC_ORIGIN_P = 'Receiving Inspection' THEN 'Leading'
			WHEN a.SBD_NC_ORIGIN_P = 'Reliability Testing (ABR)' THEN 'Leading'
			WHEN a.SBD_NC_ORIGIN_P = 'Teardown' THEN 'Lagging'
			WHEN a.SBD_NC_ORIGIN_P = 'Warranty' THEN 'Lagging'
			WHEN a.SBD_NC_ORIGIN_P = 'Internal Audit' THEN 'Leading'
			WHEN a.SBD_NC_ORIGIN_P = 'External Audit' THEN 'Lagging'
			WHEN a.SBD_NC_ORIGIN_P = 'Management Review' THEN 'Leading'
			WHEN a.SBD_NC_ORIGIN_P = 'Deviations' THEN 'Leading'
			WHEN a.SBD_NC_ORIGIN_P = 'Final Inspection' THEN 'Leading'
			WHEN a.SBD_NC_ORIGIN_P = 'Receiving' THEN 'Leading'
			WHEN a.SBD_NC_ORIGIN_P = 'Tester (FTP)' THEN 'Leading'
			WHEN a.SBD_NC_ORIGIN_P = 'In-Process' THEN 'Leading'
			WHEN a.SBD_NC_ORIGIN_P = 'FTP' THEN 'Leading'
			WHEN a.SBD_NC_ORIGIN_P = 'FSA' THEN 'Leading'
			WHEN a.SBD_NC_ORIGIN_P = 'Audit' THEN 'Leading'
			WHEN a.SBD_NC_ORIGIN_P = 'ABR' THEN 'Leading'
			WHEN a.SBD_NC_ORIGIN_P = 'Conformance' THEN 'Leading'
			WHEN a.SBD_NC_ORIGIN_P IS NULL OR a.SBD_NC_ORIGIN_P = '' THEN 'No Origin Selected'
	        ELSE NULL END AS Origin_Indicator,
	   a.ETQ_SBD_NC_INTERFACE_SOURCEKEY_MATERIAL_NUMBER AS Material_Number_Key,
	   a.ETQ_SBD_NC_INTERFACE_MATERIAL_NUMBER AS Material_Number,
	   CASE WHEN b.Hierarchical_Name is not NULL THEN b.Hierarchical_Name
	   ELSE 'Location is not selected' END AS Hierarchical_Name,
	   CASE WHEN b.Hierarchical_Name LIKE '%GTS%' THEN 'GTS'
	        WHEN b.Hierarchical_Name LIKE '%: IND :%' THEN 'IND'
			    WHEN b.Hierarchical_Name LIKE '%: IND' THEN 'IND'
			    WHEN b.Hierarchical_Name LIKE '%Security%' THEN 'Security'
			    WHEN b.Hierarchical_Name LIKE '%: OTD :%' THEN 'OTD'
			    WHEN b.Hierarchical_Name LIKE '%: OTD%' THEN 'OTD'
			    WHEN b.Hierarchical_Name LIKE 'SBD' THEN 'SBD'
			    ELSE 'Not Applicable' END AS Business,
		 	 CASE  WHEN b.Hierarchical_Name IN ('SBD : GTS : Canada : Mill Creek DC ','SBD : GTS : USA : Fontana DC', 'SBD : GTS : USA : Ft Mill DC',
	 'SBD : GTS : USA : KAN DC','SBD : GTS : USA : Northlake DC','SBD : GTS : USA : PPT : Brewster DC', 'SBD : GTS : USA : Miramar DC') THEN 'North American DC'
		 WHEN b.Hierarchical_Name LIKE '%: SAT :%' THEN 'SAT'
	        WHEN b.Hierarchical_Name LIKE '%: SAT%' THEN 'SAT'
          WHEN b.Hierarchical_Name LIKE '%: CPG :%' THEN 'CPG'
	        WHEN b.Hierarchical_Name LIKE '%: CPG%' THEN 'CPG'
	        WHEN b.Hierarchical_Name LIKE '%: FAS :%' THEN 'FAS'
	        WHEN b.Hierarchical_Name LIKE '%: FAS%' THEN 'FAS'
	        WHEN b.Hierarchical_Name LIKE '%: HTAS :%' THEN 'HTAS'
	        WHEN b.Hierarchical_Name LIKE '%: HTAS%' THEN 'HTAS'
	        WHEN b.Hierarchical_Name LIKE '%: HTA :%' THEN 'HTA'
	        WHEN b.Hierarchical_Name LIKE '%: HTA%' THEN 'HTA'
	        WHEN b.Hierarchical_Name LIKE '%: HTC :%' THEN 'HTC'
	        WHEN b.Hierarchical_Name LIKE '%: HTC%' THEN 'HTC'
	        WHEN b.Hierarchical_Name LIKE '%: HTSG :%' THEN 'HTSG'
	        WHEN b.Hierarchical_Name LIKE '%: HTSG%' THEN 'HTSG'
	        WHEN b.Hierarchical_Name LIKE '%: Infrastructure :%' THEN 'Infrastructure'
	        WHEN b.Hierarchical_Name LIKE '%: Infrastructure%' THEN 'Infrastructure'
	        WHEN b.Hierarchical_Name LIKE '%: OPG :%' THEN 'OPG'
	        WHEN b.Hierarchical_Name LIKE '%: OPG%' THEN 'OPG'
	        WHEN b.Hierarchical_Name LIKE '%: PPG :%' THEN 'PPG'
	        WHEN b.Hierarchical_Name LIKE '%: PPG%' THEN 'PPG'
	        WHEN b.Hierarchical_Name LIKE '%: PPT :%' THEN 'PPT'
	        WHEN b.Hierarchical_Name LIKE '%: PPT%' THEN 'PPT'
	        WHEN b.Hierarchical_Name LIKE '%: PTA :%' THEN 'PTA'
	        WHEN b.Hierarchical_Name LIKE '%: PTA%' THEN 'PTA'
	        WHEN b.Hierarchical_Name LIKE '%: SEF Auto :%' THEN 'SEF Auto'
	        WHEN b.Hierarchical_Name LIKE '%: SEF Auto%' THEN 'SEF Auto'
	        WHEN b.Hierarchical_Name LIKE '%: SEF Industrial :%' THEN 'SEF Industrial'
	        WHEN b.Hierarchical_Name LIKE '%: SEF Industrial%' THEN 'SEF Industrial'
	        WHEN b.Hierarchical_Name LIKE '%: SHS :%' THEN 'SHS'
	        WHEN b.Hierarchical_Name LIKE '%: SHS%' THEN 'SHS'
			WHEN b.Hierarchical_Name LIKE '%Towson%' THEN 'Design Center'
			WHEN b.Hierarchical_Name LIKE '%Damparis%' THEN 'Europe DC'
			WHEN b.Hierarchical_Name LIKE '%Weihoek%' OR b.Hierarchical_Name LIKE '%Marietta%' THEN 'SHS'
			ELSE 'Not Applicable' END AS Division,
	   CASE WHEN a.SBD_NC_PRIMARY_DEFECT_CODE_P IS NULL THEN 'N/A'
	        ELSE a.SBD_NC_PRIMARY_DEFECT_CODE_P END AS Primary_Defect_Code,
	   CASE WHEN a.SUB_DEFECT_CODE_P IS NULL THEN 'N/A'
	        ELSE a.SUB_DEFECT_CODE_P END AS Sub_Defect_Code,
	   a.ETQ_NCMR_COST_ADMINISTRATIVE AS NCMR_Administrative_Cost,
	   a.ETQ_NCMR_COST_EQUIPMENT AS NCMR_Equipment_Cost,
	   a.ETQ_NCMR_COST_LABOR AS NCMR_Labor_Cost,
	   a.ETQ_NCMR_COST_MATERIALS  AS NCMR_Material_Cost,
	   a.ETQ_NCMR_COST_TRANSPORTATION  AS NCMR_Transportation_Cost,
	   a.SBD_NC_SORT_P  AS NCMR_Sort_Cost,
	   a.SBD_NC_SCRAPPED_MATERIAL_P  AS NCMR_Scrapped_Material_Cost,
	   a.SBD_NC_MEASURENT_P AS NCMR_Measurement_Cost,
	   a.SBD_NC_REWORK_EXTERNAL_P  AS NCMR_External_Rework_Cost,
	   a.SBD_NC_REWORK_INTERNAL_P  AS NCMR_Internal_Rework_Cost,
	   a.SBD_NC_ADDITIONAL_OPERATION_P  AS NCMR_Additional_Operation_Cost,
	   a.SBD_NC_SCRAP_OF_OTHER_PARTS_IN_SA_P  AS NCMR_Scrap_of_Other_Parts_in_SA_Cost,
	   a.SBD_NC_TESTING_P  AS NCMR_Testing_Cost,
	   a.SBD_NC_RECALL_P  AS NCMR_Recall_Cost,
	   a.SBD_NC_LINE_SHUT_DOWN_P  AS NCMR_Line_Shut_Down_Cost,
	   a.SBD_NCMR_WARRANTY_COST_P  AS NCMR_Warranty_Cost,
	   a.ETQ_NCMR_COST_OTHER  AS NCMR_Other_Cost,
	   a.ETQ_NCMR_COST_TOTAL  AS NCMR_Total_Cost,
	   a.SBD_SC_SEVERITY_P AS Severity,
	   a.SBD_NC_TOTAL_DEFECT_QTY_P AS Defect_Qauntity,
	   a.SBD_NC_TOTAL_PRODUCTION_P AS Total_Production_Quantity,
	   a.SBD_NC_CHARGEBACK_VALUE_P AS Chargeback,
	   CASE WHEN SBD_NC_NCMR_TYPE_P LIKE 'Customer%' AND a.ETQ_NCMR_CUSTOMERINFO_NAME IS NOT NULL THEN ETQ_NCMR_CUSTOMERINFO_NAME
	        WHEN SBD_NC_NCMR_TYPE_P LIKE 'Customer%' AND a.ETQ_NCMR_CUSTOMERINFO_NAME IS NULL THEN 'No Customer Specified' 
			WHEN SBD_NC_NCMR_TYPE_P NOT LIKE 'Customer%' THEN 'Not Customer Type'
			ELSE NULL END AS 'Customer Name',
       CASE WHEN SBD_NC_NCMR_TYPE_P LIKE 'Supplier%' AND a.NCMR_NCMR_DOCUMENT_SUPPLIER_NAME IS NOT NULL THEN a.NCMR_NCMR_DOCUMENT_SUPPLIER_NAME
	        WHEN SBD_NC_NCMR_TYPE_P LIKE 'Supplier%' AND a.NCMR_NCMR_DOCUMENT_SUPPLIER_NAME IS NULL THEN 'No Supplier Specified' 
			WHEN SBD_NC_NCMR_TYPE_P NOT LIKE 'Supplier%' THEN 'Not Supplier Type'
			ELSE NULL END AS 'Supplier Name'
FROM
(
SELECT LINK_FORM_ID, 
       NCMR_ID,
	   ETQ_COMPLETED_DATE,
	   ETQ_CREATED_DATE,
	   ETQ_CURRENT_PHASE,
	   ETQ_DUE_DATE,
	   ETQ_MODIFIED_DATE,
	   ETQ_NUMBER,
	   NCMR_INITIATOR,
	   SAP_ISSUED_BY_P,
	   SBD_NC_IS_CAPA_REQUIRED_P,
	   SBD_NC_NCMR_IS_SCAR_REQUIRED_P,
       SBD_NC_NCMR_SCAR_JUSTIFICATION_P,
       SBD_NC_NO_CAPA_JUSTIFICATION_P,
	   SBD_NC_MANUF_LOCATION_P,
	   SBD_NC_NCMR_TYPE_P,
	   SBD_NC_ORIGIN_P,
	   ETQ_SBD_NC_INTERFACE_SOURCEKEY_MATERIAL_NUMBER,
	   ETQ_SBD_NC_INTERFACE_MATERIAL_NUMBER,
	   SBD_NC_PRIMARY_DEFECT_CODE_P,
	   SUB_DEFECT_CODE_P,
	   ETQ_NCMR_COST_ADMINISTRATIVE,
	   ETQ_NCMR_COST_EQUIPMENT,
	   ETQ_NCMR_COST_LABOR,
	   ETQ_NCMR_COST_MATERIALS,
	   ETQ_NCMR_COST_TRANSPORTATION,
	   SBD_NC_SORT_P,
	   SBD_NC_SCRAPPED_MATERIAL_P,
	   SBD_NC_MEASURENT_P,
	   SBD_NC_REWORK_EXTERNAL_P,
	   SBD_NC_REWORK_INTERNAL_P,
	   SBD_NC_ADDITIONAL_OPERATION_P,
	   SBD_NC_SCRAP_OF_OTHER_PARTS_IN_SA_P,
	   SBD_NC_TESTING_P,
	   SBD_NC_RECALL_P,
	   SBD_NC_LINE_SHUT_DOWN_P,
	   SBD_NCMR_WARRANTY_COST_P,
	   ETQ_NCMR_COST_OTHER,
	   ETQ_NCMR_COST_TOTAL,
	   SBD_SC_SEVERITY_P,
	   SBD_NC_TOTAL_DEFECT_QTY_P,
	   SBD_NC_TOTAL_PRODUCTION_P,
	   SBD_NC_CHARGEBACK_VALUE_P,
	   ETQ_NCMR_CUSTOMERINFO_NAME,
	   NCMR_NCMR_DOCUMENT_SUPPLIER_NAME
FROM [StanleyBDQDL].[ODT].[NCMR_DOCUMENT_S]
WHERE ETQ_CURRENT_PHASE != 'On-Hold'
) a
LEFT OUTER JOIN 
(
SELECT [LINK_FORM_ID],
       [NCMR_ID],
	   MAX(CASE WHEN FIELD_NAME = 'HIERARCHICAL_NAME' THEN FIELD_VALUE
	   ELSE NULL END) AS Hierarchical_Name
  FROM [StanleyBDQDL].[ODT].[NCMR_DOCUMENT_D]
  GROUP BY LINK_FORM_ID, NCMR_ID, RECORD_ORDER
  HAVING RECORD_ORDER = 1
) b
ON a.LINK_FORM_ID = b.LINK_FORM_ID
