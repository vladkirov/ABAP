      SELECT DISTINCT
          equnr,
          zztype01
        FROM ztpm_equip_plan AS plan
        WHERE equnr IN @lr_equnr
          AND datab > @iv_date
        INTO TABLE @lt_eq_plan.

      DATA(lt_eq_plan_wo_zztype) =
        filter tt_tpo_eq_plan( lt_eq_plan EXCEPT in mt_data WHERE equnr  = equnr
                                                              and zztype = zztype01 ).
      
      DATA(lt_equnr_type) = CORRESPONDING tt_r_equnr( mt_data from lt_equnr_type USING ).
=========
   DATA(lr_equnr) =  VALUE tt_r_equnr( FOR <lv_equnr> IN iht_equnr
                                          sign = 'I' option = 'EQ' ( low = <lv_equnr> ) ).

=========
    SELECT DISTINCT
        'I' AS sign,
        'EQ' AS option,
        equnr AS low,
        @abap_false AS high
      FROM ztpm_equip_plan AS plan
      WHERE equnr IN @lr_equnr
        AND datab > @iv_date
      INTO TABLE @er_equnr.

=========
        lr_packs = VALUE #( FOR <ls_auf> IN lt_afvgd
                            WHERE ( packno IS NOT INITIAL )
                            sign = 'I' option = 'EQ' ( low = <ls_auf>-packno ) ).
        SORT lr_packs BY low ASCENDING.
        DELETE ADJACENT DUPLICATES FROM lr_packs.

=========		
      lr_objnr = VALUE #( FOR <ls_resb> IN mst_resb ( sign = 'I'
                                                      option = 'EQ'
                                                      low = <ls_resb>-objnr ) ).		
													  
========
    DATA lr_matnr TYPE RANGE OF matnr.

    lr_matnr = VALUE #( FOR <ls_bseg> IN it_bseg
                        ( sign   = 'I'
                          option = 'EQ'
                          low    = <ls_bseg>-matnr  ) ).

    DELETE ADJACENT DUPLICATES FROM lr_matnr COMPARING low.
    
========	
1)	count lines in internal table with where condition
SELECT *
 FROM mara
 INTO TABLE @DATA(lt_mara)
 UP TO 10 ROWS.

DATA(lv_count) = REDUCE i( INIT i = 0 FOR wa IN lt_mara WHERE ( aenam EQ 'MARSLAN' ) NEXT i = i + 1 ).

TYPES:
  BEGIN OF ty_material,
    matnr TYPE char40,
    maktx     TYPE char40,
    matkl     TYPE char9,
  END   OF ty_material.
DATA: lt_materials TYPE STANDARD TABLE OF ty_material.
TYPES: tt_mara TYPE TABLE OF mara WITH EMPTY KEY.
DATA(count) = lines( VALUE tt_mara( FOR line IN lt_mara WHERE ( matnr = 'XXX' ) ( line ) ) ).
========

2)	get the unique material groups, use WITHOUT MEMBERS
LOOP AT lt_materials INTO DATA(ls_materials)
     GROUP BY  ( matkl = ls_materials-matkl size = GROUP SIZE )
      ASCENDING
      WITHOUT MEMBERS
      REFERENCE INTO DATA(matkl_group).
 
  WRITE: / matkl_group->matkl, matkl_group->size.
========

3)	    " Сгруппировать по ключу, создать новую строку в таблице экспортной и суммировать количество
    LOOP AT lst_orders_cleared ASSIGNING FIELD-SYMBOL(<ls_order_clear>)
        GROUP BY ( matnr   = <ls_order_clear>-matnr
                   werks   = <ls_order_clear>-werks
                   umwrk   = <ls_order_clear>-umwrk
                   umlgo   = <ls_order_clear>-umlgo )
        ASSIGNING FIELD-SYMBOL(<ls_clear_group>).

      DATA(ls_order_pm) = REDUCE lts_orders_pm_raw(
        INIT ls_sum = CORRESPONDING lts_orders_pm_raw( <ls_clear_group> )
        FOR <ls_member> IN GROUP <ls_clear_group>
        NEXT ls_sum-vmeng = ls_sum-vmeng + <ls_member>-vmeng - <ls_member>-enmng ).

      INSERT CORRESPONDING #( ls_order_pm MAPPING menge = vmeng ) INTO TABLE est_orders_pm.
    ENDLOOP.
========

4)   DATA(lst_obj_stat) =
        VALUE ltt_obj_stat(
          FOR <ls_os> IN CORRESPONDING ltt_obj_stat_h( lst_orders_pm_raw DISCARDING DUPLICATES ) (
            objnr = COND #( WHEN check_order_finish_status( iv_objnr = <ls_os>-objnr
                                                            iv_stsma = <ls_os>-stsma )
                            THEN <ls_os>-objnr
                            ELSE abap_true )
            stsma = <ls_os>-stsma
          )
        ).
========

5)	lr_matnr = VALUE #( ( sign   = 'E' option = 'CP' low = '*' )  ).
zcl_generic=>add2range( exporting i_sign = 'E' i_option = 'CP' i_low = '*' changing ct_range = <lt_table> ).
========

6)	Поиск максимума в структуре:
  DATA(ls_maximum) = REDUCE lts_kurztext(
                       INIT ls_max = VALUE lts_kurztext( )
                       FOR <ls_text> IN lt_texts
                       NEXT ls_max = nmax( val1 = <ls_text>-version
   val2 = ls_max-version ) ).
========
7) MESSAGE ID sy-msgid   "Nachrichtenklasse
      TYPE sy-msgty   "Typ (E = Error, S = Success, I = Info, A = Abbruch)
    NUMBER sy-msgno   "Nachrichtennummer
      WITH sy-msgv1   "Platzhaltervariable1
           sy-msgv2   "Platzhaltervariable2
           sy-msgv3   "Platzhaltervariable3
           sy-msgv4.  "Platzhaltervariable4
========
8) Нецикличное обновление
https://www.sapboard.ru/forum/viewtopic.php?p=585652
SY-ONCOM = 'V' => FUNCTION ... IN UPDATE TASK
SY-ONCOM = 'P' => PERFORM ... ON COMMIT
SY-ONCOM = 'T' => процесс запущен кодом транзакции
SY-ONCOM = 'N' when called from Dynamic action and
SY-ONCOM = 'S' when called executed directly.

if CAUFVD_IMP-AUART = 'PM51' and CAUFVD_IMP-iphas = '2' and sy-oncom <> 'X'.
  CALL FUNCTION 'Z_PM_V2_ORDER_UPDATE' IN UPDATE TASK
    EXPORTING
      i_aufnr = CAUFVD_IMP-aufnr.
 endif.		   
 
 CALL FUNCTION 'Z_PM_RFC_ORDER_CHANGE'
      IN BACKGROUND TASK
      DESTINATION 'NONE'
      EXPORTING
        i_aufnr = i_aufnr.
		
SET UPDATE TASK LOCAL.
CALL FUNCTION 'BAPI_ALM_ORDER_MAINTAIN'
  TABLES
	it_methods = lt_methods
	it_srule   = lt_srule
	return     = lt_return.

COMMIT WORK AND WAIT.		

DATA lv_message TYPE th_popup.
lv_message = | Hey from RFC from user { sy-uname } |.
CALL FUNCTION 'TH_POPUP'
EXPORTING
  client  = '500'
  user    = 'BRIUKHANOVIN'
  message = lv_message.

  ASSIGN ('(SAPLCOIH)CAUFVD') TO <ls_caufvd>.
  IF sy-subrc = 0.
    DATA(lv_kokrs) = <ls_caufvd>-kokrs.
  ENDIF.

================================
9)Получение UTC короткого времени
cl_abap_tstmp=>utclong2tstmp_short( utclong_current( ) )
================================
10) Все поля структуры не initial
 METHOD is_all_fields_filled_in_zssp.
    IF ms_zssp_pm188_main IS INITIAL.
      RETURN.
    ENDIF.

    DO.
      ASSIGN COMPONENT sy-index OF STRUCTURE ms_zssp_pm188_main TO FIELD-SYMBOL(<lv_value>).
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.
      IF <lv_value> IS INITIAL.
        RETURN.
      ENDIF.
    ENDDO.

    rv_all = abap_true.
  ENDMETHOD.
=================================
11) заполнение RANGE
    DATA(lr_dgr_id) = VALUE tr_dgr_id(
                        FOR GROUPS <ls_gr_mh> OF <ls_mh> IN et_mh1
                            GROUP BY ( dgr_id = <ls_mh>-dgr_id ) ASCENDING
                            WITHOUT MEMBERS
                            ( sign = 'I'  option = 'EQ'  low = <ls_gr_mh>-dgr_id ) ).
=================================
12) jest не существуют
        AND NOT EXISTS ( SELECT jest~objnr
                           FROM jest
                           WHERE jest~objnr = aufk~objnr
                             AND jest~stat  = @ms_zssp_pm188_main-stat_dlfl
                             AND jest~inact = @abap_false )						
=================================
13) маска адреса регулярное
    CONSTANTS:
      lc_date_mask      TYPE string VALUE '^(0[1-9]|[12][0-9]|3[01])[- /.](0[1-9]|1[012])[- /.](19|20)\d\d$',							 
=================================
14) валидация даты
DATA(date) = CONV d( '20160231' ).

date = COND #( WHEN date = '00010101' OR date <> 0 THEN date
               ELSE THROW cx_sy_conversion_no_date( ) ).	  
=================================
15) присвоение по стеку
FIELD-SYMBOLS: <lt_fcat> TYPE slis_t_fieldcat_alv.
ASSIGN ('(RIQMEL20)G_FIELDCAT_TAB') TO <lt_fcat>.			   
=================================
16) дата из ДД.ММ.ГГГГ
LV_DATE_SOURCE+6(4)
LV_DATE_SOURCE+3(2)
LV_DATE_SOURCE(2)
=================================
17) имя переменной rtts

DATA(lv_name_elem) = CAST cl_abap_elemdescr( cl_abap_elemdescr=>describe_by_data( lv_zzrepint ) )->get_ddic_field( )-scrtext_l.
=================================
18) корректность даты проверяется сравнением её с числом: некорректное значение не даст числа
=================================
19) регулярка на даты:
DATA:
  lv_source   TYPE string VALUE `12.05.2021`,
  lv_source2  TYPE string VALUE `2021-05-12`,
  lv_pattern  TYPE datum,
  lv_pattern2 TYPE datum.

FIND FIRST OCCURRENCE OF REGEX '^\d{4}[-](0[1-9]|1[012])[-](0[1-9]|[12][0-9]|3[01])$' IN lv_source2.
IF sy-subrc = 0.
  lv_pattern2 = |{ lv_source2(4) }{ lv_source2+5(2) }{ lv_source2+8(2) }|.
ENDIF.

FIND FIRST OCCURRENCE OF REGEX '^(0[1-9]|[12][0-9]|3[01])[/.](0[1-9]|1[012])[/.]\d{4}$' IN lv_source.
IF sy-subrc = 0.
  lv_pattern = |{ lv_source+6(4) }{ lv_source+3(2) }{ lv_source(2) }|.
ENDIF.
=================================
20) Собрать строку из значений одного из полей таблицы
    TYPES:
      BEGIN OF lts_bfunc,
        bfunc TYPE zepp_operation_reg_fact,
      END OF lts_bfunc,

      ltt_bfunc TYPE STANDARD TABLE OF lts_bfunc WITH EMPTY KEY.

    DATA(lv_str) = concat_lines_of( table = VALUE ltt_bfunc( FOR <ls_row> IN ms_sscr_params-r_bfunc_rf
                                                             WHERE ( low IS NOT INITIAL )
                                                             ( bfunc = <ls_row>-low ) )
                                    sep   = `, ` ).
=================================
21)         " Конвертация ЕИ в базовую
        " Конвертация ЕИ в базовую
        CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
          EXPORTING
            input    = lref_mdsm->erfmg
            unit_in  = lref_mdsm->erfme
            unit_out = lv_meins
          IMPORTING
            output   = lv_menge
          EXCEPTIONS
            OTHERS   = 1.
=================================
22)   METHOD get_last_day_of_month.
    rv_date = iv_date.
    rv_date+6(2) = '01'.
    rv_date += 31.
    rv_date+6(2) = '01'.
    rv_date -= 1.
  ENDMETHOD.
=================================  
23) получить методы класса
  METHOD get_current_class_methods.
    CLEAR et_methods[].

    DATA(lo_class) = CAST cl_abap_classdescr( cl_abap_objectdescr=>describe_by_data( me ) ).
    et_methods = VALUE tt_method( FOR <ls_method> IN lo_class->methods
                                  WHERE ( is_inherited = abap_true )
                                  ( <ls_method>-name ) ).
  ENDMETHOD.			
=================================
24) Уникальные значения поля в таблице атрибута класса
    DATA(lt_orders) =
      VALUE tb_bapi_order_key(
        FOR GROUPS <ls_gr_data> OF <ls_data> IN mt_data
        GROUP BY ( aufnr = <ls_data>-aufnr )
        WITHOUT MEMBERS
        ( order_number = <ls_gr_data>-aufnr )  ).  
