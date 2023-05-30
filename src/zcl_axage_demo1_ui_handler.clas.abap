class ZCL_AXAGE_DEMO1_UI_HANDLER definition
  public
  create public .

public section.

  interfaces IF_HTTP_SERVICE_EXTENSION .
protected section.
private section.
ENDCLASS.



CLASS ZCL_AXAGE_DEMO1_UI_HANDLER IMPLEMENTATION.


  method IF_HTTP_SERVICE_EXTENSION~HANDLE_REQUEST.

   data(headers) = request->get_header_fields( ).
   data(formFields) = request->get_form_fields( ).
   append INITIAL LINE TO formFields REFERENCE INTO data(form).
   form->name = 'app'.
   form->value = 'ZCL_AXAGE_DEMO1_UI'.
   z2ui5_cl_http_handler=>client = VALUE #(
      t_header = headers
      t_param  = formFields
      body     = request->get_text( ) ).

   DATA(lv_resp) = SWITCH #( request->get_method( )
      WHEN 'GET'  THEN z2ui5_cl_http_handler=>http_get( )
      WHEN 'POST' THEN z2ui5_cl_http_handler=>http_post( ) ).

   response->set_status( 200 )->set_text( lv_resp ).
  endmethod.
ENDCLASS.
