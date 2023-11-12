/* Copyright (C) 2015-2020 Bayerische Motoren Werke Aktiengesellschaft (BMW AG)
   This Source Code Form is subject to the terms of the Mozilla Public
   License, v. 2.0. If a copy of the MPL was not distributed with this
   file, You can obtain one at http://mozilla.org/MPL/2.0/. */
package org.genivi.commonapi.fdbus.deployment;

import java.util.List;

import org.eclipse.emf.ecore.EObject;
import org.franca.core.franca.FArgument;
import org.franca.core.franca.FArrayType;
import org.franca.core.franca.FAttribute;
import org.franca.core.franca.FBroadcast;
import org.franca.core.franca.FEnumerationType;
import org.franca.core.franca.FField;
import org.franca.core.franca.FInterface;
import org.franca.core.franca.FMethod;
import org.franca.core.franca.FStructType;
import org.franca.core.franca.FUnionType;
import org.franca.deploymodel.core.FDeployedInterface;
import org.franca.deploymodel.ext.providers.FDeployedProvider;
import org.franca.deploymodel.core.FDeployedTypeCollection;
import org.franca.deploymodel.dsl.fDeploy.FDExtensionElement;
import org.genivi.commonapi.fdbus.Deployment;

public class PropertyAccessor extends org.genivi.commonapi.core.deployment.PropertyAccessor
{
	public enum FDBusStringEncoding {
		utf8, utf16le, utf16be
	}

	Deployment.IDataPropertyAccessor fdbusDataAccessor_;
	Deployment.ProviderPropertyAccessor fdbusProvider_;

	PropertyAccessor parent_;
	String name_;

	public PropertyAccessor() {
		super();
		fdbusDataAccessor_ = null;
		fdbusProvider_ = null;
		parent_ = null;
		name_ = null;
	}

	public PropertyAccessor(FDeployedInterface _target) {
		super(_target);
		fdbusDataAccessor_ = new Deployment.InterfacePropertyAccessor(_target);
		fdbusProvider_ = null;
		parent_ = null;
		name_ = null;
	}

	public PropertyAccessor(FDeployedTypeCollection _target) {
		super(_target);
		fdbusDataAccessor_ = new Deployment.TypeCollectionPropertyAccessor(_target);
		fdbusProvider_ = null;
		parent_ = null;
		name_ = null;
	}

	public PropertyAccessor(FDeployedProvider _target) {
		super(_target);
		fdbusProvider_ = new Deployment.ProviderPropertyAccessor(_target);
		parent_ = null;
		fdbusDataAccessor_ = null;
		name_ = null;
	}

	public String getName() {
		if (name_ == null)
			return "";
		return name_;
	}

	private void setName(FField _element) {
		String containername = "";
		if (_element.eContainer() instanceof FStructType)
			containername = ((FStructType)(_element.eContainer())).getName() + "_";
		if (_element.eContainer() instanceof FUnionType)
			containername = ((FUnionType)(_element.eContainer())).getName() + "_";
		String parentname = parent_.name_;
		if (parentname != null) {
			name_ = parentname + containername + _element.getName() + "_";
		}
		else
			name_ = containername + _element.getName() + "_";
		return;
	}
	private void setName(FArgument _element) {
		if (_element.eContainer() instanceof FMethod)
			name_ = ((FMethod)(_element.eContainer())).getName() + "_" + _element.getName() + "_";
		if (_element.eContainer() instanceof FBroadcast)
			name_ = ((FBroadcast)(_element.eContainer())).getName() + "_" + _element.getName() + "_";
		return;
	}
	private void setName(FAttribute _element) {
		name_ = _element.getName() + "_";
		return;
	}
	private void setName(FArrayType _element) {
		if (fdbusDataAccessor_ != parent_.fdbusDataAccessor_) {
			String parentname = parent_.getName();
			if (parentname != null) {
				name_ = parentname + _element.getName() + "_";
			}
			else
				name_ = _element.getName() + "_";
		}
		else {
			name_ = parent_.getName();
		}
		return;
	}
	public PropertyAccessor(PropertyAccessor _parent, FField _element) {
		super();
		fdbusProvider_ = null;
		if (_parent.type_ != DeploymentType.PROVIDER && _parent != null && _parent.fdbusDataAccessor_ != null) {
			fdbusDataAccessor_ = _parent.fdbusDataAccessor_.getOverwriteAccessor(_element);
			type_ = DeploymentType.OVERWRITE;
		}
		else
			fdbusDataAccessor_ = null;

		parent_ = _parent;
		setName(_element);

	}
	public PropertyAccessor(PropertyAccessor _parent, FArrayType _element) {
		super();
		fdbusProvider_ = null;
		if (_parent.type_ != DeploymentType.PROVIDER && _parent != null && _parent.fdbusDataAccessor_ != null) {
			type_ = DeploymentType.OVERWRITE;
			fdbusDataAccessor_ = _parent.fdbusDataAccessor_.getOverwriteAccessor(_element);
		}
		else
			fdbusDataAccessor_ = null;
		parent_ = _parent;
		setName(_element);
	}
	public PropertyAccessor(PropertyAccessor _parent, FArgument _element) {
		type_ = DeploymentType.OVERWRITE;
		fdbusProvider_ = null;
		if (_parent.type_ == DeploymentType.INTERFACE) {
			Deployment.InterfacePropertyAccessor ipa = (Deployment.InterfacePropertyAccessor) _parent.fdbusDataAccessor_;
			fdbusDataAccessor_ = ipa.getOverwriteAccessor(_element);
		}
		else
			fdbusDataAccessor_ = null;
		parent_ = _parent;
		setName(_element);
	}

	public PropertyAccessor(PropertyAccessor _parent, FAttribute _element) {
		type_ = DeploymentType.OVERWRITE;
		fdbusProvider_ = null;
		if (_parent.type_ == DeploymentType.INTERFACE) {
			Deployment.InterfacePropertyAccessor ipa = (Deployment.InterfacePropertyAccessor) _parent.fdbusDataAccessor_;
			fdbusDataAccessor_ = ipa.getOverwriteAccessor(_element);
		}
		else
			fdbusDataAccessor_ = null;
		parent_ = _parent;
		setName(_element);
	}

	public PropertyAccessor getParent() {
		return parent_;
	}

	public PropertyAccessor getOverwriteAccessor(EObject _object) {
		if (_object instanceof FArgument)
			return new PropertyAccessor(this, (FArgument)_object);
		if (_object instanceof FAttribute)
			return new PropertyAccessor(this, (FAttribute)_object);
		if (_object instanceof FField)
			return new PropertyAccessor(this, (FField)_object);
		if (_object instanceof FArrayType)
			return new PropertyAccessor(this, (FArrayType)_object);
		return null;
	}

	public boolean isProperOverwrite() {
		// is proper overwrite if we are overwrite and none of my parents is the same accessor
		return (type_ == DeploymentType.OVERWRITE && !hasSameAccessor(fdbusDataAccessor_));
	}
	protected boolean hasSameAccessor(Deployment.IDataPropertyAccessor _accessor)
	{
		if (parent_ == null)
			return false;
		if (parent_.fdbusDataAccessor_ == _accessor)
			return true;
		return parent_.hasSameAccessor(_accessor);
	}

	public Integer getFDBusServiceID (FInterface obj) {
		try {
			if (type_ == DeploymentType.INTERFACE) {
				Deployment.InterfacePropertyAccessor ipa = (Deployment.InterfacePropertyAccessor) fdbusDataAccessor_;
				return ipa.getFDBusServiceID(obj);
			}
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}

	public List<Integer> getFDBusEventGroups (FInterface obj) {
		try {
			if (type_ == DeploymentType.INTERFACE) {
				Deployment.InterfacePropertyAccessor ipa = (Deployment.InterfacePropertyAccessor) fdbusDataAccessor_;
				return ipa.getFDBusEventGroups(obj);
			}
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}

	public Integer getFDBusGetterID (FAttribute obj) {
		try {
			if (type_ == DeploymentType.INTERFACE) {
				Deployment.InterfacePropertyAccessor ipa = (Deployment.InterfacePropertyAccessor) fdbusDataAccessor_;
				return ipa.getFDBusGetterID(obj);
			}
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}

	public Boolean getFDBusGetterReliable (FAttribute obj) {
		try {
			if (type_ == DeploymentType.INTERFACE) {
				Deployment.InterfacePropertyAccessor ipa = (Deployment.InterfacePropertyAccessor) fdbusDataAccessor_;
				return ipa.getFDBusAttributeReliable(obj);
			}
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}

	public Integer getFDBusSetterID (FAttribute obj) {
		try {
			if (type_ == DeploymentType.INTERFACE) {
				Deployment.InterfacePropertyAccessor ipa = (Deployment.InterfacePropertyAccessor) fdbusDataAccessor_;
				return ipa.getFDBusSetterID(obj);
			}
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}

	public Boolean getFDBusSetterReliable (FAttribute obj) {
		try {
			if (type_ == DeploymentType.INTERFACE) {
				Deployment.InterfacePropertyAccessor ipa = (Deployment.InterfacePropertyAccessor) fdbusDataAccessor_;
				return ipa.getFDBusAttributeReliable(obj);
			}
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}

	public Integer getFDBusNotifierID (FAttribute obj) {
		try {
			if (type_ == DeploymentType.INTERFACE) {
				Deployment.InterfacePropertyAccessor ipa = (Deployment.InterfacePropertyAccessor) fdbusDataAccessor_;
				return ipa.getFDBusNotifierID(obj);
			}
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}

	public Boolean getFDBusNotifierReliable (FAttribute obj) {
		try {
			if (type_ == DeploymentType.INTERFACE)
				return ((Deployment.InterfacePropertyAccessor) fdbusDataAccessor_).getFDBusAttributeReliable(obj);
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}

	public List<Integer> getFDBusEventGroups (FAttribute obj) {
		try {
			if (type_ == DeploymentType.INTERFACE) {
				List<Integer> groups = ((Deployment.InterfacePropertyAccessor) fdbusDataAccessor_).getFDBusNotifierEventGroups(obj);
				if (groups == null) {
					groups = ((Deployment.InterfacePropertyAccessor) fdbusDataAccessor_).getFDBusEventGroups(obj);
				}
				return groups;
			}
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}

	public String getFDBusEndianess (FAttribute obj) {
		try {
			if (type_ == DeploymentType.INTERFACE)
				return (((Deployment.InterfacePropertyAccessor) fdbusDataAccessor_).getFDBusAttributeEndianess(obj)
						== Deployment.Enums.FDBusAttributeEndianess.le ? "true" : "false");
		}
		catch (java.lang.NullPointerException e) {}
		return "false";
	}

	public Integer getFDBusMethodID (FMethod obj) {
		try {
			if (type_ == DeploymentType.INTERFACE) {
				return ((Deployment.InterfacePropertyAccessor) fdbusDataAccessor_).getFDBusMethodID(obj);
			}
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}

	public Boolean getFDBusReliable (FMethod obj) {
		try {
			if (type_ == DeploymentType.INTERFACE)
				return ((Deployment.InterfacePropertyAccessor) fdbusDataAccessor_).getFDBusReliable(obj);
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}

	public String getFDBusEndianess (FMethod obj) {
		try {
			if (type_ == DeploymentType.INTERFACE)
				return (((Deployment.InterfacePropertyAccessor) fdbusDataAccessor_).getFDBusMethodEndianess(obj)
						== Deployment.Enums.FDBusMethodEndianess.le ? "true" : "false");
		}
		catch (java.lang.NullPointerException e) {}
		return "false";
	}

	public Integer getFDBusEventID (FBroadcast obj) {
		try {
			if (type_ == DeploymentType.INTERFACE)
				return ((Deployment.InterfacePropertyAccessor) fdbusDataAccessor_).getFDBusEventID(obj);
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}

	public Boolean getFDBusReliable (FBroadcast obj) {
		try {
			if (type_ == DeploymentType.INTERFACE)
				return ((Deployment.InterfacePropertyAccessor) fdbusDataAccessor_).getFDBusReliable(obj);
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}

	public List<Integer> getFDBusEventGroups (FBroadcast obj) {
		try {
			if (type_ == DeploymentType.INTERFACE)
				return ((Deployment.InterfacePropertyAccessor) fdbusDataAccessor_).getFDBusEventGroups(obj);
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}

	public String getFDBusEndianess (FBroadcast obj) {
		try {
			if (type_ == DeploymentType.INTERFACE)
				return (((Deployment.InterfacePropertyAccessor) fdbusDataAccessor_).getFDBusBroadcastEndianess(obj)
						== Deployment.Enums.FDBusBroadcastEndianess.le ? "true" : "false");
		}
		catch (java.lang.NullPointerException e) {}
		return "false";
	}
	public EnumBackingType getEnumBackingType (FEnumerationType obj) {
		try {
			switch (type_) {
			case OVERWRITE:
				return parent_.getEnumBackingType(obj);
			default:
				return super.getEnumBackingType(obj);
			}
		}
		catch (java.lang.NullPointerException e) {}
		return EnumBackingType.UInt8;
	}
	public Integer getFDBusArrayMinLength (FArrayType obj) {
		try {
			return fdbusDataAccessor_.getFDBusArrayMinLength(obj);
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}
	public Integer getFDBusArrayMinLength (FField obj) {
		try {
			return fdbusDataAccessor_.getFDBusArrayMinLength(obj);
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}
	public Integer getFDBusArrayMinLength (FArgument obj) {
		try {
			if (type_ == DeploymentType.INTERFACE) {
				return ((Deployment.InterfacePropertyAccessor) fdbusDataAccessor_).getFDBusArrayMinLength(obj);
			}
			if (type_ == DeploymentType.OVERWRITE) {
				return parent_.getFDBusArrayMinLength(obj);
			}
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}
	public Integer getFDBusArrayMinLength (FAttribute obj) {
		try {
			if (type_ == DeploymentType.INTERFACE) {
				return ((Deployment.InterfacePropertyAccessor) fdbusDataAccessor_).getFDBusArrayMinLength(obj);
			}
			if (type_ == DeploymentType.OVERWRITE) {
				return parent_.getFDBusArrayMinLength(obj);
			}
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}
	public Integer getFDBusArrayMaxLength (FArrayType obj) {
		try {
			return fdbusDataAccessor_.getFDBusArrayMaxLength(obj);
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}
	public Integer getFDBusArrayMaxLength (FField obj) {
		try {
			return fdbusDataAccessor_.getFDBusArrayMaxLength(obj);
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}
	public Integer getFDBusArrayMaxLength (FAttribute obj) {
		try {
			if (type_ == DeploymentType.INTERFACE) {
				return ((Deployment.InterfacePropertyAccessor) fdbusDataAccessor_).getFDBusArrayMaxLength(obj);
			}
			if (type_ == DeploymentType.OVERWRITE) {
				return parent_.getFDBusArrayMaxLength(obj);
			}
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}
	public Integer getFDBusArrayMaxLength (FArgument obj) {
		try {
			if (type_ == DeploymentType.INTERFACE) {
				return ((Deployment.InterfacePropertyAccessor) fdbusDataAccessor_).getFDBusArrayMaxLength(obj);
			}
			if (type_ == DeploymentType.OVERWRITE) {
				return parent_.getFDBusArrayMaxLength(obj);
			}
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}
	public Integer getFDBusArrayLengthWidth (FArrayType obj) {
		try {
			return fdbusDataAccessor_.getFDBusArrayLengthWidth(obj);
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}
	public Integer getFDBusArrayLengthWidth (FField obj) {
		try {
			return fdbusDataAccessor_.getFDBusArrayLengthWidth(obj);
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}
	public Integer getFDBusArrayLengthWidth (FArgument obj) {
		try {
			if (type_ == DeploymentType.INTERFACE) {
				return ((Deployment.InterfacePropertyAccessor) fdbusDataAccessor_).getFDBusArrayLengthWidth(obj);
			}
			if (type_ == DeploymentType.OVERWRITE) {
				return parent_.getFDBusArrayLengthWidth(obj);
			}
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}
	public Integer getFDBusArrayLengthWidth (FAttribute obj) {
		try {
			if (type_ == DeploymentType.INTERFACE) {
				return ((Deployment.InterfacePropertyAccessor) fdbusDataAccessor_).getFDBusArrayLengthWidth(obj);
			}
			if (type_ == DeploymentType.OVERWRITE) {
				return parent_.getFDBusArrayLengthWidth(obj);
			}
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}
	public Integer getFDBusUnionLengthWidth (FUnionType obj) {
		try {
			return fdbusDataAccessor_.getFDBusUnionLengthWidth(obj);
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}

	public Integer getFDBusUnionTypeWidth (FUnionType obj) {
		try {
			return fdbusDataAccessor_.getFDBusUnionTypeWidth(obj);
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}

	public Boolean getFDBusUnionDefaultOrder (FUnionType obj) {
		try {
			return fdbusDataAccessor_.getFDBusUnionDefaultOrder(obj);
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}

	public Integer getFDBusUnionMaxLength (FUnionType obj) {
		try {
			return fdbusDataAccessor_.getFDBusUnionMaxLength(obj);
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}

	public Integer getFDBusStructLengthWidth (FStructType obj) {
		try {
			return fdbusDataAccessor_.getFDBusStructLengthWidth(obj);
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}

	public Integer getFDBusEnumWidth (FEnumerationType obj) {
		try {
			return fdbusDataAccessor_.getFDBusEnumWidth(obj);
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}

	public Integer getFDBusEnumBitWidth (FEnumerationType obj) {
		try {
			return fdbusDataAccessor_.getFDBusEnumBitWidth(obj);
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}

	public Integer getFDBusEnumInvalidValue (FEnumerationType obj) {
		try {
			return fdbusDataAccessor_.getFDBusEnumInvalidValue(obj);
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}

	public Integer getFDBusStringLength (EObject obj) {
		try {
			return fdbusDataAccessor_.getFDBusStringLength(obj);
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}

	public Integer getFDBusByteBufferMaxLength (EObject obj) {
		try {
			return fdbusDataAccessor_.getFDBusByteBufferMaxLength(obj);
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}

	public Integer getFDBusByteBufferMinLength (EObject obj) {
		try {
			return fdbusDataAccessor_.getFDBusByteBufferMinLength(obj);
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}
	public Integer getFDBusByteBufferLengthWidth(EObject obj) {
		try {
			return fdbusDataAccessor_.getFDBusByteBufferLengthWidth(obj);
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}
	public Integer getFDBusStringLengthWidth (EObject obj) {
		try {
			return fdbusDataAccessor_.getFDBusStringLengthWidth(obj);
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}

	public FDBusStringEncoding getFDBusStringEncoding (EObject obj) {
		try {
			return from(fdbusDataAccessor_.getFDBusStringEncoding(obj));
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}

	public Integer getFDBusIntegerBitWidth (EObject obj) {
		try {
			return fdbusDataAccessor_.getFDBusIntegerBitWidth(obj);
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}
	public Integer getFDBusIntegerInvalidValue (EObject obj) {
		try {
			return fdbusDataAccessor_.getFDBusIntegerInvalidValue(obj);
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}

	public Integer getFDBusArgMapMinLength (FArgument obj) {
		try {
			if (type_ == DeploymentType.INTERFACE) {
				return ((Deployment.InterfacePropertyAccessor) fdbusDataAccessor_).getFDBusArgMapMinLength(obj);
			}
			if (type_ == DeploymentType.OVERWRITE) {
				return parent_.getFDBusArgMapMinLength(obj);
			}
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}

	public Integer getFDBusArgMapMaxLength (FArgument obj) {
		try {
			if (type_ == DeploymentType.INTERFACE) {
				return ((Deployment.InterfacePropertyAccessor) fdbusDataAccessor_).getFDBusArgMapMaxLength(obj);
			}
			if (type_ == DeploymentType.OVERWRITE) {
				return parent_.getFDBusArgMapMaxLength(obj);
			}
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}

	public Integer getFDBusArgMapLengthWidth (FArgument obj) {
		try {
			if (type_ == DeploymentType.INTERFACE) {
				return ((Deployment.InterfacePropertyAccessor) fdbusDataAccessor_).getFDBusArgMapLengthWidth(obj);
			}
			if (type_ == DeploymentType.OVERWRITE) {
				return parent_.getFDBusArgMapLengthWidth(obj);
			}
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}

	public Integer getFDBusAttrMapMinLength (FAttribute obj) {
		try {
			if (type_ == DeploymentType.INTERFACE) {
				return ((Deployment.InterfacePropertyAccessor) fdbusDataAccessor_).getFDBusAttrMapMinLength(obj);
			}
			if (type_ == DeploymentType.OVERWRITE) {
				return parent_.getFDBusAttrMapMinLength(obj);
			}
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}

	public Integer getFDBusAttrMapMaxLength (FAttribute obj) {
		try {
			if (type_ == DeploymentType.INTERFACE) {
				return ((Deployment.InterfacePropertyAccessor) fdbusDataAccessor_).getFDBusAttrMapMaxLength(obj);
			}
			if (type_ == DeploymentType.OVERWRITE) {
				return parent_.getFDBusAttrMapMaxLength(obj);
			}
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}

	public Integer getFDBusAttrMapLengthWidth (FAttribute obj) {
		try {
			if (type_ == DeploymentType.INTERFACE) {
				return ((Deployment.InterfacePropertyAccessor) fdbusDataAccessor_).getFDBusAttrMapLengthWidth(obj);
			}
			if (type_ == DeploymentType.OVERWRITE) {
				return parent_.getFDBusAttrMapLengthWidth(obj);
			}
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}

	public Integer getFDBusInstanceID (FDExtensionElement obj) {
		try {
			if (type_ == DeploymentType.PROVIDER)
				return fdbusProvider_.getFDBusInstanceID(obj);
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}

	public String getFDBusUnicastAddress (FDExtensionElement obj) {
		try {
			if (type_ == DeploymentType.PROVIDER)
				return fdbusProvider_.getFDBusUnicastAddress(obj);
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}

	public Integer getFDBusReliableUnicastPort (FDExtensionElement obj) {
		try {
			if (type_ == DeploymentType.PROVIDER)
				return fdbusProvider_.getFDBusReliableUnicastPort(obj);
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}

	public Integer getFDBusUnreliableUnicastPort (FDExtensionElement obj) {
		try {
			if (type_ == DeploymentType.PROVIDER)
				return fdbusProvider_.getFDBusUnreliableUnicastPort(obj);
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}

	public List<String> getFDBusMulticastAddresses (FDExtensionElement obj) {
		try {
			if (type_ == DeploymentType.PROVIDER)
				return fdbusProvider_.getFDBusMulticastAddresses(obj);
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}

	public List<Integer> getFDBusMulticastPorts (FDExtensionElement obj) {
		try {
			if (type_ == DeploymentType.PROVIDER)
				return fdbusProvider_.getFDBusMulticastPorts(obj);
		}
		catch (java.lang.NullPointerException e) {}
		return null;
	}

	private FDBusStringEncoding from(Deployment.Enums.FDBusStringEncoding _source) {
		if (_source != null) {
			switch (_source) {
			case utf16be:
				return FDBusStringEncoding.utf16be;
			case utf16le:
				return FDBusStringEncoding.utf16le;
			default:
				return FDBusStringEncoding.utf8;
			}
		}
		return FDBusStringEncoding.utf8;
	}
}
