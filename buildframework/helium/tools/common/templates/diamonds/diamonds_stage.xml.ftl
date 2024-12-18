<#--
============================================================================ 
Name        : diamonds_stage.xml.ftl 
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
    <stages>
      <stage>    
            <name>${ant["logical.stage"]?xml}</name>
            <#if ant?keys?seq_contains("stage.start.time")><started>${ant["stage.start.time"]?xml}</started></#if>
            <#if ant?keys?seq_contains("stage.end.time")><finished>${ant["stage.end.time"]?xml}</finished></#if>
     </stage>
    </stages>
<#include "diamonds_footer.ftl"> 