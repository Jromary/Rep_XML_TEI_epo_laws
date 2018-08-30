<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xpath-default-namespace="http://www.w3.org/1999/xhtml" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:fx="http://pipoptagada">

    <xsl:output method="xml" indent="yes"/>

    <xsl:function name="fx:toDate">
        <xsl:param name="string"/>
        <xsl:variable name="fullString" select="normalize-space($string)"/>
        <xsl:variable name="dd" select="substring($fullString, 1, 2)"/>
        <xsl:variable name="mm" select="substring($fullString, 4, 2)"/>
        <xsl:variable name="yyyy" select="substring($fullString, 7, 4)"/>
        <xsl:choose>
            <xsl:when test="string-length($yyyy) > 3 ">
                <xsl:value-of select="($yyyy,$mm,$dd)" separator="-"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$yyyy"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>

    <xsl:template match="html">
        <xsl:variable name="rule" select="//p[@class = 'LMArtReg']/a[starts-with(@id, 'R')]/@id"/>
        <div type="rule" n="{$rule}">
            <xsl:apply-templates select="//div[@id = 'pagebody']"/>
        </div>
    </xsl:template>

    <xsl:template match="div[@id = 'pagebody']">
        <xsl:apply-templates select="p"/>
        <xsl:apply-templates select="div"/>
    </xsl:template>

    <!-- head of rule -->
    <xsl:template match="p[@class = 'LMArtReg']">
        <head>
            <xsl:value-of select="normalize-space(string-join(text()[2], ' '))"/>
        </head>
        <argument>
            <p>
                <xsl:value-of select="normalize-space(subsequence(text(), 3)[2])" separator=" "/>
            </p>
        </argument>
        <xsl:apply-templates select="element()"/>
    </xsl:template>

    <!-- paragraph andle -->
    <xsl:template match="div[starts-with(@class, 'paraContainer DOC4NET2_LMNormal')]">
        <xsl:variable name="pNumber" select="(.//a[@name]/@id)[1]"/>
        <xsl:choose>
            <xsl:when
                test="
                    preceding::div[starts-with(@class, 'paraContainer DOC4NET2_LMNormal')
                    and starts-with($pNumber, (.//a[@name]/@id)[1])]">
                <!--<xsl:message>On jette: <xsl:value-of select="$pNumber"/></xsl:message>-->
            </xsl:when>
            <xsl:otherwise>
                <div type="paragraph" n="{$pNumber}">
                    <!-- <xsl:value-of select="./div"/> -->
                    <xsl:apply-templates select="./div"/>
                    <!-- Look for all sub items related to this paragraph -->
                    <!--<xsl:message>para: <xsl:value-of select="$pNumber"/> - <xsl:value-of
                            select="following::div[starts-with((.//a[@name]/@id)[1], $pNumber)]//a[@name]/@id"
                            separator=", "/></xsl:message>-->
                    <xsl:apply-templates
                        select="../following-sibling::div[starts-with((.//a[@name]/@id)[1], $pNumber)]"
                        mode="subPara"/>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="div[starts-with(@class, 'paraContainer DOC4NET2_LMNormal')]" mode="subPara">
        <xsl:variable name="pNumber" select="(.//a[@name]/@id)[1]"/>
        <div type="paragraph" n="{$pNumber}">
            <xsl:apply-templates select="./div"/>
        </div>
    </xsl:template>

    <xsl:template match="div[@class = 'LMNormal']">
        <div type="paragraph">
            <p>
                <xsl:apply-templates/>
            </p>
        </div>
    </xsl:template>

    <!-- title of paragraph -->
    <xsl:template match="div[@class = ' DOC4NET2_pos_LMNormal']">
        <head>
            <!--<xsl:value-of select="normalize-space(.)"/>-->
            <xsl:apply-templates/>
        </head>
    </xsl:template>

    <!-- external sources -->
    <xsl:template match="p[@class = 'Margin']">
        <listRef type="references">
            <xsl:apply-templates select="a"/>
        </listRef>
    </xsl:template>

    <xsl:template match="b">
        <xsl:apply-templates select="element()"/>
    </xsl:template>

    <xsl:template match="span[@class = 'FootnoteReference']">
        <xsl:apply-templates select="element()"/>
    </xsl:template>

    <!-- external sources ar -->
    <xsl:template match="a[starts-with(@href, 'ar') and ends-with(@href, '.html')]">
        <xsl:variable name="number" select="substring-before(substring-after(@href, 'ar'), '.html')"/>
        <ref type="article" n="{$number}">
            <xsl:value-of select="normalize-space(.)"/>
        </ref>
    </xsl:template>

    <!-- external sources r -->
    <xsl:template match="a[starts-with(@href, 'r') and ends-with(@href, '.html')]">
        <xsl:variable name="number" select="substring-before(substring-after(@href, 'r'), '.html')"/>
        <ref type="rule" n="{$number}">
            <xsl:value-of select="normalize-space(.)"/>
        </ref>
    </xsl:template>

    <!-- external sources g -->
    <xsl:template match="a[starts-with(@href, 'http')]">
        <xsl:variable name="text" select="."/>
        <xsl:variable name="tokens" select="tokenize($text, '[  ]+')"/>
        <!--<xsl:message>Gauche: <xsl:value-of select="$tokens[1]"/></xsl:message>
        <xsl:message>Droite: <xsl:value-of select="$tokens[2]"/></xsl:message>
        <xsl:variable name="number" select="substring-after(normalize-space($text), 'G ')"/>-->
        <ref type="gDecision" n="{$tokens[2]}">
            <xsl:value-of select="."/>
        </ref>
    </xsl:template>

    <!-- paragraph of law -->
    <xsl:template match="div[starts-with(@class, 'DOC4NET2_pos_LMNormal_')]">
        <p>
            <xsl:apply-templates/>
            <!-- <xsl:value-of select="normalize-space(string-join(text(), ' '))"/>
            <xsl:apply-templates select="a"/> -->
        </p>
        <xsl:apply-templates select="a[starts-with(@href, '#conv.')]"/>
    </xsl:template>

    <!-- foot note -->
    <xsl:template match="a[starts-with(@href, '#reg.') and ends-with(@href, '-note')]">
        <xsl:variable name="reference" select="substring-after(@href, '#')"/>
        <xsl:variable name="number" select="substring-before(substring-after(@href, '#reg.'), '-')"/>
        <xsl:variable name="theNote"
            select="//div[@class = 'paraContainer DOC4NET2_FootnoteText' and descendant::a/@id = $reference]"/>
        <note n="{$number}">
            <!-- 
            <xsl:value-of
                select="normalize-space(string-join($theNote/div[starts-with(@class, 'DOC4NET2_pos_FootnoteText_')], ' '))"
            />
             -->
            <xsl:apply-templates
                select="$theNote/div[starts-with(@class, 'DOC4NET2_pos_FootnoteText_')]"/>
        </note>
    </xsl:template>

    <!-- history -->
    <xsl:template match="div[@class = 'DOC4NET2-history']">
        <div type="history">
            <list>
                <xsl:for-each-group select="div[@id = 'DOC4NET2-history']/*"
                    group-starting-with="div[@class = 'DOC4NET2-historyDate']">
                    <item>
                        <xsl:message>Date: <xsl:value-of select="current-group()[1]"/></xsl:message>
                        <xsl:apply-templates select="current-group()[1]"/>
                        <xsl:message>Item: <xsl:value-of select="current-group()[2]"/></xsl:message>
                        <xsl:apply-templates select="current-group()[2]"/>
                    </item>
                </xsl:for-each-group>
            </list>
        </div>
    </xsl:template>

    <xsl:template match="div[@class = 'DOC4NET2-historyDate']">
        <xsl:message>DateDoof: <xsl:value-of select="fx:toDate('02.04.2018')"/></xsl:message>
        <xsl:message>pipop tokenize: <xsl:value-of select="tokenize(text(), '-')"/></xsl:message>
        <xsl:for-each select="tokenize(text(), '-')">
            <xsl:choose>
                <xsl:when test="fx:toDate(.) != ''">
                    <date when="{fx:toDate(.)}">
                        <xsl:value-of select="."/>
                    </date>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:for-each>
        <!--<date>
            <xsl:apply-templates/>
        </date>-->
    </xsl:template>

    <xsl:template match="div[@class = 'DOC4NET2-historyInfo']">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>



    <!-- Concordence -->
    <xsl:template match="div[@class = 'DOC4NET2-concordance']">
        <div type="concordance">
            <table>
                <head>
                    <xsl:value-of select=".//div[@class = 'DOC4NET2-promo-title']"/>
                </head>
                <xsl:apply-templates select="table"/>
            </table>
        </div>
    </xsl:template>

    <xsl:template match="tr">
        <row>
            <xsl:apply-templates select="td"/>
        </row>
    </xsl:template>

    <xsl:template match="td">
        <cell>
            <xsl:value-of select="normalize-space(.)"/>
        </cell>
    </xsl:template>

    <!-- Generic text filtering -->

    <xsl:template match="text()">
        <xsl:if test="normalize-space(replace(., ' ', ' '))">
            <xsl:value-of select="replace(., ' ', ' ')"/>
        </xsl:if>
    </xsl:template>

    <!-- excluded -->
    <xsl:template match="div[@class = 'DOC4NET2-promo-title']"/>
    <xsl:template
        match="div[@class = 'paraBlock DOC4NET2_FootnoteText_spc DOC4NET2_manual_FootnoteText']"/>
    <xsl:template match="div[@class = 'DOC4NET2-references']"/>
    <xsl:template match="div[@class = 'DOC4NET2-noteseparator']"/>
    <xsl:template match="div[@class = 'DOC4NET2-promo-separator']"/>
    <xsl:template match="div[@class = 'DOC4NET2-promo-title']"/>
<!--    <xsl:template match="span[@class = 'Del']"/>-->

</xsl:stylesheet>
