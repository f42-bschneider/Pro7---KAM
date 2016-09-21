/**
* User clicks a button in the detail page of a Media Campaign. Once the button is clicked, a VF-page is to
* show, in where some options are to provide, among others a user can select which Campaign Items are to split. The browser is then to redirect to
* the newly created Media-Campaign if the split process is terminated successfully. Otherwise the error message is to show in the VF-page, and
* the user can then go back to the original Media-Campaign.
*/

public with sharing class Adv_MediaCampaign_Split {

    final static Integer MAX_RECORD_ITERATE_VF=1000;
    ADvendio__MediaCampaign__c mc;

    /**
    *  Rerender button Split
    */
    public Boolean showBtnSplit{
        get{
            return (!ApexPages.hasMessages(ApexPages.Severity.ERROR)) && (itmWrappers!=null && itmWrappers.size()>0);
        }

    }
    /**
    * List item wrapper are binding in data area
    */
    public List<ItemWrapper> itmWrappers{get;set;}

    /**
    * Also using in test class
    */
    public static Map<String,Map<String,Object>> mSObjFieldsInitData =new Map<String,Map<String,Object>> {

        'ADvendio__MediaCampaign__c' => new Map<String,Object>{
            'SomDig_Zahlungsbedingung__c'=>null,
            'SomDig_MasterMediaCampaign__c'=>null
        }
    };

    /**
    * Map of set of children sObject name
    * Key: parent sObject name
    * Value: Set of children
    *
    * @see #cloneProcess(Boolean forceClone)
    */
    static Map<String,Set<String>> parentChildrenObject =new Map<String,Set<String>>{

        'ADvendio__MediaCampaign__c'=>new Set<String>{

            'ADvendio__Campaign_Contact__c',
            'ADvendio__MediaCampaignTeamMember__c',
            'ADvendio__TextBlockMcAssignment__c'
            ,'ADvendio__Campaign_Item__c'
        },

        'ADvendio__Campaign_Item__c' => new Set<String>{
            'ADvendio__KeyLine__c',
            'ADvendio__Selected_Areacode__c',
            'ADvendio__Selected_City__c',
            'ADvendio__SelectedContent__c',
            'ADvendio__Selected_Country__c',
            'ADvendio__SelectedPublicationDate__c',
            'ADvendio__Selected_Region__c',

            'ADvendio__AdServerExclusion__c'
        },

        'ADvendio__KeyLine__c'=>new Set<String>{'ADvendio__KeyValue__c'}
    };

    /**
    * Map of parent field-name on children
    * Key: child sObject name
    * Value: child field reference to parent
    *
    */
    static Map<String,String> parentfield = new Map<String,String> {
        'ADvendio__Campaign_Contact__c' => 'ADvendio__Media_Campaign__c',
        'ADvendio__MediaCampaignTeamMember__c' => 'ADvendio__MediaCampaign__c',
        'ADvendio__TextBlockMcAssignment__c' => 'ADvendio__MediaCampaign__c',
        'ADvendio__Campaign_Item__c' => 'ADvendio__Media_Campaign__c',
            //Children of CampaignItem
            'ADvendio__KeyLine__c'=>'ADvendio__CampaignItem__c',
                 'ADvendio__KeyValue__c'=>'ADvendio__KeyLine__c',

            'ADvendio__Selected_Areacode__c'=>'ADvendio__Campaign_Item__c',
            'ADvendio__Selected_City__c'=>'ADvendio__Campaign_Item__c',
            'ADvendio__SelectedContent__c'=>'ADvendio__CampaignItem__c',
            'ADvendio__Selected_Country__c'=>'ADvendio__Campaign_Item__c',
            'ADvendio__SelectedPublicationDate__c'=>'ADvendio__CampaignItem__c',
            'ADvendio__Selected_Region__c'=>'ADvendio__Campaign_Item__c',

            'ADvendio__AdServerExclusion__c'=>'ADvendio__CampaignItem__c'


    };

    /**
    * Data member cache the initial value is assigned in contructor and used in split action
    */
    Map<Id,List<ADvendio__Campaign_Item__c>> mPacketIdComponentItem;
    Map<String,ADvendio__InvoiceItem__c> mIdInvoicedItem;

    /**
    * When page load:
    * Load medai campaign and campaign items
    * Load invoice-items base on item id value
    * Group component items base on packet item id
    * Manage items wrapper to for select item area
    */
    public Adv_MediaCampaign_Split(ApexPages.StandardController controller){

        //mc = (ADvendio__MediaCampaign__c) controller.getRecord();
        //cls_P7S1_CloneUtils.selectSObject(String sObjectName, String filter)
        mc = (ADvendio__MediaCampaign__c)(cls_P7S1_CloneUtils.selectSObject('ADvendio__MediaCampaign__c','id=\'' +controller.getRecord().Id + '\'').get(0));

        //query item
        List<ADvendio__Campaign_Item__c> items=(List<ADvendio__Campaign_Item__c>)cls_P7S1_CloneUtils.selectSObject(
            'ADvendio__Campaign_Item__c',
            //additional select field
            new Set<String>{
                   'ADvendio__PacketItem__r.ADvendio__Media_Campaign__c'
                   ,'SomDig_Preiskriterium__c'
                   ,'SomDig_RabattFreigegeben__c'
                   ,'ADvendio__Period__c'
                   ,'ADvendio__Amount_net_net__c'
                   ,'ADvendio__Available__c'
                   ,'SomDig_MediagattungsDifferenzierung__c'
                   ,'SomDig_MediagattungsDifferenzierungName__c'
                   ,'ADvendio__ConnectedItemID__c'
                   },
            parentfield.get('ADvendio__Campaign_Item__c')+' IN:parentIds  LIMIT '+MAX_RECORD_ITERATE_VF,
            new Set<ID>{mc.Id}
        );

        mIdInvoicedItem=getInvoiceItem(items);

        mPacketIdComponentItem=groupComponentItemByPacketItem(items);

        itmWrappers=new List<ItemWrapper>();

        for(ADvendio__Campaign_Item__c itm: items){
            itmWrappers.add(new ItemWrapper(false,mIdInvoicedItem.containsKey(itm.Id) || itm.ADvendio__ConnectedItemID__c != null, itm));
        }

    }

    /**
    * Get invoiced items
    *
    * @param items      list of campaign's items
    * @return Map<String,ADvendio__InvoiceItem__c>
    */
    static Map<String,ADvendio__InvoiceItem__c> getInvoiceItem(List<ADvendio__Campaign_Item__c> items){
        Map<String,ADvendio__InvoiceItem__c> mInvoiceItem=new Map<String,ADvendio__InvoiceItem__c>();

        Set<String> ids=new Set<String>();
        for(ADvendio__Campaign_Item__c itm: items){
            ids.add(''+itm.Id);
        }

        for(ADvendio__InvoiceItem__c invItm: [SELECT ADvendio__ItemId__c FROM ADvendio__InvoiceItem__c WHERE ADvendio__ItemId__c IN: ids AND ADvendio__Invoice__r.ADvendio__Status__c = 'Invoiced']){
            if(invItm.ADvendio__ItemId__c!=null && !mInvoiceItem.containsKey(invItm.ADvendio__ItemId__c)){
                mInvoiceItem.put(invItm.ADvendio__ItemId__c,invItm);
            }
        }

        return mInvoiceItem;

    }

    /**
    * Group campaign item (component) of the same media campaign
    *
    * @param items      list of campaign item
    * @return Map<Id,List<ADvendio__Campaign_Item__c>>
    */
    static Map<Id,List<ADvendio__Campaign_Item__c>> groupComponentItemByPacketItem(List<ADvendio__Campaign_Item__c> items){
        Map<Id,List<ADvendio__Campaign_Item__c>> mPackItmIdComponents=new Map<Id,List<ADvendio__Campaign_Item__c>>();

        for(ADvendio__Campaign_Item__c itm: items){

            //if it is component item and lookup to packet item of the same Media Campaign
            if(itm.ADvendio__PacketItem__c!=null && itm.ADvendio__Media_Campaign__c == itm.ADvendio__PacketItem__r.ADvendio__Media_Campaign__c){
                List<ADvendio__Campaign_Item__c> itms=mPackItmIdComponents.get(itm.ADvendio__PacketItem__c);

                if(itms==null)itms=new List<ADvendio__Campaign_Item__c>();

                itms.add(itm);
                mPackItmIdComponents.put(itm.ADvendio__PacketItem__c,itms);
            }

        }

        return mPackItmIdComponents;

    }

    /**
    * Action method to split media campaign is invokeb by visulaforce button
    * It actually clones a Media Campaign and selected Campaign Items. After selected Campaign Items are cloned successfully, the
    * original Campaign Items are to delete.
    *
    * @return PageReference
    */

    public PageReference split(){

        Savepoint sp = Database.setSavepoint();
        SObject newMC;

        try{

            //valid campaign item before process
            List<ADvendio__Campaign_Item__c> selectedItems=validateSelectedItem(itmWrappers);
            // if there is any error message then cancell clone
            if(ApexPages.hasMessages())return null;


            Map<String,Object> mInitFieldData=mSObjFieldsInitData.get('ADvendio__MediaCampaign__c');
            mInitFieldData.put('SomDig_MasterMediaCampaign__c',mc.Id);

            newMC=cls_P7S1_CloneUtils.clone(new List<sObject>{mc},mInitFieldData).get(0);
            insert newMC;

            //Clone only seleted child
            for(String childObjName : parentChildrenObject.get('ADvendio__MediaCampaign__c')){

                List<sObject> clonedObjs=null;
                List<sObject> originalObjs=null;

                if('ADvendio__Campaign_Item__c'==childObjName){
                    originalObjs=selectedItems;
                }
                else{
                    originalObjs=cls_P7S1_CloneUtils.selectSObject(childObjName,null,parentfield.get(childObjName)+'=\'' +mc.Id + '\'',null);
                }

                ///System.debug('>>>cloneProcess>Orginal relatedChildren: '+childObjName+' >size:'+originalObjs.size());

                //map of initial field-data
                mInitFieldData=mSObjFieldsInitData.get(childObjName);

                //add initial-data of cloned MediaCampaign ID for the selected of related children
                if(mInitFieldData!=null)mInitFieldData.put(parentfield.get(childObjName),newMC.Id);
                else mInitFieldData=new Map<String,Object>{parentfield.get(childObjName) =>newMC.Id};

                ///System.debug('>>>cloneProcess mInitFieldData: '+mInitFieldData);

                clonedObjs=cls_P7S1_CloneUtils.clone(originalObjs, mInitFieldData);

                /**
                * If contains childrent meed clone (ex: ADvendio__Campaign_Item__c contains othere children),
                * The Children must be set in map parentChildrenObject.
                *
                * Childrent of ADvendio__Campaign_Item__c
                * AdServer Exclusion (ADvendio__AdServerExclusion__c)
                * Key Line (ADvendio__KeyLine__c) contains child
                *   ADvendio__KeyValue__c
                * Selected Areacode (ADvendio__Selected_Areacode__c)
                * Selected City (ADvendio__Selected_City__c)
                * Selected Content (ADvendio__SelectedContent__c)
                * Selected Country (ADvendio__Selected_Country__c)
                * Selected Publication Date (ADvendio__SelectedPublicationDate__c)
                * Selected Region (ADvendio__Selected_Region__c)
                */
                Boolean hasChild=(parentChildrenObject.containsKey(childObjName) && parentChildrenObject.get(childObjName)!=null && parentChildrenObject.get(childObjName).size()>0);
                ///System.debug('>>>cloneProcess>hasChild: '+hasChild);

                //if cloned sobject has any child
                if(hasChild){
                    //insertClone: return Map{key: old_sObjectID, value: new insted-Parent-SObject}
                    Map<Id,sObject> oldIDnewPObj=insertClone(originalObjs,clonedObjs);

                    /**
                    * For the cloned component items, the relationship to its cloned packet item must be set correctly
                    */
                    if(originalObjs instanceof List<ADvendio__Campaign_Item__c> && oldIDnewPObj.size()>0){
                        //Set relationship the cloned component items to its cloned packet item
                        updatePacketItem(oldIDnewPObj);

                    }

                    cloneChildren(oldIDnewPObj,childObjName);

                    /** delete selected orginal campaign-items */
                    if(originalObjs instanceof List<ADvendio__Campaign_Item__c> && originalObjs.size()>0){
                        delete originalObjs;
                    }
                }
                else if(clonedObjs.size()>0)insert clonedObjs;

                ///System.debug('>>>cloneProcess>Cloned relatedChildren: '+clonedObjs);
            }


        }catch(Exception e){
            if(!ApexPages.hasMessages(ApexPages.Severity.ERROR))ApexPages.addMessages(e);
        }
        finally{
            ///System.debug('>>>>finally');

            if(ApexPages.hasMessages()){
                Database.rollback(sp);
                return null;
            }
        }
        //navigat user to cloned camapaign in edit mode
        return getPageReference(newMC.Id+'/e?retURL=/'+newMC.Id);
    }

    /**
    * Action back to orignial media campaign is invoked by visulaforce button
    *
    * @return PageReference
    */
    public PageReference back(){
        return getPageReference(mc.Id);
    }

    /**
    * Clone related children, Reset new parent id and insert
    *
    * @param mIdPsObj           map of cloned parent sObject is using for query and setting new parent-id to children
    * @param chObjName          sobject name of children
    * @param fieldRef           field reference on child sObject that lookup to parent
    * @return Map<Id,sObject>   map of insert sObject,
    *                           key(Id) is orginal-id use for query related chidren.
    *                           value(sObject) is cloned sObject, cloned sobject-id will used to assign to cloned children.
    */
    private static Map<Id,sObject> cloneChildren(Map<Id,sObject> mIdPsObj, String chObjName, String fieldRef){

        //parentIds is fix variable in selectSObject method for dynamic query filter base on value in Set
        List<sObject> originalObjs=cls_P7S1_CloneUtils.selectSObject(chObjName,null,fieldRef+' IN:parentIds',mIdPsObj.keySet());

        if (originalObjs != null) {
            List<Sobject> clonedObjs=cls_P7S1_CloneUtils.clone(originalObjs,null);

            ///System.debug('>>>cloneChildren>chObjName: '+chObjName+' >fieldRef: '+fieldRef+'\n>mIdPsObj: '+mIdPsObj);

            //the cloned objects include old-parentId
            Map<Id,List<sObject>> mParentIdChildren=groupChildrenByParentId(clonedObjs, fieldRef);

            //set newParentId
            for(ID pId: mIdPsObj.keySet()){
                //some parent has no children
                if(mParentIdChildren.containsKey(pId) && mParentIdChildren.get(pId)!=null){
                    for(sObject chObj: mParentIdChildren.get(pId)){
                        sObject p=mIdPsObj.get(pId);
                        chObj.put(fieldRef,p.Id);
                    }
                }
            }
            ///System.debug('>>>cloneChildren>clonedObjs: '+clonedObjs+'DONE');

            return insertClone(originalObjs,clonedObjs);
        } else {
            return null;
        }
    }

    /**
    * Insert cloned sObjects
    *
    * @param originalObjs      list of original sobject
    * @param clonedObjs        list of cloned sObject
    * @return Map<Id,sObject>  map of insert sObject,
    *                          Id is key of orginal-id use for query related chidren.
    *                          sObject is value of cloned sObject, cloned sobject-id will assigned to cloned children.
    */
    static Map<Id,sObject> insertClone(List<sObject> originalObjs,List<sObject> clonedObjs){

        Map<Id,sObject> mIdObj=new Map<Id,sObject>();
        //inser cloned sObjects
        if(clonedObjs.size()>0){

            insert clonedObjs;

            for(Integer i=0;i<originalObjs.size();i++){
                mIdObj.put(originalObjs[i].Id,clonedObjs[i]);
            }
        }

        ///System.debug('>>>insertClone>originalObjs: '+originalObjs.size()+'>clonedObjs: '+clonedObjs.size()+'>DONE');

        return mIdObj;

    }

    /**
    * Recursive clone children
    *
    * @param mIdPsObj          map of cloned parent sObject is using for query and setting new parent-id to children
    * @param parentObjName     parent sObject name
    */
    private static void cloneChildren(Map<Id,sObject> mIdPsObj, String parentObjName){

        //parentChildrenObject map of set-of-children-sObject-api-name
        for(String chObjName: parentChildrenObject.get(parentObjName)){

            String fieldRef=parentfield.get(chObjName);

            Map<Id,sObject> mIdSObj=cloneChildren(mIdPsObj,chObjName,fieldRef);

            if(mIdSObj != null && parentChildrenObject.get(chObjName) != null) {
                cloneChildren(mIdSObj,chObjName);
            }

        }

        ///System.debug('>>>Recursive>cloneChildren>DONE');

    }

    /**
    * Group children sObjects base on field reference value (parent-id)
    *
    * @param children                  list cloned child sObject
    * @param fieldRefToParent          field reference on child sObject
    * @return Map<Id,List<sObject>>    map of list sobject, key(Id) is parent-id, value(List<sObject>) related children
    */
    private static Map<Id,List<sObject>> groupChildrenByParentId(List<sObject> children, String fieldRefToParent){

        Map<Id,List<sObject>> mPIDChildren= new Map<Id,List<sObject>>();

        if(children.size()>0){

            for(sObject so: children){

                ID originalParentId=(ID)so.get(fieldRefToParent);

                if(originalParentId!=null){

                    List<sObject> objs=mPIDChildren.get(originalParentId);

                    if(objs==null)objs=new List<sObject>();

                    objs.add(so);

                    mPIDChildren.put(originalParentId,objs);
                }

            }
        }

        ///System.debug('>>>groupChildrenByParentId>fieldRefToParent: '+fieldRefToParent+ '\n>mPIDChildren: '+mPIDChildren+'>DONE');

        return mPIDChildren;
    }

    /**
    * Update cloned campagin items after set packet item id for component item
    *
    * @param oldIDNewItem      map cloned sObject that key is orginal-id and value cloned-parent-sobject}
    */
    static void updatePacketItem(Map<Id,sObject> oldIDNewItem){

        List<sObject> packetCompoItms=new List<sObject>();
        //Component CampaignItem lookup PackatItem by ADvendio__PacketItem__c
        for(sObject ccItem: oldIDNewItem.values()){
            //when item was cloned, it store old value of ADvendio__PacketItem__c
            ID packetItemId=(ID)ccItem.get('ADvendio__PacketItem__c');

            if(packetItemId!=null){

                sObject packetItem=oldIDNewItem.get(packetItemId);

                if(packetItem!=null){
                    ccItem.put('ADvendio__PacketItem__c',packetItem.Id);
                    packetCompoItms.add(ccItem);
                }
            }
        }

        if(packetCompoItms.size()>0)update packetCompoItms;

    }

    /**
    * Create generic page reference to naviage user to media campaign detail page
    *
    * @param objId     id of media campaign
    * @return          PageReference
    */
    private static PageReference getPageReference(String objId){
        PageReference retUrl = new PageReference('/' + objId);
        retUrl.setRedirect(true);
        return retUrl;
    }

    /**
    * Validate selected split item whether:
    * the packet-item of component is selecting or not
    * Selected-items is ready invoiced
    *
    * @param itmWrappers    List of all items wrapper
    * @return List<ADvendio__Campaign_Item__c>
    */
    private List<ADvendio__Campaign_Item__c> validateSelectedItem(List<ItemWrapper> itmWrappers){

        Map<Id,ADvendio__Campaign_Item__c> mSelectedItem=new Map<Id,ADvendio__Campaign_Item__c>();
        List<ADvendio__Campaign_Item__c> componentItems=new List<ADvendio__Campaign_Item__c>();

        List<ADvendio__Campaign_Item__c> itemsToClone=new List<ADvendio__Campaign_Item__c>();


        ///System.debug('>>>validateSelectedItem>mPacketIdComponentItem: '+mPacketIdComponentItem);


        for(ItemWrapper wrapper: itmWrappers){

            //Filter selected item
            if(wrapper.selected){
                mSelectedItem.put(wrapper.item.Id,wrapper.item);

                //if it is package item
                List<ADvendio__Campaign_Item__c> compoItems=mPacketIdComponentItem.get(wrapper.item.Id);
                if(compoItems!=null)componentItems.addAll(compoItems);
            }

        }

        //Item name is shown as bulleted line in message area
        String msg='';
        //Check to add error
        for(ADvendio__Campaign_Item__c selectedItm: mSelectedItem.values()){
            //if it is component item and package item is not selected then add error
            if(selectedItm.ADvendio__PacketItem__c!=null && !mSelectedItem.containsKey(selectedItm.ADvendio__PacketItem__c)){
                msg+='<li>'+selectedItm.Name+'</li>';
            }
            else itemsToClone.add(selectedItm);
        }

        if(String.isNotBlank(msg))addMessage(System.Label.MsgFunctionSplit,msg);

        //if component item is also selected, then no need to add to list for clone to avoid duplication
        for(ADvendio__Campaign_Item__c compoItm :componentItems){
            if(!mSelectedItem.containsKey(compoItm.Id))itemsToClone.add(compoItm);
        }

        return itemsToClone;
    }


    /**
    * Add message information as bulleted line
    *
    * @param labelVal      value of custom label
    * @param message       text description
    */
    private static void addMessage(String labelVal, String message){
        if(String.isNotBlank(message)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,('<ul style="padding-left:0">'+(labelVal==null?'':+labelVal+'')+message+'</ul>')));
        }
    }

    /**
    * Campaig item wrapper is binding in select list item
    *
    */
    public class ItemWrapper{
        /**
        * Check box binding
        */
        public Boolean selected{get;set;}
        /**
        * flag to rerender check box
        */
        public Boolean invoiced{get;set;}

        /**
        * Campaign item
        */
        public ADvendio__Campaign_Item__c item{get;set;}

        /**
        * Class constructor specifies value of data member to bind in page
        *
        * @param selected      if user ticked check box then true, otherwise false
        * @param invoiced      if item has been invoiced then true, otherwise false
        * @param item          campaig-item to display in select list item.
        */
        public ItemWrapper(Boolean selected,Boolean invoiced, ADvendio__Campaign_Item__c item){
            this.selected=selected;
            this.invoiced=invoiced;
            this.item=item;
        }

    }

}