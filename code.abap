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
                        FOR GROUPS <ls_gr_mh> OF <ls_row_mh> IN et_mh1
                            GROUP BY ( dgr_id = <ls_row_mh>-dgr_id ) ASCENDING
                            WITHOUT MEMBERS
                            ( sign = 'I'  option = 'EQ'  low = <ls_gr_mh>-dgr_id ) ).
=================================
12) jest не существуют
        AND NOT EXISTS ( SELECT jest~objnr
                           FROM jest
                           WHERE jest~objnr = aufk~objnr
                             AND jest~stat  = @ms_zssp-stat_exl
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
        GROUP BY ( aufnr = <ls_data>-aufnr ) ASCENDING
        WITHOUT MEMBERS
        ( order_number = <ls_gr_data>-aufnr )  ).  
=================================
25) Варианты
* >>> PM.099.02
    DATA: lv_report  TYPE rsvar-report,
          lv_variant TYPE rsvar-variant,
          lv_rc      TYPE syst-subrc.

*   1) Preprocessing
    lv_report  = sy-cprog.
    lv_variant = CONV #( |U_{ sy-uname }| ).

*   2) Read variant
    CALL FUNCTION 'RS_VARIANT_EXISTS'
      EXPORTING
          report    = lv_report
          variant   = lv_variant
      IMPORTING
          r_c       = lv_rc
      EXCEPTIONS
          no_report = 1
          others    = 2.
    IF sy-subrc IS INITIAL AND
       lv_rc    IS INITIAL.
*     3) Load variant
      CALL FUNCTION 'RS_SUPPORT_SELECTIONS'
        EXPORTING
            report               = lv_report
            variant              = lv_variant
        EXCEPTIONS
            variant_not_existent = 1
            others               = 2.
      IF sy-subrc IS NOT INITIAL.
*       Err->
      ENDIF.
    ENDIF.
* <<< PM.099.02
=================================
26) Заводы по КЕ
    SELECT DISTINCT werks
      FROM t001w
          JOIN t001k ON t001w~bwkey = t001k~bwkey
      WHERE t001k~bukrs IN ( SELECT DISTINCT bukrs
                               FROM tka02
                               WHERE kokrs IN @s_kokrs )
        AND werks IN @s_werks
      INTO TABLE @DATA(lt_t001w).
=================================
27) выбор минимума по дате и времени
SELECT DISTINCT
objnr,
stat,
FIRST_VALUE(udate) OVER(PARTITION BY objnr, stat ORDER BY udate, utime ) AS min_date,
FIRST_VALUE(utime) OVER(PARTITION BY objnr, stat ORDER BY udate, utime ) AS min_time
FROM jcds
=================================
28) отправить ALV вложением в письме
DATA lv_xls       TYPE xstring.
      lv_xls = _go_salv->to_xml( xml_type = if_salv_bs_xml=>c_type_xlsx ).

      DATA(lo_msg) = NEW cl_bcs_message( ).
      lo_msg->set_subject( 'test' ).

      LOOP AT ls_sel_data-r_email INTO DATA(ls_email).
        lo_msg->add_recipient( iv_address = CONV #( ls_email-low ) ).
      ENDLOOP.

      lo_msg->add_attachment( iv_filename     =  'test.xlsx'
                              iv_contents_bin = lv_xls ).
      lo_msg->set_update_task( abap_false ).
      lo_msg->send( ).
=================================
29) таблицу в текст письма
Ну вообще конечно там не так что отдал таблицу - получи текст.
надо немного "понаписать". в системе наверняка есть примеры по журналу смотри
в целом примерно так:

DATA(lo_doc) = NEW cl_dd_document( ).
lo_doc->add_static_html( .... )
lo_table = lo_doc->add_table( ... ).
lo_column = lo_table->add_column( ... ).
lo_table->new_row( ).
lo_column->add_text( ... )

    lo_doc->merge_document( ).
    DATA(lv_html) = concat_lines_of( table = lo_doc->html_table sep = cl_abap_char_utilities=>cr_lf ).
   data(lt_email_body) = cl_bcs_convert=>string_to_soli( lv_html ).	  
=================================
30) таблицу в html
а) CALL FUNCTION 'WWW_ITAB_TO_HTML'

б) https://github.com/sap-russia/itab2html
=================================
31) язык по умолчанию
zifdev_language_c=>c_s_spras-ru
=================================
32) максимумы
cl_abap_math=>max_int4.
=================================
33) ALV диалоговый выбор попап
 DATA:
          lo_f4    TYPE REF TO cl_reca_gui_f4_popup.

    FIELD-SYMBOLS: <lt_data> TYPE lvc_t_modi.

    SELECT h~code, t~codetxt
      FROM ztfi_receip_in AS h
      LEFT JOIN ztfi_receip_int AS t
        ON: h~code = t~code
      INTO TABLE @DATA(lt_receip_in)
      WHERE t~spras = @sy-langu.

    lo_f4 = cl_reca_gui_f4_popup=>factory_grid( it_f4value = lt_receip_in ).
    lo_f4->set_title( TEXT-002 ).
    lo_f4->display( IMPORTING
                      et_result = lt_receip_in
                      ef_cancelled = DATA(lv_cancelled) ).

    IF lv_cancelled = abap_true.
      RETURN.
    ENDIF.

    READ TABLE lt_receip_in REFERENCE INTO DATA(lref_receip_in) INDEX 1.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    ASSIGN co_event_data->m_data->* TO <lt_data>.
    APPEND VALUE #( row_id = is_row_no-row_id
                    fieldname = 'PAYEECODE'
                    value = lref_receip_in->code )
      TO <lt_data>.
===================================
34) Получить все выделенные строки ALV в результирующую таблицу
    DATA(lt_all_docs) = VALUE ltt_post_doc( FOR <ls_row> IN it_rows
                                            ( CORRESPONDING #( VALUE #( mt_alv[ <ls_row>-index ] OPTIONAL ) ) ) ).
===================================
35) QR-код в ZWWW:
Поменять формат шаблона на DOCX, Взять за пример RSPO_QRCODE_BARCODE_DEBUG, применить cl_abap_zip для замены ранее вставленной в нужное место картинки
===================================
36) Отладка фоновых процессов
Можно в Sm37 отметить джоб, и выполнить команду JDBG, откроется отладчик. Если есть точка остановки в коде, то можно нажать F8, иначе аккуратненько по стеку добраться до нужной программы.
===================================
37) Все статусы из ZSSP для заказа:
SELECT object, COUNT( status )
FROM ***
WHERE status IN range
GROUP BY object
HAVING COUNT( status ) = ( SELECT count( status ) FROM jest WHERE status IN range )
===================================
38) Системные статусы заказа

    SELECT SINGLE @abap_true
      FROM jest
        JOIN tj02t ON tj02t~istat = jest~stat
      WHERE jest~objnr   = @is_header-objnr
        AND jest~inact   = @abap_false
        AND tj02t~spras  = @sy-langu
        AND tj02t~txt04 IN @ms_zssp_pm106-r_sttxt
      INTO @rv_exists.
	  
	  или с буферизацией
	  
    SELECT DISTINCT
        jest~stat
      FROM jest
      WHERE jest~objnr   = @is_header-objnr
        AND jest~inact   = @abap_false
      INTO TABLE @DATA(lt_stat).

    LOOP AT lt_stat ASSIGNING FIELD-SYMBOL(<ls_stat>).
      SELECT SINGLE @abap_true
        FROM tj02t
        WHERE istat = @<ls_stat>-stat
          AND spras = @sy-langu
        INTO @rv_exists.

      IF rv_exists = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.	  
	
==================================
39) Пользовательские статусы заказа
    SELECT SINGLE @abap_true
      FROM jsto
        JOIN jest ON jest~objnr = jsto~objnr
          JOIN tj30t ON tj30t~stsma = jsto~stsma
                    AND tj30t~estat = jest~stat
      WHERE jsto~objnr   = @is_header-objnr
        AND jest~inact   = @abap_false
        AND tj30t~spras  = @sy-langu
        AND tj30t~txt04 IN @ms_zssp_pm106-r_asttx
      INTO @rv_exists.

	или

    SELECT DISTINCT
        jsto~stsma,
        jest~stat
      FROM jsto
        JOIN jest ON jest~objnr = jsto~objnr
      WHERE jsto~objnr   = @is_header-objnr
        AND jest~inact   = @abap_false
      INTO TABLE @DATA(lt_stat).

    LOOP AT lt_stat ASSIGNING FIELD-SYMBOL(<ls_stat>).
      SELECT SINGLE @abap_true
        FROM tj30t
        WHERE stsma = @<ls_stat>-stsma
          and estat = @<ls_stat>-stat
          AND spras = @sy-langu
        INTO @DATA(lv_exists).

      IF lv_exists = abap_true.
        rv_exists = abap_true.
      ENDIF.
    ENDLOOP.
	
==================================
40) иерархическая выборка селектом
  METHOD select_bom.
    CONSTANTS:
      lc_spec_status TYPE stko-stlst VALUE 02,
      lc_spec_type   TYPE stko-stlty VALUE 'M',
      lc_spec_usage  TYPE mast-stlan VALUE '4'.

    WITH
      +bom AS (
        SELECT
            stpo~idnrk AS id,
            mast~matnr AS parent
          FROM mast
            JOIN stko ON stko~stlty =  @lc_spec_type
                     AND mast~stlnr =  stko~stlnr
                     AND mast~stlal =  stko~stlal
                     AND stko~stlst <> @lc_spec_status
              JOIN stas ON stko~stlty = stas~stlty
                       AND stko~stlnr = stas~stlnr
                       AND stko~stlal = stas~stlal
                       AND stas~lkenz = @abap_false
                JOIN stpo ON stas~stlty = stpo~stlty
                         AND stas~stlnr = stpo~stlnr
                         AND stas~stlkn = stpo~stlkn
          WHERE mast~stlan = @lc_spec_usage )

        WITH ASSOCIATIONS (
          JOIN TO MANY +bom AS _tree
            ON +bom~parent = _tree~id )

      SELECT FROM HIERARCHY( SOURCE +bom
                             CHILD TO PARENT ASSOCIATION _tree
                             START WHERE parent = @iv_submt
                             SIBLINGS ORDER BY id
                             MULTIPLE PARENTS NOT ALLOWED )
        FIELDS DISTINCT id
        ORDER BY id
        INTO TABLE @et_bom.
  ENDMETHOD.
====================================
41) Проверка: BAPI или нет

  CALL FUNCTION 'IBAPI_Z_GET_BAPI_FLAG'
    EXCEPTIONS
      bapi_active     = 1
      OTHERS          = 0.
====================================
42)    "Очистка сессии под RFC для сброса стандартного кеша
    CALL FUNCTION 'RFC_CONNECTION_CLOSE'
      EXPORTING
        destination = 'NONE'
      EXCEPTIONS
        OTHERS      = 99.
    IF sy-subrc <> 0.
      "Не нужно ничего делать
    ENDIF.
====================================
43)     "Чтение данных вышестоящего заказа
    CALL FUNCTION 'BAPI_ALM_ORDER_GET_DETAIL' DESTINATION 'NONE'
      EXPORTING
        number          = ms_header_dialog-maufnr
      IMPORTING
        es_header       = ls_header
      TABLES
        et_operations   = lt_operations[]
        et_components   = lt_components[]
        et_servicelines = lt_servicelines "PM.104.04
        return          = lt_return[].
		
====================================
44) Средство поиска хелпер

  DATA(lo_dynpr) = NEW zcldev_f4_dynpr( iv_name_struct = CONV #( gc_s_screen-name_struct )
                                        iv_dyname      = gc_s_screen-dyname
                                        iv_dynumb      = gc_s_screen-dynumb      ).

  lo_dynpr->dynpr_values_read( EXCEPTIONS OTHERS = 99 ).
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  lo_dynpr->set_name_f4( lc_s_shlp-name ).
  lo_dynpr->set_f4_shlpfield( lc_s_shlp-field ).
  lo_dynpr->set_f4_valfield( lc_s_shlp-field ).

  DATA(lv_value) = lo_dynpr->get_dynpr_value( iv_field = lc_field_zzeqart ).

  IF lo_dynpr->view_f4_request( iv_value  = CONV #( lv_value ) ) = abap_true.
    cv_zzeqart = lo_dynpr->get_f4_value( lc_s_shlp-field ).
  ENDIF.
====================================
45) проверки в ракурсе перед сохранением
  LOOP AT total. " Таблица со всеми данными в ракурсе
    IF <action> = aendern OR      "Запись изменена
       <action> = neuer_eintrag.  "Новая запись

      DATA(ls_qm_trust_int) = CORRESPONDING ztqm_trust_int( <vim_total_struc> ).
====================================
46) Цикл по объектам экрана
LOOP AT SCREEN INTO DATA(ls_screen).
MODIFY SCREEN FROM ls_screen.
=============
47)
   zcldev_f4=>file(
    EXPORTING
      iv_window_title = CONV #( TEXT-010 )
      iv_file_filter  = cl_gui_frontend_services=>filetype_excel
    IMPORTING
      ev_file         = p_fname
    EXCEPTIONS
      OTHERS          = 0 ).
	  
===========
48) варианты
    DATA(ls_variant) = VALUE disvariant(
        report = sy-repid
        handle = c_s_variant_handle-head ).
    DATA(lv_exit) = abap_false.

    CALL FUNCTION 'LVC_VARIANT_F4'
      EXPORTING
        is_variant = ls_variant
        i_save     = 'A'
      IMPORTING
        e_exit     = lv_exit
        es_variant = ls_variant
      EXCEPTIONS
        OTHERS     = 1.

    IF sy-subrc = 0 AND lv_exit = abap_false.
      cv_variant = ls_variant-variant.
    ENDIF.
	
===================
49) статусы
    DATA: lt_statuses TYPE alm_me_user_status_changes_t.

    CALL FUNCTION 'ALM_ME_READ_SYSTEM_STATUS'
      EXPORTING
        object_no            = is_header-objnr
      TABLES
        system_status        = lt_statuses
      EXCEPTIONS
        error_reading_status = 1
        OTHERS               = 99.

    IF sy-subrc = 0.
      LOOP AT lt_statuses ASSIGNING FIELD-SYMBOL(<ls_status>)
                          WHERE user_status_code IN ms_zssp_pm106-r_sttxt.
        rv_exists = abap_true.
      ENDLOOP.
    ENDIF.	
====================
50) Исключения и логи
  METHOD add_err_exc_messages_to_log.
    DATA(lt_return) = VALUE bapiret2_t( ).

    CALL FUNCTION 'RS_EXCEPTION_TO_BAPIRET2'
      EXPORTING
        i_r_exception = io_exception
      CHANGING
        c_t_bapiret2  = lt_return.

    DATA(lt_ret) = VALUE bapiret2_t( FOR <ls_return> IN lt_return
                                     WHERE ( type CA 'EAX' )
                                     ( <ls_return> ) ).

    io_log->add_from_bapi( it_bapiret = lt_ret ).

    IF io_exception->mo_msg_cont IS BOUND.
      io_exception->mo_msg_cont->get_list_as_bapiret( IMPORTING et_list = DATA(lt_err_mess) ).

      DATA(lt_ret_cont) = VALUE bapiret2_t( FOR <ls_err_mess> IN lt_err_mess
                                            WHERE ( type CA 'EAX' )
                                            ( <ls_err_mess> ) ).

      io_log->add_from_bapi( it_bapiret = lt_ret_cont ).
    ENDIF.
  ENDMETHOD.

=====================  
51) utc 
cl_abap_tstmp=>utclong2tstmp_short( utclong_current( ) )
=====================
52) Исключения
    CATCH zcx_ts_gtm125_error INTO DATA(lo_gtm125_exc).
      ls_symsg = cl_message_helper=>get_t100_for_object( lo_gtm125_exc ).
      ls_symsg-msgty = 'W'.
	  
    cl_message_helper=>set_msg_vars_for_if_t100_msg( lo_err ).
=====================
53) Значения домена по RTTI
      DATA(lt_dom) = CAST cl_abap_elemdescr( cl_abap_typedescr=>describe_by_data( lv_type_save ) )->get_ddic_fixed_values( ).
      rv_status = VALUE #( lt_dom[ low = lv_type_save ]-ddtext OPTIONAL ).
=====================
54) валюта на дату
CONVERT_TO_FOREIGN_CURRENCY
CONVERT_TO_LOCAL_CURRENCY
=====================
55) исключения
      CATCH zcx_pp_vp_planning_vers INTO DATA(lo_err_vers).
        cl_message_helper=>set_msg_vars_for_if_t100_msg( lo_err_vers ).
        sy-msgty = lo_err_vers->if_t100_dyn_msg~msgty.
        lo_log->add_symsg( ).
    ENDTRY.
=====================
56) выборка строк, если дата представлена как год и месяц
        AND concat( norm~gjahr, norm~period ) >= @( |{ is_sscr_params-syear }{ CONV nsdm_month( is_sscr_params-smonth ) }| )
        AND concat( norm~gjahr, norm~period ) <= @( |{ is_sscr_params-fyear }{ CONV nsdm_month( is_sscr_params-fmonth ) }| )

    DATA(lv_period_begin) = |{ is_params-syear(4) }{ is_params-syear+4(2) }|.
    DATA(lv_period_end)   = |{ is_params-fyear(4) }{ is_params-fyear+4(2) }|.

    WITH
      +raw AS (
          SELECT
              mandt,  pwwrk,  zyear,  zmonth,  plnum,
              posnr,  matnr,  pmatnr, gsmng,   meins,
              shkzg,  verid,  lgort,  uname,   pstmp
            FROM ztpp_biplafmdsm
            WHERE pwwrk = @is_params-werks
              AND zyear BETWEEN @is_params-syear(4) AND @is_params-fyear(4) )

      SELECT
          mandt,  pwwrk,  zyear,  zmonth,  plnum,
          posnr,  matnr,  pmatnr, gsmng,   meins,
          shkzg,  verid,  lgort,  uname,   pstmp
        FROM +raw
        WHERE concat( zyear, zmonth ) >= @lv_period_begin
          AND concat( zyear, zmonth ) <= @lv_period_end
        INTO CORRESPONDING FIELDS OF TABLE @mt_biplafmdsm.
====================
57) переменная на противоположное значение bool
 mv_is_edit_mode = xsdbool( mv_is_edit_mode = abap_false ).
 ===================
 58) вывод большого объёма текста
 для вывода большого обьема текста обычно создают специальный объект в транзакции se61 и показывают его с помощью фм HELP_OBJECT_SHOW. 
 А если не охота с документацией возиться, можно еще попробовать фм CATSXT_SIMPLE_TEXT_EDITOR.
 ===================
 59) Своя кнопка в ракурсе ведения:
 http://zevolving.com/2008/09/add-custom-button-on-maintianence-view-sm30/
 
 PAI в экран ракурса:
 
   " !!!!!!!!!!!!   НЕ УДАЛЯТЬ ПРИ ПЕРЕГЕНЕРАЦИИ   !!!!!!!!!!!!!!!!!!
  " PAI для кастомных кнопок
  MODULE zz_user_pai_001.
  
  код: 
  
  FORM zz_user_command.
  FIELD-SYMBOLS: <lv_calc_type> TYPE any.

  CASE function.
    WHEN 'ZZ_COPY_TYP'.
      LOOP AT total.
        CHECK <mark> IS NOT INITIAL.

        ASSIGN COMPONENT 'CASE_TYPE' OF STRUCTURE <vim_total_struc> TO <lv_calc_type>.
        IF <lv_calc_type> IS ASSIGNED.
          MESSAGE <lv_calc_type> TYPE 'S'.
        ENDIF.
      ENDLOOP.
  ENDCASE.
ENDFORM.
========================
60) Заголовок заказа ТОРО из буфера
CO_IH_GET_HEADER
========================
61) Пройти по всем полям стуктуры/таблицы
        DATA(lo_sdescr) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_name( lv_table_name ) ).
        LOOP AT lo_sdescr->components ASSIGNING FIELD-SYMBOL(<ls_component>).
          ASSIGN COMPONENT <ls_component>-name OF STRUCTURE is_del_key TO FIELD-SYMBOL(<lv_field>).
          IF sy-subrc = 0  AND  <lv_field> IS NOT INITIAL.
            lv_where = |{ lv_where } AND { <lv_field> } = @IS_DEL_KEY-{ <lv_field> }|.
          ENDIF.
        ENDLOOP.
========================
62) имитация нажатия энтер

    CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
      EXPORTING
        functioncode = 'ENT1'
      EXCEPTIONS
        OTHERS       = 0.
========================
63) F4 код
  METHOD f4_class_code.
    CONSTANTS: BEGIN OF lc_s_screen,
                 name_struct TYPE tabname VALUE 'ZSPM_XWOC_SCREEN',
                 dyname      TYPE d020s-prog VALUE 'SAPLXWOC',
                 dynumb      TYPE d020s-dnum VALUE '0900',
               END OF lc_s_screen.

    DATA: lt_selopt TYPE ddshselops.

    DATA(lo_dynpr) = NEW zcldev_f4_dynpr( iv_name_struct = CONV #( lc_s_screen-name_struct )
                                          iv_dyname      = lc_s_screen-dyname
                                          iv_dynumb      = lc_s_screen-dynumb      ).

    lo_dynpr->dynpr_values_read( EXCEPTIONS OTHERS = 99 ).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    lo_dynpr->set_name_f4( 'ZH_CLASS_CODE' ).

    lo_dynpr->set_f4_shlpfield( 'CLASS' ).
    lo_dynpr->set_f4_shlpfield( 'KLAGR' ).
    lo_dynpr->set_f4_valfield( 'CLASS' ).
    lo_dynpr->set_f4_valfield( 'KSCHG' ).
    lo_dynpr->set_f4_valfield( 'CLINT' ).

    DATA(lv_value) = lo_dynpr->get_dynpr_value( iv_field = 'CLASS' ).

    IF cs_xwoc_screen-zzingrp IS NOT INITIAL.
      APPEND VALUE ddshselopt( shlpname  = 'ZH_CLASS_CODE'
                               shlpfield = 'KLAGR'
                               sign      = 'I'
                               option    = 'EQ'
                               low       = cs_xwoc_screen-zzingrp )
        TO lt_selopt.
    ENDIF.

    IF lo_dynpr->view_f4_request( iv_value  = CONV #( lv_value )
                                  it_selopt = lt_selopt          ) = abap_true.

      cs_xwoc_screen-zzclass_code = lo_dynpr->get_f4_value( 'CLASS' ).
      cs_xwoc_screen-zzclass_code_name = lo_dynpr->get_f4_value( 'KSCHG' ).
      cs_xwoc_screen-zzclass = lo_dynpr->get_f4_value( 'CLINT' ).

      lo_dynpr->change_dynpr_table( iv_name  = 'ZZCLASS_CODE_NAME'
                                    iv_value =  cs_xwoc_screen-zzclass_code_name ).
      " Обновить экран
      lo_dynpr->dynpr_values_update( ).
    ENDIF.
  ENDMETHOD.
  
=================================
65)  Получить присвоения (сплиты) заказа ТОРО:
      CALL FUNCTION 'CY_BT_KBED_OPR_TAB_GET'
        EXPORTING
          i_bedid              = <fs_afvgdget>-bedid
          i_bedzl              = <fs_afvgdget>-bedzl
          i_flg_no_kbed_create = true
        TABLES
          t_kbedd              = lt_kbedd
        EXCEPTIONS
          no_entry             = 1
          OTHERS               = 2.
		  
		  Потом удалить заголовочные записи - camnuf
		  
================================
66) рейндж из объекта полномочий
SUSR_USER_AUTH_FOR_OBJ_GET

================================
67) вот динамический селекционник без инсерт репорта
FREE_SELECTIONS_DIALOG		  

================================
68) Даты ISO
Для преобразования даты из ISO 8601 можно использовать класс cl_xlf_date_time.
DATA(lv_z) = cl_xlf_date_time=>create( cl_abap_tstmp=>utclong2tstmp_short( utclong_current( ) ) ).

================================
69) Проверка статусов из ASTTX
    SPLIT is_header_dialog-asttx AT ` ` INTO TABLE DATA(lt_stat).
    DELETE lt_stat WHERE table_line = ''.

    LOOP AT lt_stat ASSIGNING FIELD-SYMBOL(<ls_stat>).
      
    ENDLOOP.
	
================================	
70) поиск ошибки в bapiret2 таблице
    DATA(lv_is_err) = REDUCE abap_bool( INIT lv_tmp_err = VALUE abap_bool( )
                                        FOR <ls_ret> IN lt_ret
                                        NEXT lv_tmp_err = COND abap_bool( WHEN <ls_ret>-type CA 'EAX'
                                                                            THEN abap_true
                                                                            ELSE abap_false ) ).
																			
================================
71) Редактирование шаблонов WMS
Чтобы изменить шаблоны с вертикальным расположением нужно их вынести ниже, расширить, сменить Anchor, повернуть и тогда только редактировать. После вернуть обратно.
Поле добавляется через контекстное меню - Floating Field, потом в Bind присваивается поле структуры интерфейса

================================
72) Собрать подробный текст для сообщения ТОРО
    " Подробные тексты
    IF is_downtime-comment IS NOT INITIAL.
      DATA(lv_string) = is_downtime-comment.
      DATA(lv_count) = strlen( lv_string ) DIV lc_max_length
                       + COND i( WHEN strlen( lv_string ) MOD lc_max_length = 0
                                   THEN 0
                                   ELSE 1 ).
      DO lv_count TIMES.
        IF sy-index > 1.
          lv_string = shift_left( val    = lv_string
                                  places = lc_max_length ).
        ENDIF.

        lt_longtexts = VALUE #( BASE lt_longtexts ( objtype    = 'QMEL'
                                                    objkey     = lc_objkey
                                                    format_col = '='
                                                    text_line  = lv_string ) ).
      ENDDO.
    ENDIF.
	
================================
73) Допполя в заголовок ТОРО
    " Z-поля заголовка
    DATA(ls_extensionin) = VALUE bapiparex( structure = 'BAPI_TE_QMEL' ).
    DATA(ls_te_qmel) = VALUE bapi_te_qmel( zzintegrationsystemid = is_downtime-system_id
                                           zzref_id              = is_downtime-id
                                           zzplanind             = is_downtime-is_planed ).

    DATA(lv_container) = VALUE string( ).
    cl_abap_container_utilities=>fill_container_c(
      EXPORTING
        im_value               = ls_te_qmel
      IMPORTING
        ex_container           = lv_container
      EXCEPTIONS
        OTHERS                 = 0 ).

    ls_extensionin+30 = lv_container.
    DATA(lt_extensionin) = VALUE bapiparextab( ( ls_extensionin ) ).	
	
================================
74) Z-поля заголовка

    DATA(ls_extensionin) = VALUE bapiparex( structure = lc_name_stru_ext ).
    DATA(ls_extensionin_x) = VALUE bapiparex( structure = lc_name_stru_ext_x ).
    DATA(ls_downtime_te) = VALUE zspm_downtime_te_qmel( zzplanind = is_downtime-is_planed ).
    DATA(ls_downtime_tex) = VALUE zspm_downtime_te_qmel_x( zzplanind = abap_true ).

    DESCRIBE FIELD ls_extensionin-structure LENGTH DATA(lv_lenght_field) IN CHARACTER MODE.
    DATA(lv_cont) = VALUE string( ).
    cl_abap_container_utilities=>fill_container_c(
      EXPORTING
        im_value               = ls_downtime_te
      IMPORTING
        ex_container           = lv_cont
      EXCEPTIONS
        OTHERS                 = 0 ).
    ls_extensionin+lv_lenght_field = lv_cont.

    DATA(lv_cont_x) = VALUE string( ).
    cl_abap_container_utilities=>fill_container_c(
      EXPORTING
        im_value               = ls_downtime_tex
      IMPORTING
        ex_container           = lv_cont_x
      EXCEPTIONS
        OTHERS                 = 0 ).
    ls_extensionin_x+lv_lenght_field = lv_cont_x.

    DATA(lt_extensionin) = VALUE bapiparextab( ( ls_extensionin )
                                               ( ls_extensionin_x ) ).

================================
75) Иерархия ЕО
      WITH
        +bom AS (
          SELECT FROM equz
            FIELDS hequi,
                   equnr,
                   submt )

          WITH ASSOCIATIONS (
            JOIN TO MANY +bom AS _tree
              ON +bom~hequi = _tree~equnr )

        SELECT FROM HIERARCHY( SOURCE +bom
                               CHILD TO PARENT ASSOCIATION _tree
                               START WHERE hequi = @lv_hequi
                               SIBLINGS ORDER BY equnr
                               MULTIPLE PARENTS NOT ALLOWED
                               CYCLES BREAKUP )
          FIELDS DISTINCT equnr
          WHERE hequi IS INITIAL
          INTO TABLE @DATA(lt_bom).											   	
		  
=================================
76) Определить, что запуск из IW38 или IW37N
    CONSTANTS: BEGIN OF lc_s_prog,
                 riaufk20                TYPE icl_wf_memory_id VALUE 'RIAUFK20                                ______0000000001',
                 ri_order_operation_list TYPE icl_wf_memory_id VALUE 'RI_ORDER_OPERATION_LIST                 ______0000000001',
               END OF lc_s_prog.

    CHECK sy-tcode <> c_tcode_zec_iw32.

    " Определяем, произведён ли запуск IW32 из IW38
    DATA(lv_msgty) = VALUE syst-msgty( ).

    IMPORT dy_msgty TO lv_msgty FROM MEMORY ID lc_s_prog-riaufk20. " через zcl_data_mem=>import() не работает
    IF sy-subrc = 0.
	
=================================
77) Выбрать статусы правильно
    SELECT FROM @lht_stat AS lt
        JOIN aufk
            ON aufk~aufnr = lt~aufnr
          JOIN jsto
              ON jsto~objnr = aufk~objnr
            JOIN jest
                ON jest~objnr = jsto~objnr AND
                   jest~inact = @space
              JOIN tj30t
                  ON tj30t~estat = jest~stat AND
                     tj30t~stsma = jsto~stsma AND
                     tj30t~spras = @sy-langu
      FIELDS DISTINCT lt~aufnr
      WHERE tj30t~txt04 IN @ms_zssp_pm074_mat_quant_chg-r_user_stat
      INTO TABLE @lht_stat.

или новое

    WITH
      +aufk AS (
        SELECT FROM @lht_stat AS lt
          JOIN aufk
              ON aufk~aufnr = lt~aufnr
          FIELDS lt~aufnr,
                 aufk~objnr ),

      +jest_incl AS (
        SELECT FROM +aufk
          JOIN jsto
              ON jsto~objnr = +aufk~objnr
            JOIN jest
                ON jest~objnr = jsto~objnr AND
                   jest~inact = @space
              JOIN tj30t
                  ON tj30t~estat = jest~stat AND
                     tj30t~stsma = jsto~stsma AND
                     tj30t~spras = @lc_lang_ru
          FIELDS DISTINCT jest~objnr
          WHERE tj30t~txt04 IN @ms_zssp_pm074_mat_quant_chg-r_user_stat )

      SELECT FROM +aufk
          JOIN +jest_incl
              ON +jest_incl~objnr = +aufk~objnr
        FIELDS +aufk~aufnr
        INTO TABLE @lht_stat.

=====================================
78) Чтение данных ITOB технического объекта (ЕО, ТМ) из базы или буфера
    CALL FUNCTION 'ITOB_GET_CLASS_STANDARD'
      EXPORTING
        equnr_imp         = is_sequi-equnr
      IMPORTING
        class_exp         = lv_class
        classtype_exp     = lv_classtype
      EXCEPTIONS
        empty_key         = 1
        application_error = 2
        OTHERS            = 3.
