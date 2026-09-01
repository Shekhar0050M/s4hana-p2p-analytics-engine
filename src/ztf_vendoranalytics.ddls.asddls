@ClientHandling.algorithm: #SESSION_VARIABLE
@ClientHandling.type: #CLIENT_DEPENDENT
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Vendor Spend Analytics & Risk Scoring'
define table function ZTF_VendorAnalytics
returns
{
  client        : abap.clnt;
  vendor_id         : abap.char(10);
  total_spend   : abap.curr(15,2);
  currency_code : abap.cuky;
  order_count   : abap.int4;
  risk_category : abap.char(10);

}
implemented by method
  zcl_amdp_vendor_analytics=>get_vendor_analytics;