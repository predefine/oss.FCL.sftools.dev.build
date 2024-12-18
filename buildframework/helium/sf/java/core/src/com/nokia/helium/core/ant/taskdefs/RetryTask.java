/*
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */
/* package org.apache.tools.ant.taskdefs; */
/* * Portion Copyright (c) 2007-2008 Nokia Corporation and/or its subsidiary(-ies). All rights reserved.*/

package com.nokia.helium.core.ant.taskdefs;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.TaskContainer;
import org.apache.tools.ant.taskdefs.Sleep;

/**
 * Retries the nested task a set number of times
 * 
 * @since Ant 1.7.1
 * @ant.task name="retry" category="Core"
 */
public class RetryTask extends Task implements TaskContainer {
    /**
     * task to execute n times
     */
    private Task nestedTask;

    /**
     * set retryCount to 1 by default
     */
    private int retryCount = 1;

    /**
     * set sleepTime to 0 by default
     */
    private int sleepTime;

    /**
     * set the task
     * 
     * @param t
     *            the task to retry.
     */
    public synchronized void addTask(Task t) {
        if (nestedTask != null) {
            throw new BuildException(
                    "The retry task container accepts a single nested task"
                            + " (which may be a sequential task container)");
        }
        nestedTask = t;
    }

    /**
     * set the number of times to retry the task
     * 
     * @param n
     *            the number to use.
     * @ant.not-required Default is 1.
     */
    public void setRetryCount(int n) {
        retryCount = n;
    }

    /**
     * set the sleep time inbetween each retry
     * 
     * @param n
     *            the time in ms to sleep between each retry.
     * @ant.not-required Default is 0.
     */
    public void setSleepTime(int n) {
        sleepTime = n;
    }

    /**
     * perform the work
     * 
     * @throws BuildException
     *             if there is an error.
     */
    public void execute() {
        if (nestedTask == null) {
            throw new BuildException("The nested retry task not defined");
        }

        StringBuffer errorMessages = new StringBuffer();
        String br = getProject().getProperty("line.separator");
        for (int i = 0; i <= retryCount; i++) {
            try {
                nestedTask.perform();
                break;
            } catch (BuildException e) {
                errorMessages.append(e.getMessage());
                if (i >= retryCount) {
                    StringBuffer exceptionMessage = new StringBuffer();
                    exceptionMessage.append("Task [").append(
                            nestedTask.getTaskName());
                    exceptionMessage.append("] failed after [").append(
                            retryCount);
                    exceptionMessage.append("] attempts; giving up.")
                            .append(br);
                    exceptionMessage.append("Error messages:").append(br);
                    exceptionMessage.append(errorMessages);
                    throw new BuildException(exceptionMessage.toString(),
                            getLocation());
                }
                log("Attempt [" + i + "]:  error occurred; retrying...", e,
                        Project.MSG_INFO);
                errorMessages.append(br);
                if (sleepTime > 0) {
                    Sleep sleepTimer = new Sleep();
                    sleepTimer.setMilliseconds(sleepTime);
                    sleepTimer.execute();
                }
            }
        }
    }
}
