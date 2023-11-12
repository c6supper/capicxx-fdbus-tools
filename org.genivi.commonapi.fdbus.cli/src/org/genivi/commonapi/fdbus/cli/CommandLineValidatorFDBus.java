/* Copyright (C) 2014-2020 Calvin Ke, All rights reserved
   This Source Code Form is subject to the terms of the Mozilla Public
   License, v. 2.0. If a copy of the MPL was not distributed with this
   file, You can obtain one at http://mozilla.org/MPL/2.0/. */
package org.genivi.commonapi.fdbus.cli;

import java.util.List;

import org.eclipse.emf.common.util.BasicDiagnostic;
import org.eclipse.emf.common.util.Diagnostic;
import org.eclipse.emf.common.util.URI;
import org.eclipse.xtext.validation.ValidationMessageAcceptor;
import org.franca.deploymodel.dsl.fDeploy.FDModel;
import org.genivi.commonapi.core.verification.CommandlineValidator;
import org.genivi.commonapi.core.verification.DeploymentValidator;
import org.genivi.commonapi.fdbus.deployment.validator.FDBusDeploymentValidator;

public class CommandLineValidatorFDBus extends CommandlineValidator
{
    public CommandLineValidatorFDBus(ValidationMessageAcceptor cliMessageAcceptor)
    {
        super(cliMessageAcceptor);
    }

    @Override
    public boolean validateDeployment(URI resourcePathUri)
    {
        addIgnoreString("Unable to resolve plug-in \"platform:/plugin/org.genivi.commonapi.dbus/deployment/CommonAPI-DBus_deployment_spec.fdepl\"");
        addIgnoreString("Unable to resolve plug-in \"platform:/plugin/org.genivi.commonapi.dbus/deployment/CommonAPI-4-DBus_deployment_spec.fdepl\"");
        addIgnoreString("Couldn't resolve reference to FDSpecification 'org.genivi.commonapi.dbus.deployment'");
        addIgnoreString("Couldn't resolve reference to FDPropertyDecl");
        addIgnoreString("Couldn't resolve reference to EObject 'system'");
        addIgnoreString("Couldn't resolve reference to EObject 'session'");
        return super.validateDeployment(resourcePathUri);
    }

    @Override
    protected List<Diagnostic> validateDeployment(List<FDModel> fdepls)
    {
        BasicDiagnostic diagnostics = new BasicDiagnostic();
        FDBusDeploymentValidator validator = new FDBusDeploymentValidator();
        validator.validate(fdepls, diagnostics);
        DeploymentValidator coreValidator = new DeploymentValidator();
        coreValidator.validate(fdepls, diagnostics);
        return diagnostics.getChildren();
    }
}
