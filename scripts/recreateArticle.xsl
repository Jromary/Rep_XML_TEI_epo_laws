<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0">

    <xsl:output method="xhtml" indent="yes"/>

    <xsl:template match="/">
        <xsl:apply-templates select="descendant::div[@type = 'article']"/>
        <xsl:result-document href="./output/article/Index.html">
            <xsl:for-each select="descendant::div[@type = 'article']">
                <html>
                    <body>
                        <xsl:variable name="article" select="@n"/>
                        <a href="Article_{$article}.html"> Article <xsl:value-of select="$article"/>
                        </a>
                        <br/>
                    </body>
                </html>
            </xsl:for-each>
        </xsl:result-document>
    </xsl:template>

    <xsl:template match="div[@type = 'article']">
        <xsl:message><xsl:value-of select="@n"/></xsl:message>
        <xsl:result-document href="./output/article/Article_{@n}.html">
            <html>
                <head>
                    <link rel="stylesheet" href="../style/style.css" type="text/css"/>
                    <link href="https://fonts.googleapis.com/css?family=Roboto+Slab|Roboto" rel="stylesheet"/>
                </head>
                <body>
                    <xsl:apply-templates/>
                    <p>
                        <a href="Index.html">Homepage</a>
                    </p>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>

    <xsl:template match="div[@type = 'paragraph']">
        <xsl:variable name="para" select="@n"/>
        <div class="type_paragraph" id="{$para}">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="ref[@type = 'article']">
        <xsl:variable name="reference" select="@n"/>
        <a href="../article/Article_A{$reference}.html">
            <xsl:apply-templates/>
        </a>
    </xsl:template>

    <xsl:template match="ref[@type = 'rule']">
        <xsl:variable name="reference" select="@n"/>
        <a href="../rule/Rule_R{$reference}.html">
            <xsl:apply-templates/>
        </a>
    </xsl:template>

    <xsl:template match="ref[@type = 'gDecision']">
        <xsl:variable name="reference" select="@n"/>
        <a href="">
            <xsl:apply-templates/>
        </a>
    </xsl:template>

    <xsl:template match="listRef">
        <table title="References">
            <tr>
                <xsl:for-each select="ref[@type = 'article']">
                    <td>
                        <xsl:apply-templates select="."/>
                    </td>
                </xsl:for-each>
            </tr>
            <tr>
                <xsl:for-each select="ref[@type = 'rule']">
                    <td>
                        <xsl:apply-templates select="."/>
                    </td>
                </xsl:for-each>
            </tr>
        </table>
    </xsl:template>

    <xsl:template match="head">
        <xsl:element name="h{count(ancestor::div)}">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="note">
        <xsl:variable name="reference" select="@n"/>
        <span class="type_note" id="{$reference}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="argument">
        <div class="type_argument">
            <xsl:apply-templates/>           
        </div>
    </xsl:template>
    
    <xsl:template match="p">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <xsl:template match="del"/>
    
</xsl:stylesheet>
