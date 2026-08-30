@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Composite view for Purchase Order'
@Metadata.ignorePropagatedAnnotations: true

define root view entity ZI_ProcureOrderComp
  as select from ZI_ProcureOrder
  composition [0..*] of ZI_PoItem as _POItem
{

  key po_id,
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
        else 'Unknown Status'
      end                                                                                                   as status_text,

      case
        when total_amount >= 50000.00 then 'HIGH VALUE'
        when total_amount between 10000.00 and 49999.99 then 'MEDIUM VALUE'
        else 'STANDARD'
      end                                                                                                   as order_tier,

      @Semantics.amount.currencyCode: 'currency_code'
      cast( get_numeric_value( total_amount ) / 10 as abap.dec( 13, 2 ) ) * cast( 0.1 as abap.dec( 3, 2 ) ) as discount_amount,

      created_at,

      _POItem
}
