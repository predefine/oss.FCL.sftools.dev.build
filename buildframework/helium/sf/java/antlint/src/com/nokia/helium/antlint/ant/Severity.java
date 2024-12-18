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
package com.nokia.helium.antlint.ant;

import org.apache.tools.ant.types.EnumeratedAttribute;

/**
 * To store the antlint severties.
 */
public class Severity extends EnumeratedAttribute {

    private static final String[] VALUES = { "error", "warning" };

    /*
     * (non-Javadoc)
     * 
     * @see org.apache.tools.ant.types.EnumeratedAttribute#getValues()
     */
    @Override
    public String[] getValues() {
        return VALUES;
    }

}
