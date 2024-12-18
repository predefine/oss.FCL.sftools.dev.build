<#--
============================================================================ 
Name        : 
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
<#list doc.antDatabase.project as project>
<#list project.target as target>
<@pp.changeOutputFile name="target-${target.name}.dot" />

strict digraph G {
    rankdir=LR;
    rotate=180;
    ordering=out;
<#assign currentTarget = target.name>

<#macro targetFunc targetMain caller>
<#-- Define the targets that call this target. -->
<#if caller == 0>
    "${targetMain.name}" [fontcolor=blue,fontsize=12,shape=box,style=filled,href="project-${targetMain?parent.name}.html#${targetMain.name}"];
    <#list doc.antDatabase.project.target as callingTarget>
        <#list callingTarget.dependency as dependency>
            <#if targetMain.name == dependency>
                <#if callingTarget.name != currentTarget>
                    "${callingTarget.name}" [fontcolor=brown,fontsize=12,shape=box,href="project-${callingTarget?parent.name}.html#${callingTarget.name}"];
                </#if>
                <#if dependency.@type == "direct">
                    "${callingTarget.name}" -> "${targetMain.name}" [color=navyblue,fontsize=12];
                </#if>
                <#if dependency.@type == "exec">
                    "${callingTarget.name}" -> "${targetMain.name}" [color=limegreen,fontsize=12];
                </#if>
            </#if>
        </#list>
    </#list>
</#if>
<#if caller == 1>
    "${targetMain.name}" [fontcolor=brown,fontsize=12,shape=box,href="project-${targetMain?parent.name}.html#${targetMain.name}"];
</#if>

<#if targetMain.dependency?size == 1>
    <#list targetMain.dependency as dependency>
    "${dependency}" [fontcolor=brown,fontsize=12,shape=box,href="project-${targetMain?parent.name}.html#${dependency}"];
    </#list>
</#if>

<#assign depTotal=targetMain.dependency?size>
<#assign depLastIndex=targetMain.dependency?size-1>

<#if depTotal &gt; 1>
    <#list 0..depLastIndex as index>
        <#if targetMain.dependency[index].@type == "direct">
        "${targetMain.name}" -> "${targetMain.dependency[index]}" [color=navyblue,label="${index+1}",fontsize=12];
        </#if>
        <#if targetMain.dependency[index].@type == "exec">
        "${targetMain.name}" -> "${targetMain.dependency[index]}" [color=limegreen,label="${index+1}",fontsize=12];
        </#if>
        <#list doc.antDatabase.project.target as targetDep>
            <#if targetDep.name == targetMain.dependency[index]>
            <@targetFunc targetMain=targetDep caller=1 />
            </#if>
        </#list>
    </#list>
</#if>

<#attempt>
<#if depTotal == 1>
    <#if targetMain.dependency.@type == "direct">
    "${targetMain.name}" -> "${targetMain.dependency[depTotal-1]}" [color=navyblue];
    </#if>
    <#if targetMain.dependency.@type == "exec">
    "${targetMain.name}" -> "${targetMain.dependency[depTotal-1]}" [color=limegreen];
    </#if>
    <#list doc.antDatabase.project.target as targetDep>
        <#if targetDep.name == targetMain.dependency>
        <@targetFunc targetMain=targetDep caller=1 />
        </#if>
    </#list>
</#if>
<#recover>

</#attempt>

</#macro>

<@targetFunc targetMain=target caller=0 />
}
</#list>
</#list>

