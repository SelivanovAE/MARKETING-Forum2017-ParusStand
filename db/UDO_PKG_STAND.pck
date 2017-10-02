﻿create or replace package UDO_PKG_STAND as
  /*
    Утилиты для работы стенда
  */

  /* Константы описания режима работы стенда */
  NALLOW_MULTI_SUPPLY_YES   PKG_STD.TNUMBER := 1;                                       -- Разрешать множественную отгрузку одному посетителю
  NALLOW_MULTI_SUPPLY_NO    PKG_STD.TNUMBER := 0;                                       -- Не разрешать множественную отгрузку одному посетителю

  /* Константы режима работы стенда */
  NALLOW_MULTI_SUPPLY       PKG_STD.TNUMBER := NALLOW_MULTI_SUPPLY_YES;                 -- Возможность множественной отгрузки
  
  /* Константы описания склада для стенда */
  SSTORE_PRODUCE            AZSAZSLISTMT.AZS_NUMBER%type := 'Производство';             -- Склад производства готовой продукции
  SSTORE_GOODS              AZSAZSLISTMT.AZS_NUMBER%type := 'СГП';                      -- Склад отгрузки готовой продукции
  SRACK_PREF                STPLRACKS.PREF%type := 'АВТОМАТ';                           -- Префикс стеллажа склада отгрузки готовой продукции
  SRACK_NUMB                STPLRACKS.NUMB%type := '1';                                 -- Номер стеллажа склада отгрузки готовой продукции
  SRACK_CELL_PREF_TMPL      STPLCELLS.PREF%type := 'ЯРУС';                              -- Шаблон префикса места хранения
  SRACK_CELL_NUMB_TMPL      STPLCELLS.NUMB%type := 'МЕСТО';                             -- Шаблон номера места зранения
  NRACK_LINES               PKG_STD.TNUMBER := 1;                                       -- Количество ярусов стеллажа
  NRACK_LINE_CELLS          PKG_STD.TNUMBER := 3;                                       -- Количество ячеек (мест хранения) в ярусе
  NRACK_CELL_CAPACITY       PKG_STD.TNUMBER := 2;                                       -- Максимальное количество номенклатуры в ячейке хранения
  NRACK_CELL_SHIP_CNT       PKG_STD.TNUMBER := 1;                                       -- Количество номенклатуры, отгружаемое потребителю за одну транзакцию
  NRESTS_LIMIT_MINIMUM      PKG_STD.TLNUMBER := 50;                                     -- Минимальный критический остаток по складу (в %)  
  NRESTS_LIMIT_MIDDLE       PKG_STD.TLNUMBER := 50;                                     -- Средний остаток по складу (в %)  

  /* Константы описания движения по складу */
  SDEF_STORE_MOVE_IN        AZSGSMWAYSTYPES.GSMWAYS_MNEMO%type := 'Приход внутренний';  -- Операция прихода по умолчанию
  SDEF_STORE_MOVE_OUT       AZSGSMWAYSTYPES.GSMWAYS_MNEMO%type := 'Расход внешний';     -- Операция расхода по умолчанию
  SDEF_STORE_PARTY          INCOMDOC.CODE%type := 'Готовая продукция';                  -- Партия по умолчанию
  SDEF_FACE_ACC             FACEACC.NUMB%type := 'Универсальный';                       -- Лицевой счет по умолчанию
  SDEF_TARIF                DICTARIF.CODE%type := 'Базовый';                            -- Тариф по умолчанию
  SDEF_SHEEP_VIEW           DICSHPVW.CODE%type := 'Самовывоз';                          -- Вид отгрузки по умолчанию
  SDEF_PAY_TYPE             AZSGSMPAYMENTSTYPES.GSMPAYMENTS_MNEMO%type := 'Без оплаты'; -- Вид оплаты по умолчанию
  SDEF_TAX_GROUP            DICTAXGR.CODE%type := 'Без налогов';                        -- Налоговая группа по умолчанию
  SDEF_NOMEN_1              DICNOMNS.NOMEN_CODE%type := 'Жевательная резинка';          -- Номенклатура по умолчанию (1)
  SDEF_NOMEN_MODIF_1        NOMMODIF.MODIF_CODE%type := 'Orbit';                        -- Модификация номенклатуры по умолчанию (1)
  SDEF_NOMEN_2              DICNOMNS.NOMEN_CODE%type := 'Жевательная резинка';          -- Номенклатура по умолчанию (2)
  SDEF_NOMEN_MODIF_2        NOMMODIF.MODIF_CODE%type := 'Dirol';                        -- Модификация номенклатуры по умолчанию (2)
  SDEF_NOMEN_3              DICNOMNS.NOMEN_CODE%type := 'Жевательная резинка';          -- Номенклатура по умолчанию (3)
  SDEF_NOMEN_MODIF_3        NOMMODIF.MODIF_CODE%type := 'Eclipce';                      -- Модификация номенклатуры по умолчанию (3)

  /* Константы описания приходов */
  SINCDEPS_TYPE             DOCTYPES.DOCCODE%type := 'ПНП';                             -- Тип документа "Приход из подразделений"
  SINCDEPS_PREF             INCOMEFROMDEPS.DOC_PREF%type := 'ПНП';                      -- Префикс документа "Приход из подразделений"

  /* Константы описания расходов */
  STRINVCUST_TYPE           DOCTYPES.DOCCODE%type := 'РНОП';                            -- Тип документа "Расходная накладная на отпуск потребителям"
  STRINVCUST_PREF           INCOMEFROMDEPS.DOC_PREF%type := 'РНОП';                     -- Префикс документа "Расходная накладная на отпуск потребителям"
  STRINVCUST_REPORT         USERREPORTS.CODE%type := 'RL1580';                          -- Мнемокод пользовательского отчета для автоматической печати
    
  /* Констнаты описания состояни отгрузки посетителю стенда */
  NAGN_SUPPLY_NOT_YET       PKG_STD.TNUMBER := 1;                                       -- Отгрузки ещё не было
  NAGN_SUPPLY_ALREADY       PKG_STD.TNUMBER := 2;                                       -- Оггрузка уже была
  
  /* Констнаты описания испоьзуемых дополнительных свойств */
  SDP_BARCODE               DOCS_PROPS.CODE%type := 'ШтрихКод';                         -- Мнемокод дополнительного свойства для храения штрихкода
  
  /* Константы описания типов сообщений очереди стенда */
  SMSG_TYPE_NOTIFY          UDO_T_STAND_MSG.TP%type := 'NOTIFY';                        -- Сообщение типа "Оповещение"
  SMSG_TYPE_REST            UDO_T_STAND_MSG.TP%type := 'RESTS';                         -- Сообщение типа "Сведения об остатках"
  SMSG_TYPE_PRINT           UDO_T_STAND_MSG.TP%type := 'PRINT';                         -- Сообщение типа "Очередь печати"
  
  /* Константы описания порядка сортировки сообщений очереди стенда */
  NMSG_ORDER_ASC            PKG_STD.TNUMBER := 1;                                       -- Сначала старые
  NMSG_ORDER_DESC           PKG_STD.TNUMBER := -1;                                      -- Cначала новые
  
  /* Типы данных - конфигурация ячейки стенда */
  type TRACK_LINE_CELL_CONF is record
  (
    NRACK_LINE              PKG_STD.TREF,                                               -- Номер яруса стеллажа на котором находится чейка
    NRACK_LINE_CELL         PKG_STD.TREF,                                               -- Номер ячейки в ярусе стеллажа стенда
    SPREF                   STPLCELLS.PREF%type,                                        -- Префикс ячейки
    SNUMB                   STPLCELLS.NUMB%type,                                        -- Номер ячейки
    SNAME                   PKG_STD.TSTRING,                                            -- Полное наименование ячейки
    NNOMEN                  DICNOMNS.RN%type,                                           -- Регистрационный номер номенклатуры хранения
    SNOMEN                  DICNOMNS.NOMEN_CODE%type,                                   -- Мнемокод номенклатуры хранения
    NNOMMODIF               NOMMODIF.RN%type,                                           -- Регистрационный номер модификации номенклатуры хранения
    SNOMMODIF               NOMMODIF.MODIF_CODE%type,                                   -- Мнемокод модификации номенклатуры хранения
    NCAPACITY               PKG_STD.TNUMBER,                                            -- Вместимость ячейки
    NSHIP_CNT               PKG_STD.TNUMBER                                             -- Отгружаемое количество
  );
  
  /* Типы данных - коллекция конфигураций ячеек ярусов стенда */
  type TRACK_LINE_CELL_CONFS is table of TRACK_LINE_CELL_CONF;

  /* Типы данных - складской остаток номенклатуры */
  type TNOMEN_REST is record
  (
    NNOMEN                  DICNOMNS.RN%type,                                           -- Регистрационный номер номенклатуры остатка
    SNOMEN                  DICNOMNS.NOMEN_CODE%type,                                   -- Мнемокод номенклатуры остатка
    NNOMMODIF               NOMMODIF.RN%type,                                           -- Регистрационный номер модификации номенклатуры остатка
    SNOMMODIF               NOMMODIF.MODIF_CODE%type,                                   -- Мнемокод модификации номенклатуры остатка
    NREST                   STPLGOODSSUPPLY.QUANT%type,                                 -- Остаток в онсновной ЕИ
    NMEAS                   DICMUNTS.RN%type,                                           -- Регистрационный номер основной ЕИ номенклатуры остатка
    SMEAS                   DICMUNTS.MEAS_MNEMO%type                                    -- Мнемокод основное ЕИ номенклатуры остатка
  );
  
  /* Типы данных - коллекция складских остатков номенклатуры */
  type TNOMEN_RESTS is table of TNOMEN_REST;
  
  /* Типы данных - складской остаток ячейки стеллажа (места хранения) */
  type TRACK_LINE_CELL_REST is record
  (
    NRACK_CELL              STPLCELLS.RN%type,                                          -- Регистрационный номер ячейки
    SRACK_CELL_PREF         STPLCELLS.PREF%type,                                        -- Префикс ячейки
    SRACK_CELL_NUMB         STPLCELLS.NUMB%type,                                        -- Номер ячейки
    SRACK_CELL_NAME         PKG_STD.TSTRING,                                            -- Полное наименование ячейки
    NRACK_LINE              PKG_STD.TREF,                                               -- Номер яруса стеллажа на котором находится чейка
    NRACK_LINE_CELL         PKG_STD.TREF,                                               -- Номер ячейки в ярусе стеллажа стенда
    BEMPTY                  boolean,                                                    -- Флаг пустой ячейки
    NOMEN_RESTS             TNOMEN_RESTS := TNOMEN_RESTS()                              -- Остатки номенклатур
  );
  
  /* Типы данных - коллекция складских остатков ячеек стеллажа (места хранения) */
  type TRACK_LINE_CELL_RESTS is table of TRACK_LINE_CELL_REST;
  
  /* Типы данных - складские остатки яруса стеллажа */
  type TRACK_LINE_REST is record
  (
    NRACK_LINE              PKG_STD.TREF,                                               -- Номер яруса стеллажа
    NRACK_LINE_CELLS_CNT    PKG_STD.TREF,                                               -- Количество ячеек яруса
    BEMPTY                  boolean,                                                    -- Флаг пустого яруса
    RACK_LINE_CELL_RESTS    TRACK_LINE_CELL_RESTS := TRACK_LINE_CELL_RESTS()            -- Остатки в местах хранения яруса
  );
  
  /* Типы данных - коллекция складских остатков ярусов стеллажа */
  type TRACK_LINE_RESTS is table of TRACK_LINE_REST;
  
  /* Типы данных - складские остатки стеллажа */
  type TRACK_REST is record
  (
    NRACK                   STPLRACKS.RN%type,                                          -- Регистрационный номер стеллажа
    NSTORE                  AZSAZSLISTMT.RN%type,                                       -- Регистрационный номер склада стеллажа
    SSTORE                  AZSAZSLISTMT.AZS_NUMBER%type,                               -- Мнемокод склада стеллажа
    SRACK_PREF              STPLRACKS.PREF%type,                                        -- Префикс стеллажа
    SRACK_NUMB              STPLRACKS.NUMB%type,                                        -- Номер стеллажа
    SRACK_NAME              PKG_STD.TSTRING,                                            -- Полное наименование стеллажа
    NRACK_LINES_CNT         PKG_STD.TREF,                                               -- Количество ярусов стеллажа
    BEMPTY                  boolean,                                                    -- Флаг пустого стеллажа        
    RACK_LINE_RESTS         TRACK_LINE_RESTS := TRACK_LINE_RESTS()                      -- Остатки в ярусах стеллажа
  );
  
  /* Типы данных - посетитель стенда */
  type TSTAND_USER is record
  (
    NAGENT                  AGNLIST.RN%type,                                            -- Регистрационный номер контрагента-посетителя
    SAGENT                  AGNLIST.AGNABBR%type,                                       -- Мнемокод контрагента-посетителя
    SAGENT_NAME             AGNLIST.AGNNAME%type                                        -- Наименование контрагента-посетителя
  );
  
  /* Типы данных - сообщение */
  type TMESSAGE is record
  (
    NRN                     UDO_T_STAND_MSG.RN%type,                                    -- Регистрационный номер сообщения
    DTS                     UDO_T_STAND_MSG.TS%type,                                    -- Дата сообщения
    STS                     PKG_STD.TSTRING,                                            -- Строковое представление даты сообщения (ДД.ММ.ГГГГ ЧЧ24:ММ:СС)
    STP                     UDO_T_STAND_MSG.TP%type,                                    -- Тип сообщения
    SMSG                    UDO_T_STAND_MSG.MSG%type                                    -- Текст сообщения
  );
  
  /* Типы данных - коллекция сообщений */
  type TMESSAGES is table of TMESSAGE;
  
  /* Базовое добавление сообщения в очередь */
  procedure MSG_BASE_INSERT
  (
    STP                     varchar2,   -- Тип сообщения
    SMSG                    varchar2,   -- Текст сообщения
    NRN                     out number  -- Регистрационный номер добавленного сообщения
  );
  
  /* Базовое удаление сообщения из очереди */
  procedure MSG_BASE_DELETE
  (
    NRN                     number      -- Регистрационный номер сообщения
  );
  
  /* Добавление в очередь сообщения типа "Оповещение" */
  procedure MSG_INSERT_NOTIFY
  (
    SMSG                    varchar2    -- Текст сообщения
  );
  
  /* Добавление в очередь сообщения типа "Сведения об остатках" */
  procedure MSG_INSERT_RESTS
  (
    SMSG                    varchar2    -- Текст сообщения
  );

  /* Добавление в очередь сообщения типа "Очередь печати" */
  procedure MSG_INSERT_PRINT
  (
    SMSG                    varchar2     -- Текст сообщения
  );
  
  /* Добавление в очередь сообщения */
  procedure MSG_INSERT
  (
    STP                     varchar2,   -- Тип сообщения
    SMSG                    varchar2    -- Текст сообщения
  );
  
  /* Считывание сообщения из очереди */
  function MSG_GET
  (
    NRN                     number,     -- Регистрационный номер сообщения
    NSMART                  number := 0 -- Признак выдачи сообщения об ошибке (0 - выдавать, 1 - не выдавать)
  )return UDO_T_STAND_MSG%rowtype;
  
  /* Считывание новых сообщений из очереди */
  function MSG_GET_LIST
  (
    DFROM                   date := null,            -- Дата с которой необходимо начать список (null - не учитывать)
    STP                     varchar2 := null,        -- Тип сообщений (null - все)
    NLIMIT                  number := null,          -- Максимальное количество (null - все)
    NORDER                  number := NMSG_ORDER_ASC -- Порядок сортировки (см. констнаты SMSG_ORDER_*)
  ) return TMESSAGES;  
  
  /* Формирование наименования стеллажа (префикс-номер) */
  function RACK_BUILD_NAME 
  (
    SPREF                   varchar2 := SRACK_PREF, -- Префикс стеллажа
    SNUMB                   varchar2 := SRACK_NUMB  -- Номер стеллажа
  ) return varchar2;
  
  /* Формирование префикса ячейки яруса стеллажа склада */
  function RACK_LINE_CELL_BUILD_PREF
  (
    NRACK_LINE              number,                          -- Номер яруса стеллажа в котором находится ячейка               
    SPREF_TMPL              varchar2 := SRACK_CELL_PREF_TMPL -- Шаблон префикса
  ) return varchar2;

  /* Формирование номера ячейки яруса стеллажа склада */
  function RACK_LINE_CELL_BUILD_NUMB
  (
    NRACK_LINE_CELL         number,                          -- Номер ячейки в ярусе стеллажа
    SNUMB_TMPL              varchar2 := SRACK_CELL_NUMB_TMPL -- Шаблон номера
  ) return varchar2;
  
  /* Формирования полного имени (префикс-номер) ячейки яруса стеллажа склада (по префиксу и номеру)*/
  function RACK_LINE_CELL_BUILD_NAME
  (
    SPREF                   varchar2,   -- Префикс ячейки
    SNUMB                   varchar2    -- Номер ячейки
  ) return varchar2;  
  
  /* Формирования полного имени (префикс-номер) ячейки яруса стеллажа склада (по координатам)*/
  function RACK_LINE_CELL_BUILD_NAME
  (
    NRACK_LINE              number,                           -- Номер яруса стеллажа в котором находится ячейка
    NRACK_LINE_CELL         number,                           -- Номер ячейки в ярусе стеллажа
    SPREF_TMPL              varchar2 := SRACK_CELL_PREF_TMPL, -- Шаблон префикса    
    SNUMB_TMPL              varchar2 := SRACK_CELL_NUMB_TMPL  -- Шаблон номера
  ) return varchar2;
  
  /* Загрузка стенда товаром */
  procedure LOAD
  (
    NCOMPANY                number      -- Регистрационный номер организации 
  );

  /* Откат последней загрузки стенда */
  procedure LOAD_ROLLBACK
  (
    NCOMPANY                number      -- Регистрационный номер организации
  );

  /* Отгрузка со стенда посетителю */
  procedure SHIPMENT
  (
    NCOMPANY                number,     -- Регистрационный номер организации
    SCUSTOMER               varchar2,   -- Мнемокод контрагента-покупателя
    NRACK_LINE              number,     -- Номер яруса стеллажа стенда
    NRACK_LINE_CELL         number,     -- Номер ячейки в ярусе стеллажа стенда
    NTRANSINVCUST           out number  -- Регистрационный номер сформированной РНОП    
  );

  /* Откат отгрузки со стенда */
  procedure SHIPMENT_ROLLBACK
  (
    NCOMPANY                number,     -- Регистрационный номер организации
    NTRANSINVCUST           number      -- Регистрационный номер отгрузочной РНОП
  );
  
  /* Заполнение списка отмеченных для печати документов (автономная транзакция) */
  procedure PRINT_SET_SELECTLIST
  (
    NIDENT                  number,     -- Идентификатор буфера
    NDOCUMENT               number,     -- Регистрационный номер документа
    SUNITCODE               varchar2    -- Код раздела документа
  );
  
  /* Очистка списка отмеченных для печати документов (автономная транзакция) */
  procedure PRINT_CLEAR_SELECTLIST
  (
    NIDENT                  number      -- Идентификатор буфера
  );
  
  /* Печать РНОП через сервер печати */
  procedure PRINT
  (
    NCOMPANY                number,     -- Регистрационный номер органиазации
    NTRANSINVCUST           number      -- Регистрационный номер РНОП
  );
  
  /* Инициализация конфигурации ячеек стенда */
  procedure STAND_INIT_RACK_LINE_CELL_CONF
  (
    NCOMPANY                number      -- Регистрационный номер организации 
  );
  
  /* Сохранение текущих остатков по стенду */
  procedure STAND_SAVE_RESTS
  (
    NCOMPANY                number,     -- Регистрационный номер органиазации
    BNOTIFY_REST            boolean,    -- Флаг оповещения о текущем остатке
    BNOTIFY_LIMIT           boolean     -- Флаг оповещения о критическом снижении остатка
  );
  
  /* Получение конфигурации ячейки стенда */
  function STAND_GET_RACK_LINE_CELL_CONF
  (
    NRACK_LINE              number,     -- Номер яруса стеллажа стенда
    NRACK_LINE_CELL         number      -- Номер ячейки в ярусе стеллажа стенда
  ) return TRACK_LINE_CELL_CONF;
  
  /* Получение остатков стеллажа стенда по номенклатурам */
  function STAND_GET_RACK_NOMEN_REST
  (
    NCOMPANY                number,           -- Регистрационный номер организации
    SSTORE                  varchar2,         -- Мнемокод склада стенда
    SPREF                   varchar2,         -- Префикс стеллажа стенда
    SNUMB                   varchar2,         -- Номер стеллажа стенда
    SCELL                   varchar2 := null, -- Наименование (префикс-номер) ячейки стеллажа (null - по всем)    
    SNOMEN                  varchar2 := null, -- Номенклатура (null - по всем)
    SNOMEN_MODIF            varchar2 := null  -- Модификация (null - по всем)
  ) return TNOMEN_RESTS;
  
  /* Получение остатков стеллажа стенда по местам хранения */
  function STAND_GET_RACK_REST
  (
    NCOMPANY                number,           -- Регистрационный номер организации
    SSTORE                  varchar2,         -- Мнемокод склада стенда
    SPREF                   varchar2,         -- Префикс стеллажа стенда
    SNUMB                   varchar2,         -- Номер стеллажа стенда
    SNOMEN                  varchar2 := null, -- Номенклатура (null - по всем)
    SNOMEN_MODIF            varchar2 := null  -- Модификация (null - по всем)
  ) return TRACK_REST;
  
  /* Поиск контрагента-посетителя стенда по штрихкоду */
  function STAND_GET_AGENT_BY_BARCODE
  (
    NCOMPANY                number,     -- Регистрационный номер организации
    SBARCODE                varchar2    -- Штрихкод
  ) return TSTAND_USER;
  
  /* Проверка осуществления выдачи контрагенту-посетителю товара со стенда (см. константы NAGN_SUPPLY_*) */
  function STAND_CHECK_SUPPLY
  (
    NCOMPANY                number,     -- Регистрационный номер организации
    NAGENT                  number      -- Регистрационный номер контрагента
  ) return number;
  
  /* Аутентификация посетителя стенда по штрихкоду */
  procedure STAND_AUTH_BY_BARCODE
  (
    NCOMPANY                number,          -- Регистрационный номер организации
    SBARCODE                varchar2,        -- Штрихкод
    STAND_USER              out TSTAND_USER, -- Сведения о пользователе стенда
    RACK_REST               out TRACK_REST   -- Сведения об остатках на стенде
  );    

end;
/
create or replace package body UDO_PKG_STAND as

  /* Конфигурация ячеек стенда */
  RACK_LINE_CELL_CONFS      TRACK_LINE_CELL_CONFS;
  
  /* Базовое добавление сообщения в очередь */
  procedure MSG_BASE_INSERT
  (
    STP                     varchar2,   -- Тип сообщения
    SMSG                    varchar2,   -- Текст сообщения
    NRN                     out number  -- Регистрационный номер добавленного сообщения
  ) is
  begin
    /* Проверим параметры */
    if (STP not in (SMSG_TYPE_NOTIFY, SMSG_TYPE_REST, SMSG_TYPE_PRINT)) then
      P_EXCEPTION(0, 'Тип сообщения "%s" не поддерживается!', STP);
    end if;
    if (SMSG is null) then
      P_EXCEPTION(0, 'Не указано сообщение для добавления!');
    end if;
    /* Сформируем регистрационный номер */
    NRN := GEN_ID();
    /* Добавим сообщение */
    insert into UDO_T_STAND_MSG (RN, TS, TP, MSG) values (NRN, sysdate, STP, SMSG);
  end;
    
  /* Базовое удаление сообщения из очереди */
  procedure MSG_BASE_DELETE
  (
    NRN                     number      -- Регистрационный номер сообщения
  ) is
  begin
    /* Удалим сообщение */
    delete from UDO_T_STAND_MSG T where T.RN = NRN;
  end;
  
    /* Добавление в очередь сообщения типа "Оповещение" */
  procedure MSG_INSERT_NOTIFY
  (
    SMSG                    varchar2                 -- Текст сообщения
  ) is
    NRN                     UDO_T_STAND_MSG.RN%type; -- Регистрационный номер добавленного сообщения
  begin
    /* Выполним базовое добавление в очередь сообщений */
    MSG_BASE_INSERT(STP => SMSG_TYPE_NOTIFY, SMSG => SMSG, NRN => NRN);
  end;
  
  /* Добавление в очередь сообщения типа "Сведения об остатках" */
  procedure MSG_INSERT_RESTS
  (
    SMSG                    varchar2                 -- Текст сообщения
  ) is
    NRN                     UDO_T_STAND_MSG.RN%type; -- Регистрационный номер добавленного сообщения
  begin
    /* Выполним базовое добавление в очередь сообщений */
    MSG_BASE_INSERT(STP => SMSG_TYPE_REST, SMSG => SMSG, NRN => NRN);
  end;

  /* Добавление в очередь сообщения типа "Очередь печати" */
  procedure MSG_INSERT_PRINT
  (
    SMSG                    varchar2                 -- Текст сообщения
  ) is
    NRN                     UDO_T_STAND_MSG.RN%type; -- Регистрационный номер добавленного сообщения
  begin
    /* Выполним базовое добавление в очередь сообщений */
    MSG_BASE_INSERT(STP => SMSG_TYPE_PRINT, SMSG => SMSG, NRN => NRN);
  end;
  
  /* Добавление в очередь сообщения */
  procedure MSG_INSERT
  (
    STP                     varchar2,   -- Тип сообщения
    SMSG                    varchar2    -- Текст сообщения
  ) is
  begin
    /* Проверим параметры */
    if (STP is null) then
      P_EXCEPTION(0, 'Не указан тип сообщения!');
    end if;
    if (SMSG is null) then
      P_EXCEPTION(0, 'Не указан текст сообщения!');
    end if;
    /* Работаем от типа сообщения */
    case STP
      /* Тип сообщения - Оповещение */
      when SMSG_TYPE_NOTIFY then
        MSG_INSERT_NOTIFY(SMSG => SMSG);
      /* Тип сообщения - Сведения об остатках */        
      when SMSG_TYPE_REST then
        MSG_INSERT_RESTS(SMSG => SMSG);
      /* Тип сообщения - Очередь печати */        
      when SMSG_TYPE_PRINT then
        MSG_INSERT_PRINT(SMSG => SMSG);
      /* Неизвестный тип сообщения */
      else
        P_EXCEPTION(0, 'Тип сообщения "%s" не поддерживается!', STP);
    end case;
  end;
  
  /* Считывание сообщения из очереди */
  function MSG_GET
  (
    NRN                     number,                  -- Регистрационный номер сообщения
    NSMART                  number := 0              -- Признак выдачи сообщения об ошибке (0 - выдавать, 1 - не выдавать)
  ) return UDO_T_STAND_MSG%rowtype is
    RES                     UDO_T_STAND_MSG%rowtype; -- Результат работы
  begin
    /* Считаем данные */
    begin
      select T.* into RES from UDO_T_STAND_MSG T where T.RN = NRN;
    exception
      when NO_DATA_FOUND then
        RES.RN := null;
        PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => NSMART, NDOCUMENT => NRN, SUNIT_TABLE => 'UDO_T_STAND_MSG');
    end;
    /* Вернем результат */
    return RES;
  end;
  
  /* Считывание новых сообщений из очереди */
  function MSG_GET_LIST
  (
    DFROM                   date := null,            -- Дата с которой необходимо начать список (null - не учитывать)
    STP                     varchar2 := null,        -- Тип сообщений (null - все)
    NLIMIT                  number := null,          -- Максимальное количество (null - все)
    NORDER                  number := NMSG_ORDER_ASC -- Порядок сортировки (см. констнаты SMSG_ORDER_*)
  ) return TMESSAGES is
    RES                     TMESSAGES;               -- Результат работы
  begin
    /* Проверим корректность указания порядка сортировки */
    if (NORDER not in (NMSG_ORDER_ASC, NMSG_ORDER_DESC)) then
      P_EXCEPTION(0,
                  'Некорректно указан порядок сортировки возвращаемых сообщений!');
    end if;
    /* Инициализируем выход */
    RES := TMESSAGES();
    /* Строим список сообщений в обратном хронологическом порядке */
    for M in (select *
                from (select *
                        from (select T.*
                                from UDO_T_STAND_MSG T
                               where ((STP is null) or (STP is not null) and (T.TP = STP))
                                 and ((DFROM is null) or (DFROM is not null) and (T.TS >= DFROM))
                               order by T.RN desc) D
                       where ((NLIMIT is null) or (NLIMIT is not null) and (ROWNUM <= NLIMIT))) F
               order by F.RN * NORDER)
    loop
      /* Добавляем сообщение в ответ */
      RES.EXTEND();
      /* Описываем его */
      RES(RES.LAST).NRN := M.RN;
      RES(RES.LAST).DTS := M.TS;
      RES(RES.LAST).STS := TO_CHAR(M.TS, 'dd.mm.yyyy hh24:mi:ss');
      RES(RES.LAST).STP := M.TP;
      RES(RES.LAST).SMSG := M.MSG;
    end loop;
    /* Отдаём результат */
    return RES;
  end;
  
  /* Формирование наименования стеллажа (префикс-номер) */
  function RACK_BUILD_NAME 
  (
    SPREF                   varchar2 := SRACK_PREF, -- Префикс стеллажа
    SNUMB                   varchar2 := SRACK_NUMB  -- Номер стеллажа
  ) return varchar2 is
  begin
    return trim(SPREF) || '-' || trim(SNUMB);
  end;
  
  /* Формирование префикса ячейки яруса стеллажа склада */
  function RACK_LINE_CELL_BUILD_PREF
  (
    NRACK_LINE              number,                          -- Номер яруса стеллажа в котором находится ячейка               
    SPREF_TMPL              varchar2 := SRACK_CELL_PREF_TMPL -- Шаблон префикса
  ) return varchar2 is
  begin
    return SPREF_TMPL || NRACK_LINE;
  end;

  /* Формирование номера ячейки яруса стеллажа склада */
  function RACK_LINE_CELL_BUILD_NUMB
  (
    NRACK_LINE_CELL         number,                          -- Номер ячейки в ярусе стеллажа
    SNUMB_TMPL              varchar2 := SRACK_CELL_NUMB_TMPL -- Шаблон номера
  ) return varchar2 is
  begin
    return SNUMB_TMPL || NRACK_LINE_CELL;
  end;
  
  /* Формирования полного имени (префикс-номер) ячейки яруса стеллажа склада (по префиксу и номеру)*/
  function RACK_LINE_CELL_BUILD_NAME
  (
    SPREF                   varchar2,   -- Префикс ячейки
    SNUMB                   varchar2    -- Номер ячейки
  ) return varchar2 is
  begin
    return trim(SPREF) || '-' || trim(SNUMB);
  end;  
  
  /* Формирования полного имени (префикс-номер) ячейки яруса стеллажа склада (по координатам)*/
  function RACK_LINE_CELL_BUILD_NAME
  (
    NRACK_LINE              number,                           -- Номер яруса стеллажа в котором находится ячейка
    NRACK_LINE_CELL         number,                           -- Номер ячейки в ярусе стеллажа
    SPREF_TMPL              varchar2 := SRACK_CELL_PREF_TMPL, -- Шаблон префикса    
    SNUMB_TMPL              varchar2 := SRACK_CELL_NUMB_TMPL  -- Шаблон номера
  ) return varchar2 is
  begin
    return RACK_LINE_CELL_BUILD_NAME(SPREF => RACK_LINE_CELL_BUILD_PREF(NRACK_LINE => NRACK_LINE,
                                                                        SPREF_TMPL => SPREF_TMPL),
                                     SNUMB => RACK_LINE_CELL_BUILD_NUMB(NRACK_LINE_CELL => NRACK_LINE_CELL,
                                                                        SNUMB_TMPL      => SNUMB_TMPL));
  end;  
  
  /* Загрузка стенда товаром */
  procedure LOAD
  (
    NCOMPANY                number                              -- Регистрационный номер организации 
  ) is
    /* Типы данных */
    type TNOMEN is record                                       -- Номенклатура загрузки
    (
      SNOMEN                DICNOMNS.NOMEN_CODE%type,           -- Мнемокод номенклатуры загруки
      NNOMEN                DICNOMNS.RN%type,                   -- Рег. номер номенклатуры загруки
      SNOMMODIF             NOMMODIF.MODIF_CODE%type,           -- Мнемокод модификации номенклатуры загрузки
      NNOMMODIF             NOMMODIF.RN%type,                   -- Рег. номер модификации номенклатуры загрузки
      NQUANT                INCOMEFROMDEPSSPEC.QUANT_PLAN%type, -- Количество номенклатуры в формируемом "Приходе из подразделения"
      NINCOMEFROMDEPSSPEC   INCOMEFROMDEPSSPEC.RN%type          -- Рег. номер сформированной позиции спецификации "Приходе из подразделения" для этой номенклатуры
    );
    type TNOMENS is table of TNOMEN;                            -- Коллекция номенклатур загрузки   
    /* Переменные */
    NCRN                    INCOMEFROMDEPS.RN%type;             -- Каталог размещения документов "Приход из подразделения"
    NJUR_PERS               JURPERSONS.RN%type;                 -- Регистрационный номер юридического лица "Прихода из подразделения" (основное ЮЛ организации)
    SJUR_PERS               JURPERSONS.CODE%type;               -- Мнемокод номер юридического лица "Прихода из подразделения" (основное ЮЛ организации)
    SDOC_NUMB               INCOMEFROMDEPS.DOC_NUMB%type;       -- Номер формируемого "Прихода из подразделения"
    SOUT_DEPARTMENT         INS_DEPARTMENT.CODE%type;           -- Подразделение-отправитель формируемого "Прихода из подразделения"
    SAGENT                  AGNLIST.AGNABBR%type;               -- МОЛ формируемого "Прихода из подразделения"
    SCURRENCY               CURNAMES.CURCODE%type;              -- Валюта формируемого "Прихода из подразделения" (базовая валюта организации)
    NINCOMEFROMDEPS         INCOMEFROMDEPS.RN%type;             -- Рег. номер сформированного "Прихода из подразделения"
    NINCOMEFROMDEPSSPEC     INCOMEFROMDEPSSPEC.RN%type;         -- Рег. номер сформированной позиции спецификации "Прихода из подразделения"
    NSTRPLRESJRNL           STRPLRESJRNL.RN%type;               -- Рег. номер сформированной записи резервирования по местам хранения
    CELL_CONF               TRACK_LINE_CELL_CONF;               -- Конфигурация ячейки (места хранения) стенда
    NWARNING                PKG_STD.TREF;                       -- Флаг предупреждения процедуры отработки прихода
    SMSG                    PKG_STD.TSTRING;                    -- Текст сообщения процедуры отработки прихода
    NOMENS                  TNOMENS;                            -- Коллекция загружаемых номенклатур
  begin
    /* Определим рег. номер каталога */
    FIND_ROOT_CATALOG(NCOMPANY => NCOMPANY, SCODE => 'IncomFromDeps', NCRN => NCRN);
  
    /* Определим основное юридическое лицо организации */
    FIND_JURPERSONS_MAIN(NFLAG_SMART => 0, NCOMPANY => NCOMPANY, SJUR_PERS => SJUR_PERS, NJUR_PERS => NJUR_PERS);
  
    /* Определим базовую валюту */
    FIND_CURRENCY_BASE_NAME(NCOMPANY => NCOMPANY, SCODE => SCURRENCY, SISO => SCURRENCY);
  
    /* Определим подразделения склада, с которого производится отгузка */
    begin
      select D.CODE
        into SOUT_DEPARTMENT
        from AZSAZSLISTMT   S,
             INS_DEPARTMENT D
       where S.COMPANY = NCOMPANY
         and S.AZS_NUMBER = SSTORE_PRODUCE
         and S.DEPARTMENT = D.RN;
    exception
      when NO_DATA_FOUND then
        P_EXCEPTION(0, 'Для склада "%s" не указано подразделение!', SSTORE_PRODUCE);
    end;
  
    /* Определим МОЛ склада-получателя */
    begin
      select AG.AGNABBR
        into SAGENT
        from AZSAZSLISTMT S,
             AGNLIST      AG
       where S.COMPANY = NCOMPANY
         and S.AZS_NUMBER = SSTORE_GOODS
         and S.AZS_AGENT = AG.RN;
    exception
      when NO_DATA_FOUND then
        P_EXCEPTION(0,
                    'Для склада "%s" не указано материально ответственное лицо!',
                    SSTORE_PRODUCE);
    end;
  
    /* Обходим конфигурацию ячеек стенда для того что бы сформировать коллекцию загружаемых номенклатур */
    if ((RACK_LINE_CELL_CONFS is not null) and (RACK_LINE_CELL_CONFS.COUNT > 0)) then
      /* Инициализируеим коллекцию загружаемых номенклатур */
      NOMENS := TNOMENS();
      /* Наполним её... */
      declare
        BADD boolean := false;
      begin
        /* ...найдем для каждой из сконфигурированных ячеек стенеда... */
        for I in RACK_LINE_CELL_CONFS.FIRST .. RACK_LINE_CELL_CONFS.LAST
        loop
          BADD := true;
          if (NOMENS.COUNT > 0) then
            /* ...в коллекции загружаемых номенклатур... */
            for J in NOMENS.FIRST .. NOMENS.LAST
            loop
              /* ...аналог */
              if (NOMENS(J).NNOMMODIF = RACK_LINE_CELL_CONFS(I).NNOMMODIF) then
                /* ...если нашли - то увеличим загружаемое в стенд количество (он всегда загружается полностью) */
                BADD := false;
                NOMENS(J).NQUANT := NOMENS(J).NQUANT + RACK_LINE_CELL_CONFS(I).NCAPACITY;
              end if;
            end loop;
          end if;
          /* ...не нашли номенклатуры ячейки в коллекции для загрузки - значит добавим её, иначе ячейка будет пустой */
          if (BADD) then
            NOMENS.EXTEND();
            NOMENS(NOMENS.LAST).SNOMEN := RACK_LINE_CELL_CONFS(I).SNOMEN;
            NOMENS(NOMENS.LAST).NNOMEN := RACK_LINE_CELL_CONFS(I).NNOMEN;
            NOMENS(NOMENS.LAST).SNOMMODIF := RACK_LINE_CELL_CONFS(I).SNOMMODIF;
            NOMENS(NOMENS.LAST).NNOMMODIF := RACK_LINE_CELL_CONFS(I).NNOMMODIF;
            NOMENS(NOMENS.LAST).NQUANT := RACK_LINE_CELL_CONFS(I).NCAPACITY;
          end if;
        end loop;
      end;
      if (NOMENS.COUNT = 0) then
        P_EXCEPTION(0,
                    'Не удалось определить коллекцию загружаемых номенклатур!');
      end if;
    else
      P_EXCEPTION(0, 'Стенд не сконфигурирован!');
    end if;
  
    /* Расчитаем очередной номер документа */
    P_INCOMEFROMDEPS_GETNEXTNUMB(NCOMPANY => NCOMPANY,
                                 STYPE    => SINCDEPS_TYPE,
                                 SPREF    => SINCDEPS_PREF,
                                 SNUMB    => SDOC_NUMB);
  
    /* Генерация заголовка прихода из подразделений */
    P_INCOMEFROMDEPS_INSERT(NCOMPANY          => NCOMPANY,
                            NCRN              => NCRN,
                            SJUR_PERS         => SJUR_PERS,
                            SDOC_TYPE         => SINCDEPS_TYPE,
                            SDOC_PREF         => SINCDEPS_PREF,
                            SDOC_NUMB         => SDOC_NUMB,
                            DDOC_DATE         => TRUNC(sysdate),
                            SVALID_DOCTYPE    => null,
                            SVALID_DOCNUMB    => null,
                            DVALID_DOCDATE    => null,
                            SOUT_DEPARTMENT   => SOUT_DEPARTMENT,
                            SOUT_FACEACC      => null,
                            SOUT_GRAPHPOINT   => null,
                            SOUT_STORE        => SSTORE_PRODUCE,
                            SPARTY_AGENT      => null,
                            SSTORE            => SSTORE_GOODS,
                            SAGENT            => SAGENT,
                            SCURRENCY         => SCURRENCY,
                            SSTORE_OPER       => SDEF_STORE_MOVE_IN,
                            SPARTY            => SDEF_STORE_PARTY,
                            SNOTE             => null,
                            NCURCOURS         => null,
                            NCURBASECOURS     => null,
                            NCURCOURS_DOC     => 1,
                            NCURBASECOURS_DOC => 1,
                            SBARCODE          => null,
                            NDUP_RN           => null,
                            NRN               => NINCOMEFROMDEPS);
  
    /* Генерация спецификации прихода из подразделений */
    for I in NOMENS.FIRST .. NOMENS.LAST
    loop
      P_INCOMEFROMDEPSSPEC_INSERT(NCOMPANY        => NCOMPANY,
                                  NPRN            => NINCOMEFROMDEPS,
                                  SNOMEN          => NOMENS(I).SNOMEN,
                                  SNOMMODIF       => NOMENS(I).SNOMMODIF,
                                  SNOMNPACK       => null,
                                  SARTICLE        => null,
                                  SCELL           => null,
                                  SPARTY_AGENT    => null,
                                  SSUPPLY         => null,
                                  SSTORE          => null,
                                  NQUANT_PLAN     => NOMENS(I).NQUANT,
                                  NQUANT_FACT     => NOMENS(I).NQUANT,
                                  NQUANT_PLAN_ALT => 0,
                                  NQUANT_FACT_ALT => 0,
                                  DSROK           => null,
                                  SSERTIFICATE    => null,
                                  NPRICE          => 0,
                                  NPRICEMEAS      => 0,
                                  NSUMM_PLAN      => 0,
                                  NSUMM_FACT      => 0,
                                  SNOTE           => null,
                                  SSERNUMB        => null,
                                  SBARCODE        => null,
                                  SCOUNTRY        => null,
                                  SGTD            => null,
                                  SPRODUCER       => null,
                                  NSTORAGE_TIME   => null,
                                  SUMEAS_STORAGE  => null,
                                  NRN             => NOMENS(I).NINCOMEFROMDEPSSPEC);
    end loop;
  
    /* Установка мест хранения для спецификации */
    for I in 1 .. NRACK_LINES
    loop
      for J in 1 .. NRACK_LINE_CELLS
      loop
        /* Считаем конфигурацию ячейки */
        CELL_CONF := STAND_GET_RACK_LINE_CELL_CONF(NRACK_LINE => I, NRACK_LINE_CELL => J);
        /* Найдем позицию спецификации которой она была загружена */
        NINCOMEFROMDEPSSPEC := null;
        for N in NOMENS.FIRST .. NOMENS.LAST
        loop
          if (NOMENS(N).NNOMMODIF = CELL_CONF.NNOMMODIF) then
            NINCOMEFROMDEPSSPEC := NOMENS(N).NINCOMEFROMDEPSSPEC;
          end if;
        end loop;
        if (NINCOMEFROMDEPSSPEC is null) then
          P_EXCEPTION(0,
                      'Для модификации "%s" номенклатуры "%s" не удалось определить позицию прихода из подразделения!',
                      CELL_CONF.SNOMMODIF,
                      CELL_CONF.SNOMEN);
        end if;
        /* Установим место хранения */
        P_STRPLRESJRNL_INSERT(NCOMPANY        => NCOMPANY,
                              SMASTERUNITCODE => 'IncomFromDeps',
                              SSLAVEUNITCODE  => 'IncomFromDepsSpecs',
                              NMASTERRN       => NINCOMEFROMDEPS,
                              NSLAVERN        => NINCOMEFROMDEPSSPEC,
                              SSTORE          => SSTORE_GOODS,
                              SRACK_PREF      => SRACK_PREF,
                              SRACK_NUMB      => SRACK_NUMB,
                              SCELL_PREF      => CELL_CONF.SPREF,
                              SCELL_NUMB      => CELL_CONF.SNUMB,
                              NGOODSSUPPLY    => null,
                              NRES_TYPE       => 0,
                              SNOMEN          => CELL_CONF.SNOMEN,
                              SNOMMODIF       => CELL_CONF.SNOMMODIF,
                              SNOMNMODIFPACK  => null,
                              NNOMMODIF       => CELL_CONF.NNOMMODIF,
                              NNOMNMODIFPACK  => null,
                              SARTICLE        => null,
                              NARTICLE        => null,
                              SGOODSUNIT      => null,
                              SDOCTYPE        => SINCDEPS_TYPE,
                              DDOCDATE        => TRUNC(sysdate),
                              SDOCNUMB        => SDOC_NUMB,
                              SDOCPREF        => SINCDEPS_PREF,
                              DRESERVING_DATE => sysdate,
                              DFREE_DATE      => null,
                              NQUANT          => CELL_CONF.NCAPACITY,
                              NQUANTALT       => 0,
                              NQUANTPACK      => null,
                              NRN             => NSTRPLRESJRNL);
      end loop;
    end loop;
  
    /* Отработка документа как "Факт" */
    P_INCOMEFROMDEPS_SET_STATUS(NCOMPANY  => NCOMPANY,
                                NRN       => NINCOMEFROMDEPS,
                                NSTATUS   => 2,
                                DWORKDATE => TRUNC(sysdate),
                                NWARNING  => NWARNING,
                                SMSG      => SMSG);
    if ((NWARNING is not null) or (SMSG is not null)) then
      P_EXCEPTION(0, NVL(SMSG, 'Ошибка отработки документа!'));
    end if;
  
    /* Распределение спецификации по местам хранения */
    P_STRPLRESJRNL_INDEPTS_PROCESS(NCOMPANY => NCOMPANY, NRN => NINCOMEFROMDEPS);
  
    /* Оповестим о загузке стенда */
    MSG_INSERT_NOTIFY(SMSG => 'Стнед успешно загружен...');
  
    /* Запомним остатки по стенду */
    STAND_SAVE_RESTS(NCOMPANY => NCOMPANY, BNOTIFY_REST => true, BNOTIFY_LIMIT => false);
  end;

  /* Откат последней загрузки стенда */
  procedure LOAD_ROLLBACK
  (
    NCOMPANY                number                  -- Регистрационный номер организации
  ) is
    NINCOMEFROMDEPS         INCOMEFROMDEPS.RN%type; -- Рег. номер расформируемого "Прихода из подразделения"
    NWARNING                PKG_STD.TREF;           -- Флаг предупреждения процедуры отработки прихода
    SMSG                    PKG_STD.TSTRING;        -- Текст сообщения процедуры отработки прихода
  begin
    /* Находим последнюю загрузку */
    begin
      select max(T.RN)
        into NINCOMEFROMDEPS
        from INCOMEFROMDEPS T,
             DOCTYPES       DT,
             AZSAZSLISTMT   STORE_FROM,
             AZSAZSLISTMT   STORE_TO
       where T.COMPANY = NCOMPANY
         and T.DOC_TYPE = DT.RN
         and DT.DOCCODE = SINCDEPS_TYPE
         and trim(T.DOC_PREF) = SINCDEPS_PREF
         and T.OUT_STORE = STORE_FROM.RN
         and STORE_FROM.AZS_NUMBER = SSTORE_PRODUCE
         and T.STORE = STORE_TO.RN
         and STORE_TO.AZS_NUMBER = SSTORE_GOODS;
    exception
      when NO_DATA_FOUND then
        P_EXCEPTION(0, 'Не найдено ни одной загрузки стенда!');
    end;
  
    /* Отменяем размещение на местах хранения */
    P_STRPLRESJRNL_INDEPTS_RLLBACK(NCOMPANY => NCOMPANY, NRN => NINCOMEFROMDEPS);
  
    /* Снимаем отработку */
    P_INCOMEFROMDEPS_SET_STATUS(NCOMPANY  => NCOMPANY,
                                NRN       => NINCOMEFROMDEPS,
                                NSTATUS   => 0,
                                DWORKDATE => TRUNC(sysdate),
                                NWARNING  => NWARNING,
                                SMSG      => SMSG);
    if ((NWARNING is not null) or (SMSG is not null)) then
      P_EXCEPTION(0, NVL(SMSG, 'Ошибка снятия отработки документа!'));
    end if;
  
    /* Удаляем резервирование по местам хранения */
    for C in (select T.COMPANY,
                     T.RN
                from STRPLRESJRNL       T,
                     INCOMEFROMDEPSSPEC SP,
                     DOCLINKS           L
               where T.COMPANY = NCOMPANY
                 and SP.PRN = NINCOMEFROMDEPS
                 and L.IN_DOCUMENT = SP.RN
                 and L.IN_UNITCODE = 'IncomFromDepsSpecs'
                 and L.OUT_UNITCODE = 'StoragePlacesResJournal'
                 and L.OUT_DOCUMENT = T.RN)
    loop
      P_STRPLRESJRNL_DELETE(NCOMPANY => C.COMPANY, NRN => C.RN);
    end loop;
  
    /* Удаляем документ */
    P_INCOMEFROMDEPS_DELETE(NCOMPANY => NCOMPANY, NRN => NINCOMEFROMDEPS);

    /* Запомним остатки по стенду */
    STAND_SAVE_RESTS(NCOMPANY => NCOMPANY, BNOTIFY_REST => false, BNOTIFY_LIMIT => true);    
  end;

  /* Отгрузка со стенда посетителю */
  procedure SHIPMENT
  (
    NCOMPANY                number,                    -- Регистрационный номер организации
    SCUSTOMER               varchar2,                  -- Мнемокод контрагента-покупателя
    NRACK_LINE              number,                    -- Номер яруса стеллажа стенда
    NRACK_LINE_CELL         number,                    -- Номер ячейки в ярусе стеллажа стенда
    NTRANSINVCUST           out number                 -- Регистрационный номер сформированной РНОП
  ) is
    NCRN                    INCOMEFROMDEPS.RN%type;    -- Каталог размещения РНОП
    NJUR_PERS               JURPERSONS.RN%type;        -- Регистрационный номер юридического лица РНОП (основное ЮЛ организации)
    SJUR_PERS               JURPERSONS.CODE%type;      -- Мнемокод номер юридического лица РНОП (основное ЮЛ организации)
    SCURRENCY               CURNAMES.CURCODE%type;     -- Валюта формируемого РНОП (базовая валюта организации)
    SNUMB                   TRANSINVCUST.NUMB%type;    -- Номер формируемого РНОП
    SMOL                    AGNLIST.AGNABBR%type;      -- МОЛ склада отгрузки РНОП
    SMSG                    PKG_STD.TSTRING;           -- Текст сообщения процедуры добавления РНОП/спецификации РНОП/отработки РНОП    
    NTRANSINVCUSTSPECS      TRANSINVCUSTSPECS.RN%type; -- Регистрационный номер сформированной спецификации РНОП
    NGOODSSUPPLY            GOODSSUPPLY.RN%type;       -- Регистрационный номер товарного запаса для резервирования
    NSTRPLRESJRNL           STRPLRESJRNL.RN%type;      -- Регистрационный номер сформированной записи резервирования по местам хранения
    NTMP_QUANT              PKG_STD.TQUANT;            -- Буфер для количества номенклатуры в товарном запасе
    CELL_CONF               TRACK_LINE_CELL_CONF;      -- Конфигурация ячейки (места хранения) стенда    
  begin
    /* Определим рег. номер каталога */
    FIND_ROOT_CATALOG(NCOMPANY => NCOMPANY, SCODE => 'GoodsTransInvoicesToConsumers', NCRN => NCRN);
  
    /* Определим основное юридическое лицо организации */
    FIND_JURPERSONS_MAIN(NFLAG_SMART => 0, NCOMPANY => NCOMPANY, SJUR_PERS => SJUR_PERS, NJUR_PERS => NJUR_PERS);
  
    /* Определим базовую валюту */
    FIND_CURRENCY_BASE_NAME(NCOMPANY => NCOMPANY, SCODE => SCURRENCY, SISO => SCURRENCY);
  
    /* Считаем конфигурацию ячейки из которой происходит отгрузка */
    CELL_CONF := STAND_GET_RACK_LINE_CELL_CONF(NRACK_LINE => NRACK_LINE, NRACK_LINE_CELL => NRACK_LINE_CELL);
  
    /* Определим МОЛ склада отгрузки */
    begin
      select AG.AGNABBR
        into SMOL
        from AZSAZSLISTMT S,
             AGNLIST      AG
       where S.COMPANY = NCOMPANY
         and S.AZS_NUMBER = SSTORE_GOODS
         and S.AZS_AGENT = AG.RN;
    exception
      when NO_DATA_FOUND then
        P_EXCEPTION(0,
                    'Для склада "%s" не указано материально ответственное лицо!',
                    SSTORE_PRODUCE);
    end;
  
    /* Расчитаем очередной номер РНОП */
    P_TRANSINVCUST_GETNEXTNUMB(NCOMPANY  => NCOMPANY,
                               SJUR_PERS => SJUR_PERS,
                               DDOCDATE  => TRUNC(sysdate),
                               STYPE     => STRINVCUST_TYPE,
                               SPREF     => STRINVCUST_PREF,
                               SNUMB     => SNUMB);
  
    /* Добавляем заголовок РНОП */
    P_TRANSINVCUST_INSERT(NCOMPANY       => NCOMPANY,
                          NCRN           => NCRN,
                          SJUR_PERS      => SJUR_PERS,
                          SDOCTYPE       => STRINVCUST_TYPE,
                          SPREF          => STRINVCUST_PREF,
                          SNUMB          => SNUMB,
                          DDOCDATE       => TRUNC(sysdate),
                          NAUTO_CURCOURS => 1,
                          DSALEDATE      => TRUNC(sysdate),
                          SACCDOC        => null,
                          SACCNUMB       => null,
                          DACCDATE       => null,
                          SDIRDOC        => null,
                          SDIRNUMB       => null,
                          DDIRDATE       => null,
                          SSTOPER        => SDEF_STORE_MOVE_OUT,
                          SFACEACC       => SDEF_FACE_ACC,
                          SGRAPHPOINT    => null,
                          SAGENT         => SCUSTOMER,
                          STARIF         => SDEF_TARIF,
                          NSERVACT_SIGN  => 0,
                          SSTORE         => SSTORE_GOODS,
                          SMOL           => SMOL,
                          SSHEEPVIEW     => SDEF_SHEEP_VIEW,
                          SPAYTYPE       => SDEF_PAY_TYPE,
                          NDISCOUNT      => 0,
                          SCURRENCY      => SCURRENCY,
                          NCURCOURS      => 1,
                          NCURBASE       => 1,
                          NFA_COURS      => 1,
                          NFA_BASECOURS  => 1,
                          NSUMM          => 0,
                          NSUMMWITHNDS   => 0,
                          SRECIPDOC      => null,
                          SRECIPNUMB     => null,
                          DRECIPDATE     => null,
                          SFERRYMAN      => null,
                          SSHIPPER       => null,
                          SAGNFIFO       => null,
                          SFORWARDER     => null,
                          SWAYBLADENUMB  => null,
                          SDRIVER        => null,
                          SCAR           => null,
                          SROUTE         => null,
                          STRAILER1      => null,
                          STRAILER2      => null,
                          SCOMMENTS      => null,
                          SACC_AGENT     => null,
                          SSUBDIV        => null,
                          SBARCODE       => null,
                          SPAYCONF_TYPE  => null,
                          SPAYCONF_NUMB  => null,
                          DPAYCONF_DATE  => null,
                          SREG_AGENT     => null,
                          NRN            => NTRANSINVCUST,
                          SMSG           => SMSG);
  
    /* Добавим спецификацию РНОП */
    P_TRANSINVCUSTSPECS_INSERT(NCOMPANY         => NCOMPANY,
                               NPRN             => NTRANSINVCUST,
                               STAXGR           => SDEF_TAX_GROUP,
                               SGOODSPARTY      => null,
                               SNOMEN           => CELL_CONF.SNOMEN,
                               SNOMMODIF        => CELL_CONF.SNOMMODIF,
                               SNOMNMODIFPACK   => null,
                               SARTICLE         => null,
                               SCELL            => null,
                               SHLCARGOCLASS    => null,
                               NTEMPERATURE     => null,
                               NPRICE           => 0,
                               NDISCOUNT        => 0,
                               NQUANT           => CELL_CONF.NSHIP_CNT,
                               NQUANTALT        => 0,
                               NCOEFF           => 0,
                               NCOEFF_VAL_SIGN  => 0,
                               NCOEFF_CALC_SIGN => 1,
                               NPRICEMEAS       => 0,
                               NSUMM            => 0,
                               NSUMMWITHNDS     => 0,
                               NSUMM_NDS        => 0,
                               NAUTOCALC_SIGN   => 1,
                               DBEGINDATE       => null,
                               DENDDATE         => null,
                               SSERNUMB         => null,
                               SCOUNTRY         => null,
                               SGTD             => null,
                               SNOTE            => null,
                               NDUP_RN          => null,
                               NRN              => NTRANSINVCUSTSPECS,
                               SMSG             => SMSG);
  
    /* Найдем товарный запас */
    FIND_STPLGOODSSUPPLY_BY_PARTY(NFLAG_SMART   => 1,
                                  NCOMPANY      => NCOMPANY,
                                  SSTORE        => SSTORE_GOODS,
                                  SRACK         => RACK_BUILD_NAME(SPREF => SRACK_PREF, SNUMB => SRACK_NUMB),
                                  SCELL         => CELL_CONF.SNAME,
                                  SINDOC        => SDEF_STORE_PARTY,
                                  SSERNUMB      => null,
                                  SCOUNTRY      => null,
                                  SGTD          => null,
                                  SNOMEN        => CELL_CONF.SNOMEN,
                                  SNOMMODIF     => CELL_CONF.SNOMMODIF,
                                  SNOMMODIFPACK => null,
                                  SARTICLE      => null,
                                  DDATE         => sysdate,
                                  NGOODSSUPPLY  => NGOODSSUPPLY,
                                  NQUANT        => NTMP_QUANT,
                                  NQUANTALT     => NTMP_QUANT,
                                  NQUANTPACK    => NTMP_QUANT);
    if (NGOODSSUPPLY is null) then
      P_EXCEPTION(0,
                  'Не удалось определить товарный запас модификации "%s" номенклатуры "%s" на месте хранения "%s" стеллажа "%s" склада "%s"!',
                  CELL_CONF.SNOMMODIF,
                  CELL_CONF.SNOMEN,
                  CELL_CONF.SNAME,
                  RACK_BUILD_NAME(SPREF => SRACK_PREF, SNUMB => SRACK_NUMB),
                  SSTORE_GOODS);
    end if;
  
    /* Резервируем товар на местах хранения */
    P_STRPLRESJRNL_INSERT(NCOMPANY        => NCOMPANY,
                          SMASTERUNITCODE => 'GoodsTransInvoicesToConsumers',
                          SSLAVEUNITCODE  => 'GoodsTransInvoicesToConsumersSpecs',
                          NMASTERRN       => NTRANSINVCUST,
                          NSLAVERN        => NTRANSINVCUSTSPECS,
                          SSTORE          => SSTORE_GOODS,
                          SRACK_PREF      => SRACK_PREF,
                          SRACK_NUMB      => SRACK_NUMB,
                          SCELL_PREF      => CELL_CONF.SPREF,
                          SCELL_NUMB      => CELL_CONF.SNUMB,
                          NGOODSSUPPLY    => NGOODSSUPPLY,
                          NRES_TYPE       => 1,
                          SNOMEN          => CELL_CONF.SNOMEN,
                          SNOMMODIF       => CELL_CONF.SNOMMODIF,
                          SNOMNMODIFPACK  => null,
                          NNOMMODIF       => CELL_CONF.NNOMMODIF,
                          NNOMNMODIFPACK  => null,
                          SARTICLE        => null,
                          NARTICLE        => null,
                          SGOODSUNIT      => null,
                          SDOCTYPE        => STRINVCUST_TYPE,
                          DDOCDATE        => TRUNC(sysdate),
                          SDOCNUMB        => SNUMB,
                          SDOCPREF        => STRINVCUST_PREF,
                          DRESERVING_DATE => sysdate,
                          DFREE_DATE      => null,
                          NQUANT          => CELL_CONF.NSHIP_CNT,
                          NQUANTALT       => 0,
                          NQUANTPACK      => null,
                          NRN             => NSTRPLRESJRNL);
  
    /* Отработаем сформированный РНОП как факт */
    P_TRANSINVCUST_SET_STATUS(NCOMPANY   => NCOMPANY,
                              NRN        => NTRANSINVCUST,
                              NSTATUS    => 2,
                              DWORK_DATE => TRUNC(sysdate),
                              SMSG       => SMSG);
  
    /* Спишем резерв с мест хранения */
    P_STRPLRESJRNL_GTINV2C_PROCESS(NCOMPANY => NCOMPANY, NRN => NTRANSINVCUST, NRES_TYPE => 1);
  
    /* Сообщим, что произошло списание */
    MSG_INSERT_NOTIFY(SMSG => 'Произошла отгрузка "' || CELL_CONF.SNOMEN || ' - ' || CELL_CONF.SNOMMODIF ||
                              '"  посетителю "' || SCUSTOMER || '", документ-подтверждение: ' || STRINVCUST_TYPE || ' №' ||
                              STRINVCUST_PREF || '-' || SNUMB || ' от ' || TO_CHAR(sysdate, 'dd.mm.yyyy'));
  
    /* Запомним остатки по стенду */
    STAND_SAVE_RESTS(NCOMPANY => NCOMPANY, BNOTIFY_REST => false, BNOTIFY_LIMIT => true);
  end;

  /* Откат отгрузки со стенда */
  procedure SHIPMENT_ROLLBACK
  (
    NCOMPANY                number,               -- Регистрационный номер организации
    NTRANSINVCUST           number                -- Регистрационный номер отгрузочной РНОП
  ) is
    SCUSTOMER               AGNLIST.AGNABBR%type; -- Мнемокод контрагента отгрузки
    SMSG                    PKG_STD.TSTRING;      -- Текст сообщения процедуры отработки прихода
  begin
    /* Считаем мнемокод контрагента отгрузочного документа */
    begin
      select A.AGNABBR
        into SCUSTOMER
        from TRANSINVCUST T,
             AGNLIST      A
       where T.RN = NTRANSINVCUST
         and T.AGENT = A.RN;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0, NDOCUMENT => NTRANSINVCUST, SUNIT_TABLE => 'TRANSINVCUST');
    end;
  
    /* Отменяем размещение на местах хранения */
    P_STRPLRESJRNL_GTINV2C_RLLBACK(NCOMPANY => NCOMPANY, NRN => NTRANSINVCUST, NRES_TYPE => 1);
  
    /* Снимаем отработку */
    P_TRANSINVCUST_SET_STATUS(NCOMPANY   => NCOMPANY,
                              NRN        => NTRANSINVCUST,
                              NSTATUS    => 0,
                              DWORK_DATE => TRUNC(sysdate),
                              SMSG       => SMSG);
    if (SMSG is not null) then
      P_EXCEPTION(0, SMSG);
    end if;
  
    /* Удаляем резервирование по местам хранения */
    for C in (select T.COMPANY,
                     T.RN
                from STRPLRESJRNL      T,
                     TRANSINVCUSTSPECS SP,
                     DOCLINKS          L
               where T.COMPANY = NCOMPANY
                 and SP.PRN = NTRANSINVCUST
                 and L.IN_DOCUMENT = SP.RN
                 and L.IN_UNITCODE = 'GoodsTransInvoicesToConsumersSpecs'
                 and L.OUT_UNITCODE = 'StoragePlacesResJournal'
                 and L.OUT_DOCUMENT = T.RN)
    loop
      P_STRPLRESJRNL_DELETE(NCOMPANY => C.COMPANY, NRN => C.RN);
    end loop;
  
    /* Удаляем документ */
    P_TRANSINVCUST_DELETE(NCOMPANY => NCOMPANY, NRN => NTRANSINVCUST);
  
    /* Скажем что откатили отгрузку */
    MSG_INSERT_NOTIFY(SMSG => 'Отгрузка посетителю "' || SCUSTOMER || '" была отменена...');
  
    /* Запомним остатки по стенду */
    STAND_SAVE_RESTS(NCOMPANY => NCOMPANY, BNOTIFY_REST => true, BNOTIFY_LIMIT => false);
  end;
  
  /* Заполнение списка отмеченных для печати документов (автономная транзакция) */
  procedure PRINT_SET_SELECTLIST
  (
    NIDENT                  number,       -- Идентификатор буфера
    NDOCUMENT               number,       -- Регистрационный номер документа
    SUNITCODE               varchar2      -- Код раздела документа
  ) is
    NSLRN                   PKG_STD.TREF; -- Рег. номер позиции буфера выбранных документов
    pragma AUTONOMOUS_TRANSACTION;
  begin
    /* Добавляем РНОП в список выбранных документов */
    P_SELECTLIST_INSERT_EXT(NIDENT     => NIDENT,
                            NDOCUMENT  => NDOCUMENT,
                            SUNITCODE  => SUNITCODE,
                            NDOCUMENT1 => null,
                            SUNITCODE1 => null,
                            NCRN       => null,
                            NRN        => NSLRN);
    /* Подтверждаем автономную транзакцию */
    commit;                            
  end;
  
  /* Очистка списка отмеченных для печати документов (автономная транзакция) */
  procedure PRINT_CLEAR_SELECTLIST
  (
    NIDENT                  number      -- Идентификатор буфера
  ) is
    pragma AUTONOMOUS_TRANSACTION;
  begin
    /* Зачищаем буфер */
    P_SELECTLIST_CLEAR(NIDENT => NIDENT);
    /* Подтверждаем автономную транзакцию */
    commit;                            
  end;
  
  /* Печать РНОП через сервер печати */
  procedure PRINT
  (
    NCOMPANY                number,          -- Регистрационный номер органиазации
    NTRANSINVCUST           number           -- Регистрационный номер РНОП
  ) is
    NIDENT                  PKG_STD.TREF;    -- Идентификатор отмеченных записей для документа отгрузки    
    NTRINVCUST_REPORT       PKG_STD.TREF;    -- Рег. номер формируемого отчета
    STRANSINVCUST           PKG_STD.TSTRING; -- Описание документа отгрузки
    SAGENT                  PKG_STD.TSTRING; -- Контрагент документа отгразки
    NPQ                     PKG_STD.TREF;    -- Рег. номер позиции очереди отчета
  begin
    /* Считаем данные документа отгрузки */
    begin
      select trim(T.PREF) || '-' || trim(T.NUMB) || ' от ' || TO_CHAR(T.DOCDATE, 'dd.mm.yyyy'),
             AG.AGNABBR
        into STRANSINVCUST,
             SAGENT
        from TRANSINVCUST T,
             AGNLIST      AG
       where T.RN = NTRANSINVCUST
         and T.COMPANY = NCOMPANY
         and T.AGENT = AG.RN;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0, NDOCUMENT => NTRANSINVCUST, SUNIT_TABLE => 'TRANSINVCUST');
    end;
    /* Найдем регистрационный номер отчета */
    FIND_USERREP_CODE(NFLAG_SMART => 0, NCOMPANY => NCOMPANY, SCODE => STRINVCUST_REPORT, NRN => NTRINVCUST_REPORT);
    /* Генерируем идентификатор отмеченных записей */
    P_SELECTLIST_GENIDENT(NIDENT => NIDENT);
    /* Кладём документ в буфер (автономная транзакция) */
    PRINT_SET_SELECTLIST(NIDENT    => NIDENT,
                         NDOCUMENT => NTRANSINVCUST,
                         SUNITCODE => 'GoodsTransInvoicesToConsumers');  
    /* Передадим отчет серверу печати */
    PKG_RPTPRTQUEUE.RESET_PARAMETER();
    PKG_RPTPRTQUEUE.SET_PARAMETER(SNAME       => 'NCOMPANY',
                                  NDATA_TYPE  => 1,
                                  SSTR_VALUE  => null,
                                  NNUM_VALUE  => NCOMPANY,
                                  DDATE_VALUE => null,
                                  BLIST_IDENT => false);
    PKG_RPTPRTQUEUE.SET_PARAMETER(SNAME       => 'NIDENT',
                                  NDATA_TYPE  => 1,
                                  SSTR_VALUE  => null,
                                  NNUM_VALUE  => NIDENT,
                                  DDATE_VALUE => null,
                                  BLIST_IDENT => true);
    PKG_RPTPRTQUEUE.SET_PARAMETER(SNAME       => 'SSELLER',
                                  NDATA_TYPE  => 0,
                                  SSTR_VALUE  => null,
                                  NNUM_VALUE  => null,
                                  DDATE_VALUE => null,
                                  BLIST_IDENT => false);
    PKG_RPTPRTQUEUE.SET_PARAMETER(SNAME       => 'SSEL_BNKATR',
                                  NDATA_TYPE  => 0,
                                  SSTR_VALUE  => null,
                                  NNUM_VALUE  => null,
                                  DDATE_VALUE => null,
                                  BLIST_IDENT => false);
    PKG_RPTPRTQUEUE.SET_PARAMETER(SNAME       => 'SSENDER',
                                  NDATA_TYPE  => 0,
                                  SSTR_VALUE  => null,
                                  NNUM_VALUE  => null,
                                  DDATE_VALUE => null,
                                  BLIST_IDENT => false);
    PKG_RPTPRTQUEUE.SET_PARAMETER(SNAME       => 'SSND_BNKATR',
                                  NDATA_TYPE  => 0,
                                  SSTR_VALUE  => null,
                                  NNUM_VALUE  => null,
                                  DDATE_VALUE => null,
                                  BLIST_IDENT => false);
    PKG_RPTPRTQUEUE.SET_PARAMETER(SNAME       => 'SRECEIVER',
                                  NDATA_TYPE  => 0,
                                  SSTR_VALUE  => SAGENT,
                                  NNUM_VALUE  => null,
                                  DDATE_VALUE => null,
                                  BLIST_IDENT => false);
    PKG_RPTPRTQUEUE.SET_PARAMETER(SNAME       => 'SREC_BNKATR',
                                  NDATA_TYPE  => 0,
                                  SSTR_VALUE  => null,
                                  NNUM_VALUE  => null,
                                  DDATE_VALUE => null,
                                  BLIST_IDENT => false);
    PKG_RPTPRTQUEUE.SET_PARAMETER(SNAME       => 'NNUMB_LINES_FIRST',
                                  NDATA_TYPE  => 1,
                                  SSTR_VALUE  => null,
                                  NNUM_VALUE  => 10,
                                  DDATE_VALUE => null,
                                  BLIST_IDENT => false);
    PKG_RPTPRTQUEUE.SET_PARAMETER(SNAME       => 'NNUMB_LINES_LAST',
                                  NDATA_TYPE  => 1,
                                  SSTR_VALUE  => null,
                                  NNUM_VALUE  => 10,
                                  DDATE_VALUE => null,
                                  BLIST_IDENT => false);
    PKG_RPTPRTQUEUE.SET_PARAMETER(SNAME       => 'NNUMB_LINES',
                                  NDATA_TYPE  => 1,
                                  SSTR_VALUE  => null,
                                  NNUM_VALUE  => 10,
                                  DDATE_VALUE => null,
                                  BLIST_IDENT => false);
    PKG_RPTPRTQUEUE.SET_PARAMETER(SNAME       => 'NSHOW_NOMEN',
                                  NDATA_TYPE  => 3,
                                  SSTR_VALUE  => null,
                                  NNUM_VALUE  => 1,
                                  DDATE_VALUE => null,
                                  BLIST_IDENT => false);
    PKG_RPTPRTQUEUE.REGISTER_REPORT(NREPORT_TYPE     => 0,
                                    BWAIT_COMPLEET   => false,
                                    NCOMPANY         => NCOMPANY,
                                    NIDENT           => null,
                                    NUSER_REPORT     => NTRINVCUST_REPORT,
                                    NCALC_TABLE      => null,
                                    NCALC_TABLE_LINK => null,
                                    SCALC_TABLE_URL  => null,
                                    SCALC_TABLE_DB   => null,
                                    NQUEUE           => NPQ);
    /* Зачищаем буфер отмеченных документов (автономная транзакция) */
    PRINT_CLEAR_SELECTLIST(NIDENT => NIDENT);
    /* Оповестим пользователей о том, что отчет поставлен в очередь */
    MSG_INSERT_NOTIFY(SMSG => 'Накладаня "' || STRANSINVCUST || '" для посетителя "' || SAGENT ||
                              '" поставлена в очередь');
    /* Оповестим службу автоматической печати, о том, что надо следить за отчетом */
    MSG_INSERT_PRINT(SMSG => NPQ);
  exception
     /* В случае любых ошибок - зачистим всё что сохранили автономной транзакцией в буфере */
     when others then
       /* Зачищаем буфер отмеченных документов (автономная транзакция) */
       PRINT_CLEAR_SELECTLIST(NIDENT => NIDENT);
       raise;
  end;
  
  /* Инициализация конфигурации ячеек стенда */
  procedure STAND_INIT_RACK_LINE_CELL_CONF 
  (
    NCOMPANY                number              -- Регистрационный номер организации 
  ) is
    NDEF_NOMEN_1              DICNOMNS.RN%type; -- Номенклатура по умолчанию (1)
    NDEF_NOMEN_MODIF_1        NOMMODIF.RN%type; -- Модификация номенклатуры по умолчанию (1)
    NDEF_NOMEN_2              DICNOMNS.RN%type; -- Номенклатура по умолчанию (2)
    NDEF_NOMEN_MODIF_2        NOMMODIF.RN%type; -- Модификация номенклатуры по умолчанию (2)
    NDEF_NOMEN_3              DICNOMNS.RN%type; -- Номенклатура по умолчанию (3)
    NDEF_NOMEN_MODIF_3        NOMMODIF.RN%type; -- Модификация номенклатуры по умолчанию (3)
  begin
    /* Инициализируем коллекцию */
    RACK_LINE_CELL_CONFS := TRACK_LINE_CELL_CONFS();
    /* Разыменуем номенклатуры по умолчанию */
    FIND_DICNOMNS_BY_CODE(NFLAG_SMART => 0, NCOMPANY => NCOMPANY, SNOMEN_CODE => SDEF_NOMEN_1, NRN => NDEF_NOMEN_1);
    FIND_NOMMODIF_BY_CODE(NPRN => NDEF_NOMEN_1, SCODE => SDEF_NOMEN_MODIF_1, NFRN => NDEF_NOMEN_MODIF_1);
    FIND_DICNOMNS_BY_CODE(NFLAG_SMART => 0, NCOMPANY => NCOMPANY, SNOMEN_CODE => SDEF_NOMEN_2, NRN => NDEF_NOMEN_2);
    FIND_NOMMODIF_BY_CODE(NPRN => NDEF_NOMEN_2, SCODE => SDEF_NOMEN_MODIF_2, NFRN => NDEF_NOMEN_MODIF_2);
    FIND_DICNOMNS_BY_CODE(NFLAG_SMART => 0, NCOMPANY => NCOMPANY, SNOMEN_CODE => SDEF_NOMEN_3, NRN => NDEF_NOMEN_3);
    FIND_NOMMODIF_BY_CODE(NPRN => NDEF_NOMEN_3, SCODE => SDEF_NOMEN_MODIF_3, NFRN => NDEF_NOMEN_MODIF_3);
    /* Обходям ярусы */
    for I in 1 .. NRACK_LINES
    loop
      /* Обходим ячейки яруса */
      for J in 1 .. NRACK_LINE_CELLS
      loop
        /* Добавим ячейку в коллекцию */
        RACK_LINE_CELL_CONFS.EXTEND();
        RACK_LINE_CELL_CONFS(RACK_LINE_CELL_CONFS.LAST).NRACK_LINE := I;
        RACK_LINE_CELL_CONFS(RACK_LINE_CELL_CONFS.LAST).NRACK_LINE_CELL := J;
        RACK_LINE_CELL_CONFS(RACK_LINE_CELL_CONFS.LAST).SPREF := RACK_LINE_CELL_BUILD_PREF(NRACK_LINE => I);
        RACK_LINE_CELL_CONFS(RACK_LINE_CELL_CONFS.LAST).SNUMB := RACK_LINE_CELL_BUILD_NUMB(NRACK_LINE_CELL => J); 
        RACK_LINE_CELL_CONFS(RACK_LINE_CELL_CONFS.LAST).SNAME := RACK_LINE_CELL_BUILD_NAME(NRACK_LINE => I, NRACK_LINE_CELL => J);
        RACK_LINE_CELL_CONFS(RACK_LINE_CELL_CONFS.LAST).NCAPACITY := NRACK_CELL_CAPACITY;
        RACK_LINE_CELL_CONFS(RACK_LINE_CELL_CONFS.LAST).NSHIP_CNT := NRACK_CELL_SHIP_CNT;
        /* Конфигурируем ячейку */
        case
          /* 1 - 1 */
          when (I = 1) and (J = 1) then
            begin
              RACK_LINE_CELL_CONFS(RACK_LINE_CELL_CONFS.LAST).NNOMEN := NDEF_NOMEN_1;
              RACK_LINE_CELL_CONFS(RACK_LINE_CELL_CONFS.LAST).SNOMEN := SDEF_NOMEN_1;
              RACK_LINE_CELL_CONFS(RACK_LINE_CELL_CONFS.LAST).NNOMMODIF := NDEF_NOMEN_MODIF_1;
              RACK_LINE_CELL_CONFS(RACK_LINE_CELL_CONFS.LAST).SNOMMODIF := SDEF_NOMEN_MODIF_1;
            end;
          /* 1 - 2 */
          when (I = 1) and (J = 2) then
            begin
              RACK_LINE_CELL_CONFS(RACK_LINE_CELL_CONFS.LAST).NNOMEN := NDEF_NOMEN_2;
              RACK_LINE_CELL_CONFS(RACK_LINE_CELL_CONFS.LAST).SNOMEN := SDEF_NOMEN_2;
              RACK_LINE_CELL_CONFS(RACK_LINE_CELL_CONFS.LAST).NNOMMODIF := NDEF_NOMEN_MODIF_2;
              RACK_LINE_CELL_CONFS(RACK_LINE_CELL_CONFS.LAST).SNOMMODIF := SDEF_NOMEN_MODIF_2;
            end;
          /* 1 - 3 */
          when (I = 1) and (J = 3) then
            begin
              RACK_LINE_CELL_CONFS(RACK_LINE_CELL_CONFS.LAST).NNOMEN := NDEF_NOMEN_3;
              RACK_LINE_CELL_CONFS(RACK_LINE_CELL_CONFS.LAST).SNOMEN := SDEF_NOMEN_3;
              RACK_LINE_CELL_CONFS(RACK_LINE_CELL_CONFS.LAST).NNOMMODIF := NDEF_NOMEN_MODIF_3;
              RACK_LINE_CELL_CONFS(RACK_LINE_CELL_CONFS.LAST).SNOMMODIF := SDEF_NOMEN_MODIF_3;
            end;
          /* Неизвестная ячейка */
          else
            P_EXCEPTION(0,
                        'Неизвестная ячейка №%s в ярусе №%s - не могу задать конфигурацию!',
                        TO_CHAR(J),
                        TO_CHAR(I));
        end case;
      end loop;
    end loop;
  end;
  
  /* Сохранение текущих остатков по стенду */
  procedure STAND_SAVE_RESTS
  (
    NCOMPANY                number,                   -- Регистрационный номер органиазации
    BNOTIFY_REST            boolean,                  -- Флаг оповещения о текущем остатке
    BNOTIFY_LIMIT           boolean                   -- Флаг оповещения о критическом снижении остатка
  ) is
    NTOTAL                  PKG_STD.TLNUMBER := 0;    -- Текущий итог по остаткам
    SRESTS                  PKG_STD.TLSTRING;         -- Строка остатков для сообщения
    NR                      TNOMEN_RESTS;             -- Текущие остатки номенклатуры стенда
  begin
    /* Получим остатки по стенду */
    NR := STAND_GET_RACK_NOMEN_REST(NCOMPANY => NCOMPANY,
                                    SSTORE   => SSTORE_GOODS,
                                    SPREF    => SRACK_PREF,
                                    SNUMB    => SRACK_NUMB);
    /* Запомним остатки по стенду */
    MSG_INSERT_RESTS(SMSG => UDO_PKG_STAND_WEB.STAND_RACK_NOMEN_REST_TO_JSON(NR => NR).TO_CHAR());
    /* Суммируем остатки если они есть и выставляем по коллекции номенклатуру и ЕИ для сообщений*/
    if ((NR is not null) and (NR.COUNT > 0)) then
      for N in NR.FIRST .. NR.LAST
      loop
        NTOTAL := NTOTAL + NR(N).NREST;
        SRESTS := SRESTS || NR(N).SNOMMODIF || ' - ' || NR(N).NREST || '; ';
      end loop;
    end if;
    /* Если просили оповестить об остатках в принципе */
    if (BNOTIFY_REST) then
      if (NTOTAL = 0) then
        MSG_INSERT_NOTIFY(SMSG => 'На стенде больше нет товара');
      else
        MSG_INSERT_NOTIFY(SMSG => 'Текущий остаток по стенду: ' || SRESTS);
      end if;
    end if;
    /* Если просили оповестить о критическом снижении остатка */
    if (BNOTIFY_LIMIT) then
      /* Оповещаем, если они ниже критического лимита или их нет вообще */
      if (NTOTAL = 0) then
        MSG_INSERT_NOTIFY(SMSG => 'На стенде больше нет товара! Загрузите стенд!');
      else
        if ((NTOTAL / (NRACK_LINES * NRACK_LINE_CELLS * NRACK_CELL_CAPACITY) * 100) < NRESTS_LIMIT_MINIMUM) then
          MSG_INSERT_NOTIFY(SMSG => 'Текущая загруженность стенда ' ||
                                    TO_CHAR(ROUND(NTOTAL / (NRACK_LINES * NRACK_LINE_CELLS * NRACK_CELL_CAPACITY) * 100,
                                                  2)) || '% ниже критической отметки в ' ||
                                    TO_CHAR(NRESTS_LIMIT_MINIMUM) || '%! Приготовьтесь загрузить стенд!');
        end if;
      end if;
    end if;
  end;
  
  /* Получение конфигурации ячейки стенда */
  function STAND_GET_RACK_LINE_CELL_CONF
  (
    NRACK_LINE              number,     -- Номер яруса стеллажа стенда
    NRACK_LINE_CELL         number      -- Номер ячейки в ярусе стеллажа стенда
  ) return TRACK_LINE_CELL_CONF is
  begin
    /* Обходим конфигурацию ячеек стенда и находим нужную */
    if ((RACK_LINE_CELL_CONFS is not null) and (RACK_LINE_CELL_CONFS.COUNT > 0)) then
      for I in RACK_LINE_CELL_CONFS.FIRST .. RACK_LINE_CELL_CONFS.LAST
      loop
        /* Если нашлась нужная ячейка... */
        if ((RACK_LINE_CELL_CONFS(I).NRACK_LINE = NRACK_LINE) and
           (RACK_LINE_CELL_CONFS(I).NRACK_LINE_CELL = NRACK_LINE_CELL)) then
          /* ...вернём её */
          return RACK_LINE_CELL_CONFS(I);
        end if;
      end loop;
    else
      P_EXCEPTION(0, 'Не задана конфигурация ячеек стенда!');
    end if;
    /* Если мы здесь - то очевидно ничего не нашли */
    P_EXCEPTION(0,
                'Для чейчки №%s яруса №%s стенда конфигурация не определена!',
                TO_CHAR(NRACK_LINE_CELL),
                TO_CHAR(NRACK_LINE));
  end;
  
  /* Получение остатков стеллажа стенда по номенклатурам */
  function STAND_GET_RACK_NOMEN_REST
  (
    NCOMPANY                number,           -- Регистрационный номер организации
    SSTORE                  varchar2,         -- Мнемокод склада стенда
    SPREF                   varchar2,         -- Префикс стеллажа стенда
    SNUMB                   varchar2,         -- Номер стеллажа стенда
    SCELL                   varchar2 := null, -- Наименование (префикс-номер) ячейки стеллажа (null - по всем)
    SNOMEN                  varchar2 := null, -- Номенклатура (null - по всем)
    SNOMEN_MODIF            varchar2 := null  -- Модификация (null - по всем)
  ) return TNOMEN_RESTS is
    NSTORE                  PKG_STD.TREF;     -- Рег. номер склада
    NRACK                   PKG_STD.TREF;     -- Рег. номер стеллажа
    NCELL                   PKG_STD.TREF;     -- Рег. номер ячейки
    BADD                    boolean;          -- Флаг необходимости добавления номенклатуры в коллекцию
    N                       PKG_STD.TNUMBER;  -- Порядковый номер номенклатуры в результирующей коллекции
    NREST                   PKG_STD.TLNUMBER; -- Остаток по текущей номенклатуре в текущем месте хранения
    NTMP                    PKG_STD.TLNUMBER; -- Буфер для рассчетов
    RES                     TNOMEN_RESTS;     -- Результат работы
  begin
    /* Проверим параметры */
    if (((SNOMEN is null) and (SNOMEN_MODIF is not null)) or ((SNOMEN is not null) and (SNOMEN_MODIF is null))) then
      P_EXCEPTION(0,
                  'Обязательно одновременное указание номенклатуры и модификации!');
    end if;
    /* Найдём рег. номер склада */
    FIND_DICSTORE_NUMB(NFLAG_SMART => 0, NCOMPANY => NCOMPANY, SNUMB => SSTORE, NRN => NSTORE);
    /* Найдем рег. номер стеллажа */
    P_STPLRACKS_FIND(NFLAG_SMART => 0,
                     NCOMPANY    => NCOMPANY,
                     SSTORE      => SSTORE,
                     SPREF       => SPREF,
                     SNUMB       => SNUMB,
                     NRN         => NRACK);
    /* Найдём рег. номер ячейки */
    FIND_STPLCELLS_NUMB(NFLAG_SMART  => 0,
                        NFLAG_OPTION => 1,
                        NCOMPANY     => NCOMPANY,
                        NSTORE       => NSTORE,
                        SSTORE       => SSTORE,
                        SCELL        => SCELL,
                        NRN          => NCELL);
    /* Инициализируем выход */
    RES := TNOMEN_RESTS();
    /* Обходим номенклатуры */
    for NMNS in (select DN.RN NNOMEN,
                        DN.NOMEN_CODE SNOMEN,
                        NM.RN NNOMMODIF,
                        NM.MODIF_CODE SNOMMODIF,
                        DM.RN NMEAS,
                        DM.MEAS_MNEMO SMEAS,
                        RACK_LINE_CELL_BUILD_NAME(SPREF => C.PREF, SNUMB => C.NUMB) SCELL
                   from STPLGOODSSUPPLY SG,
                        GOODSSUPPLY     G,
                        GOODSPARTIES    GP,
                        STPLRACKS       R,
                        STPLCELLS       C,
                        INCOMDOC        IND,
                        DICNOMNS        DN,
                        NOMMODIF        NM,
                        DICMUNTS        DM
                  where G.COMPANY = NCOMPANY
                    and G.STORE = NSTORE
                    and G.RN = SG.GOODSSUPPLY
                    and R.RN = NRACK
                    and R.RN = C.PRN
                    and C.RN = SG.CELL
                    and G.PRN = GP.RN
                    and GP.INDOC = IND.RN
                    and IND.CODE = SDEF_STORE_PARTY
                    and GP.NOMMODIF = NM.RN
                    and NM.PRN = DN.RN
                    and DN.UMEAS_MAIN = DM.RN
                    and ((NCELL is null) or ((NCELL is not null) and (C.RN = NCELL)))
                    and ((SNOMEN is null) or ((SNOMEN is not null) and (DN.NOMEN_CODE = SNOMEN)))
                    and ((SNOMEN_MODIF is null) or ((SNOMEN_MODIF is not null) and (NM.MODIF_CODE = SNOMEN_MODIF)))
                  group by DN.RN,
                           DN.NOMEN_CODE,
                           NM.RN,
                           NM.MODIF_CODE,
                           DM.RN,
                           DM.MEAS_MNEMO,
                           RACK_LINE_CELL_BUILD_NAME(SPREF => C.PREF, SNUMB => C.NUMB))
    loop
      /* Попробуем найти номенклатуру в коллекции */
      BADD := true;
      if (RES.COUNT > 0) then
        for I in RES.FIRST .. RES.LAST
        loop
          if (RES(I).NNOMMODIF = NMNS.NNOMMODIF) then
            BADD := false;
            N    := I;
            exit;
          end if;
        end loop;
      end if;
      /* Добавим номенклатуру в коллекцию, если надо */
      if (BADD) then
        /* Новый элемент */
        RES.EXTEND();
        N := RES.LAST;
        /* Инициализируем номенклатуру */
        RES(N).NNOMEN := NMNS.NNOMEN;
        RES(N).SNOMEN := NMNS.SNOMEN;
        RES(N).NNOMMODIF := NMNS.NNOMMODIF;
        RES(N).SNOMMODIF := NMNS.SNOMMODIF;
        RES(N).NREST := 0;
        RES(N).NMEAS := NMNS.NMEAS;
        RES(N).SMEAS := NMNS.SMEAS;
      end if;
      /* Вычислим остаток по данной номенклатуре */
      P_STPLGOODSSUPPLY_GETREST(NFLAG_SMART   => 0,
                                NCOMPANY      => NCOMPANY,
                                SSTORE        => SSTORE,
                                SCELL         => NMNS.SCELL,
                                SNOMEN        => NMNS.SNOMEN,
                                SNOMMODIF     => NMNS.SNOMMODIF,
                                SNOMMODIFPACK => null,
                                SINDOC        => SDEF_STORE_PARTY,
                                SSERNUMB      => null,
                                SCOUNTRY      => null,
                                SGTD          => null,
                                NQUANT        => NREST,
                                NQUANTALT     => NTMP,
                                NQUANTPACK    => NTMP);
      /* Накопим остаток */
      RES(N).NREST := NREST + RES(N).NREST;
    end loop;
    /* Вернем результат */
    return RES;
  end;

  /* Получение остатков стеллажа стенда по местам хранения */
  function STAND_GET_RACK_REST
  (
    NCOMPANY                number,            -- Регистрационный номер организации
    SSTORE                  varchar2,          -- Мнемокод склада стенда
    SPREF                   varchar2,          -- Префикс стеллажа стенда
    SNUMB                   varchar2,          -- Номер стеллажа стенда
    SNOMEN                  varchar2 := null,  -- Номенклатура (null - по всем)
    SNOMEN_MODIF            varchar2 := null   -- Модификация (null - по всем)    
  ) return TRACK_REST is
    CELL                    STPLCELLS%rowtype; -- Запись ячейки стеллажа
    RES                     TRACK_REST;        -- Результат работы
  begin
    /* Находим стеллаж и инициализируем результат */
    begin
      select T.RN,
             T.STORE,
             S.AZS_NUMBER,
             trim(T.PREF),
             trim(T.NUMB),
             RACK_BUILD_NAME(SPREF => T.PREF, SNUMB => T.NUMB),
             NRACK_LINES
        into RES.NRACK,
             RES.NSTORE,
             RES.SSTORE,
             RES.SRACK_PREF,
             RES.SRACK_NUMB,
             RES.SRACK_NAME,
             RES.NRACK_LINES_CNT
        from STPLRACKS    T,
             AZSAZSLISTMT S
       where T.COMPANY = NCOMPANY
         and T.STORE = S.RN
         and S.AZS_NUMBER = SSTORE
         and trim(T.PREF) = SPREF
         and trim(T.NUMB) = SNUMB;
    exception
      when NO_DATA_FOUND then
        P_EXCEPTION(0,
                    'Стеллаж "%s" на складе "%s" не определён!',
                    RACK_BUILD_NAME(SPREF => SPREF, SNUMB => SNUMB),
                    SSTORE);
    end;
    /* Скажем, что стеллаж пустой */
    RES.BEMPTY := true;
    /* Инициализируем коллекцию ярусов */
    RES.RACK_LINE_RESTS := TRACK_LINE_RESTS();
    /* Обходим ярусы (согласно конфигурации стенда) */
    for L in 1 .. RES.NRACK_LINES_CNT
    loop
      /* Добавим новый ярус */
      RES.RACK_LINE_RESTS.EXTEND();
      RES.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS := TRACK_LINE_CELL_RESTS();
      /* Инициализируем его */
      RES.RACK_LINE_RESTS(L).NRACK_LINE := L;
      RES.RACK_LINE_RESTS(L).NRACK_LINE_CELLS_CNT := NRACK_LINE_CELLS;
      /* Скажем что ярус пустой */
      RES.RACK_LINE_RESTS(L).BEMPTY := true;
      /* Обходим ячейки яруса (согласно конфигурации стенда) */
      for C in 1 .. RES.RACK_LINE_RESTS(L).NRACK_LINE_CELLS_CNT
      loop
        /* Найдём рег. номер ячейки */
        FIND_STPLCELLS_NUMB(NFLAG_SMART  => 0,
                            NFLAG_OPTION => 0,
                            NCOMPANY     => NCOMPANY,
                            NSTORE       => RES.NSTORE,
                            SSTORE       => RES.SSTORE,
                            SCELL        => RACK_LINE_CELL_BUILD_NAME(NRACK_LINE => L, NRACK_LINE_CELL => C),
                            NRN          => CELL.RN);
        /* Считаем ячейку */
        begin
          select T.* into CELL from STPLCELLS T where T.RN = CELL.RN;
        exception
          when NO_DATA_FOUND then
            PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0, NDOCUMENT => CELL.RN, SUNIT_TABLE => 'STPLCELLS');
        end;
        /* Добавим ячейку в ярус */
        RES.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS.EXTEND();
        RES.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).NOMEN_RESTS := TNOMEN_RESTS();
        /* Проинициализируем ячейку */
        RES.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).NRACK_CELL := CELL.RN;
        RES.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).SRACK_CELL_PREF := trim(CELL.PREF);
        RES.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).SRACK_CELL_NUMB := trim(CELL.NUMB);
        RES.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).SRACK_CELL_NAME := RACK_LINE_CELL_BUILD_NAME(SPREF => CELL.PREF,
                                                                                                    SNUMB => CELL.NUMB);
        RES.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).NRACK_LINE := L;
        RES.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).NRACK_LINE_CELL := C;
        /* Скажем что ячейка пустая */
        RES.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).BEMPTY := true;
        /* Теперь наполним ячейку остатками номенклатуры */
        RES.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).NOMEN_RESTS := STAND_GET_RACK_NOMEN_REST(NCOMPANY     => NCOMPANY,
                                                                                                SSTORE       => RES.SSTORE,
                                                                                                SPREF        => RES.SRACK_PREF,
                                                                                                SNUMB        => RES.SRACK_NUMB,
                                                                                                SCELL        => RES.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C)
                                                                                                                .SRACK_CELL_NAME,
                                                                                                SNOMEN       => SNOMEN,
                                                                                                SNOMEN_MODIF => SNOMEN_MODIF);
      
      
        /* Если запас по номенклатуре не нулевой, то выставим ячейке, ярусу и стеллажу флаг заполненности */
        if (RES.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).NOMEN_RESTS.COUNT > 0) then
          for N in RES.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).NOMEN_RESTS.FIRST .. RES.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C)
                                                                                       .NOMEN_RESTS.LAST
          loop
            if (RES.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).NOMEN_RESTS(N).NREST <> 0) then
              RES.RACK_LINE_RESTS(L).RACK_LINE_CELL_RESTS(C).BEMPTY := false;
              RES.RACK_LINE_RESTS(L).BEMPTY := false;
              RES.BEMPTY := false;
              exit;
            end if;
          end loop;
        end if;
      end loop;
    end loop;
    /* Вернем результат */
    return RES;
  end;
  
  /* Поиск контрагента-посетителя стенда по штрихкоду */
  function STAND_GET_AGENT_BY_BARCODE
  (
    NCOMPANY                number,             -- Регистрационный номер организации
    SBARCODE                varchar2            -- Штрихкод
  ) return TSTAND_USER is
    NVERSION                VERSIONS.RN%type;   -- Версия раздела "Контрагенты"
    NDP_BARCODE             DOCS_PROPS.RN%type; -- Регистрационный номер дополнительного свойства для хранения штрихкода
    RES                     TSTAND_USER;        -- Результат работы
  begin
    /* Определим версию раздела "Контрагенты" */
    FIND_VERSION_BY_COMPANY(NCOMPANY => NCOMPANY, SUNITCODE => 'AGNLIST', NVERSION => NVERSION);
  
    /* Определим регистрационный номер дополнительного свойства для хранения штрихкода */
    FIND_DOCS_PROPS_CODE(NFLAG_SMART => 0, NCOMPANY => NCOMPANY, SCODE => SDP_BARCODE, NRN => NDP_BARCODE);
  
    /* Найдем контрагента с указанным штрихкодом */
    begin
      select AG.RN,
             AG.AGNABBR,
             AG.AGNNAME
        into RES.NAGENT,
             RES.SAGENT,
             RES.SAGENT_NAME
        from AGNLIST AG
       where AG.VERSION = NVERSION
         and F_DOCS_PROPS_GET_STR_VALUE(NPROPERTY => NDP_BARCODE, SUNITCODE => 'AGNLIST', NDOCUMENT => AG.RN) =
             SBARCODE;
    exception
      when TOO_MANY_ROWS then
        P_EXCEPTION(0,
                    'Найдено более одного контрагента со штрихкодом "%s"!',
                    SBARCODE);
      when NO_DATA_FOUND then
        P_EXCEPTION(0, 'Контрагент со штрихкодом "%s" не определён!', SBARCODE);
    end;
  
    /* Вернем результат */
    return RES;
  end;
  
  /* Проверка осуществления выдачи контрагенту-посетителю товара со стенда (см. константы NAGN_SUPPLY_*) */
  function STAND_CHECK_SUPPLY
  (
    NCOMPANY                number,          -- Регистрационный номер организации
    NAGENT                  number           -- Регистрационный номер контрагента
  ) return number is
    NRES                    PKG_STD.TNUMBER; -- Результат работы
  begin
    /* Пробуем найти РНОПотр с данным контрагентом, по складу стенда, с номенклатурой стенда, с типом и префиксом по умолчанию для стенда */
    begin
      select count(*)
        into NRES
        from TRANSINVCUST      T,
             DOCTYPES          DT,
             AZSAZSLISTMT      ST
       where T.COMPANY = NCOMPANY
         and trim(T.PREF) = STRINVCUST_PREF
         and T.DOCTYPE = DT.RN
         and DT.DOCCODE = STRINVCUST_TYPE
         and T.AGENT = NAGENT
         and T.STORE = ST.RN
         and ST.AZS_NUMBER = SSTORE_GOODS;
    exception
      when others then
        P_EXCEPTION(0,
                    'Ошибка поиска расходных накладных на отпуск потребителям для контрагента (RN: %s)!',
                    TO_CHAR(NAGENT));
    end;
    
    /* Таких нет... */
    if (NRES = 0) then
      /* ...значит не отгружали данному контрагенту */
      NRES := NAGN_SUPPLY_NOT_YET;
    else
      /* ...или есть и тогда - отгружали */
      NRES := NAGN_SUPPLY_ALREADY;
    end if;
  
    /* Вернем результат */
    return NRES;
  end;  
  
  /* Аутентификация посетителя стенда по штрихкоду */
  procedure STAND_AUTH_BY_BARCODE
  (
    NCOMPANY                number,          -- Регистрационный номер организации
    SBARCODE                varchar2,        -- Штрихкод    
    STAND_USER              out TSTAND_USER, -- Сведения о пользователе стенда
    RACK_REST               out TRACK_REST   -- Сведения об остатках на стенде
  ) is
  begin
    /* Найдем контрагента по штрихкоду */
    STAND_USER := STAND_GET_AGENT_BY_BARCODE(NCOMPANY => NCOMPANY, SBARCODE => SBARCODE);
  
    /* Проверим, что отгрузки данному контрагенту ещё не было (если надо, конечно) */
    if (NALLOW_MULTI_SUPPLY = NALLOW_MULTI_SUPPLY_NO) then
      if (STAND_CHECK_SUPPLY(NCOMPANY => NCOMPANY, NAGENT => STAND_USER.NAGENT) = NAGN_SUPPLY_ALREADY) then
        P_EXCEPTION(0,
                    'Извините, отгрузка для посетителя "%s" уже производилась!',
                    STAND_USER.SAGENT_NAME);
      end if;
    end if;
  
    /* Получим остатки по стеллажу, который обслуживает стенд */
    RACK_REST := STAND_GET_RACK_REST(NCOMPANY     => NCOMPANY,
                                     SSTORE       => SSTORE_GOODS,
                                     SPREF        => SRACK_PREF,
                                     SNUMB        => SRACK_NUMB);
  end;

begin
  /* Инициализация коллеции номенклатур стенда */
  STAND_INIT_RACK_LINE_CELL_CONF(NCOMPANY => GET_SESSION_COMPANY());
end;
/
