# Mechanical strict-C99 view: remove empty file-scope declarations after function-defining macros.
# Original vendor bytes are checked and retained unchanged.
set(_ns_dom_semicolon_inputs
  "src/html/html_div_element.c|7e1037fa9c30d4a4d4d6d34651d62ee653d1cf08210560e614447412c5a04dbe"
  "src/html/html_button_element.c|723c4cdefffcbe23f25606bd4c744da6d34bc23dcae41ccfd980943b05962e6c"
  "src/html/html_li_element.c|338f7c750ee5c97afbffbc6ae3f021f5d99516bb75b4332ee6cc22aaaf16d58f"
  "src/html/html_base_element.c|48ffe89eedb064cc85036d54fc0dd7510f6bba9d15066c637a8eeaae60eebf73"
  "src/html/html_table_element.c|4b2060adc640999ea95759b2e96c22642604a4f3ee9d084c6dc4b6c1552de7b4"
  "src/html/html_font_element.c|5efecce60a640d463ba42bf2e096fd1c3a5be2ec7f786df6cef2ac0bb93e3455"
  "src/html/html_image_element.c|c27c64fbf4127c90d3bf97351ced3857e404192ced6bb4182b9ccb740e483f70"
  "src/html/html_object_element.c|866f0c8932803a23894160f8bb34d129f5cfa0445f31c9d7f652b61134d14eb3"
  "src/html/html_br_element.c|890267eb871f65c6922ba6c7fcba3dd2f598bfa21a3f415e3c726ae7e6a7eba4"
  "src/html/html_input_element.c|72d946a7d2e9efeb1e64ddabb60f60d02499496451c01573d74793583fc2d4a7"
  "src/html/html_applet_element.c|c872b2edbb7e6df56e90738128f77024286edaa5523260718f55afd2107427eb"
  "src/html/html_hr_element.c|c8e6141af3519b62a4a468e3726f2c930bbf28c4b6181b3e8c944a5e73bf3832"
  "src/html/html_area_element.c|bb9da410c8a6d2dfa84f036612eca5e32510fdfce295a78456b84587426f82f0"
  "src/html/html_iframe_element.c|df101a6fe140034c89d8b6be554071217fcb2e96abe22adcce69af17f24706b6"
  "src/html/html_ulist_element.c|62f05dd8abf1ef66d6ab382f22dce0b17ff66101e796eb36622349bdec5c8626"
  "src/html/html_script_element.c|4edbd98e502d502e0ed41ffa655113332f78d69ab5ef3465441b225563c8e959"
  "src/html/html_tablerow_element.c|47784852ad2f41aea38f0e541be1b717b1eaf375183e340e7dcdbf7a295bbaff"
  "src/html/html_style_element.c|388f33c1c7301aa93f17644e97160ad53f668f5b865271c3c23850dfcb8bec9a"
  "src/html/html_opt_group_element.c|e1573d28f925a2cac16b529688a04d6c471a2981a20bd5b14bd4084553bc8850"
  "src/html/html_paragraph_element.c|a64c0c8b92b4880d6c4ea157199cc1443e10fdde81e0779561a224a13ebfd86d"
  "src/html/html_anchor_element.c|9d7bc82972e5621a2d6fb32365907606362bb8a64c02262c3e654bf2fc7fc0d9"
  "src/html/html_quote_element.c|244bc99cceb92d96e4fdfa645802e357e4bce586128051598393143b84c58a6b"
  "src/html/html_mod_element.c|ab52afca554806f07a73bb871bce7513e04d3ce6dd8b9ac4da2d5b8f06c05bbc"
  "src/html/html_heading_element.c|4ca7bec13d9b919c96916a7b3bb6efa2800484bde6a3e45b3409203c0fd084b1"
  "src/html/html_map_element.c|eba6d16eea5642c77e23cb92c8c84e2548e32be81960350ff10a2c5924d2712e"
  "src/html/html_tablecell_element.c|a9321d4567e45277a438118db413bfd52fa52485f9ba68e26b67f72b3a1e00f4"
  "src/html/html_label_element.c|c7d2d2b791d27495c5498778a099a0ff5ecdbf6bb291c44ae6d7536c1d11f2a7"
  "src/html/html_legend_element.c|ce96424b316e44f6d61e003101454e4d3cb2c60051ef5bc41755a3e9f819ae82"
  "src/html/html_olist_element.c|6a5be87eb1d3f41040b2537113061d11b7ce5737e3338c18b55fa55d105efca4"
  "src/html/html_tablesection_element.c|b81d5f5be55544b56c8c35cdfd69309709c9392302a85df20e42a02dc837d316"
  "src/html/html_tablecaption_element.c|afeb562eb2a71fb808fab90d2b11a5cdb60f7786ad5f584799c512f546e67ca5"
  "src/html/html_basefont_element.c|57983d52c6e035b72f1da08063770d14a7262e2b050266c15cf80c0fbe68c06d"
  "src/html/html_frame_element.c|99032f7208883796262f1e71744bcb8a1d366c254a9a56f280ba38d9accf1edf"
  "src/html/html_frameset_element.c|8080fa15f9ed97020996dda08d912185a767d8ca65126a074e5be8d68d58d647"
  "src/html/html_param_element.c|7e80641dbbda4696d8997a30fe9ffd255af0f391462b1c74dc8b2d2232517d1d"
  "src/html/html_tablecol_element.c|262839682f4cb6250e2dd5c02fc15fdf0b643e10e661beccd0428e0e1cfbd96c"
  "src/html/html_text_area_element.c|da75b4d11996999a2883f26306ff4136db269e00c454dc6c62d455eeff4526dc"
  "src/html/html_isindex_element.c|5797bcb7eedc19252710a7bcff6d20ef2592908148c6fc0ff9d9f145db9f6407"
)
function(lmx_netsurf_dom_view source output)
  file(RELATIVE_PATH rel "${LMX_NETSURF_VENDOR_DIR}/libdom" "${source}")
  set(result "${source}")
  foreach(item IN LISTS _ns_dom_semicolon_inputs)
    string(REPLACE "|" ";" fields "${item}")
    list(GET fields 0 path)
    list(GET fields 1 expected)
    if(rel STREQUAL path)
      file(SHA256 "${source}" actual)
      if(NOT actual STREQUAL expected)
        message(FATAL_ERROR "NetSurf C99 view input changed: ${rel}")
      endif()
      file(READ "${source}" text)
      string(REGEX REPLACE "((SIMPLE_GET_SET|SIMPLE_GET|SIMPLE_SET)[ \t]*\\([A-Za-z_]+\\));" "\\1" text "${text}")
      set(result "${CMAKE_CURRENT_BINARY_DIR}/c99-view/libdom/${rel}")
      get_filename_component(parent "${result}" DIRECTORY)
      file(MAKE_DIRECTORY "${parent}")
      file(WRITE "${result}" "${text}")
    endif()
  endforeach()
  set(${output} "${result}" PARENT_SCOPE)
endfunction()
