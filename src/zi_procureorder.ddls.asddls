@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Order Header Tabl'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_ProcureOrder as select from ztb_po_hdr

/* Interview Note: 
     Compositions require a strict two-way handshake with the child's 
     'association to parent'. If the compiler hits a metadata cache lock 
     during circular dependency compilation, renaming the composition alias 
     forces the repository to drop the old cache and re-evaluate from scratch. */
composition [0..*] of ZI_PoItem as _POItem 
{
    key po_id,
        vendor_name,
        @Semantics.amount.currencyCode: 'currency_code'
        total_amount,
        currency_code,
        status,
        created_at,
        
        _POItem
}
