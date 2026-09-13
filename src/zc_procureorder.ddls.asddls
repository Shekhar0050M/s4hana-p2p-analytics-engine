@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption view for Purchase Order'
@Metadata.ignorePropagatedAnnotations: true
//@Metadata.allowExtensions: true
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

  @EndUserText.label: 'Purchase Order ID'
  @UI.lineItem: [{ position: 10 }]
  @UI.identification: [{ position: 10 }]
  @Search.defaultSearchElement: true
  @UI.selectionField: [{ position: 10 }]
  key po_id,

  @EndUserText.label: 'Vendor Name'
  @UI.lineItem: [{ position: 20 }]
  @UI.identification: [{ position: 20 }]
  @UI.selectionField: [{ position: 20 }]
  @Search.defaultSearchElement: true
  vendor_name,

  vendor_name_upper,
  po_summary_string,

  @EndUserText.label: 'Total Amount'
  @Semantics.amount.currencyCode: 'currency_code'
  @UI.lineItem: [{ position: 30 }]
  @UI.identification: [{ position: 30 }]
  @UI.fieldGroup: [{ qualifier: 'FinancialGroup', position: 10 }]
  total_amount,

  @EndUserText.label: 'Currency'
  @UI.lineItem: [{ position: 40 }]
  @UI.fieldGroup: [{ qualifier: 'FinancialGroup', position: 20 }]
  currency_code,

  @EndUserText.label: 'Status'
  @UI.lineItem: [{ position: 50 }]
  @UI.identification: [{ position: 50 }, 
                       { type: #FOR_ACTION, dataAction: 'setComplete', label: 'Set Complete' } ]
  @UI.selectionField: [{ position: 30 }] 
  status,

  @EndUserText.label: 'Status Description'
  @UI.lineItem: [{ position: 60 }]
  status_text,

  @EndUserText.label: 'Order Tier'
  @UI.lineItem: [{ position: 70 }]
  order_tier,

  @EndUserText.label: 'Discount Amount'
  @Semantics.amount.currencyCode: 'currency_code'
  @UI.lineItem: [{ position: 80 }]
  @UI.fieldGroup: [{ qualifier: 'FinancialGroup', position: 30 }]
  discount_amount,

  @EndUserText.label: 'Created At'
  @UI.lineItem: [{ position: 90 }]
  created_at,

  /* Associations – this is the critical part */
  _POItem: redirected to composition child ZC_PoItem01,
  _VendorAnalytics
}
