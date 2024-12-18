 <!DOCTYPE XSLT  [
      <!ENTITY AZ  "ABCDEFGHIJKLMNOPQRSTUVWXYZ">
      <!ENTITY az  "abcdefghijklmnopqrstuvwxyz">
 ]><xsl:stylesheet  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<!--Copyright (c) 2009 Nokia Corporation and/or its subsidiary(-ies).
	All rights reserved.
	This component and the accompanying materials are made available
	under the terms of the License "Eclipse Public License v1.0"
	which accompanies this distribution, and is available
	at the URL "http://www.eclipse.org/legal/epl-v10.html".

	Initial Contributors:
	Nokia Corporation - initial contribution.
	Contributors:
	Description:
	Module containing the validation logic for system definition 3.0.0 syntax
-->
	<xsl:key name="named" match="*[ancestor::systemModel]" use="@name"/>
	<xsl:param name="Filename"/> <!--<Filename> - (optional) the full system model path to the current sysdef file. This is needed to determine non-standard path errors -->
	<xsl:variable name="info" select="document(/model//info[@type='extra']/@href,/model)//c"/>

	<xsl:variable name="all-ids">
		<xsl:apply-templates select="document(/model/sysdef/@href)| SystemDefinition" mode="ids"/>
	</xsl:variable>

	<xsl:variable name="sf-ns">http://www.symbian.org/system-definition</xsl:variable>
 
<xsl:template match="/model" priority="-1">
	<xsl:apply-templates select="." mode="check"/>
</xsl:template>

<xsl:template match="/model" mode="check">
	<xsl:for-each select="sysdef">
		<xsl:apply-templates select="document (@href,. )/*">
			<xsl:with-param name="filename">
				<xsl:choose>
					<xsl:when test="starts-with(current()/@href,current()/@rootpath)">
						<xsl:value-of select="substring-after(current()/@href,current()/@rootpath)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@href"/>
					</xsl:otherwise>
				</xsl:choose>
			 </xsl:with-param>
		</xsl:apply-templates>
	</xsl:for-each>



<xsl:apply-templates mode="x-check" select="document (//info[@type='vp']/@href)/*">
	<xsl:with-param name="sysdef" select="document (sysdef/@href)/*"/>
</xsl:apply-templates>

<xsl:apply-templates mode="x-check" select="document (//info[@type='build']/@href)/*">
	<xsl:with-param name="sysdef" select="document (sysdef/@href)/*"/>
</xsl:apply-templates>
</xsl:template>

<xsl:template match="/SystemDefinition[starts-with(@schema,'3.0.')]" mode="ids">
	<xsl:for-each select="//*[@id and not(@href)]"><xsl:value-of select="concat(' ',@id,' ')"/></xsl:for-each>
	<xsl:apply-templates select="document(//layer/@href | //package/@href | //collection/@href | //component/@href,.)/*" mode="ids"/>
</xsl:template>

<xsl:template match="/SystemDefinition[starts-with(@schema,'3.0.')and systemModel]" priority="2">
	<xsl:param name="filename" select="$Filename"/>
<xsl:call-template name="Section">
	<xsl:with-param name="text">System Definition: <xsl:value-of select="*/@name"/></xsl:with-param>
	<xsl:with-param name="sub"><xsl:value-of select="(string-length($all-ids) - string-length(translate($all-ids,' ','')) - 1) div 2 "/> items</xsl:with-param>
</xsl:call-template>
	<xsl:apply-templates select="*">
		<xsl:with-param name="filename" select="$filename"/>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="/SystemDefinition[starts-with(@schema,'3.0.')] | systemModel">
	<xsl:param name="filename"  select="$Filename"/>
		
<xsl:if test="descendant::unit and not(self::systemModel)">
<xsl:call-template name="Section">
	<xsl:with-param name="text"><xsl:value-of select="translate(substring(name(*),1,1),'clp','CLP')"/><xsl:value-of select="substring(name(*),2)"/> Definition: <xsl:value-of select="*/@name"/></xsl:with-param>
	<xsl:with-param name="id"><xsl:value-of select="*/@id"/></xsl:with-param>
	<xsl:with-param name="sub"><xsl:value-of select="count(//unit)"/> unit<xsl:if test="count(//unit)!=1">s</xsl:if></xsl:with-param>
</xsl:call-template>
</xsl:if>
<xsl:if test="self::systemModel and not(@name)">
	<xsl:call-template name="Error"><xsl:with-param name="text">systemModel element should have a name</xsl:with-param></xsl:call-template>
</xsl:if>
	<xsl:apply-templates select="*">
		<xsl:with-param name="filename" select="$filename"/>
	</xsl:apply-templates>
	<xsl:for-each select="//text()[normalize-space(.)!='']">
		<xsl:if test="not(ancestor::meta)">
			<xsl:call-template name="Error"><xsl:with-param name="text">Text content not valid in <xsl:value-of select="name(..)"/> (<xsl:value-of select="normalize-space(.)"/>)</xsl:with-param></xsl:call-template>
		</xsl:if>
	</xsl:for-each>
</xsl:template>


<xsl:template match="@*" mode="valid">
	<xsl:call-template name="Error"><xsl:with-param name="text">Attribute <xsl:value-of select="name()"/>="<xsl:value-of select="."/>" is not valid for <xsl:value-of select="name(..)"/></xsl:with-param></xsl:call-template>
</xsl:template>

<xsl:template match="@before|package/@span|layer/@span|collection/@level|package/@level|package/@levels|layer/@levels" mode="valid"/> <!-- really should check syntax -->

<xsl:template match="@href|@id|@filter|package/@version|unit/@version|unit/@prebuilt" mode="valid"/> 

<xsl:template match="component/@introduced" mode="valid"/>
<xsl:template match="component/@deprecated" mode="valid">
	<xsl:if test="../@purpose='mandatory'">
		<xsl:call-template name="Warning"><xsl:with-param name="text">Deprecated component <id><xsl:value-of select="../@id"/></id> should not be mandatory</xsl:with-param></xsl:call-template>
	</xsl:if>
</xsl:template>

<xsl:template match="@name" mode="valid"> <!-- look for various naming troubles -->
	<xsl:variable name="pre"><xsl:value-of select="name(..)"/> with name "<xsl:value-of select="."/>"</xsl:variable>
	<xsl:if test="normalize-space(.)!=.">
		<xsl:call-template name="Warning"><xsl:with-param name="text"><xsl:value-of select="$pre"/> has unexpected whitespace</xsl:with-param></xsl:call-template>
	</xsl:if>

	<xsl:choose> <!-- these are likely to all be the same error -->
		<xsl:when test=".=../@id or .=substring-after(../@id,':')">
			<xsl:call-template name="Error"><xsl:with-param name="text"><xsl:value-of select="$pre"/> is the same as the id</xsl:with-param></xsl:call-template>
		</xsl:when>

		<xsl:when test="contains(.,'_')">
			<xsl:call-template name="Error"><xsl:with-param name="text">
			<xsl:value-of select="$pre"/> must not contain the underscore character (_)</xsl:with-param></xsl:call-template>
		</xsl:when>
		<xsl:when test="translate(.,'&az;0123456789_ ','')=''">
			<xsl:call-template name="Warning"><xsl:with-param name="text">The human-readable name for <xsl:value-of select="name(..)"/> "<xsl:value-of select="."/>" cannot be entirely lowercase</xsl:with-param></xsl:call-template>
		</xsl:when>
	</xsl:choose>

	<xsl:variable name="spaced" select="concat(' ',.,' ')"/>
	<xsl:variable name="this" select="."/>
	<xsl:variable name="terms" select="document('')/*/xsl:template[@name='bad-names']/*"/>
	<xsl:variable name="std" select="document('')/*/xsl:template[@name='std-names']/*"/>

	<xsl:for-each select="$terms"> <!-- common errors in names -->
		<xsl:if test="contains($spaced,concat(' ',.,' '))">
			<xsl:choose>
				<xsl:when test="name()='bad'">
					<xsl:call-template name="Warning"><xsl:with-param name="text">
						<xsl:value-of select="$pre"/> should use "<xsl:value-of select="@ok"/>"</xsl:with-param></xsl:call-template>
				</xsl:when>
				<xsl:when test="name()='pref'">
					<xsl:call-template name="Note"><xsl:with-param name="text">
						<xsl:value-of select="$pre"/> should use "<xsl:value-of select="@ok"/>" instead of "<xsl:value-of select="."/>"</xsl:with-param></xsl:call-template>
				</xsl:when>
			</xsl:choose>
		</xsl:if>
	</xsl:for-each>

	<xsl:if test="../self::component and 
		( (substring(.,string-length(.) - string-length(' Plugin') + 1) = ' Plugin') or
		 (substring(.,string-length(.) - string-length(' Plugins') + 1) = ' Plugins') ) 
		  and not(contains(../@class,'plugin'))">
		<xsl:call-template name="Note"><xsl:with-param name="text">
			<xsl:value-of select="$pre"/> should have class "plugin"</xsl:with-param></xsl:call-template>
	</xsl:if>

	<xsl:for-each select="$std"> <!-- standard naming schemes -->
		<xsl:choose>
			<xsl:when test="name()='suffix' and substring($this/../@id,string-length($this/../@id) - string-length(.) + 1)=. 
				and not(substring($this,string-length($this) - string-length(@name) + 1) = @name or  substring($this,string-length($this) - string-length(@or) + 1) = @or)">
				<xsl:call-template name="Note"><xsl:with-param name="text">
					<xsl:value-of select="$pre"/> should end with "...<xsl:value-of select="@name"/>"<xsl:if test="@or"> or "...<xsl:value-of select="@or"/>"</xsl:if></xsl:with-param></xsl:call-template>
			</xsl:when>
			<xsl:when test="name()='prefix' and starts-with($this/../@id,.) and not(starts-with($this,@name))">
				<xsl:call-template name="Note"><xsl:with-param name="text">
					<xsl:value-of select="$pre"/> should start with "<xsl:value-of select="@name"/>..."</xsl:with-param></xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:for-each>

</xsl:template>


<xsl:template match="component/@origin-model" mode="valid"/>

<xsl:template match="unit/@priority" mode="valid">
	<xsl:call-template name="Note"><xsl:with-param name="text">Attribute <xsl:value-of select="name()"/> is deprecated</xsl:with-param></xsl:call-template>
</xsl:template>


<xsl:template match="@*[namespace-uri()!='']" mode="valid"> 
	<xsl:call-template name="Note"><xsl:with-param name="text">Extension attribute <xsl:value-of select="local-name()"/>="<xsl:value-of select="."/>" in namespace <xsl:value-of select="namespace-uri()"/></xsl:with-param></xsl:call-template>
</xsl:template>

<xsl:template match="@*[namespace-uri()='http://www.nokia.com/qt' and local-name()='proFile']" mode="valid"/> 
	

<xsl:template match="@*[namespace-uri()='http://www.nokia.com/qt' and local-name()='qmakeArgs' and not(../@*[local-name()='proFile'])]" mode="valid"> 
	<xsl:call-template name="Error"><xsl:with-param name="text">Extension attribute <code><xsl:value-of select="local-name()"/>="<xsl:value-of select="."/>"</code> in namespace <xsl:value-of select="namespace-uri()"/> cannot be used without a proFile extention attribute</xsl:with-param></xsl:call-template>
</xsl:template>


<xsl:template match="@*[namespace-uri()='http://www.nokia.com/qt' and local-name()='qmakeArgs']" mode="valid"> 
	<xsl:call-template name="Note"><xsl:with-param name="text">Use of extension attribute <code><xsl:value-of select="local-name()"/>="<xsl:value-of select="."/>"</code> in namespace <xsl:value-of select="namespace-uri()"/> is deprecated. Put contents in the "<code>symbian: { ... }</code>" section of <xsl:value-of select="../@bldFile"/>/<xsl:value-of select="../@*[namespace-uri()='http://www.nokia.com/qt' and local-name()='proFile']"/></xsl:with-param></xsl:call-template>
</xsl:template>

<xsl:template match="@*[namespace-uri()='http://www.nokia.com/qt' and local-name()='qmakeArgs' and .='-r']" mode="valid"> 
	<xsl:call-template name="Warning"><xsl:with-param name="text">Extension attribute <code><xsl:value-of select="name()"/>="<xsl:value-of select="."/>"</code> must be removed. The attribute is deprecated and that is the default behaviour</xsl:with-param></xsl:call-template>
</xsl:template>


<xsl:template match="@replace" mode="valid">
	<xsl:if test="/SystemDefinition[@schema='3.0.0']">
		<xsl:call-template name="Error"><xsl:with-param name="text">Attribute <b><xsl:value-of select="name()"/></b>="<xsl:value-of select="."/>" not valid in schema <xsl:value-of select="/SystemDefinition/@schema"/>. Must use schema 3.0.1 or higher</xsl:with-param></xsl:call-template>
	</xsl:if>
</xsl:template>


<xsl:template name="bad-names">
	<bad ok="SHAI">shai</bad>
	<bad ok="API">api</bad>
	<pref ok="A-GPS">AGPS</pref>
	<pref ok="APIs">Headers</pref>
</xsl:template>

<xsl:template name="std-names">
	<suffix name=" API">_api</suffix>
	<suffix name=" SHAI">_shai</suffix>
	<suffix name=" Info">_info</suffix>
	<suffix name=" Public Interfaces">_pub</suffix>
	<suffix name=" Platform Interfaces">_plat</suffix>
	<suffix name=" Test" or="Tests">test</suffix>
</xsl:template>

<xsl:template name="validate-class">
	<ok>plugin</ok>
	<ok>doc</ok>
	<ok>tool</ok>
	<ok>config</ok>
	<ok>api</ok>
	<w d="deprecated">test</w>
</xsl:template>

<xsl:template name="validate-purpose">
	<ok>mandatory</ok>
	<ok>optional</ok>
	<ok>development</ok>
</xsl:template>
<xsl:template name="validate-target">
	<ok>other</ok>
	<ok>desktop</ok>
	<ok>device</ok>
</xsl:template>


<xsl:template name="validate-tech-domain">
	<ok>lo</ok>
	<ok>hb</ok>
	<ok>mm</ok>
	<ok>ma</ok>
	<ok>pr</ok>
	<ok>vc</ok>
	<ok>se</ok>
	<ok>ui</ok>
	<ok>dc</ok>
	<ok>de</ok>
	<ok>dm</ok>
	<ok>rt</ok>
	<ok>to</ok>
	<w d="Non-standard">ocp</w>
</xsl:template>

<xsl:template match="component/@class" mode="valid">
	<xsl:call-template name="checklist">
		<xsl:with-param name="list" select="normalize-space(.)"/>
		<xsl:with-param name="values" select="document('')/*/xsl:template[@name=concat('validate-',name(current()))]/*"/>
	</xsl:call-template>
</xsl:template> 

<xsl:template name="checklist">
	<xsl:param name="list" select="."/><xsl:param name="values"/><xsl:param name="sep" select="' '"/>
	<xsl:variable name="item">
		<xsl:choose>
			<xsl:when test="contains($list,$sep)"><xsl:value-of select="substring-before($list,$sep)"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="$list"/></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="v" select="$values[.=$item]"/>
	<xsl:choose>
		<xsl:when test="not($v)">
			<xsl:call-template name="Error"><xsl:with-param name="text">Illegal <xsl:value-of select="name()"/> value <xsl:value-of select="name()"/>="<xsl:value-of select="."/>"</xsl:with-param></xsl:call-template>
		</xsl:when> 
		<xsl:when test="name($v)='ok'"/> 
		<xsl:when test="name($v)='w'">
			<xsl:call-template name="Warning"><xsl:with-param name="text"><xsl:value-of select="$v/@d"/> value in <xsl:value-of select="name()"/>="<xsl:value-of select="."/>"</xsl:with-param></xsl:call-template>
		</xsl:when> 
	</xsl:choose>	
	<xsl:if test="contains($list,$sep)">
		<xsl:call-template name="checklist">
			<xsl:with-param name="list" select="substring-after($list,$sep)"/>
			<xsl:with-param name="values" select="$values"/>
			<xsl:with-param name="sep" select="$sep"/>			
		</xsl:call-template>
	</xsl:if>
</xsl:template> 


<xsl:template match="package/@tech-domain|component/@purpose|component/@target" mode="valid">
	<xsl:variable name="v" select="document('')/*/xsl:template[@name=concat('validate-',name(current()))]/*[.=current()]"/>
	<xsl:variable name="ns"><xsl:apply-templates select="../@id" mode="namespace-for-id"/></xsl:variable>
	<xsl:choose>
		<xsl:when test="not($v) and $ns=$sf-ns">
			<xsl:call-template name="Error"><xsl:with-param name="text">Illegal <xsl:value-of select="name()"/> value <xsl:value-of select="name()"/>="<xsl:value-of select="."/>"</xsl:with-param></xsl:call-template>
		</xsl:when> 
		<xsl:when test="not($v)">
			<xsl:call-template name="Note"><xsl:with-param name="text">Non-standard <xsl:value-of select="name()"/> value <xsl:value-of select="name()"/>="<xsl:value-of select="."/>"</xsl:with-param></xsl:call-template>
		</xsl:when> 
		<xsl:when test="name($v)='ok'"/> 
		<xsl:when test="name($v)='w'">
			<xsl:call-template name="Warning"><xsl:with-param name="text"><xsl:value-of select="$v/@d"/> value in <xsl:value-of select="name()"/>="<xsl:value-of select="."/>"</xsl:with-param></xsl:call-template>
		</xsl:when> 
	</xsl:choose>
</xsl:template> 





<xsl:template match="*" priority="-2">
	<xsl:call-template name="Error"><xsl:with-param name="text">Element "<xsl:value-of select="name()"/>" is not valid in the context of "<xsl:value-of select="name(..)"/>"<xsl:if test="ancestor::meta"> in <xsl:value-of select="ancestor::meta/@rel"/> metadata section</xsl:if></xsl:with-param></xsl:call-template>
</xsl:template>

<xsl:template match="component[not(parent::collection) or (parent::SystemDefinition and count(../*)=1)] | 
	collection[not(parent::package) or (parent::SystemDefinition and count(../*)=1)] | 
	package[not(parent::package or parent::layer or (parent::SystemDefinition and count(../*)=1))] |
	layer[not(parent::systemModel)] " priority="3">
	<xsl:call-template name="Error"><xsl:with-param name="text"><xsl:value-of select="name()"/> "<id><xsl:value-of select="@id"/></id>" has invalid parent <xsl:value-of select="name(..)"/> "<id><xsl:value-of select="../@id"/></id>"</xsl:with-param></xsl:call-template>
</xsl:template>

<xsl:template match="layer | package | collection | component">
	<xsl:param name="filename"/>

<xsl:if test="self::package[not(@href)] and not(parent::SystemDefinition)">
<xsl:call-template name="Section">
	<xsl:with-param name="id"><xsl:value-of select="@id"/></xsl:with-param>
	<xsl:with-param name="text"><xsl:value-of select="translate(substring(name(),1,1),'clp','CLP')"/><xsl:value-of select="substring(name(),2)"/>: <xsl:value-of select="@name"/></xsl:with-param>
	<xsl:with-param name="sub"><xsl:value-of select="count(descendant::unit)"/> unit<xsl:if test="count(descendant::unit)!=1">s</xsl:if></xsl:with-param>
</xsl:call-template>
</xsl:if>

<xsl:apply-templates select="@*" mode="valid"/>
<xsl:apply-templates select="@id"/>
<xsl:if test="self::component">
	<xsl:choose>
		<xsl:when test="count(unit[not(@filter | @version)]) = 0 "/>
		<xsl:when test="count(unit[not(@version)]) &gt; 1 and descendant-or-self::*[contains(@filter,'s60')]">
			<xsl:call-template name="Warning"><xsl:with-param name="text">S60 Component <id><xsl:value-of select="@id"/></id> has <xsl:value-of select="count(unit)"/> units.</xsl:with-param></xsl:call-template>
		</xsl:when>
		<xsl:when test="count(unit[not(@version)]) &gt; 1">
			<xsl:call-template name="Error"><xsl:with-param name="text">Component "<id><xsl:value-of select="@id"/></id>" has <xsl:value-of select="count(unit)"/> units.</xsl:with-param></xsl:call-template>
		</xsl:when>
	</xsl:choose>
	<xsl:choose>
		<xsl:when test="unit"/>
		<xsl:when test="contains(comment(),'PLACEHOLDER=')"/>
		<xsl:when test="comment()">
			<xsl:call-template name="Note"><xsl:with-param name="text">Component "<xsl:value-of select="@name"/>" is empty.</xsl:with-param></xsl:call-template>
		</xsl:when>
		<xsl:when test="not(comment())">
			<xsl:call-template name="Warning"><xsl:with-param name="text">Component "<xsl:value-of select="@name"/>" is empty and has no comment</xsl:with-param></xsl:call-template>
		</xsl:when>
	</xsl:choose>
</xsl:if>
<xsl:if test="@href">
	<xsl:variable name="child" select="document(@href,.)/SystemDefinition"/>
	<xsl:if test="@id!=$child/@id">
		<xsl:call-template name="Error"><xsl:with-param name="text"><xsl:value-of select="name()"/> "<id><xsl:value-of select="@id"/></id>" must match ID in linked file "<xsl:value-of select="@href"/>"</xsl:with-param></xsl:call-template>
	</xsl:if>
	<xsl:if test="$child/@href">
		<xsl:call-template name="Error"><xsl:with-param name="text">linked <xsl:value-of select="name()"/> "<id><xsl:value-of select="@id"/></id>" cannot be a link</xsl:with-param></xsl:call-template>
	</xsl:if>
	<xsl:for-each select="@*[name()!='id']">
		<xsl:if test="$child/@*[name()=name(current())]">
			<xsl:call-template name="Warning"><xsl:with-param name="text">linked <xsl:value-of select="name()"/> "<id><xsl:value-of select="@id"/></id>" has duplicate attribute to linking document. Duplicate ignored.</xsl:with-param></xsl:call-template>
		</xsl:if>
	</xsl:for-each>
	<xsl:if test="*">
		<xsl:call-template name="Error"><xsl:with-param name="text"><xsl:value-of select="name()"/> "<id><xsl:value-of select="@id"/></id>" cannot have both link and content. Content ignored.</xsl:with-param></xsl:call-template>
	</xsl:if>
</xsl:if>
<xsl:if test="@href and name()!=name(document(@href,.)/SystemDefinition/*)">
		<xsl:call-template name="Error"><xsl:with-param name="text"><xsl:value-of select="name()"/> "<id><xsl:value-of select="@id"/></id>" must match item in linked file "<xsl:value-of select="@href"/>"</xsl:with-param></xsl:call-template>
</xsl:if>
<xsl:if test="not(@href)">
	<xsl:apply-templates select="*">
		<xsl:with-param name="filename" select="$filename"/>
	</xsl:apply-templates>
</xsl:if>
<xsl:if test="@href">
	<xsl:apply-templates select="document(@href,.)/*">
		<xsl:with-param name="filename">
			<xsl:call-template name="normpath">
				<xsl:with-param name="path">
					<xsl:if test="not(starts-with(current()/@href,'/'))">
						<xsl:call-template name="before">
							<xsl:with-param name="text" select="$filename"/>
						</xsl:call-template>
					</xsl:if>
					<xsl:value-of select="current()/@href"/>
				 </xsl:with-param>
			</xsl:call-template>
		 </xsl:with-param>
	</xsl:apply-templates>
</xsl:if>

<xsl:if test="self::colleciton and not(@level) and ../@levels">
	<xsl:call-template name="Error"><xsl:with-param name="text">Collection <id><xsl:value-of select="@id"/></id> has no level, despite levels "<xsl:value-of select="../@levels"/>" being defined in <xsl:value-of select="name(..)"/> "<id><xsl:value-of select="../@id"/></id>"</xsl:with-param></xsl:call-template>
</xsl:if>
</xsl:template>



<xsl:template match="meta">	<xsl:param name="filename"/>
	<xsl:apply-templates select="@*"/>
</xsl:template>

<xsl:template match="meta/@rel | meta/@type | meta/@href"/> <!-- anything is valid -->

<xsl:template match="unit">	<xsl:param name="filename"/>
	<xsl:apply-templates select="@*">
		<xsl:with-param name="filename" select="$filename"/>
	</xsl:apply-templates>
</xsl:template>

<!-- config metadata -->

<xsl:template match="meta[@rel='config']">	<xsl:param name="filename"/>
	<xsl:if test="@type!='auto'">
	<xsl:call-template name="Warning"><xsl:with-param name="text">Unrecognised configuration metadata type <xsl:value-of select="@type"/></xsl:with-param></xsl:call-template>		
	</xsl:if>
	<xsl:for-each select="descendant::text()[normalize-space(.)!='']">
		<xsl:call-template name="Error"><xsl:with-param name="text">Text content not valid in <xsl:value-of select="name(..)"/> (<xsl:value-of select="normalize-space(.)"/>)</xsl:with-param></xsl:call-template>
	</xsl:for-each>
	<xsl:if test="pick">
		<xsl:variable name="npicks" select="count(pick) +1"/>
		<xsl:for-each select="../descendant-or-self::component">
			<xsl:if test="count(unit) &gt; $npicks">
				<xsl:call-template name="Warning"><xsl:with-param name="text">Configuration metadata should have at least one fewer pick elements (<xsl:value-of select="$npicks - 1"/>) than the number of units in <xsl:value-of select="name(..)"/> "<id><xsl:value-of select="../@id"/></id>" (<xsl:value-of select="count(unit)"/>)</xsl:with-param></xsl:call-template>				
			</xsl:if>
		</xsl:for-each>
	</xsl:if>
	<xsl:apply-templates select="@* | *"/>
</xsl:template>


<xsl:template match="meta[@rel='config']/defined | meta[@rel='config']/not-defined | meta[@rel='config']/pick/defined | meta[@rel='config']/pick/not-defined">
	<xsl:if test="node()">
		<xsl:call-template name="Error"><xsl:with-param name="text">Configuration metadata <xsl:value-of select="name()"/> must be empty</xsl:with-param></xsl:call-template>		
	</xsl:if>
	<xsl:if test="not(@condition)">
		<xsl:call-template name="Error"><xsl:with-param name="text">Configuration metadata <xsl:value-of select="name()"/> must have a condition</xsl:with-param></xsl:call-template>		
	</xsl:if>
		<xsl:apply-templates select="@*[name()!='condition']" mode="valid"/>
</xsl:template>

<xsl:template match="meta[@rel='config']/pick">
	<xsl:choose>
		<xsl:when test="not(@version)">
			<xsl:call-template name="Error"><xsl:with-param name="text">Configuration metadata <xsl:value-of select="name()"/> must have a version</xsl:with-param></xsl:call-template>		
		</xsl:when>
		<xsl:when test="not(../../descendant::unit[@version=current()/@version])">
			<xsl:call-template name="Error"><xsl:with-param name="text">Configuration metadata <xsl:value-of select="name()"/> version="<xsl:value-of select="@version"/>" must match a unit within the containing <xsl:value-of select="name(../..)"/> "<xsl:value-of select="../../@id"/>"</xsl:with-param></xsl:call-template>				
		</xsl:when>
	</xsl:choose>
	<xsl:apply-templates select="@*[name()!='version']" mode="valid"/>
	<xsl:apply-templates select="*"/>
</xsl:template>

<!-- /config metadata -->



<xsl:template match="unit/@* | meta/@*" priority="-1">	
	<xsl:apply-templates select="." mode="valid"/>
</xsl:template>

<xsl:template match="@*[.='']" mode="valid">
	<xsl:call-template name="Error"><xsl:with-param name="text">Empty attribute "<xsl:value-of select="name()"/>" on <xsl:value-of select="name(..)"/><xsl:if test="../@id[.!='']"> "<id><xsl:value-of select="../@id"/></id>"</xsl:if></xsl:with-param></xsl:call-template>
</xsl:template>


<xsl:template match="@id" mode="path">
	<xsl:choose>
		<xsl:when test="contains(.,':')"><xsl:value-of  select="substring-after(.,':')"/></xsl:when>
		<xsl:otherwise><xsl:value-of  select="."/></xsl:otherwise>
	</xsl:choose>
</xsl:template>


<xsl:template match="@id">
<xsl:if test="contains(concat(' ',substring-after($all-ids,concat(' ',.,' '))),concat(' ',.,' '))">
	<xsl:call-template name="Error"><xsl:with-param name="text">Duplicate ID: <xsl:value-of select="name(..)"/> "<xsl:value-of select="."/>"</xsl:with-param></xsl:call-template>
</xsl:if>

<xsl:if test="contains(.,':') and not(ancestor::*/namespace::*[name()=substring-before(current(),':')])">
	<xsl:call-template name="Error"><xsl:with-param name="text">Undefined namespace for ID "<id><xsl:value-of select="."/></id>"</xsl:with-param></xsl:call-template>
</xsl:if>

<xsl:if test="translate(.,'-','')!=.">
	<xsl:call-template name="Error"><xsl:with-param name="text">ID "<id><xsl:value-of select="."/></id>" contains reserved character "-" </xsl:with-param></xsl:call-template>
</xsl:if>

<xsl:if test="contains(.,'.') and not(parent::package) and not(contains(ancestor::package/@id,'.'))">
	<xsl:call-template name="Error"><xsl:with-param name="text">ID "<xsl:value-of select="."/>" contains reserved character "<code>.</code>" </xsl:with-param></xsl:call-template>
</xsl:if>

<xsl:if test="translate(substring(.,1,1),'0123456789','')=''">
	<xsl:call-template name="Error"><xsl:with-param name="text">ID "<id><xsl:value-of select="."/></id>" cannot begin with a digit</xsl:with-param></xsl:call-template>
</xsl:if>


<xsl:if test="translate(.,'&AZ;','')!=.">
	<xsl:call-template name="Warning"><xsl:with-param name="text">IDs should be entirely in lowercase (<xsl:value-of select="."/>)</xsl:with-param></xsl:call-template>
</xsl:if>


<!-- should also test for outside the range of  Letter | Digit | '.' | '-' | '_' | ':' | CombiningChar | Extender
	see http://www.w3.org/TR/2000/WD-xml-2e-20000814#NT-Name
 -->
</xsl:template>


<xsl:template match="@*" mode="namespace-for-id">
<xsl:choose>
	<xsl:when test="contains(.,':') and ancestor::*/namespace::*[name()=substring-before(current(),':')]">
		<xsl:value-of select="ancestor::*/namespace::*[name()=substring-before(current(),':')]"/>
	</xsl:when>
	<xsl:when test="ancestor::SystemDefinition/@id-namespace"><xsl:value-of select="ancestor::SystemDefinition/@id-namespace"/></xsl:when>
	<xsl:otherwise><xsl:value-of select="$sf-ns"/></xsl:otherwise>
</xsl:choose>
</xsl:template>


<xsl:template mode="localid" match="*">
	<xsl:choose>
		<xsl:when test="contains(@id,':')">/<xsl:value-of select="substring-after(@id,':')"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="@id"/></xsl:otherwise>
	</xsl:choose>
</xsl:template>
<xsl:template match="@bldFile|@mrp|@base"><xsl:param name="filename"/>
<xsl:if test="substring(.,string-length(.))='/'">
		<xsl:call-template name="Warning"><xsl:with-param name="text"><code><xsl:value-of select="name()"/></code> path "<xsl:value-of select="."/>" should not end in /</xsl:with-param></xsl:call-template>
</xsl:if>
<xsl:if test="contains(.,'\')">
		<xsl:call-template name="Error"><xsl:with-param name="text"><code><xsl:value-of select="name()"/></code> path "<xsl:value-of select="."/>" must use only forward slashes</xsl:with-param></xsl:call-template>
</xsl:if>

<xsl:if test="count(//unit[@bldFile=current()]/..) &gt; 1">
		<xsl:call-template name="Error"><xsl:with-param name="text"><code><xsl:value-of select="name()"/></code> path "<xsl:value-of select="."/>" appears in components <xsl:for-each select="//unit[@bldFile=current()]/..">
			<id><xsl:value-of select="@id"/></id>
			<xsl:choose>
			<xsl:when test="position()=last() - 1"> and </xsl:when>
			<xsl:when test="position()!=last()">, </xsl:when>
			</xsl:choose>
			</xsl:for-each>
		</xsl:with-param>
		<xsl:with-param name="sub">Use filters or config metadata to control what kind of builds a component can appear in</xsl:with-param>
		</xsl:call-template>
</xsl:if>

<!-- this is a realtive path, so just check that it's the expected number of dirs down -->
	<xsl:variable name="fullpath"><xsl:call-template name="normpath">
				<xsl:with-param name="path">
					<xsl:if test="not(starts-with(.,'/'))">
						<xsl:call-template name="before">
							<xsl:with-param name="text" select="$filename"/>
						</xsl:call-template>
					</xsl:if>
					<xsl:value-of select="."/>
				 </xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="path">
			<xsl:choose>
				<xsl:when test="not(contains($filename,':'))">/<xsl:for-each select="ancestor::*/@id"><xsl:apply-templates mode="path" select="."/>/</xsl:for-each></xsl:when>
				<xsl:otherwise><xsl:for-each select="../../../@id|../../@id"><xsl:apply-templates mode="path" select="."/>/</xsl:for-each></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="segment"> <!-- the part relative to the fragment directory -->
			<xsl:choose>
				<xsl:when test="ancestor::layer">
					<xsl:apply-templates select="ancestor::package" mode="localid"/>/<xsl:apply-templates select="ancestor::collection" mode="localid"/>
				</xsl:when>
				<xsl:when test="ancestor::package">
				<xsl:apply-templates select="ancestor::collection" mode="localid"/>
				</xsl:when>
				<xsl:when test="ancestor::collection"/>
			</xsl:choose>/<xsl:apply-templates select="ancestor::component" mode="localid"/>/</xsl:variable>
		<xsl:choose>
			<xsl:when test="not(starts-with(concat(.,'/'),$segment) or starts-with(concat('/',.,'/'),$segment)) and $path-errors">
				<xsl:call-template name="Note"><xsl:with-param name="text">Unexpected <code><xsl:value-of select="name()"/></code> path for <xsl:apply-templates mode="path" select="../../../@id"/> -&gt; <strong><xsl:apply-templates mode="path" select="../../@id"/></strong>: "<xsl:value-of select="$fullpath"/>"</xsl:with-param></xsl:call-template>
			</xsl:when>
		</xsl:choose>
</xsl:template>


<xsl:template match="@bldFile[starts-with(.,'/') or contains(.,'../') or contains(.,':')] | @mrp[starts-with(.,'/') or contains(.,'../') or contains(.,':')] |@base[starts-with(.,'/') or contains(.,'../') or contains(.,':')]"><xsl:param name="filename"/>
<xsl:if test="substring(.,string-length(.))='/'">
		<xsl:call-template name="Warning"><xsl:with-param name="text"><code><xsl:value-of select="name()"/></code> path "<xsl:value-of select="."/>" should not end in /</xsl:with-param></xsl:call-template>
</xsl:if>
<xsl:if test="contains(.,'\')">
		<xsl:call-template name="Error"><xsl:with-param name="text"><code><xsl:value-of select="name()"/></code> path "<xsl:value-of select="."/>" must use only forward slashes</xsl:with-param></xsl:call-template>
</xsl:if>
	<xsl:variable name="fullpath"><xsl:call-template name="normpath">
				<xsl:with-param name="path">
					<xsl:if test="not(starts-with(.,'/'))">
						<xsl:call-template name="before">
							<xsl:with-param name="text" select="$filename"/>
						</xsl:call-template>
					</xsl:if>
					<xsl:value-of select="."/>
				 </xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="path">
			<xsl:choose>
				<xsl:when test="not(contains($filename,':'))">/<xsl:for-each select="ancestor::*/@id"><xsl:apply-templates mode="path" select="."/>/</xsl:for-each></xsl:when>
				<xsl:otherwise><xsl:for-each select="../../../@id|../../@id"><xsl:apply-templates mode="path" select="."/>/</xsl:for-each></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="segment">
			<xsl:choose>
				<xsl:when test="ancestor::layer">
					<xsl:value-of select="concat($fullpath,'/')"/>
				</xsl:when>
				<xsl:when test="ancestor::package">
					<xsl:value-of select="concat('/',substring-after(substring-after($fullpath,'/'),'/'),'/')"/>
				</xsl:when>
				<xsl:when test="ancestor::collection">
					<xsl:value-of select="concat('/',substring-after(substring-after(substring-after($fullpath,'/'),'/'),'/'),'/')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat('/',substring-after(substring-after(substring-after(substring-after($fullpath,'/'),'/'),'/'),'/'),'/')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
<xsl:choose>
	<xsl:when test="contains($filename,':')">
		<xsl:choose>
			<xsl:when test="not(starts-with(.,$path) or concat(.,'/')=$path) and $path-errors">
				<xsl:call-template name="Note"><xsl:with-param name="text">Unexpected <code><xsl:value-of select="name()"/></code> path for <xsl:apply-templates mode="path" select="../../../@id"/> -&gt; <strong><xsl:apply-templates mode="path" select="../../@id"/></strong>: "<xsl:value-of select="."/>"</xsl:with-param></xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:when>
	<xsl:otherwise>
		<xsl:choose>
			<xsl:when test="not($path-errors)"/>
			<xsl:when test="substring-before(substring($segment,2),'/') != substring-before(substring($path,2),'/') and (ancestor::SystemDefinition/@id-namespace!='http://www.symbian.org/system-definition' and not(contains(../../@id,':')))">
				<xsl:call-template name="Warning"><xsl:with-param name="text">Unexpected <code><xsl:value-of select="name()"/></code> path for <xsl:apply-templates mode="path" select="../../../@id"/> -&gt; <strong><xsl:apply-templates mode="path" select="../../@id"/></strong>: "<xsl:value-of select="$fullpath"/>"</xsl:with-param></xsl:call-template>
			</xsl:when>
			<xsl:when test="substring-before(substring($segment,2),'/') != substring-before(substring($path,2),'/')">
				<xsl:call-template name="Error"><xsl:with-param name="text">Unexpected <code><xsl:value-of select="name()"/></code> path for <xsl:apply-templates mode="path" select="../../../@id"/> -&gt; <strong><xsl:apply-templates mode="path" select="../../@id"/></strong>: "<xsl:value-of select="$fullpath"/>"</xsl:with-param></xsl:call-template>
			</xsl:when>
			<xsl:when test="not(starts-with($segment,$path))">
				<xsl:call-template name="Note"><xsl:with-param name="text">Unexpected <code><xsl:value-of select="name()"/></code> path for <xsl:apply-templates mode="path" select="../../../@id"/> -&gt; <strong><xsl:apply-templates mode="path" select="../../@id"/></strong>: "<xsl:value-of select="$fullpath"/>"</xsl:with-param></xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="SystemDefinition" mode="check-matches">
	<xsl:param name="which"/>
	<xsl:param name="other"/>
	<xsl:for-each select="//*[@mrp]">
		<xsl:variable name="mrp" select="@mrp"/>
		<xsl:if test="not($other//*[@mrp=$mrp])">
			<xsl:call-template name="Error"><xsl:with-param name="text"><xsl:value-of select="$mrp"/> has no match in <xsl:value-of select="$which"/>.</xsl:with-param></xsl:call-template>
		</xsl:if>
	</xsl:for-each>
</xsl:template>

<xsl:template match="*" mode="value">
	<xsl:call-template name="Error"><xsl:with-param name="text">
		<xsl:value-of select="name()"/>:<xsl:for-each select="@*"><xsl:value-of select="concat(name(),'=',.)"/></xsl:for-each>
	</xsl:with-param></xsl:call-template>
</xsl:template>

<xsl:template match="*" mode="compare"><xsl:param name="base"/>
<xsl:variable name="n" select="@id"/>
<xsl:variable name="tag" select="name()"/>
<xsl:variable name="v"><xsl:apply-templates select="." mode="value"/></xsl:variable>
<xsl:variable name="v2"><xsl:apply-templates mode="value" select="$base//*[name()=$tag and @id=$n]"/></xsl:variable>
<xsl:if  test="$v != $v2">
	<xsl:call-template name="Error"><xsl:with-param name="text">
		<xsl:value-of select="concat(name(),' ',@name)"/> not identical. [<xsl:value-of select="$v"/>|<xsl:value-of select="$v2"/>]</xsl:with-param></xsl:call-template>
</xsl:if>	
</xsl:template>



<xsl:template match="unit" mode="compare" priority="1"><xsl:param name="base"/>
<xsl:variable name="n" select="concat(@version,':',@mrp,'.',@prebuilt)"/>
<xsl:variable name="v"><xsl:apply-templates select="." mode="value"/></xsl:variable>
<xsl:variable name="v2"><xsl:apply-templates mode="value" select="$base//unit[concat(@version,':',@mrp,'.',@prebuilt)=$n]"/></xsl:variable>
<xsl:if  test="$v != $v2">
	<xsl:call-template name="Error"><xsl:with-param name="text">
		<xsl:value-of select="concat('&#xa;',name(),' ',../@name,' v',@version)"/> not identical. [<xsl:value-of select="$v"/>|<xsl:value-of select="$v2"/>]</xsl:with-param></xsl:call-template>
</xsl:if>
</xsl:template>

<xsl:template match="/variations/@module"> (<xsl:value-of select="."/>)</xsl:template>

<xsl:template match="/variations" mode="x-check"><xsl:param name="sysdef"/>
<xsl:call-template name="Section"><xsl:with-param name="text">vp cross-check <xsl:apply-templates select="@module"/></xsl:with-param></xsl:call-template>
<xsl:for-each select="//component">
	<xsl:variable name="found">
		<xsl:apply-templates select="$sysdef" mode="lookfor">
			<xsl:with-param name="id" select="@name"/>
			<xsl:with-param name="version" select="@version"/>
		</xsl:apply-templates>
	</xsl:variable>
	<xsl:if test="$found=''">
		<xsl:call-template name="Error"><xsl:with-param name="text">VP component "<xsl:value-of select="@name"/>"<xsl:if test="@version"> v<xsl:value-of select="@version"/></xsl:if> not in SysDef</xsl:with-param></xsl:call-template>
	</xsl:if>
</xsl:for-each>
</xsl:template>

<xsl:template match="*" mode="lookfor"><xsl:param name="id"/><xsl:param name="version"/>
	<xsl:choose>
		<xsl:when test="string-length($version) and //component[@id=$id and unit[@version=$version]]">Found</xsl:when>
		<xsl:when test="string-length($version)=0 and //*[@id=$id]">Found</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="document(//layer/@href | //package/@href | //collection/@href | //component/@href,.)/*/*" mode="lookfor">
				<xsl:with-param name="version" select="$version"/>
				<xsl:with-param name="id" select="$id"/>
			</xsl:apply-templates>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>



<xsl:template match="SystemBuild" mode="x-check"><xsl:param name="sysdef"/>

<xsl:call-template name="Section"><xsl:with-param name="text">System Build cross-check</xsl:with-param></xsl:call-template>
<xsl:for-each select="//ref">
	<xsl:variable name="found">
		<xsl:apply-templates select="$sysdef" mode="lookfor">
		<xsl:with-param name="id" select="current()/@item"/>
	</xsl:apply-templates>
</xsl:variable>
	<xsl:if test="$found=''">
		<xsl:call-template name="Error"><xsl:with-param name="text">Build item "<xsl:value-of select="@item"/>" not in SysDef</xsl:with-param></xsl:call-template>
</xsl:if>
</xsl:for-each>

<xsl:for-each select="//listRef">
	<xsl:if test="not(//list[@name=current()/@list])">
		<xsl:call-template name="Error"><xsl:with-param name="text">Build list "<xsl:value-of select="@name"/>" not defined</xsl:with-param></xsl:call-template>
</xsl:if>	
</xsl:for-each>
</xsl:template>


<xsl:template name="my-release">
	<xsl:variable name="n" select="@name"/>
	<xsl:variable name="new" select="@introduced"/>
	<xsl:variable name="end" select="@deprecated"/>
	<xsl:choose>
		<xsl:when test="$new!='' and $end!=''">(<xsl:value-of select="concat($new,' - ',$end)"/>)</xsl:when>
		<xsl:when test="$new!='' ">(<xsl:value-of select="$new"/>)</xsl:when>
		<xsl:when test="$end!=''">(? - <xsl:value-of select="$end"/>)</xsl:when>
	</xsl:choose>
</xsl:template>

<xsl:template name="normpath"><xsl:param name="path"/>
<!-- normalize out any ".." in the path in $path  -->
<xsl:choose>
	<xsl:when test="contains($path,'/../')">
	<xsl:call-template name="normpath">
		<xsl:with-param name="path">
		<xsl:call-template name="before">
			<xsl:with-param name="text" select="substring-before($path,'/../')"/>
		</xsl:call-template>
		<xsl:value-of select="substring-after($path,'/../')"/>
		</xsl:with-param>
		</xsl:call-template>
	</xsl:when>
	<xsl:otherwise><xsl:value-of select="$path"/></xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- return all text before the last / -->
<xsl:template name="before"><xsl:param name="text"/>
<xsl:if test="contains($text,'/')">
	<xsl:value-of select="substring-before($text,'/')"/>/<xsl:call-template name="before"><xsl:with-param name="text" select="substring-after($text,'/')"/></xsl:call-template>
	</xsl:if>
</xsl:template>


</xsl:stylesheet>