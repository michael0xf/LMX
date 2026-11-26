/* SPDX-License-Identifier: MIT */
#include <assert.h>
#include <string.h>
#include <libxml/parser.h>
#include <libxml/tree.h>
#include <libxml/xpath.h>
#include <libxml/xpathInternals.h>
#include <libxml/xmlwriter.h>
#include <libxml/xmlschemas.h>

int main(void)
{
    const char text[] = "<m:record xmlns:m='urn:lmx:test'><m:value unit='m'>42</m:value></m:record>";
    const char schema[] = "<xs:schema xmlns:xs='http://www.w3.org/2001/XMLSchema'><xs:element name='count' type='xs:int'/></xs:schema>";
    xmlDocPtr doc = xmlReadMemory(text, (int)strlen(text), "memory.xml", "UTF-8", XML_PARSE_NONET);
    xmlXPathContextPtr xpath;
    xmlXPathObjectPtr answer;
    xmlBufferPtr buffer;
    xmlTextWriterPtr writer;
    xmlSchemaParserCtxtPtr schema_parser;
    xmlSchemaPtr compiled_schema;
    xmlSchemaValidCtxtPtr validator;
    xmlChar *content;
    assert(doc != NULL);
    xpath = xmlXPathNewContext(doc); assert(xpath != NULL);
    assert(xmlXPathRegisterNs(xpath, BAD_CAST "m", BAD_CAST "urn:lmx:test") == 0);
    answer = xmlXPathEvalExpression(BAD_CAST "/m:record/m:value[@unit='m']", xpath);
    assert(answer && answer->nodesetval && answer->nodesetval->nodeNr == 1);
    content = xmlNodeGetContent(answer->nodesetval->nodeTab[0]);
    assert(content && xmlStrEqual(content, BAD_CAST "42")); xmlFree(content);
    xmlXPathFreeObject(answer); xmlXPathFreeContext(xpath); xmlFreeDoc(doc);
    buffer = xmlBufferCreate(); assert(buffer != NULL);
    writer = xmlNewTextWriterMemory(buffer, 0); assert(writer != NULL);
    assert(xmlTextWriterStartDocument(writer, NULL, "UTF-8", NULL) >= 0);
    assert(xmlTextWriterWriteElement(writer, BAD_CAST "count", BAD_CAST "42") >= 0);
    assert(xmlTextWriterEndDocument(writer) >= 0); xmlFreeTextWriter(writer);
    doc = xmlReadMemory((const char *)xmlBufferContent(buffer), (int)xmlBufferLength(buffer), "roundtrip.xml", "UTF-8", XML_PARSE_NONET);
    assert(doc != NULL); xmlBufferFree(buffer);
    schema_parser = xmlSchemaNewMemParserCtxt(schema, (int)strlen(schema)); assert(schema_parser != NULL);
    compiled_schema = xmlSchemaParse(schema_parser); assert(compiled_schema != NULL);
    validator = xmlSchemaNewValidCtxt(compiled_schema); assert(validator != NULL);
    assert(xmlSchemaValidateDoc(validator, doc) == 0);
    xmlSchemaFreeValidCtxt(validator); xmlSchemaFree(compiled_schema); xmlSchemaFreeParserCtxt(schema_parser); xmlFreeDoc(doc);
    xmlCleanupParser();
    return 0;
}
