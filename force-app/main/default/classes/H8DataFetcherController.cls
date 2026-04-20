/**
* @description       : master controller for fetching data from the server using dynamic SOQL queries. It provides methods to execute queries and return results in a structured format.
* @author            : daniel@hyphen8.com
* @last modified on  : 20-04-2026
* @last modified by  : daniel@hyphen8.com
**/
public with sharing class H8DataFetcherController {
    @TestVisible
    private static List<H8_DataFetcherQuery__mdt> testQueries;
    
    @AuraEnabled
    public static QueryResult getSObjects(String queryDeveloperName, String bindsJson) {
        QueryDefinition def = getQueryDefinition(queryDeveloperName);
        System.AccessLevel access = resolveAccessLevel(def.accessMode);
        Map<String, Object> binds = parseBindsJson(bindsJson);
        return new QueryResult(Database.queryWithBinds(def.soqlTemplate, binds, access));
    }

    @AuraEnabled(cacheable=true)
    public static List<QueryOption> getAvailableQueries() {
        List<QueryOption> results = new List<QueryOption>();
        for (H8_DataFetcherQuery__mdt q : getQueryMetadata()) {
            results.add(new QueryOption(q.DeveloperName, q.MasterLabel, q.ObjectApiName__c, q.AccessMode__c));
        }
        return results;
    }

    private static QueryDefinition getQueryDefinition(String queryDeveloperName) {
        if (String.isBlank(queryDeveloperName)) {
            throw new AuraHandledException('Query DeveloperName is required.');
        }

        List<H8_DataFetcherQuery__mdt> found = new List<H8_DataFetcherQuery__mdt>();
        for (H8_DataFetcherQuery__mdt queryMetadata : getQueryMetadata()) {
            if (queryMetadata.DeveloperName == queryDeveloperName) {
                found.add(queryMetadata);
                break;
            }
        }
        if (found.isEmpty()) {
            throw new AuraHandledException('Unknown Data Fetcher query: ' + queryDeveloperName);
        }

        H8_DataFetcherQuery__mdt q = found[0];
        if (String.isBlank(q.ObjectApiName__c) || String.isBlank(q.SoqlTemplate__c)) {
            throw new AuraHandledException('Query metadata is missing Object API Name or SOQL Template.');
        }

        String template = q.SoqlTemplate__c.trim();
        validateTemplate(template, q.ObjectApiName__c);
        return new QueryDefinition(q.ObjectApiName__c, template, q.AccessMode__c);
    }

    private static List<H8_DataFetcherQuery__mdt> getQueryMetadata() {
        if (Test.isRunningTest() && testQueries != null) {
            return testQueries;
        }

        return [
            SELECT DeveloperName, MasterLabel, ObjectApiName__c, SoqlTemplate__c, AccessMode__c
            FROM H8_DataFetcherQuery__mdt
            WITH SYSTEM_MODE
            ORDER BY MasterLabel
        ];
    }

    private static void validateTemplate(String soqlTemplate, String objectApiName) {
        // Minimal guardrail: ensure the query is a SELECT against the expected base object.
        // This helps keep the generic typing correct and prevents metadata from pointing to a different object.
        if (!soqlTemplate.toLowerCase().startsWith('select ')) {
            throw new AuraHandledException('SOQL template must be a SELECT.');
        }

        // Allow whitespace/newlines and optional alias after the object name.
        Pattern fromPattern = Pattern.compile('(?i)\\bfrom\\s+' + Pattern.quote(objectApiName) + '\\b');
        if (!fromPattern.matcher(soqlTemplate).find()) {
            throw new AuraHandledException('SOQL template must be a SELECT FROM ' + objectApiName + '.');
        }
    }

    private static Map<String, Object> parseBindsJson(String bindsJson) {
        if (String.isBlank(bindsJson)) {
            return new Map<String, Object>();
        }

        try {
            return (Map<String, Object>) JSON.deserializeUntyped(bindsJson);
        } catch (Exception e) {
            throw new AuraHandledException('Binds must be a JSON object (map).');
        }
    }

    private static System.AccessLevel resolveAccessLevel(String accessMode) {
        if (accessMode == 'SYSTEM') {
            return System.AccessLevel.SYSTEM_MODE;
        } else {
            return System.AccessLevel.USER_MODE;
        }
    }
    
    public class QueryResult {
        public QueryResult(List<SObject> results) {
            this.results = results;
            if (this.results.isEmpty() == false) {
                this.firstResult = this.results.get(0);
            }
        }
        @AuraEnabled
        public final List<SObject> results;
        @AuraEnabled
        public final SObject firstResult;
    }

    public class QueryOption {
        public QueryOption(String developerName, String label, String objectApiName, String accessMode) {
            this.developerName = developerName;
            this.label = label;
            this.objectApiName = objectApiName;
            this.accessMode = accessMode;
        }
        @AuraEnabled public final String developerName;
        @AuraEnabled public final String label;
        @AuraEnabled public final String objectApiName;
        @AuraEnabled public final String accessMode;
    }

    private class QueryDefinition {
        public QueryDefinition(String objectApiName, String soqlTemplate, String accessMode) {
            this.objectApiName = objectApiName;
            this.soqlTemplate = soqlTemplate;
            this.accessMode = accessMode;
        }
        public final String objectApiName;
        public final String soqlTemplate;
        public final String accessMode;
    }
}
