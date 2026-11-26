/* SPDX-License-Identifier: MIT */
#include <assert.h>
#include <string.h>
#include <dom/dom.h>
#include <dom/bindings/hubbub/parser.h>

static void message(uint32_t level, void *context, const char *format, ...)
{ (void)level; (void)context; (void)format; }
static dom_string *string(const char *s)
{
    dom_string *result;
    assert(dom_string_create((const uint8_t *)s, strlen(s), &result) == DOM_NO_ERR);
    return result;
}
int main(void)
{
    const char html[] = "<!doctype html><title>LMX</title><table><tr><td>A&amp;B<td>second</table>";
    dom_hubbub_parser_params params = {0};
    dom_hubbub_parser *parser;
    dom_document *doc;
    dom_nodelist *list;
    dom_node *cell;
    dom_string *name, *text, *replacement;
    uint32_t length;
    size_t offset;
    params.enc = "UTF-8"; params.fix_enc = true; params.msg = message;
    assert(dom_hubbub_parser_create(&params, &parser, &doc) == DOM_HUBBUB_OK);
    for (offset = 0; offset < sizeof html - 1; offset += 7) {
        size_t n = sizeof html - 1 - offset;
        if (n > 7) n = 7;
        assert(dom_hubbub_parser_parse_chunk(parser, (const uint8_t *)html + offset, n) == DOM_HUBBUB_OK);
    }
    assert(dom_hubbub_parser_completed(parser) == DOM_HUBBUB_OK);
    dom_hubbub_parser_destroy(parser);
    name = string("tbody");
    assert(dom_document_get_elements_by_tag_name(doc, name, &list) == DOM_NO_ERR);
    assert(dom_nodelist_get_length(list, &length) == DOM_NO_ERR && length == 1);
    dom_nodelist_unref(list); dom_string_unref(name);
    name = string("td");
    assert(dom_document_get_elements_by_tag_name(doc, name, &list) == DOM_NO_ERR);
    assert(dom_nodelist_get_length(list, &length) == DOM_NO_ERR && length == 2);
    assert(dom_nodelist_item(list, 0, &cell) == DOM_NO_ERR && cell != NULL);
    assert(dom_node_get_text_content(cell, &text) == DOM_NO_ERR);
    assert(dom_string_byte_length(text) == 3 && memcmp(dom_string_data(text), "A&B", 3) == 0);
    dom_string_unref(text);
    replacement = string("changed");
    assert(dom_node_set_text_content(cell, replacement) == DOM_NO_ERR);
    assert(dom_node_get_text_content(cell, &text) == DOM_NO_ERR && dom_string_isequal(text, replacement));
    dom_string_unref(text); dom_string_unref(replacement); dom_node_unref(cell);
    dom_nodelist_unref(list); dom_string_unref(name); dom_node_unref(doc);
    return 0;
}
