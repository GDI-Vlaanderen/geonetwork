package org.fao.geonet.services;

import java.io.File;
import java.sql.SQLException;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import jeeves.exceptions.MissingParameterEx;
import jeeves.resources.dbms.Dbms;
import jeeves.server.context.ServiceContext;
import jeeves.utils.Util;
import jeeves.utils.Xml;

import org.apache.commons.lang.StringUtils;
import org.fao.geonet.GeonetContext;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.constants.Geonet.Settings;
import org.fao.geonet.constants.Params;
import org.fao.geonet.kernel.AccessManager;
import org.fao.geonet.kernel.DataManager;
import org.fao.geonet.kernel.setting.SettingManager;
import org.fao.geonet.util.MailSender;
import org.jdom.Element;

public class Utils {

	/**
	 * Search for a UUID or an internal identifier parameter and return an
	 * internal identifier using default UUID and identifier parameter names
	 * (ie. uuid and id).
	 * 
	 * @param params
	 *            The params to search ids in
	 * @param context
	 *            The service context
	 * @param uuidParamName		UUID parameter name
	 * @param uuidParamName		Id parameter name
	 *  
	 * @return
	 * @throws Exception
	 */
	public static String getIdentifierFromParameters(Element params,
			ServiceContext context, String uuidParamName, String idParamName)
			throws Exception {

		// the metadata ID
		String id;
		GeonetContext gc = (GeonetContext) context
				.getHandlerContext(Geonet.CONTEXT_NAME);
		DataManager dm = gc.getDataManager();

		// does the request contain a UUID ?
		try {
			String uuid = Util.getParam(params, uuidParamName);
			// lookup ID by UUID
            Dbms dbms = (Dbms) context.getResourceManager().open(Geonet.Res.MAIN_DB);
			id = dm.getMetadataId(dbms, uuid);
		}
        catch (MissingParameterEx x) {
			// request does not contain UUID; use ID from request
			try {
				id = Util.getParam(params, idParamName);
			} catch (MissingParameterEx xx) {
				// request does not contain ID
				// give up
				throw new Exception("Request must contain a UUID ("
						+ uuidParamName + ") or an ID (" + idParamName + ")");
			}
		}
		return id;
	}

	/**
	 * Search for a UUID or an internal identifier parameter and return an
	 * internal identifier using default UUID and identifier parameter names
	 * (ie. uuid and id).
	 * 
	 * @param params
	 *            The params to search ids in
	 * @param context
	 *            The service context
	 * @return
	 * @throws Exception
	 */
	public static String getIdentifierFromParameters(Element params,
			ServiceContext context) throws Exception {
		return getIdentifierFromParameters(params, context, Params.UUID, Params.ID);
	}

	public static Element getNewRootElement(ServiceContext context, Dbms dbms, String status, String changeMessage, String userId) throws SQLException {
		Element root = new Element("root");
		addUserContent(dbms, root, userId, "user", "group");
		root.addContent(new Element("node").setText(context.getServlet().getNodeType().toLowerCase()));
		root.addContent(new Element("siteUrl").setText(getContextUrl(context)));
		root.addContent(new Element("metadatacenter").setText(context.getServlet().getFromDescription()));
		root.addContent(new Element("status").setText(status));
		root.addContent(new Element("changeMessage").setText(changeMessage));
		return root;
	}

	public static void addUserContent(Dbms dbms, Element root, String userId, String userElementName, String groupElementName) throws SQLException {
		List<Element> userList = dbms.select("SELECT surname, name FROM Users WHERE id = '" + userId + "'").getChildren();
		Element user = (Element) userList.get(0);
		user.detach();
		user.setName(userElementName);
		root.addContent(user);
		List<Element> groupList = dbms.select("SELECT description FROM groups as g, usergroups as ug WHERE ug.userid = '" + userId + "' AND ug.groupid = g.id").getChildren();
		for (Element group : groupList) {
			root.addContent(new Element(groupElementName).setText(group.getChildText("description")));
		}		
	}

	public static String buildMetadataLink(ServiceContext context, String metadataUUID) {
		return getContextUrl(context)
				+ "/apps/tabsearch/index.html?uuid=" + metadataUUID + "&external=true";
	}

	public static String getContextUrl(ServiceContext context) {
		GeonetContext gc = (GeonetContext) context
				.getHandlerContext(Geonet.CONTEXT_NAME);
		String protocol = gc.getSettingManager().getValue(
				Geonet.Settings.SERVER_PROTOCOL);
		String host = gc.getSettingManager().getValue(
				Geonet.Settings.SERVER_HOST);
		String port = gc.getSettingManager().getValue(
				Geonet.Settings.SERVER_PORT);
		return /*protocol + */"https://" + host + ((port.equals("80") || port.equals("443")) ? "" : ":" + port)
				+ context.getBaseUrl();
	}

	public static void sendEmail(ServiceContext context, String sendTo, String replyTo, String replyToDescr, Element params)
			throws Exception {
		GeonetContext gc = (GeonetContext) context
				.getHandlerContext(Geonet.CONTEXT_NAME);
		SettingManager sm = gc.getSettingManager();
		AccessManager am = gc.getAccessManager();

		String host = sm.getValue(Settings.SYSTEM_FEEDBACK_MAILSERVER_HOST);
		String port = sm.getValue(Settings.SYSTEM_FEEDBACK_MAILSERVER_PORT);
		String from = sm.getValue(Settings.SYSTEM_FEEDBACK_EMAIL);
		boolean emailNotes = true;

		if (host.length() == 0) {
			context.error("Mail server host not configured, email notifications won't be sent.");
			emailNotes = false;
		}

		if (port.length() == 0) {
			context.error("Mail server port not configured, email notifications won't be sent.");
			emailNotes = false;
		}

		if (from.length() == 0) {
			context.error("Mail feedback address not configured, email notifications won't be sent.");
			emailNotes = false;
		}

		if (!emailNotes) {
			context.info("Would send email with message grablock service but no email server configured");
		} else {
			String fromDescr = context.getServlet().getFromDescription();
			String styleSheet = context.getAppPath() + 	File.separator + Geonet.Path.STYLESHEETS + File.separator + Geonet.File.STATUS_CHANGE_EMAIL;
			Element emailElement = Xml.transform(params, styleSheet);
			MailSender sender = new MailSender(context);
			sender.sendWithReplyTo(sm, from,
					fromDescr, sendTo, null, replyTo, replyToDescr, emailElement.getChildText("subject"),
					emailElement.getChildText("message"));
		}
	}

	/**
	 * Process the users and metadata records for emailing notices.
	 *
	 * @param context
	 *            The service context
	 * @param dbms
	 *            The dbms
	 * @param replyTo
	 *            The replyTo email
	 * @param replyToDescr
	 *            The replyTo description configured in the web.xml
	 * @param records
	 *            The selected set of records
	 * @param subject
	 *            Subject to be used for email notices
	 * @param status
	 *            The status being set
	 * @param changeDate
	 *            Datestamp of status change
	 */
	@SuppressWarnings("unchecked")
	public static void processList(ServiceContext context, Dbms dbms, String replyTo, String replyToDescr, Element contentUsers, String subject, String status,
			String changeDate, String changeMessage, Map<String,Map<String,String>> metadataMap, List<String> emailMetadataIdList)
			throws Exception {
		Set<String> metadataIds = new HashSet<String>();
		String currentUserId = null;
		String userId = null;
		String currentEmail = null;
		List<Element> records = contentUsers.getChildren();
		Iterator<Element> recordsIterator = records.iterator();
		Element root = null;
		Element metadata = null;
		while(recordsIterator.hasNext()) {
			Element record = recordsIterator.next();
			String metadataId = record.getChildText("metadataid");
			String metadataUUID = record.getChildText("metadatauuid");
			userId = record.getChildText("userid");
			if (currentUserId==null) {
				currentUserId = userId;
				currentEmail = record.getChildText("email");
				if (currentEmail!=null) {
					currentEmail = currentEmail.toLowerCase();
				}
				root = getNewRootElement(context, dbms, status, changeMessage, context.getUserSession().getUserId());
			} else if (!currentUserId.equals(userId)) {
				if (StringUtils.isNotBlank(currentEmail) && metadataIds.size()>0) {
					sendEmail(context, currentEmail, replyTo, replyToDescr, root);
					metadataIds.clear();
				}
				currentUserId = userId;
				currentEmail = record.getChildText("email");
				if (currentEmail!=null) {
					currentEmail = currentEmail.toLowerCase();
				}
				root = getNewRootElement(context, dbms, status, changeMessage, context.getUserSession().getUserId());
			}
			if (StringUtils.isNotBlank(currentEmail) && !emailMetadataIdList.contains(currentEmail + "_" + metadataId)) {
				emailMetadataIdList.add(currentEmail + "_" + metadataId);
				metadataIds.add(metadataId);
				metadata = new Element("metadata");
				root.addContent(metadata);
				metadata.addContent(new Element("url").setText(buildMetadataLink(context, metadataUUID)));
				metadata.addContent(new Element("title").setText(metadataMap.get(metadataUUID).get("title").toString()));
				metadata.addContent(new Element("currentStatus").setText(metadataMap.get(metadataUUID).get("currentStatus").toString()));
				if (metadataMap.get(metadataUUID).get("previousStatus")!=null) {
					metadata.addContent(new Element("previousStatus").setText(metadataMap.get(metadataUUID).get("previousStatus").toString()));
				}
			}
		}

		if (StringUtils.isNotBlank(currentEmail) && metadataIds.size()>0) {
			sendEmail(context, currentEmail, replyTo, replyToDescr, root);
		}
	}

}
