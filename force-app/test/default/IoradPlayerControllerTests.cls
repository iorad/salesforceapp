@isTest
private class IoradPlayerControllerTests {

    private static SObject generateArticle(String Title, String UrlName, String summary) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        for (Schema.SObjectType item : gd.values()) {
            Schema.DescribeSObjectResult detail = item.getDescribe();
            if (detail != null && detail.getName().endsWith('__kav')) {
                //Creating a new sObject
                sObject sObj = Schema.getGlobalDescribe().get(detail.getName()).newSObject();
                sObj.put('Title' , title);
                sObj.put('UrlName' , urlName);
                sObj.put('Summary' , summary);
                return sObj;
            }
        }

        sObject sObj = new Iorad_Tutorial__c();
        sObj.put('Name' , title);
        sObj.put('UrlName__c' , urlName);
        sObj.put('Summary__c' , summary);
 
        return sObj;
    }

    @isTest static void testConstructor() {
    	SObject article = generateArticle('test 1', 'test-1', '');
        if (article != null) {
            insert article;
        }

    	Test.setCurrentPage(Page.IoradPlayerPage);   	
    	ApexPages.currentPage().getParameters().put('id', article.Id);

    	IoradPlayerController demo = new IoradPlayerController();
    	System.assertEquals(article.Id, ApexPages.currentPage().getParameters().get('id'));
    	System.assertEquals(article.Id, demo.article.get('Id'));
    }

    @isTest static void testIoradLink() {
        String link = 'https://iorad.com/player';
    	SObject article = generateArticle('test 2', 'test-2', '<a href="' + link + '">test link</a>');
        if (article != null) {
            insert article;
        }

        Test.setCurrentPage(Page.IoradPlayerPage);   	
    	ApexPages.currentPage().getParameters().put('id', article.Id);

    	IoradPlayerController demo = new IoradPlayerController();
        System.assertEquals(link, demo.player);
    }

    @isTest static void testGetAppVersion() {
        IoradPlayerController demo = new IoradPlayerController();
        System.assertEquals(demo.getAppVersion(), IoradPlayerController.VERSION);
    }
}