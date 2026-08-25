CLASS zcl_syntax_practice DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_syntax_practice IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

* Inline declaration
    DATA(l_v_name) = 'Shekhar Suman'.
    out->write( l_v_name ).

* Select Statement with Inline declaration
    SELECT SINGLE currency,
                  decimals
           FROM i_currency
           WHERE currency = 'USD'
           INTO @DATA(l_wa_currency).

    out->write( |Select output { l_wa_currency-Currency } { l_wa_currency-Decimals } | ).

* Select Statement with Inline declaration
    SELECT SINGLE currency AS money,
                  decimals AS value
           FROM i_currency
           WHERE currency = 'USD'
           INTO @DATA(l_wa_icurrency).

    out->write( |Select output { l_wa_icurrency-money } { l_wa_icurrency-value } | ).

******************************************************************************************
* 01+practiceCode

    SELECT *
        from i_currency
        INTO TABLE @DATA(l_i_ekko)
        UP TO 10 rows.

    LOOP AT l_i_ekko ASSIGNING FIELD-SYMBOL(<l_fs_ekko>).
        out->write( | { <l_fs_ekko>-Currency } { <l_fs_ekko>-CurrencyISOCode } { <l_fs_ekko>-Decimals } | ).
    ENDLOOP.

******************************************************************************************

  ENDMETHOD.
ENDCLASS.
