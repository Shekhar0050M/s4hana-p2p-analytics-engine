@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Order Header Tabl'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_ProcureOrder as select from ztb_po_hdr
{
    key po_id,
        vendor_name,
        @Semantics.amount.currencyCode: 'currency_code'
        total_amount,
        currency_code,
        status,
        created_at
}
