CLASS zcl_axage_demo1_ui DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    DATA command TYPE string.
    DATA objxml TYPE string.
    DATA results TYPE string.
    DATA help TYPE string.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA bill_developer TYPE REF TO zcl_axage_actor.
    DATA mark_consultant TYPE REF TO zcl_axage_actor.
    DATA engine TYPE REF TO zcl_axage_engine.
    DATA check_initialized TYPE abap_bool.
    METHODS init_game.
ENDCLASS.



CLASS zcl_axage_demo1_ui IMPLEMENTATION.


  METHOD init_game.
    engine = NEW #( ).
    DATA(entrance)   = NEW zcl_axage_room( name = 'Entrance' descr = 'You are in the entrance area. Welcome.' ).
    DATA(developer)  = NEW zcl_axage_room( name = 'Developers office' descr = 'The developers area. be quiet!' ).
    DATA(consulting) = NEW zcl_axage_room( name = 'Consulting Department' descr = 'This is the area where the consultants work. Bring coffee!' ).

    engine->map->add_room( entrance ).
    engine->map->add_room( developer ).
    engine->map->add_room( consulting ).
    engine->map->set_floor_plan( VALUE #(
      ( `+--------------------+ +--------------------+` )
      ( `|                    | |                    |` )
      ( `|                    | |                    |` )
      ( `|                    +-+                    |` )
      ( `|     ENTRANCE              DEVELOPERS      |` )
      ( `|                    +-+                    |` )
      ( `|                    | |                    |` )
      ( `|                    | |                    |` )
      ( `+--------+  +--------+ +--------------------+` )
      ( `         |  |` )
      ( `+--------+  +--------+` )
      ( `|                    |` )
      ( `|                    |` )
      ( `|                    |` )
      ( `|   CONSULTANTS      |` )
      ( `|                    |` )
      ( `|                    |` )
      ( `|                    |` )
      ( `+--------------------+` ) ) ).

    entrance->set_exits(
      e = developer
      s = consulting ).
    developer->set_exits(
      w = entrance ).
    consulting->set_exits(
      n = entrance ).
    DATA(cutter_knife) = NEW zcl_axage_thing( name = 'KNIFE' descr = 'a very sharp cutter knife' ).
    developer->things->add( cutter_knife ).
    DATA(needed_to_open_box) = NEW zcl_axage_thing_list(  ).
    needed_to_open_box->add( cutter_knife ).
    DATA(content_of_box) = NEW zcl_axage_thing_list( ).
    content_of_box->add( NEW zcl_axage_thing( name = 'RFC' descr = 'The request for change.' ) ).
    DATA(card_box) = NEW zcl_axage_openable_thing(
      name    = 'BOX'
      descr   = 'a little card box'
      content = content_of_box
      needed  = needed_to_open_box ).
    consulting->things->add( card_box ).

    engine->player->set_location( entrance ).

    bill_developer = NEW #( name = 'Bill' descr = 'An ABAP developer' ).
    bill_developer->set_location( developer ).
    bill_developer->add_sentences( VALUE #(
      ( |Hey, I am Bill, an experienced ABAP developer.| )
      ( |If you have programming tasks for me, you can pass the requirement to me| ) ) ).

    mark_consultant = NEW #( name = 'Mark' descr = 'An SAP consultant' ).
    mark_consultant->set_location( consulting ).
    mark_consultant->add_sentences( VALUE #(
      ( |Hello, My name is Mark and I am an SAP consultant| )
      ( |You can ask me anything about SAP processes.| ) ) ).

    engine->actors->add( bill_developer ).
    engine->actors->add( mark_consultant ).
  ENDMETHOD.


  METHOD z2ui5_if_app~main.
    IF check_initialized = abap_false.
      check_initialized = abap_true.
      command = 'MAP'.
      init_game(  ).
      help = engine->interprete( 'HELP' )->get( ).
      CALL TRANSFORMATION id SOURCE oref = engine
                           RESULT XML objxml.
    ELSE.
      CALL TRANSFORMATION id SOURCE XML objxml
                           RESULT oref = engine.
    ENDIF.


    CASE client->get( )-event.
      WHEN 'BUTTON_POST'.
        client->popup_message_toast( |{ command } - send to the server| ).
        DATA(result) = engine->interprete( command ).
        result->add( |You are in the { engine->player->location->name }.| ).

        IF engine->player->location->things->exists( 'RFC' ).
          engine->mission_completed = abap_true.
          result->add( 'Congratulations! You delivered the RFC to the developers!' ).
        ENDIF.
        results = |{ result->get(  ) } \n | &&  results.

      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( client->get( )-id_prev_app_stack  ) ).
    ENDCASE.

    CALL TRANSFORMATION id SOURCE oref = engine
                         RESULT XML objxml.

    DATA(view) = z2ui5_cl_xml_view=>factory( )->shell( ).
    DATA(page) = view->page(
      title          = 'abap2UI5 and AXAGE - ABAP teX Adventure #1'
      navbuttonpress = client->_event( 'BACK' )
      shownavbutton  = abap_false
    ).
    page->header_content(
         )->link(
             text = 'Source_Code'
             href = z2ui5_cl_xml_view=>hlp_get_source_code_url( app = me get = client->get( ) )
             target = '_blank'
     ).

    DATA(grid) = page->grid( 'L12 M12 S12' )->content( 'layout' ).
    grid->simple_form(
        title = 'Axage' editable = abap_true
        )->content( 'form'
            )->title( 'Game Input'
            )->label( 'Command'
            )->input( client->_bind( command )
            )->button(
                text  = 'Execute Command'
                press = client->_event( 'BUTTON_POST' )
            )->input(
               value = client->_bind( objxml )

    ).
    page->grid( 'L8 M8 S8' )->content( 'layout' ).
    grid->simple_form( title = 'Game Console' editable = abap_true )->content( 'form'
        )->text_area( value = client->_bind( results ) editable = 'false' growingmaxlines = '40' growing = abap_True
                      height = '600px'
        )->text_area( value = client->_bind( help ) editable = 'false' growingmaxlines = '40' growing = abap_True
                      height = '600px'
        ).
    client->set_next( VALUE #( xml_main = page->get_root( )->xml_get( ) ) ).

  ENDMETHOD.
ENDCLASS.
