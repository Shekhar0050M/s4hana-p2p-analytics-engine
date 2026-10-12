@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO Item Consumption'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true

@UI.headerInfo: {
    typeName: 'Purchase Order Item',
    typeNamePlural: 'Purchase Order Items',
    title: { type: #STANDARD, value: 'item_id' },
    description: { type: #STANDARD, value: 'material' }
}

define view entity ZC_PoItem01
  as projection on ZI_PoItem
{

      /* Sub-Object Page Facet: Renders details when a line item is clicked */
      @UI.facet: [
        {
          id: 'ItemDetails',
          purpose: #STANDARD,
          type: #IDENTIFICATION_REFERENCE,
          label: 'Item Details',
          position: 10
        }
      ]  
        
      @EndUserText.label: 'Purchase Order ID'
      @UI.lineItem: [{ position: 1 }]
      @UI.identification: [{ position: 1 }]
  key po_id,

      @EndUserText.label: 'Item ID'
      @UI.lineItem: [{ position: 10 }]
      @UI.identification: [{ position: 10 }]
  key item_id,

      @EndUserText.label: 'Material'
      @UI.lineItem: [{ position: 20 }]
      @UI.identification: [{ position: 20 }]
      material,

      @EndUserText.label: 'Quantity'
      @Semantics.quantity.unitOfMeasure: 'unit'
      @UI.lineItem: [{ position: 30 }]
      @UI.identification: [{ position: 30 }]
      quantity,

      @EndUserText.label: 'Unit'
      @UI.lineItem: [{ position: 40 }]
      @UI.identification: [{ position: 40 }]
      unit,

      @EndUserText.label: 'Currency Code'
      @UI.lineItem: [{ position: 50 }]
      @UI.identification: [{ position: 50 }]
      currency_code,

      @EndUserText.label: 'Net Amount'
      @UI.lineItem: [{ position: 60 }]
      @UI.identification: [{ position: 60 }]
      @Semantics.amount.currencyCode: 'currency_code'
      net_amount,

      /* MUST point to the parent projection */
      _ProcureOrderComp : redirected to parent ZC_ProcureOrder
}
