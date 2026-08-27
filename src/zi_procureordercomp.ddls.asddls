@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption view for Purchase Order'
@Metadata.ignorePropagatedAnnotations: true

define root view entity ZI_ProcureOrderComp
  as select from ZI_ProcureOrder
  composition [0..*] of ZI_PoItem as _POItem
{
      @UI.facet: [
        { id: 'HeaderDetails', purpose: #STANDARD, type: #IDENTIFICATION_REFERENCE, label: 'General Information', position: 10 },
        { id: 'Financials', purpose: #STANDARD, type: #FIELDGROUP_REFERENCE, targetQualifier: 'FinancialGroup', label: 'Financial Details', position: 20 },
        { id: 'ItemDetails', purpose: #STANDARD, type: #LINEITEM_REFERENCE, label: 'Line Items', position: 30, targetElement: '_POItem' }
      ]

      @UI.lineItem: [{ position: 10, label: 'Purchase Order ID' }]
      @UI.identification: [{ position: 10, label: 'Purchase Order ID' }]
      @UI.selectionField: [{ position: 10 }]
  key po_id,

      @UI.lineItem: [{ position: 20, label: 'Vendor Name' }]
      @UI.identification: [{ position: 20, label: 'Vendor Name' }]
      @UI.selectionField: [{ position: 20 }]
      vendor_name,

      upper( vendor_name )                                                                                  as vendor_name_upper,
      concat_with_space( po_id, vendor_name, 1 )                                                            as po_summary_string,

      @Semantics.amount.currencyCode: 'currency_code'
      @UI.lineItem: [{ position: 30, label: 'Total Amount' }]
      @UI.identification: [{ position: 30, label: 'Total Amount' }]
      @UI.fieldGroup: [{ qualifier: 'FinancialGroup', position: 10, label: 'Total Amount' }]
      total_amount,

      @UI.lineItem: [{ position: 40, label: 'Currency' }]
      @UI.fieldGroup: [{ qualifier: 'FinancialGroup', position: 20, label: 'Currency' }]
      currency_code,

      @UI.lineItem: [{ position: 50, label: 'Status' }]
      @UI.identification: [{ position: 50, label: 'Status Code' }]
      @UI.selectionField: [{ position: 30 }]
      status,

      @UI.lineItem: [{ position: 60, label: 'Status Description' }]
      case status
        when 'A' then 'Approved'
        when 'N' then 'New / Pending'
        when 'R' then 'Rejected'
        else 'Unknown Status'
      end                                                                                                   as status_text,

      @UI.lineItem: [{ position: 70, label: 'Order Tier' }]
      case
        when total_amount >= 50000.00 then 'HIGH VALUE'
        when total_amount between 10000.00 and 49999.99 then 'MEDIUM VALUE'
        else 'STANDARD'
      end                                                                                                   as order_tier,

      @Semantics.amount.currencyCode: 'currency_code'
      @UI.lineItem: [{ position: 80, label: 'Discount Amount' }]
      @UI.fieldGroup: [{ qualifier: 'FinancialGroup', position: 30, label: 'Calculated Discount' }]
      cast( get_numeric_value( total_amount ) / 10 as abap.dec( 13, 2 ) ) * cast( 0.1 as abap.dec( 3, 2 ) ) as discount_amount,

      @UI.lineItem: [{ position: 90, label: 'Created At' }]
      created_at,

      _POItem
}
