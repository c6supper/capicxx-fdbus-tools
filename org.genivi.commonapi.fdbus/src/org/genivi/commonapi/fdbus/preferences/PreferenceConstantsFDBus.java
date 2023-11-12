/* Copyright (C) 2014-2020 Bayerische Motoren Werke Aktiengesellschaft (BMW AG)
   This Source Code Form is subject to the terms of the Mozilla Public
   License, v. 2.0. If a copy of the MPL was not distributed with this
   file, You can obtain one at http://mozilla.org/MPL/2.0/. */
package org.genivi.commonapi.fdbus.preferences;

import org.genivi.commonapi.core.preferences.PreferenceConstants;


public interface PreferenceConstantsFDBus extends PreferenceConstants
{
    public static final String SCOPE                   = "org.genivi.commonapi.fdbus.ui";
    public static final String PROJECT_PAGEID          = "org.genivi.commonapi.fdbus.ui.preferences.CommonAPIFDBusPreferencePage";

    // preference keys
    public static final String P_LICENSE_FDBUS        	= P_LICENSE;
    public static final String P_OUTPUT_PROXIES_FDBUS  = P_OUTPUT_PROXIES;
    public static final String P_OUTPUT_STUBS_FDBUS    = P_OUTPUT_STUBS;
	public static final String P_OUTPUT_COMMON_FDBUS   = P_OUTPUT_COMMON;
	public static final String P_OUTPUT_DEFAULT_FDBUS  = P_OUTPUT_DEFAULT;
	public static final String P_OUTPUT_SUBDIRS_FDBUS  = P_OUTPUT_SUBDIRS;
    public static final String P_GENERATEPROXY_FDBUS   = P_GENERATE_PROXY;
    public static final String P_GENERATESTUB_FDBUS    = P_GENERATE_STUB;
    public static final String P_GENERATE_COMMON_FDBUS	= P_GENERATE_COMMON;    
	public static final String P_LOGOUTPUT_FDBUS       = P_LOGOUTPUT;
	public static final String P_USEPROJECTSETTINGS_FDBUS= P_USEPROJECTSETTINGS;
	public static final String P_GENERATE_CODE_FDBUS   = P_GENERATE_CODE;
	public static final String P_GENERATE_DEPENDENCIES_FDBUS = P_GENERATE_DEPENDENCIES;
	public static final String P_GENERATE_SYNC_CALLS_FDBUS = P_GENERATE_SYNC_CALLS;
    public static final String P_ENABLE_FDBUS_VALIDATOR= "enableFDBusValidator";
    public static final String P_ENABLE_FDBUS_DEPLOYMENT_VALIDATOR = "enableFDBusDeploymentValidator";

	// preference values
    public static final String DEFAULT_OUTPUT_FDBUS   	= "./src-gen/";
}
