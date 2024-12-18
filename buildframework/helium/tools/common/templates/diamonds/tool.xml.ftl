<#--
============================================================================ 
Name        : tool.xml.ftl 
Part of     : Helium 

Copyright (c) 2009 Nokia Corporation and/or its subsidiary(-ies).
All rights reserved.
This component and the accompanying materials are made available
under the terms of the License "Eclipse Public License v1.0"
which accompanies this distribution, and is available
at the URL "http://www.eclipse.org/legal/epl-v10.html".

Initial Contributors:
Nokia Corporation - initial contribution.

Contributors:

Description:

============================================================================
-->
<#include "diamonds_header.ftl"> 
<#include "diamonds_macro.ftl">
    <tools>
<#if ant?keys?seq_contains("env.SYMSEE_VERSION")>         
        <tool>
            <name>SymSEE</name>
            <version>${ant["env.SYMSEE_VERSION"]?xml}</version>
        </tool>
</#if>
<#if (doc)??>
<#list doc["environment/tool"] as tool>
        <#if tool.path?length &gt; 0>
        <tool>
            <name>${tool.name?xml}</name>
            <version>${tool.version?xml}</version>
        </tool>
        </#if>
</#list>
</#if>
        <tool>
            <name>Helium</name>
            <version>${ant["helium.version"]?xml}</version>
        </tool>
    </tools>
<#include "diamonds_footer.ftl">
