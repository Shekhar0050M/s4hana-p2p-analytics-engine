# ZI_VendorAnalytics

**Type**: CDS View Entity (Interface wrapper)  
**Layer**: Analytics  
**File**: `src/zi_vendoranalytics.ddls.asddls`

## Purpose
Thin interface view that selects from the Table Function.  
Gives a clean CDS entity that can be further projected or associated to.

## Full Source Code

```abap
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View Wrapper Vendor Analytics'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_VendorAnalytics as select from ZTF_VendorAnalytics
{
    key vendor_id,
    @Semantics.amount.currencyCode: 'currency_code'
    total_spend,
    currency_code,
    order_count,
    risk_category
}
```

## Block-by-Block Explanation

```abap
define view entity ZI_VendorAnalytics as select from ZTF_VendorAnalytics
```
- **Why**: Table Functions cannot be used directly in many places (e.g. as association targets in some scenarios).  
- **Function**: Wraps the TF into a regular CDS View Entity.  
- **Relevance**: Standard pattern – always put a thin interface view on top of a Table Function.

```abap
@Semantics.amount.currencyCode: 'currency_code'
total_spend,
```
- Same semantic annotation we already saw for amounts.

## Linked Objects
- **Source**: [[06-ZTF_VendorAnalytics]]
- **Projected by**: [[09-ZC_VendorAnalytics]]
- **Associated from**: [[05-ZI_ProcureOrderComp]]

## Relevance
Keeps the architecture layered and clean.  
The composite BO associates to this view (or its consumption counterpart) instead of talking directly to the Table Function.
