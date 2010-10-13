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
package com.nokia.helium.metadata.ant.types;

import java.util.Collection;

/**
 * This interface describe what a Metadata filter
 * Collection must implements as interface.
 *
 */
public interface MetaDataFilterCollection {
    
    /**
     * Get the nested filters.
     * @return a Collection of metadatafilters objects.
     */
    Collection<MetaDataFilter> getAllFilters();
}