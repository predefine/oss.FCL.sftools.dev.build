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
package com.nokia.helium.antlint.ant.types;

import java.util.List;

import com.nokia.helium.ant.data.ProjectMeta;
import com.nokia.helium.ant.data.PropertyMeta;
import com.nokia.helium.ant.data.RootAntObjectMeta;

/**
 * <code>CheckPropertyName</code> is used to check the naming convention of
 * property names.
 * 
 * <pre>
 * Usage:
 * 
 *  &lt;antlint&gt;
 *       &lt;fileset id=&quot;antlint.files&quot; dir=&quot;${antlint.test.dir}/data&quot;&gt;
 *               &lt;include name=&quot;*.ant.xml&quot;/&gt;
 *               &lt;include name=&quot;*build.xml&quot;/&gt;
 *               &lt;include name=&quot;*.antlib.xml&quot;/&gt;
 *       &lt;/fileset&gt;
 *       &lt;checkPropertyName severity=&quot;error&quot; regexp=&quot;([a-z0-9[\\d\\-]]*)&quot; /&gt;
 *  &lt;/antlint&gt;
 * </pre>
 * 
 * @ant.task name="checkPropertyName" category="AntLint"
 * 
 */
public class CheckPropertyName extends AbstractProjectCheck {

    private String regExp;

    /**
     * {@inheritDoc}
     */
    protected void run(RootAntObjectMeta root) {
        if (root instanceof ProjectMeta) {
            ProjectMeta projectMeta = (ProjectMeta) root;
            List<PropertyMeta> properties = projectMeta.getProperties();
            for (PropertyMeta propertyMeta : properties) {
                if (!matches(propertyMeta.getName(), getRegExp())) {
                    report("Invalid property name: " + propertyMeta.getName(),
                            propertyMeta.getLineNumber());
                }
            }
        }
    }

    /**
     * Set the regular expression.
     * 
     * @param regExp the regExp to set
     */
    public void setRegExp(String regExp) {
        this.regExp = regExp;
    }

    /**
     * Get the regular expression.
     * 
     * @return the regExp
     */
    public String getRegExp() {
        return regExp;
    }
}
