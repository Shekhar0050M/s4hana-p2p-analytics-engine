@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Composite view for Purchase Order'
@Metadata.ignorePropagatedAnnotations: true

define root view entity ZI_ProcureOrderComp
  as select from ZI_ProcureOrder
  composition [0..*] of ZI_PoItem          as _POItem
  association [0..1] to ZC_VendorAnalytics as _VendorAnalytics on $projection.po_id = _VendorAnalytics.vendor_id
  association [0..1] to ZI_VENDOR01        as _Vendor          on $projection.vendor_id = _Vendor.vendor_id
{

  key po_id,
      vendor_id,
      vendor_name,

      upper( vendor_name )                                                                                  as vendor_name_upper,
      concat_with_space( po_id, vendor_name, 1 )                                                            as po_summary_string,

      @Semantics.amount.currencyCode: 'currency_code'
      total_amount,
      currency_code,

      status,

      case status
        when 'A' then 'Approved'
        when 'N' then 'New / Pending'
        when 'R' then 'Rejected'
        when 'C' then 'Completed'
        when 'X' then 'Cancelled'
        else 'Unknown Status'
      end                                                                                                   as status_text,

      case status
        when 'A' then 3  -- 3: Positive (Green)
        when 'N' then 2  -- 2: Critical (Yellow/Orange)
        when 'R' then 1  -- 1: Negative (Red)
        when 'C' then 3  -- 3: Positive (Green)
        when 'X' then 1  -- 1: Negative (Red)
        else 0           -- 0: Neutral (Grey)
      end                                                                                                   as status_criticality,

      case
        when total_amount >= 50000.00 then 'HIGH VALUE'
        when total_amount between 10000.00 and 49999.99 then 'MEDIUM VALUE'
        else 'STANDARD'
      end                                                                                                   as order_tier,
      
      case
        when total_amount >= 50000.00 then 1                    -- 1: Attention / High Exposure (Red)
        when total_amount between 10000.00 and 49999.99 then 2  -- 2: Medium (Yellow)
        else 3                                                  -- 3: Standard / Low Risk (Green)
      end                                                                                                   as order_tier_criticality,
      

      @Semantics.amount.currencyCode: 'currency_code'
      cast( get_numeric_value( total_amount ) / 10 as abap.dec( 13, 2 ) ) * cast( 0.1 as abap.dec( 3, 2 ) ) as discount_amount,

      created_at,

      _POItem,
      _VendorAnalytics,
      _Vendor
}
