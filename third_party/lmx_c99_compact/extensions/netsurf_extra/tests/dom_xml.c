/* SPDX-License-Identifier: MIT */
#include <assert.h>
#include <string.h>
#include <dom/dom.h>
#include <dom/bindings/xml/xmlparser.h>
static void message(uint32_t level, void *context, const char *format, ...)
{ (void)level; (void)context; (void)format; }
int main(void)
{
    uint8_t xml[] = "<root unit='m'><value>42 &amp; 7</value></root>";
    uint8_t broken[] = "<root><value></root>";
    dom_document *doc = NULL;
    dom_xml_parser *parser = dom_xml_parser_create("UTF-8", NULL, message, NULL, &doc);
    dom_element *root;
    dom_string *text, *key, *attribute;
    assert(parser != NULL && doc != NULL);
    assert(dom_xml_parser_parse_chunk(parser, xml, sizeof xml - 1) == DOM_XML_OK);
    assert(dom_xml_parser_completed(parser) == DOM_XML_OK);
    dom_xml_parser_destroy(parser);
    assert(dom_document_get_document_element(doc, &root) == DOM_NO_ERR && root != NULL);
    assert(dom_string_create((const uint8_t *)"unit", 4, &key) == DOM_NO_ERR);
    assert(dom_element_get_attribute(root, key, &attribute) == DOM_NO_ERR);
    assert(dom_string_byte_length(attribute) == 1 && dom_string_data(attribute)[0] == 'm');
    assert(dom_node_get_text_content(root, &text) == DOM_NO_ERR);
    assert(dom_string_byte_length(text) == 6 && memcmp(dom_string_data(text), "42 & 7", 6) == 0);
    dom_string_unref(key); dom_string_unref(attribute); dom_string_unref(text);
    dom_node_unref(root); dom_node_unref(doc);
    parser = dom_xml_parser_create("UTF-8", NULL, message, NULL, &doc);
    assert(parser != NULL);
    assert(dom_xml_parser_parse_chunk(parser, broken, sizeof broken - 1) != DOM_XML_OK);
    dom_xml_parser_destroy(parser); dom_node_unref(doc);
    return 0;
}
