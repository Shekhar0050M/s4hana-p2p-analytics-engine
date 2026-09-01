# ZCL_AMDP_VENDOR_ANALYTICS

**Type**: ABAP Class (AMDP)  
**Layer**: Analytics / Database Logic  
**File**: `src/zcl_amdp_vendor_analytics.clas.abap`

## Purpose
Contains the actual **SQLScript** implementation that runs inside the HANA database.  
Performs aggregation of purchase-order spend per vendor and assigns a simple risk category.

## Full Source Code

```abap
CLASS zcl_amdp_vendor_analytics DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_amdp_marker_hdb .

    CLASS-METHODS get_vendor_analytics
      FOR TABLE FUNCTION ztf_vendoranalytics.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_amdp_vendor_analytics IMPLEMENTATION.
  METHOD get_vendor_analytics 
    BY DATABASE FUNCTION FOR HDB 
    LANGUAGE SQLSCRIPT 
    OPTIONS READ-ONLY 
    USING ZTB_PO_HDR.

    lt_spend = select client,
                      po_id as vendor_id,
                      sum(total_amount) as total_spend,
                      currency_code,
                      count(*) as order_count
                 from ztb_po_hdr
                group by client, po_id, currency_code;

    return select client,
                  vendor_id,
                  total_spend,
                  currency_code,
                  order_count,
                  case
                    when total_spend > 50000 then 'HIGH'
                    when total_spend > 10000 then 'MEDIUM'
                    else 'LOW'
                  end as risk_category
             from :lt_spend;

  ENDMETHOD.
ENDCLASS.
```

## Block-by-Block Explanation

### Marker Interface
```abap
INTERFACES if_amdp_marker_hdb .
```
- **Why**: Mandatory for any class that contains AMDP methods.  
- **Function**: Tells the ABAP runtime that this class can contain database procedures/functions.  
- **Relevance**: Without it the `BY DATABASE` syntax is not allowed.

### Method signature for Table Function
```abap
CLASS-METHODS get_vendor_analytics
  FOR TABLE FUNCTION ztf_vendoranalytics.
```
- **Why**: Links the method to the CDS Table Function defined earlier.  
- **Function**: The method must return a result set that matches the TF signature.  
- **Relevance**: Type-safe contract between CDS and AMDP.

### AMDP Method Header
```abap
METHOD get_vendor_analytics 
  BY DATABASE FUNCTION FOR HDB 
  LANGUAGE SQLSCRIPT 
  OPTIONS READ-ONLY 
  USING ZTB_PO_HDR.
```
- **`BY DATABASE FUNCTION`** → This is a function (returns a table), not a procedure.  
- **`FOR HDB`** → Only for SAP HANA.  
- **`LANGUAGE SQLSCRIPT`** → The body is written in SQLScript (HANA’s SQL dialect).  
- **`OPTIONS READ-ONLY`** → Declares that the function does not change data (important for optimisation and security).  
- **`USING ZTB_PO_HDR`** → Lists all ABAP Dictionary objects that the SQLScript code is allowed to access.

### Intermediate result (lt_spend)
```abap
lt_spend = select client,
                  po_id as vendor_id,
                  sum(total_amount) as total_spend,
                  currency_code,
                  count(*) as order_count
             from ztb_po_hdr
            group by client, po_id, currency_code;
```
- **Why**: First aggregate the raw header data.  
- **Function**: Classic SQL aggregation.  
- **Note**: In this simplified demo `po_id` is used as `vendor_id` (in a real system you would have a real vendor number).  
- **Relevance**: Shows how to use table variables in SQLScript.

### Final RETURN with Risk Logic
```abap
return select client,
              vendor_id,
              total_spend,
              currency_code,
              order_count,
              case
                when total_spend > 50000 then 'HIGH'
                when total_spend > 10000 then 'MEDIUM'
                else 'LOW'
              end as risk_category
         from :lt_spend;
```
- **Why**: Apply business rule for risk category on the already aggregated data.  
- **Function**: SQL CASE expression.  
- **Relevance**: Demonstrates that complex business logic can live entirely inside the database layer for maximum performance.

## Linked Objects
- **Implements**: [[06-ZTF_VendorAnalytics]]
- **Reads**: [[01-ZTB_PO_HDR]]
- **Result consumed by**: [[08-ZI_VendorAnalytics]]

## Relevance
This class is the **performance-critical** part of the solution.  
By pushing the aggregation and risk scoring into HANA via AMDP, the application layer stays thin and the calculation scales with the database.
