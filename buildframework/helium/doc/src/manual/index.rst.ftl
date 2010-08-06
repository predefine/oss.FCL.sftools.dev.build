<#--
============================================================================ 
Name        : index.rst.ftl
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
###################################
  Helium Manual
###################################


.. toctree::
   :maxdepth: 2

   introduction
   support
<#if !ant?keys?seq_contains("sf")>
   retrieving
</#if>
   configuring
   running
   debugging
   stages
   stage_matti
<#if !ant?keys?seq_contains("sf")>
   nokiastages
   datapackage
   iad
</#if>
   documentation
   quality
   cruisecontrol
   sysdef3
   metrics

   
   
   