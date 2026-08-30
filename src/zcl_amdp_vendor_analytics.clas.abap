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
  METHOD get_vendor_analytics BY DATABASE FUNCTION FOR HDB LANGUAGE SQLSCRIPT OPTIONS READ-ONLY USING ZTB_PO_HDR.

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
