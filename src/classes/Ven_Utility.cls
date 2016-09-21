/**
* ===================================================================
* (c) factory42 GmbH 2015, Germany, All rights reserved
* Ven_OppPipelineCmpCtrl
* @author       MS factory42 GmbH
* @email        mschmit@factory42.com
* @version      V0.1
* @date         2015/10/12
* @description  
* @lastchange  
* @objects      
* =================================================================
*/
public without sharing class Ven_Utility {
	
	public class InputSelectOpt{
		@AuraEnabled
		public String text;

		@AuraEnabled
		public String label;

		public InputSelectOpt(String text, String label){
			this.text 	= text;
			this.label 	= label;
		}
	}

	/*****************
	*
	*****************/
	public static List<String> getPicklistValues(String objName, String fieldName){
		List<Schema.PicklistEntry> picklistEntries	= Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(fieldName).getDescribe().getPickListValues();

		List<String> picklistValues = new List<String>();

		for(Schema.PicklistEntry pe : picklistEntries){
			picklistValues.add(pe.getValue());
		}

		return picklistValues;
	}

	/*****************
	*
	*****************/
	public static List<InputSelectOpt> getInputSelectOptsByPicklistValues(String objName, String fieldName){
		List<InputSelectOpt> selects = new List<InputSelectOpt>();

		for(String picklistValue : getPicklistValues(objName, fieldName)){
			selects.add(new InputSelectOpt(picklistValue, picklistValue));
		}

		return selects;
	} 
	

	/*****************
	*
	*****************/
	public static Id getRoleIdByName(String roleName){
		return [SELECT Id FROM UserRole WHERE DeveloperName = :roleName LIMIT 1][0].Id;
	}


	/***************************
	*
	***************************/
	public static String getMonthNameByDate(Date d, Boolean compact) {
		Integer month = d.month();

		if(month == 1){
			return compact ? 'Jan' : 'January';
		}
		else if(month == 2){
			return compact ? 'Feb' : 'February';
		}
		else if(month == 3){
			return compact ? 'Mar' : 'March';
		}
		else if(month == 4){
			return compact ? 'Apr' : 'April';
		}
		else if(month == 5){
			return 'May';
		}
		else if(month == 6){
			return compact ? 'Jun' : 'June';
		}
		else if(month == 7){
			return compact ? 'Jul' : 'July';
		}
		else if(month == 8){
			return compact ? 'Aug' : 'August';
		}
		else if(month == 9){
			return compact ? 'Sep' : 'September';
		}
		else if(month == 10){
			return compact ? 'Oct' : 'October';
		}
		else if(month == 11){
			return compact ? 'Nov' : 'November';
		}
		else if(month == 12){
			return compact ? 'Dec' : 'December';
		}

		return null;
	}


	/***************************
	*
	***************************/
	public static List<SObject> convertJSONToListOfSObject(String json) {
        Object[] values = (Object[])System.JSON.deserializeUntyped(json);

        List<SObject> newSObjectsList = new List<SObject>();
        for (Object v : values) {
            Map<String, Object> m = (Map<String, Object>) v;

            Schema.SObjectType targetType = Schema.getGlobalDescribe().get((String) m.get('sobjectType'));

            SObject o = targetType.newSObject();

            Map<String, Schema.SObjectField> fields = targetType.getDescribe().fields.getMap();
            for (String fieldName : m.keySet()) {

            	if(fieldName == 'Id' || fieldName == 'id'){
            		o.put(fieldName, m.get(fieldName));
            	}
            	else {
            		// Filter out any psuedo fields such as LastNameLocal
	                Schema.SObjectField fi = fields.get(fieldName);
	                if (fi != null) {
	                    if (fi.getDescribe().isCreateable() && fi.getDescribe().isUpdateable()) {
	                        o.put(fieldName, m.get(fieldName)); 
	                    }
	                }	
            	}
            }

            newSObjectsList.add(o);
        }

        return newSObjectsList;
    }

    
	/***************************
	*
	***************************/
    public static Decimal getSomLikelihoodByEffYield(Decimal effYield){
    	List<Ven_SomLikelihood__c> somLikelihoods 	= Ven_SomLikelihood__c.getAll().values();
		
		Decimal somLikelihood;

		for(Ven_SomLikelihood__c slh : somLikelihoods){
			if(effYield >= slh.Ven_Min__c && effYield <= slh.Ven_Max__c){
				Integer month = Date.today().month();

				if(month == 1){
					somLikelihood = slh.Ven_Jan__c;
				}
				else if(month == 2){
					somLikelihood = slh.Ven_Feb__c;
				}
				else if(month == 3){
					somLikelihood = slh.Ven_Mar__c;
				}
				else if(month == 4){
					somLikelihood = slh.Ven_Apr__c;
				}
				else if(month == 5){
					somLikelihood = slh.Ven_May__c;
				}
				else if(month == 6){
					somLikelihood = slh.Ven_Jun__c;
				}
				else if(month == 7){
					somLikelihood = slh.Ven_Jul__c;
				}
				else if(month == 8){
					somLikelihood = slh.Ven_Aug__c;
				}
				else if(month == 9){
					somLikelihood = slh.Ven_Sep__c;
				}
				else if(month == 10){
					somLikelihood = slh.Ven_Oct__c;
				}
				else if(month == 11){
					somLikelihood = slh.Ven_Nov__c;
				}
				else if(month == 12){
					somLikelihood = slh.Ven_Dec__c;
				}

				break;
			}
		}

		return somLikelihood;
	}
}