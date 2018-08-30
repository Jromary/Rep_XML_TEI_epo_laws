<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xpath-default-namespace="http://www.w3.org/1999/xhtml" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:fx="http://pipoptagada">

    <!-- output -->
    <xsl:output method="xml" indent="yes"/>
    <xsl:template match="html">
        <div type="" n="">
            <xsl:apply-templates select="//div[@id = 'pagebody']"/>
        </div>
    </xsl:template>

    <!-- importent part -->
    <xsl:template match="div[@id = 'pagebody']">
        <xsl:apply-templates select="p"/>
        <xsl:apply-templates select="div"/>
    </xsl:template>


    <xsl:template match="div[starts-with(@class, 'DOC4NET2_Section')]">
        <xsl:choose>
            <xsl:when test="h2[@class = 'DOC4NET2_Title']">
                <head>
                    <xsl:apply-templates select="h2"/>
                </head>
                <xsl:apply-templates select="div[starts-with(@class, 'paraBlock DOC4NET2_Subhead_spc')]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each-group select="*" group-starting-with="p[@class = 'LMCCVN']">
                    <xsl:variable name="number" select="current-group()[1]/a[@name and @id]/@id"/>
                    <div type="article" n="{$number}">

                        <xsl:apply-templates select="current-group()[1]"/>
                        <xsl:apply-templates select="current-group()[2]"/>

                    </div>
                </xsl:for-each-group>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="div[starts-with(@class, 'paraBlock DOC4NET2_Subhead_spc')]">
        <argument>
            <p>
                <xsl:apply-templates/>
            </p>
        </argument>
    </xsl:template>

    <xsl:template match="p[@class = 'LMCCVN']">
        <head>
            <xsl:value-of select="text()[2]"/>
        </head>
        <argument>
            <p>
                <xsl:value-of select="text()[3]"/>
            </p>
        </argument>
    </xsl:template>

    <!-- foot note references -->
    <xsl:template match="a[starts-with(@href, '#proa69.') and ends-with(@href, '-note')]">
        <xsl:variable name="reference" select="substring-after(@href, '#')"/>
        <xsl:variable name="number"
            select="substring-before(substring-after(@href, '#proa69.'), '-')"/>
        <xsl:variable name="theNote"
            select="//div[@class = 'FootnoteText' and descendant::a/@id = $reference]"/>
        <note n="{$number}">
            <!-- 
            <xsl:value-of
                select="normalize-space(string-join($theNote/div[starts-with(@class, 'DOC4NET2_pos_FootnoteText_')], ' '))"
            />
             -->
            <xsl:apply-templates select="$theNote/text()"/>
        </note>
    </xsl:template>


    <!-- other notation for a paragraph, without a title / head -->
    <xsl:template match="div[@class = 'LMNormal']">
        <div type="paragraph">
            <p>
                <xsl:apply-templates/>
            </p>
        </div>
    </xsl:template>
    
    <!-- Generic text filtering -->

    <xsl:template match="text()">
        <xsl:if test="normalize-space(replace(., ' ', ' '))">
            <xsl:value-of select="replace(., ' ', ' ')"/>
        </xsl:if>
    </xsl:template>

    <!-- excluded -->
    <xsl:template
        match="div[@class = 'paraBlock DOC4NET2_FootnoteText_spc DOC4NET2_manual_FootnoteText']"/>
    <xsl:template match="div[@class = 'DOC4NET2-references']"/>
    <xsl:template match="div[@class = 'DOC4NET2-noteseparator']"/>
    <xsl:template match="div[@class = 'DOC4NET2-promo-separator']"/>
    <xsl:template match="div[@class = 'DOC4NET2-promo-title']"/>
    <xsl:template match="div[@class = 'DOC4NET2-notes']"/>

</xsl:stylesheet>
