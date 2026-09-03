/**
 * @description       : without sharing query method for customLightningDataTableController, used only
 *                       when the "SYSTEM_MODE_WITHOUT_SHARING" data access mode is requested. Apex
 *                       sharing rules are fixed per class at compile time, so bypassing sharing on
 *                       demand requires executing the query from a dedicated without sharing class.
 * @author            : daniel@hyphen8.com
 * @last modified on  : 03-09-2026
 * @last modified by  : daniel@hyphen8.com
**/
@SuppressWarnings('PMD')
public without sharing class customLightningDataTableNoSharing {

    public static List<SObject> queryWithoutSharing(String query) {
        return Database.query(query, AccessLevel.SYSTEM_MODE);
    }

    public static List<Database.DeleteResult> deleteWithoutSharing(List<Id> ids) {
        return Database.delete(ids, AccessLevel.SYSTEM_MODE);
    }
}
