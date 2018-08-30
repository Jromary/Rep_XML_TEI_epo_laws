<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns="http://www.tei-c.org/ns/1.0" xpath-default-namespace="http://www.w3.org/1999/xhtml">


    <xsl:output method="xml" indent="yes"/>

    <xsl:include href="transfo.xsl"/>

    <xsl:template match="/">
        <TEI>
            <teiHeader>
                <fileDesc>
                    <titleStmt>
                        <title>Convention on the Grant of European Patents (European Patent Convention)</title>
                    </titleStmt>
                    <publicationStmt>
                        <authority>
                            <orgName>EPO</orgName>
                        </authority>
                        <date type="published">5 October 1973 
                            as revised by the Act revising Article 63 EPC of 17 December 1991
                            and the Act revising the EPC of 29 November 2000</date>
                    </publicationStmt>
                    <sourceDesc>
                        <bibl><ref target="https://www.epo.org/law-practice/legal-texts/html/epc/2016/e/ma1.html"
                            >https://www.epo.org/law-practice/legal-texts/html/epc/2016/e/ma1.html</ref></bibl>
                    </sourceDesc>
                </fileDesc>
                
            </teiHeader>
            <text>
                <body>
                    <xsl:for-each
                        select="collection('../Ressources/article_xhtml/.?select=ar*.html')">
                        <xsl:sort select="tokenize(document-uri(.), '[^0-9]+')[2]"
                            data-type="number"/>
                        <xsl:message><xsl:value-of select="document-uri(.)"/> - <xsl:value-of
                                select="tokenize(document-uri(.), '[^0-9]+')[2]"/></xsl:message>
                        <xsl:apply-templates/>
                    </xsl:for-each>
                </body>
            </text>
        </TEI>
    </xsl:template>
</xsl:stylesheet>
