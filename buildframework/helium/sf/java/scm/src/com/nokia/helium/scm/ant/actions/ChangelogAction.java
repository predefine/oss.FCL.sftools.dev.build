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

package com.nokia.helium.scm.ant.actions;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Iterator;

import org.apache.maven.scm.ChangeSet;
import org.apache.maven.scm.ScmException;
import org.apache.maven.scm.ScmRevision;
import org.apache.maven.scm.command.changelog.ChangeLogScmResult;
import org.apache.maven.scm.command.changelog.ChangeLogSet;
import org.apache.maven.scm.manager.ScmManager;
import org.apache.maven.scm.repository.ScmRepository;
import org.apache.tools.ant.BuildException;
import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;

/**
 * Get change log within a date range i.e startDate and endDate; OR get change log of a number of
 * days i.e numDays OR get change log within a range of starVersion and endVersion Parameters either
 * startDate="20090317 18:49:31" endDate="20090318 24:49:31" datePattern="yyyyMMdd HH:mm:ss" Or
 * numDays='1' Or startVersion="1" endVersion="2" Add logOutput="xml" to output log in xml format
 * 
 * <pre>
 * &lt;hlm:scm verbose="false" scmUrl="scm:hg:${repo.dir}/changelog"&gt;
 *     &lt;hlm:changelog basedir="${repo.dir}/changelog" startVersion="1" endVersion="2"/&gt;
 *     &lt;hlm:changelog baseDir="${repo.dir}/changelog" numDays='1' /&gt;
 * &lt;/hlm:scm&gt;
 * </pre>
 * 
 * @ant.type name="changelog" category="SCM"
 */
public class ChangelogAction extends BaseDirectoryScmAction {

    private String startDate;

    private String endDate;

    private String datePattern;

    private String logOutput;

    private int numDays;

    private String startVersion;

    private String endVersion;
    private File xmlbom;

    /**
     * Start version
     * 
     * @ant.not-required
     */
    public void setStartVersion(String startVersion) {
        this.startVersion = startVersion;
    }

    /**
     * End version
     * 
     * @ant.not-required
     */
    public void setEndVersion(String endVersion) {
        this.endVersion = endVersion;
    }

    /**
     * Start date
     * 
     * @ant.not-required
     */
    public void setStartDate(String startDate) {
        this.startDate = startDate;
    }

    /**
     * End date
     * 
     * @ant.not-required
     */
    public void setEndDate(String endDate) {
        this.endDate = endDate;
    }

    /**
     * Number of days
     * 
     * @ant.not-required
     */
    public void setNumDays(int numDays) {
        this.numDays = numDays;
    }

    /**
     * Date pattern default is EEE MMM dd HH:mm:ss yyyy Z
     * 
     * @ant.not-required
     */
    public void setDatePattern(String datePattern) {
        this.datePattern = datePattern;
    }

    /**
     * Output pattern default is log output, to get xml output set logoutput=xml
     * 
     * @ant.not-required
     */
    public void setLogOutput(String logOutput) {
        this.logOutput = logOutput;
    }

    /**
     * File for xml output of changeset list
     * 
     * @ant.not-required
     */
    public void setXmlbom(File xmlbom) {
        this.xmlbom = xmlbom;
    }

    /**
     * {@inheritDoc}
     */
    @SuppressWarnings("unchecked")
    @Override
    public void execute(ScmRepository repository) throws ScmException {
        ScmManager scmManager = getTask().getScmManager();
        ScmRevision startRevision = new ScmRevision(startVersion);
        ScmRevision endRevision = new ScmRevision(endVersion);

        ChangeLogScmResult result;
        Date start = null;
        Date end = null;

        if (numDays == 0 && (startDate != null || endDate != null)) {
            try {
                SimpleDateFormat format = new SimpleDateFormat(datePattern);
                start = format.parse(startDate);
                end = format.parse(endDate);
            }
            catch (ParseException e) {
                throw new ScmException("Date Format not supported:" + e.getMessage());
            }
        }
        else {
            start = null;
            end = null;
        }
        try {
            if (startVersion == null) {
                result = scmManager.changeLog(repository, getScmFileSet(), start, end, numDays, null, datePattern);
            } else {
                result = scmManager.changeLog(repository, getScmFileSet(), startRevision, endRevision, datePattern);
            }
        }
        catch (ScmException e) {
            throw new BuildException("Execution of SCM changelog action failed.");
        }
        if (!result.isSuccess()) {
            throw new BuildException("SCM changelog command unsuccessful.");
        }
        // Output changelog information
        ChangeLogSet changelogSet = result.getChangeLog();
        if (logOutput != null && logOutput.equals("xml")) {
            getTask().log(changelogSet.toXML());
        }
        else if (xmlbom != null) {
            String output = "";
            for (Object object : changelogSet.getChangeSets()) {
                String revision = "";
                ChangeSet changeSet = (ChangeSet) object;
                for (String line : changeSet.toString().split("\n")) {
                    if (line.contains("revision:")) {
                        revision = line.replace("revision:", "");
                    }
                }

                output = output + "<task><id>" + revision + "</id><synopsis>"
                    + changeSet.getComment() + "</synopsis><completed>"
                    + new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss").format(changeSet.getDate())
                    + "</completed></task>";
            }
            String[] path = getTask().getScmUrl().split("/");
            String xml = "<bom><build>untitled</build><content>\n";
            String thisproject = "<project>" + "<name>" + path[path.length - 1] + "</name>"
                + "<baseline>" + getTask().getScmUrl() + "</baseline>"
                + "<database>mercurial</database>" + output + "</project>\n";
            xml = xml + thisproject;
            try {
                if (xmlbom.exists()) {
                    SAXReader xmlReader = new SAXReader();
                    Document antDoc = xmlReader.read(xmlbom);
                    for (Iterator iterator = antDoc.selectNodes("//project").iterator(); iterator.hasNext();) {
                        boolean equal = false;
                        Element element = (Element) iterator.next();
                        for (Iterator iterator2 = antDoc.selectNodes("//baseline").iterator(); iterator2.hasNext();) {
                            Element e2 = (Element) iterator2.next();
                            if (e2.getText().equals(getTask().getScmUrl())) {
                                equal = true;
                            }
                        }
                        if (!equal) {
                            xml = xml + element.asXML() + "\n";
                        }
                    }
                }
                xml = xml + "</content></bom>";

                FileWriter fstream = new FileWriter(xmlbom);
                BufferedWriter out = new BufferedWriter(fstream);
                out.write(xml);
                out.close();
            } catch (DocumentException e) {
                e.printStackTrace();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        else {
            Iterator iterator = changelogSet.getChangeSets().iterator();
            while (iterator.hasNext()) {
                getTask().log(iterator.next().toString());
            }
        }
    }
}
