//=============================================================================
//===   Copyright (C) 2001-2007 Food and Agriculture Organization of the
//===   United Nations (FAO-UN), United Nations World Food Programme (WFP)
//===   and United Nations Environment Programme (UNEP)
//===
//===   This program is free software; you can redistribute it and/or modify
//===   it under the terms of the GNU General Public License as published by
//===   the Free Software Foundation; either version 2 of the License, or (at
//===   your option) any later version.
//===
//===   This program is distributed in the hope that it will be useful, but
//===   WITHOUT ANY WARRANTY; without even the implied warranty of
//===   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
//===   General Public License for more details.
//===
//===   You should have received a copy of the GNU General Public License
//===   along with this program; if not, write to the Free Software
//===   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
//===
//===   Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
//===   Rome - Italy. email: geonetwork@osgeo.org
//==============================================================================

package org.fao.geonet.util;

import java.util.ArrayList;
import java.util.List;
import java.util.Properties;

import javax.mail.Session;
import javax.mail.internet.InternetAddress;

import jeeves.interfaces.Logger;
import jeeves.server.context.ServiceContext;
import jeeves.utils.Util;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.mail.DefaultAuthenticator;
import org.apache.commons.mail.EmailException;
import org.apache.commons.mail.SimpleEmail;
import org.fao.geonet.constants.Geonet.Settings;
import org.fao.geonet.kernel.setting.SettingManager;

public class MailSender extends Thread
{
	Logger      _logger;
	SimpleEmail _mail;

	public MailSender(ServiceContext context)
	{
		_logger = context.getLogger();
	}

	public void send(SettingManager settings, String from, String fromDescr, String to, String toDescr, String subject, String message)
	{
		_mail = new SimpleEmail();
		configureBasics(settings);
		try
		{
			_mail.setFrom(from, fromDescr);
			_mail.addTo(to);
			_mail.setSubject(subject);
			_mail.setCharset("utf-8");
			_mail.setMsg(message);
			start();
		}
		catch(EmailException e)
		{
			logEx(e);
		}
	}

	public void sendWithReplyTo(SettingManager settings, String from, String fromDescr, String to, String toDescr, String replyTo, String replyToDesc, String subject, String message)
	{
		_mail = new SimpleEmail();
		
		configureBasics(settings);
		try
		{
			_mail.setFrom(from, fromDescr);
			_mail.addTo(to);
			_mail.setSubject(subject);
			_mail.setCharset("utf-8");
			_mail.setMsg(message);
			List<InternetAddress> addressColl = new ArrayList<InternetAddress>();
			addressColl.add(new InternetAddress(replyTo, replyToDesc));
			_mail.setReplyTo(addressColl);

			start();
		}
		catch(Exception e)
		{
			logEx(e);
		}
	}

	public void run()
	{
		try
		{
			_mail.send();

			_logger.info("Mail sent");
		}
		catch(EmailException e)
		{
			logEx(e);
		}
	}

	private void logEx(Exception e)
	{
		_logger.error("Unable to mail feedback");
		_logger.error("  Exception : " + e);
		_logger.error("  Message   : " + e.getMessage());
		_logger.error("  Stack     : " + Util.getStackTrace(e));
	}
    /**
     * Create data information to compose the mail
     *
     * @param hostName
     * @param smtpPort
     * @param from
     * @param username
     * @param password
     * @param email
     * @param ssl
     * @param tls
     * @param ignoreSslCertificateErrors
     */
    private void configureBasics(String hostName, Integer smtpPort,
                                        String from, String username, String password, Boolean ssl,
                                        Boolean tls, Boolean ignoreSslCertificateErrors) {
        if (hostName != null) {
            _mail.setHostName(hostName);
        } else {
            throw new IllegalArgumentException(
                "Missing settings in System Configuration (see Administration menu) - cannot send mail");
        }
        if (StringUtils.isNotBlank(smtpPort + "")) {
        	_mail.setSmtpPort(smtpPort);
        } else {
            throw new IllegalArgumentException(
                "Missing settings in System Configuration (see Administration menu) - cannot send mail");
        }
        if (username != null) {
            _mail.setAuthenticator(new DefaultAuthenticator(username, password));
        }
        if (tls != null && tls) {
            _mail.setTLS(tls);
        }

        if (ssl != null && ssl) {
            _mail.setSSL(ssl);
            if (StringUtils.isNotBlank(smtpPort + "")) {
                _mail.setSslSmtpPort(smtpPort + "");
            }
        }

        if (ignoreSslCertificateErrors != null && ignoreSslCertificateErrors) {
            try {
                Session mailSession = _mail.getMailSession();
                Properties p = mailSession.getProperties();
                p.setProperty("mail.smtp.ssl.trust", "*");

            } catch (EmailException e) {
                // Ignore the exception. Can't be reached because the host name is always set above or an
                // IllegalArgumentException is thrown.
            }
        }

        if (StringUtils.isNotBlank(from)) {
            try {
                _mail.setFrom(from);
            } catch (EmailException e) {
                throw new IllegalArgumentException(
                    "Invalid 'from' email setting in System Configuration (see Administration menu) - cannot send " +
                        "mail", e);
            }
        } else {
            throw new IllegalArgumentException(
                "Missing settings in System Configuration (see Administration menu) - cannot send mail");
        }
    }

    /**
     * Configure the basics (hostname, port, username, password,...)
     *
     * @param settings
     * @param email
     */
    private void configureBasics(SettingManager settings) {
		String username = settings
            .getValue(Settings.SYSTEM_FEEDBACK_MAILSERVER_USERNAME);
        String password = settings
            .getValue(Settings.SYSTEM_FEEDBACK_MAILSERVER_PASSWORD);
        Boolean ssl = settings
            .getValueAsBool(Settings.SYSTEM_FEEDBACK_MAILSERVER_SSL, false);
        Boolean tls = settings
            .getValueAsBool(Settings.SYSTEM_FEEDBACK_MAILSERVER_TLS, false);

        String hostName = settings.getValue(Settings.SYSTEM_FEEDBACK_MAILSERVER_HOST);
        Integer smtpPort = Integer.valueOf(settings
            .getValue(Settings.SYSTEM_FEEDBACK_MAILSERVER_PORT));

        String from = settings.getValue(Settings.SYSTEM_FEEDBACK_EMAIL);
        Boolean ignoreSslCertificateErrors =
            settings.getValueAsBool(Settings.SYSTEM_FEEDBACK_MAILSERVER_IGNORE_SSL_CERTIFICATE_ERRORS, false);


        configureBasics(hostName, smtpPort, from, username, password, ssl, tls, ignoreSslCertificateErrors);
    }
};

