@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption view for Purchase Order'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true

@UI.headerInfo: {
    typeName: 'Purchase Order',
    typeNamePlural: 'Purchase Orders',
    title: { type: #STANDARD, value: 'po_id' },
    description: { type: #STANDARD, value: 'vendor_name' }
}

define root view entity ZC_ProcureOrder
  provider contract transactional_query
  as projection on ZI_ProcureOrderComp
{
  @UI.facet: [
    { id: 'HeaderDetails', purpose: #STANDARD, type: #IDENTIFICATION_REFERENCE, label: 'General Information', position: 10 },
    { id: 'Financials',    purpose: #STANDARD, type: #FIELDGROUP_REFERENCE, targetQualifier: 'FinancialGroup', label: 'Financial Details', position: 20 },
    { id: 'ItemDetails',   purpose: #STANDARD, type: #LINEITEM_REFERENCE, label: 'Line Items', position: 30, targetElement: '_POItem' },
    { id: 'VendorAnalytics', purpose: #STANDARD, type: #IDENTIFICATION_REFERENCE, label: 'Vendor Spend & Risk', position: 40, targetElement: '_VendorAnalytics' }
  ]

  @UI.lineItem: [{ position: 10, label: 'Purchase Order ID' }]
  @UI.identification: [{ position: 10, label: 'Purchase Order ID' }]
  @UI.selectionField: [{ position: 10 }]
  @Search.defaultSearchElement: true
  key po_id,

  @UI.lineItem: [{ position: 20, label: 'Vendor Name' }]
  @UI.identification: [{ position: 20, label: 'Vendor Name' }]
  @UI.selectionField: [{ position: 20 }]
  @Search.defaultSearchElement: true
  vendor_name,

  vendor_name_upper,
  po_summary_string,

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
  status_text,

  @UI.lineItem: [{ position: 70, label: 'Order Tier' }]
  order_tier,

  @Semantics.amount.currencyCode: 'currency_code'
  @UI.lineItem: [{ position: 80, label: 'Discount Amount' }]
  @UI.fieldGroup: [{ qualifier: 'FinancialGroup', position: 30, label: 'Calculated Discount' }]
  discount_amount,

  @UI.lineItem: [{ position: 90, label: 'Created At' }]
  created_at,

  /* Associations – this is the critical part */
  _POItem: redirected to composition child ZC_PoItem01,
  _VendorAnalytics
}
