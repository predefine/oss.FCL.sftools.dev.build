<#--
============================================================================ 
Name        : email.html.ftl 
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
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
  <head>
  <meta http-equiv="Content-Type" content="text/html;charset=utf-8">
    <title>
      Build result e-mail from ${ant["env.COMPUTERNAME"]}.
    </title>
    <style type="text/css">
        body{font-family:Verdana; font-size:10pt; line-height:1.1em; padding: 10px 10px; background-color:#E4F0F4;}
        h1{
          font-size:14pt;
          color:#000;
          padding: 20px 15px;
              margin:0;
         }
        h2{font-size:12pt;}
        h5{
          font-size:10pt;
          background-color:#8495BA;
          color:#fff;
          heigth:20pt;
          padding: 5px 15px;
          border-left:2px solid #5A6FA0;
          border-bottom:2px solid #5A6FA0;
          border-top:2px solid #98A6C6;
          border-right:2px solid #98A6C6;
          margin:0;
         }
 
  
        p {
          font-size:10pt;
          padding: 0em 1em 1em 1em;
          margin: 0 1em 0.5em 1em;
          border-right:1px solid #5A6FA0;
          border-top:0;
          border-bottom:1px solid #98A6C6;
          border-left:1px solid #98A6C6;
          background-color:#CDE4EB;
          white-space:normal;
        }
 
        .data{color:#00F;}
        .okmessage{color:#24A22D;font-weight:bold; display:block; margin-bottom: 1em;padding-top: 1em;}
        .errormessage{color:#F00;font-weight:bold; display:block; margin-bottom: 1em;padding-top: 1em;}
 
        span.items{text-indent:-1em; padding-left: 1em; display:block; word-wrap:normal;}

        span.bold{font-weight:bold; display:block; padding: 1em 0;}
        p.maintext{padding-top: 1em;}
        p.logfolder{color:#000;font-weight:bold; padding-top: 1em;}
        p.distrib{font-weight:bold;}
 
 
        a:link,a:visited{color:#00E;}
        
    </style>
  </head>
  <body>
      <!-- The title -->
      <div id="buildname">
        <h1>This is an e-mail notification that a build has been completed on ${ant["env.COMPUTERNAME"]}</h1>
      </div>

    <#assign table_info = pp.loadData('com.nokia.helium.metadata.ORMFMPPLoader',
        "${dbPath}") >

    <#assign convertedLogFile = "${logpath}"?replace("\\","/")>
    <#list table_info['jpa']['select l from LogFile l where LOWER(l.path)=\'${convertedLogFile?lower_case}\''] as logfile>


<#assign error_count = table_info['jpasingle']['select Count(m.id) from MetadataEntry m JOIN m.severity as p where m.logFileId=${logfile.id} and p.severity=\'ERROR\''][0]> 
    <!-- section -->
    <#macro create_section title type>
           <div id="foldername">
               <h5>${title}</h5>
               <p class="maintext">
                   <!-- content span -->
                   <span class="${type}"><#nested></span>
               </p>
           </div>
       </#macro>
<#if (error_count > 0)>
        <span class="errormessage">
            ${logfile.path}...FAIL<br/>
            <#list table_info['jpa']['select e from MetadataEntry e JOIN e.severity s where s.severity=\'ERROR\' and e.logFileId=${logfile.id}'] as entry >
            <ul>
            <#if entry.text??>${entry.text?html}</#if><br/>
            </ul>
            </#list>
        </span>
<#else>
    <span class="okmessage">${logfile.path}...OK<br/></span>
</#if>
</#list>
</body>
</html>