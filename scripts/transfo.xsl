<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xpath-default-namespace="http://www.w3.org/1999/xhtml" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:fx="http://pipoptagada">

    <!-- output -->
    <xsl:output method="xml" indent="yes"/>

    <!-- functions -->
    <!-- date transformation -->
    <xsl:function name="fx:toDate">
        <xsl:param name="string"/>
        <xsl:variable name="fullString" select="normalize-space($string)"/>
        <xsl:variable name="dd" select="substring($fullString, 1, 2)"/>
        <xsl:variable name="mm" select="substring($fullString, 4, 2)"/>
        <xsl:variable name="yyyy" select="substring($fullString, 7, 4)"/>
        <xsl:choose>
            <xsl:when test="string-length($yyyy) > 3">
                <xsl:value-of select="($yyyy, $mm, $dd)" separator="-"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$yyyy"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- start of ducument -->
    <xsl:template match="html">
        <xsl:choose>
            <xsl:when test="//p[@class = 'LMArtReg']/a[starts-with(@id, 'R')]">
                <xsl:variable name="rule"
                    select="//p[@class = 'LMArtReg']/a[starts-with(@id, 'R')]/@id"/>
                <div type="rule" n="{$rule}">
                    <xsl:apply-templates select="//div[@id = 'pagebody']"/>
                </div>
            </xsl:when>
            <xsl:when test="//p[@class = 'LMArtReg']/a[starts-with(@id, 'A')]">
                <xsl:variable name="article"
                    select="//p[@class = 'LMArtReg']/a[starts-with(@id, 'A')]/@id"/>
                <div type="article" n="{$article}">
                    <xsl:apply-templates select="//div[@id = 'pagebody']"/>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <div type="" n="">
                    <xsl:apply-templates select="//div[@id = 'pagebody']"/>
                </div>
            </xsl:otherwise>
        </xsl:choose>


        <!--  <xsl:variable name="rule" select="//p[@class = 'LMArtReg']/a[starts-with(@id, 'R')]/@id"/>
        <div type="rule" n="{$rule}">
            <xsl:apply-templates select="//div[@id = 'pagebody']"/>
        </div>-->
    </xsl:template>

    <!-- important part -->
    <xsl:template match="div[@id = 'pagebody']">
        <xsl:apply-templates select="p"/>
        <xsl:apply-templates select="div"/>
    </xsl:template>

    <!-- head of art/rule -->
    <xsl:template match="p[@class = 'LMArtReg']">
        <head>
            <xsl:value-of select="normalize-space(string-join(text()[2], ' '))"/>
        </head>
        <argument>
            <p>
                <xsl:for-each select="subsequence(text(), 2)">
                    <xsl:choose>
                        <xsl:when
                            test="starts-with(normalize-space(.), 'Article') or starts-with(normalize-space(.), 'Rule')"/>
                        <xsl:otherwise>
                            <xsl:value-of select="normalize-space(.)" separator=" "/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
                <xsl:apply-templates select="span"/>
            </p>
        </argument>
        <xsl:apply-templates select="a"/>
    </xsl:template>

    <!-- paragraph andle :
    looking for every paragraph
    if there is a paragraph before starting with the same name than it's a sub-paragraph
    use special template to indent correctly
    -->
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

                    <xsl:for-each-group select="../following-sibling::*"
                        group-starting-with="div[starts-with((.//a[@name]/@id)[1], $pNumber)]">
                       <!-- <xsl:message>Sous paragraph: </xsl:message>-->
                        <xsl:for-each select="current-group()">
                         <!--   <xsl:message>
                                <xsl:value-of select="."/>
                            </xsl:message>-->
                            <xsl:choose>
                                <xsl:when
                                    test=".//div[starts-with(@class, 'paraContainer DOC4NET2_LMNormal') and starts-with((.//a[@name]/@id)[1], $pNumber)]">
                                    <xsl:apply-templates select="node()" mode="subPara"/>
                                </xsl:when>
                                <!--<xsl:when test=".[@class = 'LMNormal']">
                                    <xsl:apply-templates select="node()"/>
                                </xsl:when>-->
                                <xsl:otherwise> </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                        <!--<xsl:choose>
                            <xsl:when test="string-length(normalize-space(.[1]))>1 and 1>string-length(normalize-space(.[2]))">
                                <xsl:apply-templates select=".[1]" mode="subPara"/>
                            </xsl:when>
                            <xsl:when test="string-length(normalize-space(.[1]))>1 and string-length(normalize-space(.[2]))>1">
                                <xsl:apply-templates select=".[1]" mode="subPara"/>
                                <xsl:apply-templates select=".[2]"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:message>pipop probleme de paragraph</xsl:message>
                            </xsl:otherwise>
                        </xsl:choose>-->
                    </xsl:for-each-group>

                    <!--
                    <xsl:apply-templates
                        select="../following-sibling::div[starts-with((.//a[@name]/@id)[1], $pNumber)]"
                        mode="subPara"/>-->
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="parcourPara">
        <xsl:param name="list"/>
        <xsl:param name="contextNumber"/>
        <xsl:if test="count($list) > 1">
            <xsl:choose>
                <xsl:when test="$list[1][1][starts-with((.//a[@name]/@id)[1], $contextNumber)]">
                    <xsl:variable name="currentNumber" select="$list[1][1]//(a[@name]/@id)[1]"/>
                    <xsl:message>dans : <xsl:value-of select="$contextNumber"/> -> est sous
                        paragraph: <xsl:value-of select="$currentNumber"/></xsl:message>
                    <!-- je suis sous paragraph avec num -->
                    <!-- je me copie -->
                    <div type="paragraph" id="{$currentNumber}">
                        
                        <xsl:apply-templates select="$list[1][1]/div"/><!-- copie du numeroté -->
                        
                        <xsl:for-each select="subsequence($list[1], 2)"><!-- copie des non numeroté -->
                            <xsl:apply-templates/>
                        </xsl:for-each>
                        
                        <!-- je lance l'appel recurcif avec mon propre num sur $list sans le premier element-->
                        <xsl:call-template name="parcourPara">
                            <xsl:with-param name="contextNumber" select="$currentNumber"/>
                            <xsl:with-param name="list" select="subsequence($list, 2)"/>
                        </xsl:call-template>
                    </div>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="currentNumber" select="$list[1][1]//(a[@name]/@id)[1]"/>
                    <!-- je suis un nouveau paragraph independant du context actuel -->
                    <!-- je me copie et je lance une recherche de ss paragraphe avec mon num -->
                    <div type="paragraph" id="{$currentNumber}">
                        
                        <xsl:apply-templates select="$list[1][1]/div"/><!-- copie du numeroté -->
                        
                        <xsl:for-each select="subsequence($list[1], 2)"><!-- copie des non numeroté -->
                            <xsl:apply-templates/>
                        </xsl:for-each>
                        
                        <!-- je lance l'appel recurcif avec mon propre num sur $list sans le premier element-->
                        <xsl:call-template name="parcourPara">
                            <xsl:with-param name="contextNumber" select="$currentNumber"/>
                            <xsl:with-param name="list" select="subsequence($list, 2)"/>
                        </xsl:call-template>
                    </div>
                </xsl:otherwise>
            </xsl:choose>
            <!-- je lance une recherche avec context number sur list sans le premier elem -->
            <xsl:call-template name="parcourPara">
                <xsl:with-param name="contextNumber" select="$contextNumber"/>
                <xsl:with-param name="list" select="subsequence($list, 2)"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>


    <xsl:template match="div[starts-with(@class, 'paraContainer DOC4NET2_LMNormal')]" mode="subPara">
        <xsl:variable name="pNumber" select="(.//a[@name]/@id)[1]"/>
        <div type="paragraph" n="{$pNumber}">
            <xsl:apply-templates select="./div"/>
        </div>
    </xsl:template>

    <xsl:template match="div[@class = 'LMNormal']" mode="subPara">
        <div type="paragraph">
            <p>
                <xsl:apply-templates/>
            </p>
        </div>
    </xsl:template>

    <!-- other notation for a paragraph, without a title / head -->
    <xsl:template match="div[@class = 'LMNormal']">
        <div type="paragraph">
            <p>
                <xsl:apply-templates/>
            </p>
        </div>
    </xsl:template>

    <xsl:template match="div[@class = 'paraContainer DOC4NET2_DefMargin']">
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
    <!-- references -->
    <xsl:template match="p[@class = 'Margin']">
        <listRef type="references">
            <!--<xsl:apply-templates select="a"/>
            <xsl:apply-templates select="span"/>-->
            <xsl:apply-templates/>
        </listRef>
    </xsl:template>

    <xsl:template match="b">
        <xsl:apply-templates select="element()"/>
    </xsl:template>

    <xsl:template match="span[@class = 'FootnoteReference']">
        <xsl:apply-templates select="element()"/>
    </xsl:template>

    <!-- external sources ar (article) -->
    <xsl:template match="a[starts-with(@href, 'ar') and ends-with(@href, '.html')]">
        <xsl:variable name="number" select="substring-before(substring-after(@href, 'ar'), '.html')"/>
        <ref type="article" n="{$number}">
            <xsl:value-of select="normalize-space(.)"/>
        </ref>
    </xsl:template>

    <!-- external sources r (rule) -->
    <xsl:template match="a[starts-with(@href, 'r') and ends-with(@href, '.html')]">
        <xsl:variable name="number" select="substring-before(substring-after(@href, 'r'), '.html')"/>
        <ref type="rule" n="{$number}">
            <xsl:value-of select="normalize-space(.)"/>
        </ref>
    </xsl:template>

    <!-- external sources g (gDecision) -->
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

    <!-- paragraph -->
    <xsl:template match="div[starts-with(@class, 'DOC4NET2_pos_LMNormal_')]">
        <p>
            <xsl:apply-templates/>
            <!-- <xsl:value-of select="normalize-space(string-join(text(), ' '))"/>
            <xsl:apply-templates select="a"/> -->
        </p>
        <xsl:apply-templates select="a[starts-with(@href, '#conv.')]"/>
    </xsl:template>

    <!-- foot note references -->
    <xsl:template match="a[starts-with(@href, '#conv.') and ends-with(@href, '-note')]">
        <xsl:variable name="reference" select="substring-after(@href, '#')"/>
        <xsl:variable name="number" select="substring-before(substring-after(@href, '#conv.'), '-')"/>
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

    <!-- history -->
    <xsl:template match="div[@class = 'DOC4NET2-history']">
        <div type="history">
            <list>
                <xsl:for-each-group select="div[@id = 'DOC4NET2-history']/*"
                    group-starting-with="div[@class = 'DOC4NET2-historyDate']">
                    <item>
                        <!--<xsl:message>Date: <xsl:value-of select="current-group()[1]"/></xsl:message>-->
                        <xsl:apply-templates select="current-group()[1]"/>
                        <!--<xsl:message>Item: <xsl:value-of select="current-group()[2]"/></xsl:message>-->
                        <xsl:apply-templates select="current-group()[2]"/>
                    </item>
                </xsl:for-each-group>
            </list>
        </div>
    </xsl:template>

    <xsl:template match="div[@class = 'DOC4NET2-historyDate']">
        <!--<xsl:message>DateDoof: <xsl:value-of select="fx:toDate('02.04.2018')"/></xsl:message>
        <xsl:message>pipop tokenize: <xsl:value-of select="tokenize(text(), '-')"/></xsl:message>-->
        <xsl:for-each select="tokenize(text(), '-')">
            <xsl:variable name="theDate">
                <xsl:variable name="transi" select="tokenize(., ' ')"/>
                <xsl:for-each select="$transi">
                    <xsl:if test="matches(., '\d{2}\.\d{2}\.\d{4}')">
                        <xsl:value-of select="."/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="fx:toDate($theDate) != ''">
                    <date when="{fx:toDate($theDate)}">
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

    <!-- diferents article in same file (ma???.html)-->

    <xsl:template
        match="div[starts-with(@class, 'DOC4NET2_Section_l0_0em_r0_0em') and following-sibling::h2[starts-with(@class, 'DOC4NET2_Title')]]">
        <xsl:choose>
            <xsl:when test="h2[@class = 'DOC4NET2_Title']">
                <head>
                    <xsl:apply-templates select="h2"/>
                </head>
                <xsl:apply-templates
                    select="div[starts-with(@class, 'paraBlock DOC4NET2_Subhead_spc')]"/>
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

    <!-- deleted / added -->

    <xsl:template match="span[@class = 'Del']">
        <xsl:choose>
            <xsl:when test="normalize-space(replace(., ',', ' '))">
                <pc>
                    <del>
                        <xsl:apply-templates/>
                    </del>
                </pc>
            </xsl:when>
            <xsl:when test="normalize-space(replace(., '.', ' '))">
                <pc>
                    <del>
                        <xsl:apply-templates/>
                    </del>
                </pc>
            </xsl:when>
            <xsl:when test="normalize-space(replace(., '-', ' '))">
                <pc>
                    <del>
                        <xsl:apply-templates/>
                    </del>
                </pc>
            </xsl:when>
            <xsl:when test="1 > string-length(normalize-space(.))">
                <pc>
                    <del>
                        <xsl:apply-templates/>
                    </del>
                </pc>
            </xsl:when>
            <xsl:otherwise>
                <del>
                    <xsl:apply-templates/>
                </del>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="span[@class = 'New']">
        <xsl:choose>
            <xsl:when test="normalize-space(replace(., ',', ' '))">
                <pc>
                    <add>
                        <xsl:apply-templates/>
                    </add>
                </pc>
            </xsl:when>
            <xsl:when test="normalize-space(replace(., '.', ' '))">
                <pc>
                    <add>
                        <xsl:apply-templates/>
                    </add>
                </pc>
            </xsl:when>
            <xsl:when test="normalize-space(replace(., '-', ' '))">
                <pc>
                    <add>
                        <xsl:apply-templates/>
                    </add>
                </pc>
            </xsl:when>
            <xsl:when test="1 > string-length(normalize-space(.))">
                <pc>
                    <add>
                        <xsl:apply-templates/>
                    </add>
                </pc>
            </xsl:when>
            <xsl:otherwise>
                <add>
                    <xsl:apply-templates/>
                </add>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- Generic text filtering -->

    <xsl:template match="text()">
        <xsl:if test="normalize-space(replace(., ' ', ' '))">
            <xsl:value-of select="replace(., ' ', ' ')"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="p[@class = 'Margin']/text()">
        <pc>
            <xsl:value-of select="."/>
        </pc>
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
