public with sharing class Lcm_CaseTeamMember_Assignment {

    /**
    * @param listNewCases list of Cases (Trigger.new)
    * @param mapOldCases map of Cases by their Id (Trigger.oldMap)
    * @param mapNewCases map of Cases by their Id (Trigger.newMap)
    * update the Case Team with the last Owner with defined Roles.
    **/
    public static void setCaseTeamMembers(List<Case> listNewCases, Map<Id, Case> mapOldCases, Map<Id, Case> mapNewCases) {
        List<CaseTeamMember> ctm_list = new List<CaseTeamMember>();
        Map<Id, Set<Id>> ctm_ids = new Map<Id, Set<Id>>();
        for (CaseTeamMember ctm : [Select Id, MemberId, ParentId from CaseTeamMember where ParentId in :mapNewCases.keySet()]) {
            Set<Id> ctm_set;
            if (ctm_ids.containsKey(ctm.ParentId)) {
                ctm_set = ctm_ids.get(ctm.ParentId);
            } else {
                ctm_set = new Set<Id>();
            }
            ctm_set.add(ctm.MemberId);
            ctm_ids.put(ctm.ParentId, ctm_set);
        }
        Map<String,Id> ctr_map = new Map<String,Id>();
        for (CaseTeamRole ctr : [Select Id, Name from CaseTeamRole]) {
            ctr_map.put(ctr.Name, ctr.Id);
        }
        for (Case c : listNewCases) {
            if (mapOldCases.get(c.Id).OwnerId != mapNewCases.get(c.Id).OwnerId) {
                Set<Id> ctm_set = (ctm_ids.containsKey(c.Id)) ? ctm_ids.get(c.Id) : new Set<Id>();
                String co_id = mapOldCases.get(c.Id).OwnerId;
                if (co_id.startsWith('005') && !ctm_set.contains(co_id)) {
                    CaseTeamMember ctm = new CaseTeamMember();
                    ctm.MemberId = co_id;
                    ctm.ParentId = c.Id;
                    ctm.TeamRoleId = (co_id == c.CreatedById) ? ctr_map.get('Anforderungsmanager') : ctr_map.get('Beobachter');
                    ctm_list.add(ctm);
                }
            }
        }
        if (!ctm_list.isEmpty()) {
            Database.insert(ctm_list, false);
        }
    }

}