/* Copyright (C) 2014-2020 Calvin Ke, All rights reserved
   This Source Code Form is subject to the terms of the Mozilla Public
   License, v. 2.0. If a copy of the MPL was not distributed with this
   file, You can obtain one at http://mozilla.org/MPL/2.0/. */
package org.genivi.commonapi.fdbus.validator;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.emf.common.util.BasicDiagnostic;
import org.eclipse.emf.common.util.Diagnostic;
import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.xtext.validation.FeatureBasedDiagnostic;
import org.eclipse.xtext.validation.ValidationMessageAcceptor;
import org.franca.deploymodel.dsl.fDeploy.FDModel;
import org.franca.deploymodel.dsl.validation.IFDeployExternalValidator;
import org.genivi.commonapi.fdbus.deployment.validator.FDBusDeploymentValidator;
import org.genivi.commonapi.fdbus.preferences.PreferenceConstantsFDBus;
// cli should be fine, don't support UI yet.
// import org.genivi.commonapi.fdbus.ui.CommonApiFDBusUiPlugin;

public class DeploymentValidatorFDBus implements IFDeployExternalValidator {

	@Override
	public void validateModel(FDModel fdepl, ValidationMessageAcceptor messageAcceptor) {
		try {
			if (!isDeploymentValidatorEnabled())
			{
				return;
			}
			List<FDModel> modelList = new ArrayList<FDModel>();
			modelList.add(fdepl);
			FDBusDeploymentValidator validator = new FDBusDeploymentValidator();
			BasicDiagnostic diagnostics = new BasicDiagnostic();
			validator.validate(modelList, diagnostics);
			// copy the diagnostics to the message acceptor
			for (Diagnostic diagnostic: diagnostics.getChildren() ) {
				if (diagnostic instanceof FeatureBasedDiagnostic) {
					FeatureBasedDiagnostic fd = (FeatureBasedDiagnostic) diagnostic;
					int severity = fd.getSeverity();
					if (severity == Diagnostic.WARNING) {
						messageAcceptor.acceptWarning(fd.getMessage(), fd.getSourceEObject(), fd.getFeature(), -1, fd.getIssueCode(), fd.getIssueData());
					}
					if (severity == Diagnostic.ERROR) {
						messageAcceptor.acceptError(fd.getMessage(), fd.getSourceEObject(), fd.getFeature(), -1, fd.getIssueCode(), fd.getIssueData());
					}
					if (severity == Diagnostic.INFO) {
						messageAcceptor.acceptInfo(fd.getMessage(), fd.getSourceEObject(), fd.getFeature(), -1, fd.getIssueCode(), fd.getIssueData());
					}
				}
			}
		}
		catch (Exception ex) {
			ex.printStackTrace();
			throw ex;
		}
	}

	public boolean isDeploymentValidatorEnabled()
	{
		// cli should be fine, don't support UI yet.
		// IPreferenceStore prefs = CommonApiFDBusUiPlugin.getValidatorPreferences();
		// return prefs != null && prefs.getBoolean(PreferenceConstantsFDBus.P_ENABLE_FDBUS_DEPLOYMENT_VALIDATOR);
		return false;
	}
}
