/**
 * @description       : Test class for H8DataFetcherFieldSelectorController
 * @author            : daniel@hyphen8.com
 * @last modified on  : 13-04-2026
 * @last modified by  : daniel@hyphen8.com
**/
@isTest
public class H8DataFetcherFieldSelectorControllerTest {
    
    @isTest
	public static void doTest() {
		List<H8DataFetcherFieldSelectorController.Field> fields = H8DataFetcherFieldSelectorController.getObjectFields('User');
		Assert.areNotEqual(fields, null, 'Expected non-null list of fields');
	}
}