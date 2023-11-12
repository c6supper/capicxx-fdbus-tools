/* Copyright (C) 2014-2020 Bayerische Motoren Werke Aktiengesellschaft (BMW AG)
   This Source Code Form is subject to the terms of the Mozilla Public
   License, v. 2.0. If a copy of the MPL was not distributed with this
   file, You can obtain one at http://mozilla.org/MPL/2.0/. */
package org.genivi.commonapi.fdbus.preferences;


import java.util.HashMap;
import java.util.Map;
import java.io.File;

import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.generator.OutputConfiguration;
import org.franca.core.franca.FModel;

public class FPreferencesFDBus
{

    private static FPreferencesFDBus instance    = null;
    private Map<String, String> preferences = null;

    private FPreferencesFDBus()
    {
        preferences = new HashMap<String, String>();
        clidefPreferences();
    }

    public void resetPreferences()
    {
        preferences.clear();
    }

    public Map<String, String> getPreferences() {
		return preferences;
	}    
    
    
    public static FPreferencesFDBus getInstance()
    {
        if (instance == null) {
            instance = new FPreferencesFDBus();
        }
        return instance;
    }

    public void clidefPreferences()
    {
        if (!preferences.containsKey(PreferenceConstantsFDBus.P_OUTPUT_DEFAULT_FDBUS)) {
            preferences.put(PreferenceConstantsFDBus.P_OUTPUT_DEFAULT_FDBUS, PreferenceConstantsFDBus.DEFAULT_OUTPUT_FDBUS);
        }    	
        if (!preferences.containsKey(PreferenceConstantsFDBus.P_OUTPUT_COMMON_FDBUS)) {
            preferences.put(PreferenceConstantsFDBus.P_OUTPUT_COMMON_FDBUS, PreferenceConstantsFDBus.DEFAULT_OUTPUT_FDBUS);
        }    	
        if (!preferences.containsKey(PreferenceConstantsFDBus.P_OUTPUT_PROXIES_FDBUS)) {
            preferences.put(PreferenceConstantsFDBus.P_OUTPUT_PROXIES_FDBUS, PreferenceConstantsFDBus.DEFAULT_OUTPUT_FDBUS);
        }
        if (!preferences.containsKey(PreferenceConstantsFDBus.P_OUTPUT_STUBS_FDBUS)) {
            preferences.put(PreferenceConstantsFDBus.P_OUTPUT_STUBS_FDBUS, PreferenceConstantsFDBus.DEFAULT_OUTPUT_FDBUS);
        }
        if (!preferences.containsKey(PreferenceConstantsFDBus.P_OUTPUT_SUBDIRS_FDBUS)) {
            preferences.put(PreferenceConstantsFDBus.P_OUTPUT_SUBDIRS_FDBUS, "false");
        }
        if (!preferences.containsKey(PreferenceConstantsFDBus.P_LICENSE_FDBUS)) {
            preferences.put(PreferenceConstantsFDBus.P_LICENSE_FDBUS, PreferenceConstantsFDBus.DEFAULT_LICENSE);
        }
        if (!preferences.containsKey(PreferenceConstantsFDBus.P_GENERATEPROXY_FDBUS)) {
            preferences.put(PreferenceConstantsFDBus.P_GENERATEPROXY_FDBUS, "true");
        }
        if (!preferences.containsKey(PreferenceConstantsFDBus.P_GENERATESTUB_FDBUS)) {
            preferences.put(PreferenceConstantsFDBus.P_GENERATESTUB_FDBUS, "true");
        }
        if (!preferences.containsKey(PreferenceConstantsFDBus.P_GENERATE_COMMON_FDBUS)) {
            preferences.put(PreferenceConstantsFDBus.P_GENERATE_COMMON_FDBUS, "true");
        }        
        if (!preferences.containsKey(PreferenceConstantsFDBus.P_GENERATE_CODE_FDBUS)) {
            preferences.put(PreferenceConstantsFDBus.P_GENERATE_CODE_FDBUS, "true");    
        }
        if (!preferences.containsKey(PreferenceConstantsFDBus.P_GENERATE_DEPENDENCIES_FDBUS)) {
            preferences.put(PreferenceConstantsFDBus.P_GENERATE_DEPENDENCIES_FDBUS, "true");    
        }
        if (!preferences.containsKey(PreferenceConstantsFDBus.P_GENERATE_SYNC_CALLS_FDBUS)) {
            preferences.put(PreferenceConstantsFDBus.P_GENERATE_SYNC_CALLS_FDBUS, "true");    
        }
    }

    public String getPreference(String preferencename, String defaultValue) {
    	
    	if (preferences.containsKey(preferencename)) {
    		return preferences.get(preferencename);
    	}
    	System.err.println("Unknown preference " + preferencename);
        return "";
    }
    
    public void setPreference(String name, String value) {
        if(preferences != null) {
        	preferences.put(name, value);
        }
    }
 
    public String getModelPath(FModel model)
    {
        String ret = model.eResource().getURI().toString();
        return ret;
    }

    /**
     * Set the output path configurations (based on stored preference values) for file system access types 
     * (instance of AbstractFileSystemAccess)
     * @return
     */
    public HashMap<String, OutputConfiguration> getOutputpathConfiguration() {
        return getOutputpathConfiguration(null);
    }

    /**
     * Set the output path configurations (based on stored preference values) for file system access types
     * (instance of AbstractFileSystemAccess)
     * @subdir the subdir to use, can be null
     * @return
     */
    public HashMap<String, OutputConfiguration> getOutputpathConfiguration(String subdir) {
        String defaultDir = getPreference(PreferenceConstantsFDBus.P_OUTPUT_DEFAULT_FDBUS, PreferenceConstantsFDBus.DEFAULT_OUTPUT_FDBUS);
        String commonDir = getPreference(PreferenceConstantsFDBus.P_OUTPUT_COMMON_FDBUS, defaultDir);
        String outputProxyDir = getPreference(PreferenceConstantsFDBus.P_OUTPUT_PROXIES_FDBUS, defaultDir);
        String outputStubDir = getPreference(PreferenceConstantsFDBus.P_OUTPUT_STUBS_FDBUS, defaultDir);

        if (null != subdir && getPreference(PreferenceConstantsFDBus.P_OUTPUT_SUBDIRS_FDBUS, "false").equals("true")) {
            defaultDir = new File(defaultDir, subdir).getPath();
            commonDir = new File(commonDir, subdir).getPath();
            outputProxyDir = new File(outputProxyDir, subdir).getPath();
            outputStubDir = new File(outputStubDir, subdir).getPath();
        }

        HashMap<String, OutputConfiguration>  outputs = new HashMap<String, OutputConfiguration> ();

        OutputConfiguration commonOutput = new OutputConfiguration(PreferenceConstantsFDBus.P_OUTPUT_COMMON_FDBUS);
        commonOutput.setDescription("Common Output Folder");
        commonOutput.setOutputDirectory(commonDir);
        commonOutput.setCreateOutputDirectory(true);
        outputs.put(IFileSystemAccess.DEFAULT_OUTPUT, commonOutput);
        
        OutputConfiguration proxyOutput = new OutputConfiguration(PreferenceConstantsFDBus.P_OUTPUT_PROXIES_FDBUS);
        proxyOutput.setDescription("Proxy Output Folder");
        proxyOutput.setOutputDirectory(outputProxyDir);
        proxyOutput.setCreateOutputDirectory(true);
        outputs.put(PreferenceConstantsFDBus.P_OUTPUT_PROXIES_FDBUS, proxyOutput);
        
        OutputConfiguration stubOutput = new OutputConfiguration(PreferenceConstantsFDBus.P_OUTPUT_STUBS_FDBUS);
        stubOutput.setDescription("Stub Output Folder");
        stubOutput.setOutputDirectory(outputStubDir);
        stubOutput.setCreateOutputDirectory(true);
        outputs.put(PreferenceConstantsFDBus.P_OUTPUT_STUBS_FDBUS, stubOutput);
        
        return outputs;
    }
    
}
