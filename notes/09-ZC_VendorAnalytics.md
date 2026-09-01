# ZC_VendorAnalytics

**Type**: CDS Root View Entity (Consumption)  
**Layer**: Consumption / UI  
**File**: `src/zc_vendoranalytics.ddls.asddls`

## Purpose
UI-ready consumption view for vendor analytics.  
Adds header information and line-item annotations so it can be used as a facet or standalone list.

## Full Source Code

```abap
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
```

## Block-by-Block Explanation

### Header Info
```abap
@UI.headerInfo: {
    typeName: 'Vendor Analytics',
    typeNamePlural: 'Vendor Analytics',
    title: { type: #STANDARD, value: 'vendor_id' }
}
```
- **Why**: Controls the title area of the Object Page / List Report.  
- **Function**: `typeName` is the singular label, `title` decides which field is shown as the main title.  
- **Relevance**: Pure UI annotation – no impact on data.

### Line Item & Identification annotations
```abap
@UI.lineItem: [{ position: 10, label: 'Vendor ID' }]
@UI.identification: [{ position: 10, label: 'Vendor ID' }]
```
- **`@UI.lineItem`** → appears in the table/list view.  
- **`@UI.identification`** → appears in the Object Page header / identification section.  
- **Why both**: Different UI areas need the same field.  
- **Relevance**: Enables zero-code Fiori Elements UI.

## Linked Objects
- **Source**: [[08-ZI_VendorAnalytics]]
- **Associated from**: [[05-ZI_ProcureOrderComp]] and [[10-ZC_ProcureOrder]]
- **Exposed in service**: [[12-ZUI_PROCUREORDER_O2]]

## Relevance
This view makes the analytics result **UI-ready**.  
It is referenced both as a standalone entity and as a facet of the Purchase Order object page.
