@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View Wrapper Vendor Analytics'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_VendorAnalytics as select from ZTF_VendorAnalytics( input_parameter: 1 )
{
    key vendor_id,
    @Semantics.amount.currencyCode: 'currency_code'
    total_spend,
    currency_code,
    order_count,
    risk_category
}
