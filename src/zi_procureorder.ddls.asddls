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
        
        case status
          when 'A' then 'Approved'
          when 'N' then 'New / Pending'
          when 'R' then 'Rejected'
          else 'Unknown Status'
        end as status_text,
        
        case 
          when total_amount >= 50000.00 then 'HIGH VALUE'
          when total_amount between 10000.00 and 49999.99 then 'MEDIUM VALUE'
          else 'STANDARD'
        end as order_tier,
        
        cast( get_numeric_value( total_amount ) / 10 as abap.dec( 13, 2 ) ) as discount_amount,
        
        created_at,
        
        _POItem
}
