(
SELECT CONCAT('CORRACT_ID_', a.CORRACT_ID) AS ID,
       CAST(a.ETQ_CREATED_DATE AS DATE) AS Created_Date,
	   CAST(a.ETQ_DUE_DATE AS DATE) AS Due_Date,
	   CAST(a.ETQ_COMPLETED_DATE AS DATE) AS Completed_Date,
	   CAST(a.ETQ_MODIFIED_DATE AS DATE) AS Last_Modified_Date,
	   CASE WHEN ETQ_CURRENT_PHASE = 'Closed'THEN 'Closed'
	        WHEN ETQ_CURRENT_PHASE = 'Voided' OR ETQ_CURRENT_PHASE = 'Void' THEN 'Voided'
	        ELSE 'Open' END AS Status,
	   CASE WHEN ETQ_CURRENT_PHASE = 'Closed' THEN DATEDIFF(day, ETQ_CREATED_DATE, ETQ_COMPLETED_DATE)
	        ELSE NULL END AS 'Days to close',
	   CASE WHEN ETQ_COMPLETED_DATE IS NULL AND ETQ_CURRENT_PHASE NOT IN ('Voided', 'Void', 'Closed') THEN DATEDIFF(day, ETQ_CREATED_DATE, CURRENT_TIMESTAMP at time zone 'Eastern Standard Time')
	        ELSE NULL END AS Aging_Days,
	   CASE WHEN ETQ_COMPLETED_DATE IS NULL AND ETQ_CURRENT_PHASE NOT IN ('Voided', 'Void', 'Closed') THEN DATEDIFF(day, ETQ_DUE_DATE, CURRENT_TIMESTAMP at time zone 'Eastern Standard Time')
	        ELSE NULL END AS Overdue_Days,

	   CASE WHEN ETQ_CURRENT_PHASE = 'Closed' THEN 'Closed'
	        WHEN ETQ_CURRENT_PHASE IN ('Voided', 'Void') THEN 'Voided'
	        WHEN ETQ_CURRENT_PHASE != 'Closed' AND ETQ_CURRENT_PHASE NOT IN ('Voided', 'Void') AND DATEDIFF(day, ETQ_DUE_DATE, CURRENT_TIMESTAMP at time zone 'Eastern Standard Time') > 0 THEN 'Overdue'
			WHEN ETQ_CURRENT_PHASE != 'Closed' AND ETQ_CURRENT_PHASE NOT IN ('Voided', 'Void') AND DATEDIFF(day, ETQ_DUE_DATE, CURRENT_TIMESTAMP at time zone 'Eastern Standard Time') = 0 THEN 'Due Today'
			WHEN ETQ_CURRENT_PHASE != 'Closed' AND ETQ_CURRENT_PHASE NOT IN ('Voided', 'Void') AND DATEDIFF(day, ETQ_DUE_DATE, CURRENT_TIMESTAMP at time zone 'Eastern Standard Time') < 0 THEN 'Not Overdue'
			ELSE NULL END AS Overdue,
	   CASE WHEN ETQ_CURRENT_PHASE != 'Closed' AND ETQ_CURRENT_PHASE NOT IN ('Voided', 'Void') AND DATEDIFF(day, ETQ_DUE_DATE, CURRENT_TIMESTAMP at time zone 'Eastern Standard Time') >= -5 
			AND DATEDIFF(day, ETQ_DUE_DATE, CURRENT_TIMESTAMP at time zone 'Eastern Standard Time') <= 0 THEN 'Y'
			ELSE 'N' END AS Due_Within_5_Days,
	   CASE WHEN ETQ_CURRENT_PHASE = 'Closed' THEN 'Closed'
	        WHEN ETQ_CURRENT_PHASE IN ('Voided', 'Void') THEN 'Voided'
	        WHEN ETQ_CURRENT_PHASE != 'Closed' AND ETQ_CURRENT_PHASE NOT IN ('Voided', 'Void') AND DATEDIFF(day, ETQ_DUE_DATE, CURRENT_TIMESTAMP at time zone 'Eastern Standard Time') >= 30 THEN 'Overdue +30 Days'
			ELSE NULL END AS Overdue_30_Days,	
			ETQ_CURRENT_PHASE,
	   CASE WHEN ETQ_CURRENT_PHASE = 'Identification / Problem Description' AND a.ETQ_NUMBER LIKE 'QCAPA%' THEN '1. Identification / Problem Description'
	        WHEN ETQ_CURRENT_PHASE = 'Root Cause Analysis' AND a.ETQ_NUMBER LIKE 'QCAPA%'  THEN '2. Root Cause Analysis'
			WHEN ETQ_CURRENT_PHASE = 'Corrective / Preventive Action' AND a.ETQ_NUMBER LIKE 'QCAPA%'  THEN '3. Corrective / Preventive Action'
	        WHEN ETQ_CURRENT_PHASE = 'Identification / Problem Description' AND a.ETQ_NUMBER LIKE 'CAPA%' THEN '1. Identification / Problem Description'
			WHEN ETQ_CURRENT_PHASE = 'Review Information / Define Team' AND a.ETQ_NUMBER LIKE 'CAPA%' THEN '2. Review Information / Define Team'
			WHEN ETQ_CURRENT_PHASE = 'Develop RCA and Solution' AND a.ETQ_NUMBER LIKE 'CAPA%' THEN '3. Develop RCA and Solution'
			WHEN ETQ_CURRENT_PHASE = 'RCA and Solution Approval' AND a.ETQ_NUMBER LIKE 'CAPA%' THEN '4. RCA and Solution Approval'
			WHEN ETQ_CURRENT_PHASE = 'Solution Implementation' AND a.ETQ_NUMBER LIKE 'CAPA%' THEN '5. Solution Implementation'
			WHEN ETQ_CURRENT_PHASE = 'Effectiveness Check  / Validation' AND a.ETQ_NUMBER LIKE 'CAPA%' THEN '6. Effectiveness Check  / Validation'
			WHEN ETQ_CURRENT_PHASE = 'Closed' THEN 'Closed'
			WHEN ETQ_CURRENT_PHASE = 'Voided' OR ETQ_CURRENT_PHASE = 'Void' THEN 'Voided'
			ELSE NULL END AS Current_Phase,
	   a.ETQ_NUMBER AS CAPA_Number,
	   CASE WHEN a.ETQ_NUMBER LIKE 'QCAPA%' THEN 'QCAPA'
	        WHEN a.ETQ_NUMBER LIKE 'CAPA%' THEN 'MQC'
	        ELSE NULL END AS CAPA_Type,
	   a.SBD_CAPA_OI_PART_NAME_SF_P AS Part_Name,
       a.SBD_CAPA_OI_PART_NUMBER_SF_P AS Part_Number,
       a.SBD_CAPA_OI_PROCESS_SF_P AS Process,
       a.ETQ_CORRACT_DEPARTMENT AS Department,
       a.SBD_CAPA_CAPA_MANUFACTURING_LOCATION_P AS Manufacturing_Location,
       CASE WHEN a.SBD_CAPA_CAPA_PRIMARY_DEFECT_CODE_P IS NULL THEN 'N/A'
	   ELSE a.SBD_CAPA_CAPA_PRIMARY_DEFECT_CODE_P END AS Primary_Defect_Code,
	   CASE WHEN a.SUB_DEFECT_CODE_1_P IS NULL THEN 'N/A' 
	   ELSE a.SUB_DEFECT_CODE_1_P END AS Sub_Defect_Code,
       a.SBD_CAPA_CAPA_INVOLVE_SC_PART_P AS Involve_SC_Part,
       a.SBD_CAPA_CAPA_ORIGIN_P AS Origin,
       a.SBD_CAPA_CAPA_ORIGINATOR_P AS Originator,
       a.SBD_CAPA_CAPA_SEVERITY_P AS Severity,
       a.ETQ_CORRACT_COST_ADMINISTRATIVE AS Administrative_Cost,
	   a.ETQ_CORRACT_COST_EQUIPMENT AS Equipment_Cost,
	   a.ETQ_CORRACT_COST_LABOR AS Labor_Cost,
	   a.ETQ_CORRACT_COST_MATERIALS AS Material_Cost,
	   a.ETQ_CORRACT_COST_OTHER AS Other_Cost,
	   a.ETQ_CORRACT_COST_TRANSPORTATION AS Transportation_Cost,
       a.SBD_CAPA_CAPA_COST_WARRANTY_P AS Warranty_Cost,
       a.ETQ_CORRACT_COST_TOTAL AS Total_Cost,
	   'N/A' AS Supplier_Name,
	     a.SBD_CAPA_CAPA_ROOT_CAUSE_DEFECT_CODE_P AS RCA_DEFECT_CODE,
       a.SBD_CAPA_CAPA_ROOT_CAUSE_DETECTION_CODE_P AS RCA_DETECTION_CODE,
       a.SBD_CAPA_CAPA_ROOT_CAUSE_SYSTEMIC_CODE_P AS RCA_SYSTEMIC_CODE,
	   b.Hierarchical_Name,
	   CASE WHEN b.Hierarchical_Name LIKE '%GTS%' THEN 'GTS'
            WHEN b.Hierarchical_Name LIKE '%: IND :%' THEN 'IND'
		    WHEN b.Hierarchical_Name LIKE '%: IND' THEN 'IND'
			WHEN b.Hierarchical_Name LIKE '%Security%' THEN 'Security'
			WHEN b.Hierarchical_Name LIKE '%: OTD :%' THEN 'OTD'
			WHEN b.Hierarchical_Name LIKE '%: OTD%' THEN 'OTD'
			WHEN b.Hierarchical_Name LIKE 'SBD' THEN 'SBD'
			ELSE NULL END AS Business,
	   CASE WHEN b.Hierarchical_Name LIKE '%: SAT :%' THEN 'SAT'
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
			    ELSE 'NA' END AS Division,
			    CONCAT('https://stanleybd.etq.com/prod/rel/#/app/system/document/CORRACT/CORRACT_DOCUMENT/', a.CORRACT_ID) AS Link
       FROM
       (
       SELECT LINK_FORM_ID, 
       CORRACT_ID,
       CORRACT_EVENT_TYPE,
       ETQ_CREATED_DATE,
       ETQ_COMPLETED_DATE,
       ETQ_DUE_DATE,
       ETQ_CURRENT_PHASE,
       ETQ_LAST_EDITOR,
       ETQ_MODIFIED_DATE,
       ETQ_NUMBER,
       SBD_CAPA_OI_PART_NAME_SF_P,
       SBD_CAPA_OI_PART_NUMBER_SF_P,
       SBD_CAPA_OI_PROCESS_SF_P,
       ETQ_CORRACT_DEPARTMENT,
       SBD_CAPA_CAPA_MANUFACTURING_LOCATION_P,
       SBD_CAPA_CAPA_PRIMARY_DEFECT_CODE_P,
       SBD_CAPA_CAPA_INVOLVE_SC_PART_P,
       SBD_CAPA_CAPA_ORIGIN_P,
       SBD_CAPA_CAPA_ORIGINATOR_P,
       SBD_CAPA_CAPA_SEVERITY_P,
       SUB_DEFECT_CODE_1_P,
       ETQ_CORRACT_COST_ADMINISTRATIVE,
	     ETQ_CORRACT_COST_EQUIPMENT,
	     ETQ_CORRACT_COST_LABOR,
	     ETQ_CORRACT_COST_MATERIALS,
	     ETQ_CORRACT_COST_OTHER,
	     ETQ_CORRACT_COST_TRANSPORTATION,
       SBD_CAPA_CAPA_COST_WARRANTY_P,
       ETQ_CORRACT_COST_TOTAL,
       SBD_CAPA_CAPA_ROOT_CAUSE_DEFECT_CODE_P,
       SBD_CAPA_CAPA_ROOT_CAUSE_DETECTION_CODE_P,
       SBD_CAPA_CAPA_ROOT_CAUSE_SYSTEMIC_CODE_P
       FROM [StanleyBDQDL].[ODT].[CORRACT_DOCUMENT_S]
       WHERE ETQ_NUMBER NOT LIKE 'CA-%' AND ETQ_NUMBER NOT LIKE 'PTG%') a
       LEFT JOIN 
       (
       SELECT [LINK_FORM_ID],
       [CORRACT_ID],
       MAX(CASE WHEN FIELD_NAME = 'HIERARCHICAL_NAME' THEN FIELD_VALUE
        ELSE NULL END) AS Hierarchical_Name
       FROM [StanleyBDQDL].[ODT].[CORRACT_DOCUMENT_D]
       GROUP BY LINK_FORM_ID, CORRACT_ID, RECORD_ORDER
       HAVING RECORD_ORDER = 1
       ) b
       ON a.LINK_FORM_ID = b.LINK_FORM_ID
)
UNION
(
SELECT 
       CONCAT('SCAR_ID_', a.SCAR_ID) AS ID,
       CAST(a.ETQ_CREATED_DATE AS DATE) AS Created_Date,
	   CAST(a.ETQ_DUE_DATE AS DATE) AS Due_Date,
	   CAST(a.ETQ_COMPLETED_DATE AS DATE) AS Completed_Date,
	   CAST(a.ETQ_MODIFIED_DATE AS DATE) AS Last_Modified_Date,
	   CASE WHEN ETQ_CURRENT_PHASE = 'Closed'THEN 'Closed'
	        WHEN ETQ_CURRENT_PHASE = 'Voided' THEN 'Voided'
	        ELSE 'Open' END AS Status,
	   CASE WHEN ETQ_CURRENT_PHASE = 'Closed' THEN DATEDIFF(day, ETQ_CREATED_DATE, ETQ_COMPLETED_DATE)
	        ELSE NULL END AS 'Days to close',
	   CASE WHEN ETQ_COMPLETED_DATE IS NULL AND ETQ_CURRENT_PHASE NOT IN ('Voided', 'Closed') THEN DATEDIFF(day, ETQ_CREATED_DATE, CURRENT_TIMESTAMP at time zone 'Eastern Standard Time')
	        ELSE NULL END AS Aging_Days,
	   CASE WHEN ETQ_COMPLETED_DATE IS NULL AND ETQ_CURRENT_PHASE NOT IN ('Voided', 'Closed') THEN DATEDIFF(day, ETQ_DUE_DATE, CURRENT_TIMESTAMP at time zone 'Eastern Standard Time')
	        ELSE NULL END AS Overdue_Days,
	   CASE WHEN ETQ_CURRENT_PHASE = 'Closed' THEN 'Closed'
	        WHEN ETQ_CURRENT_PHASE IN ('Voided') THEN 'Voided'
	        WHEN ETQ_CURRENT_PHASE != 'Closed' AND ETQ_CURRENT_PHASE NOT IN ('Voided') AND DATEDIFF(day, ETQ_DUE_DATE, CURRENT_TIMESTAMP at time zone 'Eastern Standard Time') > 0 THEN 'Overdue'
			WHEN ETQ_CURRENT_PHASE != 'Closed' AND ETQ_CURRENT_PHASE NOT IN ('Voided') AND DATEDIFF(day, ETQ_DUE_DATE, CURRENT_TIMESTAMP at time zone 'Eastern Standard Time') = 0 THEN 'Due Today'
			WHEN ETQ_CURRENT_PHASE != 'Closed' AND ETQ_CURRENT_PHASE NOT IN ('Voided') AND DATEDIFF(day, ETQ_DUE_DATE, CURRENT_TIMESTAMP at time zone 'Eastern Standard Time') < 0 THEN 'Not Overdue'
			ELSE NULL END AS Overdue,
	   CASE WHEN ETQ_CURRENT_PHASE != 'Closed' AND ETQ_CURRENT_PHASE NOT IN ('Voided') AND DATEDIFF(day, ETQ_DUE_DATE, CURRENT_TIMESTAMP at time zone 'Eastern Standard Time') >= -5 
			AND DATEDIFF(day, ETQ_DUE_DATE, CURRENT_TIMESTAMP at time zone 'Eastern Standard Time') <= 0 THEN 'Y'
			ELSE 'N' END AS Due_Within_5_Days,
	   CASE WHEN ETQ_CURRENT_PHASE = 'Closed' THEN 'Closed'
	        WHEN ETQ_CURRENT_PHASE IN ('Voided') THEN 'Voided'
	        WHEN ETQ_CURRENT_PHASE != 'Closed' AND ETQ_CURRENT_PHASE NOT IN ('Voided') AND DATEDIFF(day, ETQ_DUE_DATE, CURRENT_TIMESTAMP at time zone 'Eastern Standard Time') >= 30 THEN 'Overdue +30 Days'
			ELSE NULL END AS Overdue_30_Days,	
			ETQ_CURRENT_PHASE,
	   CASE WHEN ETQ_CURRENT_PHASE = 'Identification / Problem Description' THEN '1. Identification / Problem Description'
	        WHEN ETQ_CURRENT_PHASE = 'Define Team / Containment' THEN '2. Define Team / Containment'
			WHEN ETQ_CURRENT_PHASE = 'Send to Supplier' THEN '3. Send to Supplier'
			WHEN ETQ_CURRENT_PHASE = 'Verification and Effectiveness' THEN '4. Verification and Effectiveness'
			WHEN ETQ_CURRENT_PHASE = 'Closed' THEN 'Closed'
			WHEN ETQ_CURRENT_PHASE = 'Voided' THEN 'Voided'
			ELSE NULL END AS Current_Phase,
	   a.ETQ_NUMBER AS CAPA_Number,
	   CASE WHEN a.ETQ_NUMBER LIKE 'SCAR%' THEN 'SCAR'
	        ELSE NULL END AS CAPA_Type,
	   a.SBD_SCAR_8D_OI_PART_NAME_P AS Part_Name,
       a.SBD_SCAR_8D_OI_PART_NUMBER_P AS Part_Number,
       a.SBD_SCAR_8D_OI_PART_PROCESS_CB_P AS Process,
       a.SCAR_DEPARTMENT AS Department,
       a.SBD_CAPA_SCAR_MANUFACTURING_LOCATIONS_P AS Manufacturing_Location,
       'N/A' AS Primary_Defect_Code,
	   'N/A' AS Sub_Defect_Code,
       a.SBD_CAPA_SCAR_SC_PART_P AS Involve_SC_Part,
       a.SBD_CAPA_SCAR_ORIGIN_P AS Origin,
       a.SBD_CAPA_SCAR_ORIGINATOR_P AS Originator,
       a.SBD_CAPA_SCAR_SEVERITY_P AS Severity,
       a.SBD_CAPA_SCAR_COST_ADMINISTRATIVE_P AS Administrative_Cost,
	   a.SBD_CAPA_SCAR_COST_SAVINGS_EQUIPMENT_P AS Equipment_Cost,
	   a.SBD_CAPA_SCAR_COST_LABOR_P AS Labor_Cost,
	   a.SBD_CAPA_SCAR_COST_MATERIALS_P AS Material_Cost,
	   a.SBD_CAPA_SCAR_COST_OTHER_P AS Other_Cost,
	   a.SBD_CAPA_SCAR_COST_TRANSPORTATION_P AS Transportation_Cost,
       a.SBD_SCAR_WARRANTY_COST_P AS Warranty_Cost,
       a.SBD_CAPA_SCAR_COST_TOTAL_P AS Total_Cost,
	     a.SBD_SCAR_8D_OI_SUPPLIER_NAME_P AS Supplier_Name,
	   	 a.SBD_CAPA_SCAR_ROOT_CAUSE_CODE_P AS RCA_DEFECT_CODE,
	     a.SBD_CAPA_SCAR_RCA_DETECTION_CAUSE_CODE_P AS RCA_DETECTION_CODE,
	     a.SBD_CAPA_SCAR_RCA_SYSTEMIC_CAUSE_CODE_P AS RCA_SYSTEMIC_CODE,
	   b.Hierarchical_Name,
	   CASE WHEN b.Hierarchical_Name LIKE '%GTS%' THEN 'GTS'
            WHEN b.Hierarchical_Name LIKE '%: IND :%' THEN 'IND'
		    WHEN b.Hierarchical_Name LIKE '%: IND' THEN 'IND'
			WHEN b.Hierarchical_Name LIKE '%Security%' THEN 'Security'
			WHEN b.Hierarchical_Name LIKE '%: OTD :%' THEN 'OTD'
			WHEN b.Hierarchical_Name LIKE '%: OTD%' THEN 'OTD'
			WHEN b.Hierarchical_Name LIKE 'SBD' THEN 'SBD'
			ELSE NULL END AS Business,
	   CASE WHEN b.Hierarchical_Name LIKE '%: SAT :%' THEN 'SAT'
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
			ELSE 'NA' END AS Division,
			CONCAT('https://stanleybd.etq.com/prod/rel/#/app/system/document/CORRACT/SCAR_DOCUMENT/', a.SCAR_ID) AS Link
FROM
(
SELECT LINK_FORM_ID, 
       SCAR_ID,
       ETQ_CREATED_DATE,
       ETQ_COMPLETED_DATE,
       ETQ_DUE_DATE,
       ETQ_CURRENT_PHASE,
       ETQ_LAST_EDITOR,
       ETQ_MODIFIED_DATE,
       ETQ_NUMBER,
       SBD_SCAR_8D_OI_PART_NAME_P,
       SBD_SCAR_8D_OI_PART_NUMBER_P,
       SBD_SCAR_8D_OI_PART_PROCESS_CB_P,
       SCAR_DEPARTMENT,
       SBD_CAPA_SCAR_MANUFACTURING_LOCATIONS_P,
       SBD_CAPA_SCAR_SC_PART_P,
       SBD_CAPA_SCAR_ORIGIN_P,
       SBD_CAPA_SCAR_ORIGINATOR_P,
       SBD_CAPA_SCAR_SEVERITY_P,
       SBD_CAPA_SCAR_COST_ADMINISTRATIVE_P,
	     SBD_CAPA_SCAR_COST_SAVINGS_EQUIPMENT_P,
	     SBD_CAPA_SCAR_COST_LABOR_P,
	     SBD_CAPA_SCAR_COST_MATERIALS_P,
	     SBD_CAPA_SCAR_COST_OTHER_P,
	     SBD_CAPA_SCAR_COST_TRANSPORTATION_P,
       SBD_SCAR_WARRANTY_COST_P,
       SBD_CAPA_SCAR_COST_TOTAL_P,
	     SBD_SCAR_8D_OI_SUPPLIER_NAME_P,
	     SBD_CAPA_SCAR_ROOT_CAUSE_CODE_P,
	     SBD_CAPA_SCAR_RCA_DETECTION_CAUSE_CODE_P,
	     SBD_CAPA_SCAR_RCA_SYSTEMIC_CAUSE_CODE_P
       FROM [StanleyBDQDL].[ODT].[CORRACT_SCARDOCUMENT_S]
) a
LEFT OUTER JOIN
(
SELECT [LINK_FORM_ID],
       [SCAR_ID],
       MAX(CASE WHEN FIELD_NAME = 'HIERARCHICAL_NAME' THEN FIELD_VALUE
        ELSE NULL END) AS Hierarchical_Name
       FROM [StanleyBDQDL].[ODT].[CORRACT_SCARDOCUMENT_D]
       GROUP BY LINK_FORM_ID, SCAR_ID, RECORD_ORDER
       HAVING RECORD_ORDER = 1
	   ) b
	   on a.SCAR_ID = b.SCAR_ID
)
                           