/*
* Copyright (c) 2007-2008 Nokia Corporation and/or its subsidiary(-ies).
* All rights reserved.
* This component and the accompanying materials are made available
* under the terms of the License "Eclipse Public License v1.0"
* which accompanies this distribution, and is available
* at the URL "http://www.eclipse.org/legal/epl-v10.html".
*
* Initial Contributors:
* Nokia Corporation - initial contribution.
*
* Contributors:
*
* Description: 
*
*/
 
package com.nokia.helium.ccmtask.ant.commands;

/**
 * This object is used to Synchronize a ccm project.
 *
 */
public class Synchronize extends CcmCommand
{
    private String project;
    private boolean recursive = true;
    

    /**
     * Get the project to checkout.
     * @return
     */
    public String getProject()
    {
        return project;
    }

    /**
     * Set the project to checkout.
     * @return the project four part name
     */
    public void setProject(String project)
    {
        this.project = project;
    }
    
    /**
     * Shall subprojects workarea be maintained relatively to the parent.
     * @return
     */
    public boolean getRecursive()
    {
        return recursive;
    }

    /**
     * Set if the checkout should be a recursive.
     * @param recursive
     */
    public void setRecursive(boolean recursive)
    {
        this.recursive = recursive;
    } 
    
}
