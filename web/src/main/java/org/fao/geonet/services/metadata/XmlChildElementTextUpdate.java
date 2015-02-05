//=============================================================================
//===	Copyright (C) 2001-2007 Food and Agriculture Organization of the
//===	United Nations (FAO-UN), United Nations World Food Programme (WFP)
//===	and United Nations Environment Programme (UNEP)
//===
//===	This program is free software; you can redistribute it and/or modify
//===	it under the terms of the GNU General Public License as published by
//===	the Free Software Foundation; either version 2 of the License, or (at
//===	your option) any later version.
//===
//===	This program is distributed in the hope that it will be useful, but
//===	WITHOUT ANY WARRANTY; without even the implied warranty of
//===	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
//===	General Public License for more details.
//===
//===	You should have received a copy of the GNU General Public License
//===	along with this program; if not, write to the Free Software
//===	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
//===
//===	Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
//===	Rome - Italy. email: geonetwork@osgeo.org
//==============================================================================

package org.fao.geonet.services.metadata;

import java.util.ArrayList;
import java.util.List;

import jeeves.constants.Jeeves;
import jeeves.interfaces.Service;
import jeeves.resources.dbms.Dbms;
import jeeves.server.ServiceConfig;
import jeeves.server.context.ServiceContext;
import jeeves.utils.Util;
import jeeves.utils.Xml;

import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.lang.StringUtils;
import org.fao.geonet.GeonetContext;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.constants.Params;
import org.fao.geonet.kernel.DataManager;
import org.jdom.Element;
import org.jdom.Namespace;

//=============================================================================

/**
 * Inserts a new metadata to the system (data is validated)
 */

public class XmlChildElementTextUpdate implements Service {
	// --------------------------------------------------------------------------
	// ---
	// --- Init
	// ---
	// --------------------------------------------------------------------------

	private String stylePath;

	public void init(String appPath, ServiceConfig params) throws Exception {
		this.stylePath = appPath + Geonet.Path.UPDATE_STYLESHEETS;
	}

	// --------------------------------------------------------------------------
	// ---
	// --- Service
	// ---
	// --------------------------------------------------------------------------

	public Element exec(Element params, ServiceContext context)
			throws Exception {
		Element response = new Element(Jeeves.Elem.RESPONSE);
		Element modifiedRecords = new Element("modified");
		response.addContent(modifiedRecords);
		Element unchangedRecords = new Element("unchanged");
		response.addContent(unchangedRecords);
		Element unchangedByErrorRecords = new Element("unchangedbyerror");
		response.addContent(unchangedByErrorRecords);
		Element lockedbyRecords = new Element("lockedby");
		response.addContent(lockedbyRecords);
		String scope = Util.getParam(params, "scope", "0");
		String executeType = Util.getParam(params, "executeType", "0");
		String childTextValue = Util.getParam(params, "childTextValue", "");
		String xpathExpression = Util.getParam(params, "xpathExpression", "");
		String styleSheet = Util.getParam(params, Params.STYLESHEET, "");
		String uuids = Util.getParam(params, "uuids", "");
		List<Element> userGroups = params.getChildren(Params.GROUPS);

		String xslChoice = Util.getParam(params, "xslChoice", "");
		String filterChoice = Util.getParam(params, "filterChoice", "");
		boolean bProceed = false;
		if (!StringUtils.isBlank(scope)) {
			switch (Integer.parseInt(scope)) {
			case 0:
			case 1:
				bProceed = true;
				break;
			default:
				break;
			}
		}
		if (bProceed && !StringUtils.isBlank(executeType)) {
			bProceed = false;
			switch (Integer.parseInt(executeType)) {
			case 0:
			case 1:
				bProceed = true;
				break;
			default:
				break;
			}
		}
		if (bProceed && !StringUtils.isBlank(filterChoice)) {
			bProceed = false;
			switch (Integer.parseInt(filterChoice)) {
			case 1:
				if (!StringUtils.isBlank(uuids)) {
					bProceed = true;
				}
				break;
			case 2:
				if (userGroups != null && userGroups.size() > 0) {
					bProceed = true;
				}
				break;
			case 3:
				bProceed = true;
				break;
			default:
				break;
			}
		}
		if (bProceed && !StringUtils.isBlank(xslChoice)) {
			bProceed = false;
			switch (Integer.parseInt(xslChoice)) {
			case 1:
				if (!StringUtils.isBlank(xpathExpression)
						&& !StringUtils.isBlank(childTextValue)) {
					bProceed = true;
				}
				break;
			case 2:
				if (!StringUtils.isBlank(styleSheet)) {
					bProceed = true;
				}
				break;
			default:
				break;
			}
		}
		if (bProceed) {
			GeonetContext gc = (GeonetContext) context
					.getHandlerContext(Geonet.CONTEXT_NAME);
			DataManager dm = gc.getDataManager();
			Dbms dbms = (Dbms) context.getResourceManager().open(
					Geonet.Res.MAIN_DB);
			List<String> uuidList = new ArrayList<String>();
			String whereClause = getWhereClause(uuidList, filterChoice, uuids,
					userGroups);
			String[] tableNames = { "Metadata", "Workspace" };
			Element result = dbms
					.select("SELECT id, schemaid, uuid, lockedby FROM "
							+ tableNames[Integer.parseInt(scope)] + whereClause
							+ " ORDER BY id ASC");
			for (int i = 0; i < result.getContentSize(); i++) {
				Element record = (Element) result.getContent(i);
				String id = record.getChildText("id");
				String uuid = record.getChildText("uuid");
				String lockedby = record.getChildText("lockedby");
				if (!StringUtils.isBlank(lockedby)/* && scope.equals("0")*/) {
					lockedbyRecords.addContent(new Element(Params.UUID)
							.setText(uuid));
				}
				try {
					Element md = (scope.equals("0") ? dm.getMetadataNoInfo(
							context, id) : dm.getMetadataFromWorkspaceNoInfo(
							context, id));
					if (md == null) {
						continue;
					}
					md.detach();
					boolean isModified = false;
					if (xslChoice.equals("1")) {
						isModified = modifyByXPathExpression(context, dm, dbms,
								modifiedRecords, md, id, uuid, xpathExpression,
								childTextValue, scope, executeType);
					}
					if (xslChoice.equals("2")) {
						isModified = modifyByStyleSheet(context, dm, dbms,
								modifiedRecords, md, id, uuid, styleSheet,
								scope, executeType);
					}
					if (!isModified) {
						unchangedRecords.addContent(new Element(Params.UUID)
								.setText(uuid));
					}
				} catch (Exception e) {
					unchangedByErrorRecords.addContent(new Element(Params.UUID)
							.setText(uuid));
				}
				if (uuidList != null) {
					uuidList.remove(uuid);
				}
			}
			if (uuidList != null) {
				for (String uuid : uuidList) {
					unchangedRecords.addContent(new Element(Params.UUID)
							.setText(uuid + " (niet gevonden uuid of uuid van een geharvest metadata record)"));
				}
			}
		}
		return response;
	}

	private String getWhereClause(List<String> uuidList, String filterChoice,
			String uuids, List<Element> userGroups) {
		String whereClause = " where not (isharvested='y') and istemplate='n' and schemaid = 'iso19139'";
		int filter = Integer.parseInt(filterChoice);
		switch (filter) {
		case 1:
			uuids = uuids.replaceAll("\\s+", "");
			if (!StringUtils.isBlank(uuids)) {
				whereClause += " and uuid in ('"
						+ uuids.replaceAll("\'", "").replaceAll(",", "\',\'")
						+ "')";
				CollectionUtils.addAll(uuidList, uuids.split(","));
			}
			break;
		case 2:
			List<String> groupIdList = new ArrayList<String>();
			for (Element group : userGroups) {
				groupIdList.add(group.getText());
			}
			whereClause += " and id in (select metadataid from operationallowed where groupid in ('"
					+ StringUtils.join(groupIdList, "','")
					+ "') and operationid = '2')";
			break;
		case 3:
			break;
		}
		return whereClause;
	}

	private boolean modifyByXPathExpression(ServiceContext context,
			DataManager dm, Dbms dbms, Element modifiedRecords, Element md,
			String id, String uuid, String xpathExpression,
			String childTextValue, String scope, String executeType)
			throws Exception {
		List<Namespace> nss = new ArrayList<Namespace>();
		nss.addAll(md.getAdditionalNamespaces());
		nss.add(md.getNamespace());
		List<?> objectList = Xml.selectNodes(md, xpathExpression, nss);
		int count = 0;
		for (Object o : objectList) {
			if (o != null && o instanceof Element) {
				String oldChildTextValue = ((Element) o).getText();
				((Element) o).setText(childTextValue);
				if (!childTextValue.equals(oldChildTextValue)) {
					count++;
				}
			}
		}
		if (count>0) {
			if (executeType.equals("1")) {
				updateMetadata(context, dm, dbms, md, id, uuid, scope);
			}
			modifiedRecords.addContent(new Element(Params.UUID)
			.setText(uuid + " (" + count + " vervanging(en))"));
		}
		return count > 0;
	}

	private boolean modifyByStyleSheet(ServiceContext context, DataManager dm,
			Dbms dbms, Element modifiedRecords, Element md, String id,
			String uuid, String styleSheet, String scope, String executeType)
			throws Exception {
		boolean isModified = false;
		int oldLength = Xml.getString(md).length();
		md = Xml.transform(md, stylePath + "/" + styleSheet);
		int newLength = Xml.getString(md).length();
		if (newLength != oldLength) {
			if (executeType.equals("1")) {
				updateMetadata(context, dm, dbms, md, id, uuid, scope);
			}
			isModified = true;
			modifiedRecords.addContent(new Element(Params.UUID).setText(uuid
					+ " (Aantal bytes gewijzigd van " + oldLength + " naar "
					+ newLength + ")"));
		}
		return isModified;
	}

	private void updateMetadata(ServiceContext context, DataManager dm,
			Dbms dbms, Element md, String id, String uuid, String scope)
			throws Exception {
		System.out.println("Updating record with uuid" + uuid);
		if (scope.equals("0")) {
			dm.getXmlSerializer().update(dbms, id, md, null, false, context);
		} else {
			dm.getXmlSerializer().updateWorkspace(dbms, id, md, null, false,
					context, null, false);
		}
		dbms.commit();
		dm.indexInThreadPoolIfPossible(dbms, id, scope.equals("1"));
		System.out.println("Updated");
	}
}

// =============================================================================

