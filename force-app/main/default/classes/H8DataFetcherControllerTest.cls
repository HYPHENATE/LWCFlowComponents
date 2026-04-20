/**
* @description       : Test class for H8DataFetcherController
* @author            : daniel@hyphen8.com
* @last modified on  : 20-04-2026
* @last modified by  : daniel@hyphen8.com
**/
@isTest
public class H8DataFetcherControllerTest {
    private static H8_DataFetcherQuery__mdt buildQueryMetadata(String developerName, String label, String objectApiName, String soqlTemplate, String accessMode) {
        return (H8_DataFetcherQuery__mdt)new MockMetaManager('H8_DataFetcherQuery__mdt')
            .addFieldValue('MasterLabel', label)
            .addFieldValue('DeveloperName', developerName)
            .addFieldValue('ObjectApiName__c', objectApiName)
            .addFieldValue('SoqlTemplate__c', soqlTemplate)
            .addFieldValue('AccessMode__c', accessMode)
            .getSingleMockMetaData();
    }
    
    @IsTest
	static void canQuery() {
	  insert new List<SObject>{ new Account(Name = 'One', Type = 'Customer'), new Account(Name = 'Two', Type = 'Customer') };
      H8DataFetcherController.testQueries = new List<H8_DataFetcherQuery__mdt>{
          buildQueryMetadata(
              'AccountByType',
              'Account By Type',
              'Account',
              'SELECT Id, Name, Type FROM Account WHERE Type = :type ORDER BY Name',
              'SYSTEM'
          )
      };

	  H8DataFetcherController.QueryResult result = H8DataFetcherController.getSObjects(
		  'AccountByType',
          '{"type":"Customer"}'
	  );
  
	  Assert.areEqual(2, result.results.size(), 'We always expected 2 results to be returned here');
	  Assert.areEqual('One', result.firstResult.get(Account.Name), 'The first account name should always be One');
	}

    @IsTest
    static void availableQueriesUseMockMetadata() {
        H8DataFetcherController.testQueries = new List<H8_DataFetcherQuery__mdt>{
            buildQueryMetadata(
                'AccountByType',
                'Account By Type',
                'Account',
                'SELECT Id, Name FROM Account',
                'USER'
            ),
            buildQueryMetadata(
                'ContactByEmail',
                'Contact By Email',
                'Contact',
                'SELECT Id, Name, Email FROM Contact WHERE Email = :email',
                'SYSTEM'
            )
        };

        List<H8DataFetcherController.QueryOption> results = H8DataFetcherController.getAvailableQueries();

        Assert.areEqual(2, results.size(), 'we always expect 2 metadata configurations to be returned here');
        Assert.areEqual('AccountByType', results[0].developerName, 'we expect the first result to be AccountByType');
        Assert.areEqual('ContactByEmail', results[1].developerName, 'we expect the second result to be ContactByEmail');
    }

    // @IsTest
    // static void unknownQueryThrowsWhenMockMetadataMissing() {
    //     H8DataFetcherController.testQueries = new List<H8_DataFetcherQuery__mdt>{
    //         buildQueryMetadata(
    //             'AccountByType',
    //             'Account By Type',
    //             'Account',
    //             'SELECT Id, Name FROM Account',
    //             'USER'
    //         )
    //     };

    //     try {
    //         H8DataFetcherController.getSObjects('MissingQuery', null);
    //         Assert.fail('Expected an exception when query metadata is missing.');
    //     } catch (AuraHandledException ex) {
    //         Assert.isTrue(ex.getMessage().contains('Unknown Data Fetcher query'));
    //     }
    // }
}
