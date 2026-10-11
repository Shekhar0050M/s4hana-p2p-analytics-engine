@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Vendor Master Consumption'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true

@UI.headerInfo: {
  typeName: 'Vendor',
  typeNamePlural: 'Vendors',
  title: { type: #STANDARD, value: 'vendor_id' },
  description: { type: #STANDARD, value: 'vendor_name' }
}

define view entity ZC_Vendor01
  as select from ZI_VENDOR01
{
      @EndUserText.label: 'Vendor ID'
      @UI.lineItem: [{ position: 10 }]
      @UI.identification: [{ position: 10 }]
      @Search.defaultSearchElement: true
      @UI.selectionField: [{ position: 10 }]
  key vendor_id,

      @EndUserText.label: 'Vendor Name'
      @UI.lineItem: [{ position: 20 }]
      @UI.identification: [{ position: 20 }]
      @Search.defaultSearchElement: true
      @UI.selectionField: [{ position: 20 }]
      vendor_name,

      @EndUserText.label: 'Country'
      @UI.lineItem: [{ position: 30 }]
      @UI.identification: [{ position: 30 }]
      country,

      @EndUserText.label: 'City'
      @UI.lineItem: [{ position: 40 }]
      city,

      @EndUserText.label: 'Payment Terms'
      @UI.lineItem: [{ position: 50 }]
      payment_terms,

      @EndUserText.label: 'Risk Score'
      @UI.lineItem: [{ position: 60 }]
      @UI.identification: [{ position: 40 }]
      risk_score,

      @EndUserText.label: 'Active'
      @UI.lineItem: [{ position: 70 }]
      is_active
}
