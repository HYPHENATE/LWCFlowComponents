/**
* @description       : Test class for H8DataFetcherController
* @author            : daniel@hyphen8.com
* @last modified on  : 13-04-2026
* @last modified by  : daniel@hyphen8.com
**/
@isTest
public class H8DataFetcherControllerTest {
    
    @IsTest
	static void canQuery() {
	  insert new List<SObject>{ new Account(Name = 'One', Type = 'Customer'), new Account(Name = 'Two', Type = 'Customer') };
  
	  H8DataFetcherController.QueryResult result = H8DataFetcherController.getSObjects(
		'AccountByType',
        '{"type":"Customer"}'
	  );
  
	  Assert.areEqual(2, result.results.size());
	  Assert.areEqual('One', result.firstResult.get(Account.Name));
	}
}
