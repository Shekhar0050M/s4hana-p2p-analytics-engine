@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO Item Storage'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_PoItem as select from ztb_po_item
association to parent ZI_ProcureOrder as _ProcureOrder on $projection.po_id = _ProcureOrder.po_id
{
    @UI.lineItem: [{ position: 10, label: 'PO ID' }]
    key po_id,
    
    @UI.lineItem: [{ position: 20, label: 'Item ID' }]
    key item_id,
    
    @UI.lineItem: [{ position: 30, label: 'Material' }]
    material,
    
    @Semantics.quantity.unitOfMeasure: 'unit'
    @UI.lineItem: [{ position: 40, label: 'Quantity' }]
    quantity, 
    
    @UI.lineItem: [{ position: 50, label: 'Unit' }]
    unit,
    
    _ProcureOrder
}
