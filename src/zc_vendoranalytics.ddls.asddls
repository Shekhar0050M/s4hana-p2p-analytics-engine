@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption View - Vendor Analytics'

@UI.headerInfo: {
    typeName: 'Vendor Analytics',
    typeNamePlural: 'Vendor Analytics',
    title: {
        type: #STANDARD,
        value: 'vendor_id'
    }
}

define root view entity ZC_VendorAnalytics
  as select from ZI_VendorAnalytics
{
    @UI.lineItem: [{ position: 10, label: 'Vendor ID' }]
    @UI.identification: [{ position: 10, label: 'Vendor ID' }]
    key vendor_id,

    @Semantics.amount.currencyCode: 'currency_code'
    @UI.lineItem: [{ position: 20, label: 'Total Spend' }]
    @UI.identification: [{ position: 20, label: 'Total Spend' }]
    total_spend,

    @UI.lineItem: [{ position: 30, label: 'Currency' }]
    currency_code,

    @UI.lineItem: [{ position: 40, label: 'Order Count' }]
    order_count,

    @UI.lineItem: [{ position: 50, label: 'Risk Category' }]
    risk_category
}
