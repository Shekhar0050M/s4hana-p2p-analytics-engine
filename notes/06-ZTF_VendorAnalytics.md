# ZTF_VendorAnalytics

**Type**: CDS Table Function  
**Layer**: Analytics  
**File**: `src/ztf_vendoranalytics.ddls.asddls`

## Purpose
Defines the **contract** (input/output signature) of a database function that will be implemented in SQLScript via AMDP.  
Used for vendor-level aggregation (total spend, order count, risk category).

## Full Source Code

```abap
@ClientHandling.algorithm: #SESSION_VARIABLE
@ClientHandling.type: #CLIENT_DEPENDENT
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Vendor Spend Analytics & Risk Scoring'
define table function ZTF_VendorAnalytics
returns
{
  client        : abap.clnt;
  vendor_id     : abap.char(10);
  total_spend   : abap.curr(15,2);
  currency_code : abap.cuky;
  order_count   : abap.int4;
  risk_category : abap.char(10);
}
implemented by method
  zcl_amdp_vendor_analytics=>get_vendor_analytics;
```

## Block-by-Block Explanation

### Client Handling
```abap
@ClientHandling.algorithm: #SESSION_VARIABLE
@ClientHandling.type: #CLIENT_DEPENDENT
```
- **Why**: Table functions that read client-dependent tables must declare how client is handled.  
- **Function**: Uses the current session client automatically.  
- **Relevance**: Prevents cross-client data leakage.

### Return Structure
```abap
returns
{
  client        : abap.clnt;
  vendor_id     : abap.char(10);
  total_spend   : abap.curr(15,2);
  currency_code : abap.cuky;
  order_count   : abap.int4;
  risk_category : abap.char(10);
}
```
- **Why**: Explicitly defines the shape of the result set.  
- **Function**: Acts as the “interface” that the AMDP method must fulfil.  
- **Relevance**: CDS and the AMDP method are loosely coupled via this signature.

### Implementation Link
```abap
implemented by method
  zcl_amdp_vendor_analytics=>get_vendor_analytics;
```
- **Why**: Connects the CDS definition to the real ABAP/SQLScript implementation.  
- **Function**: At runtime the framework calls the AMDP method.  
- **Relevance**: This is the bridge between pure CDS and HANA-native code.

## Linked Objects
- **Implemented by**: [[07-ZCL_AMDP_VENDOR_ANALYTICS]]
- **Consumed by**: [[08-ZI_VendorAnalytics]]

## Relevance
Table Functions are the **recommended way** to expose complex HANA logic (window functions, complex aggregations, predictive, etc.) to the CDS world.  
In this project it calculates vendor risk scoring that would be expensive or impossible in pure CDS.
