/**
* Handles the Services constants Strings
*
* @author  Sebastian Listl
* @version 0.1, 2014-10-15
*/
public with sharing class P7S1_Liferay_Constants {
  	public static String PORTAL_SEVEN_ONE_MEDIA = 'sevenonemedia.de';
  	public static String PORTAL_SEVEN_ONE_MEDIA_CH = 'sevenonemedia.ch';
  	public static String PORTAL_SEVEN_ONE_MEDIA_COM = 'sevenonemedia.com';
  	public static String PORTAL_ADFACTORY = 'sevenone-adfactory.de';
	
  	public static String ACTION_UPDATE = 'update';
  	public static String ACTION_ACTIVATE = 'activate';
  	public static String ACTION_CONFIRM = 'confirm';
  	public static String ACTION_DELETE = 'delete';

 	public static String PORTAL_STATUS_UNCONFIRMEND = 'Neu';
  	public static String PORTAL_STATUS_ACTIVE = 'Aktiv';
  	public static String PORTAL_STATUS_LIFERAY_ACTIVE = 'Liferay Aktiv';
  	public static String PORTAL_STATUS_ADFACTORY_ACTIVE = 'Adfactory Aktiv';
  	public static String PORTAL_STATUS_INACTIVE = 'Gesperrt';
  	public static String PORTAL_STATUS_DELETED = 'Gelöscht';

  	public static String PORTAL_EVENT_STATUS_CREATED = 'created';
  	public static String PORTAL_EVENT_STATUS_ACTIVATED_SF = 'activated-salesforce';
  	public static String PORTAL_EVENT_STATUS_ACTIVATED_LR = 'activated-liferay';
  	public static String PORTAL_EVENT_STATUS_ACTIVATED_AF = 'activated-adfactory';
  	public static String PORTAL_EVENT_STATUS_CONFIRMED = 'confirmed';
  	public static String PORTAL_EVENT_STATUS_UPDATED = 'updated';
  	public static String PORTAL_EVENT_STATUS_DELETED = 'deleted';
  	public static String PORTAL_EVENT_STATUS_DELETED_API = 'deleted-api';
  	//@DEPRECATED
  	public static String PORTAL_EVENT_EMAIL_SENT = 'email_sent';
  	public static String PORTAL_EVENT_EMAIL_SENT_OPTIN = 'email-sent-optin-link';
  	public static String PORTAL_EVENT_EMAIL_SENT_ADMIN_ACTIVATION = 'email-sent-adm-activation';
  	public static String PORTAL_EVENT_EMAIL_SENT_WELCOME = 'email-sent-welcome';
  	public static String PORTAL_EVENT_EMAIL_SENT_DELETE_CONFIRM = 'email-sent-delete-confirm';
  	public static String PORTAL_EVENT_NEWSLETTER_SUBSCRIBE_CONFIRM_SEND = 'newsletter-subscribe-confirm-send';

  	public static String PORTAL_EMAIL_TEMPLATE_PREFIX_ADFACTORY = 'P7S1_Adfactory';
  	public static String PORTAL_EMAIL_TEMPLATE_PREFIX_LIFERAY = 'P7S1_Liferay';

  	public static String PORTAL_EMAIL_TEMPLATE_OPTIN_LINK = 'OptInLink';
  	public static String PORTAL_EMAIL_TEMPLATE_WELCOME = 'Welcome';
  	public static String PORTAL_EMAIL_TEMPLATE_DEL_CONFIRM = 'DeleteConfirm';
  	public static String PORTAL_EMAIL_TEMPLATE_ADMIN_ACTIVATION = 'AdminActivation';

  	public static String PORTAL_COMPANY_TYPE_SF_NO_MATCH = 'no match';
 	public static String PORTAL_COMPANY_TYPE_SF_ADVERTISER = 'Werbungtreibender';
  	public static String PORTAL_COMPANY_TYPE_SF_ADVERTISING_AGENCY = 'Werbeagentur';
  	public static String PORTAL_COMPANY_TYPE_SF_MEDIA_AGENCY = 'Mediaagentur';

	public static String NEWSLETTER_ACTION_SUBSCRIBE_EMAIL = 'subscribe-email';
	public static String NEWSLETTER_TEMPLATE_SUBSCRIBE_EMAIL = 'SubscribeNewsletter';

}