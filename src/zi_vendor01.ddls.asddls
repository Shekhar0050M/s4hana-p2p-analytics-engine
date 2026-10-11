@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Vendor Master Interface'
@Metadata.ignorePropagatedAnnotations: true

define view entity ZI_VENDOR01
  as select from ztb_vendor01
{
  key vendor_id,
      vendor_name,
      country,
      city,
      payment_terms,
      risk_score,
      is_active
}
