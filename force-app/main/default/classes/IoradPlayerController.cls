public with sharing class IoradPlayerController {
    
    public static String VERSION = '1.0.0';

    public String player { get; set; }
    public SObject article { get; set; }

    public IoradPlayerController() {
        String id = Apexpages.currentPage().getParameters().get('id');
        if (id != null) {
            this.populateArticle(id);
        }
    }

    private void populateArticle(String id) {
        Schema.DescribeSObjectResult objectType = this.getObjectTypeByKeyPrefixOrId(id);
        if (objectType != null && (objectType.getName().endsWith('__kav') || objectType.getName().endsWith('Iorad_Tutorial__c'))) {
            this.populateArticle(id, objectType);
        }
    }

    private void populateArticle(String id, Schema.DescribeSObjectResult objectType) {
        List<String> availableFields = new List<String>();
        Map<String, Schema.SObjectField> fields = objectType.fields.getMap();
        for (Schema.SObjectField field : fields.values()) {
            Schema.DescribeFieldResult detail = field.getDescribe();
            availableFields.add(detail.getName());
        }

        if (availableFields.size() > 0) {
            String textFields = String.join(availableFields, ', ');
            String query = 'SELECT ' + textFields + ' FROM ' + objectType.getSObjectType() + ' WHERE Id = :id LIMIT 1';
            this.article = Database.query(query);
            if (this.article != null) {
                for (String key : availableFields) {
                    Object objValue = this.article.get(key);
                    String textValue = objValue != null && objValue instanceof String ? objValue.toString() : '';
                    String link = this.getIoradPlayerLink(textValue);
                    if (link != null && link != '') {
                        this.player = link;
                    }
                }
            }
        }
    }

    public String getAppVersion() {
        return IoradPlayerController.VERSION;
    }

    private Schema.DescribeSObjectResult getObjectTypeByKeyPrefixOrId(String keyPrefixOrId) {
        Schema.DescribeSObjectResult result = null;
        String keyPrefix = keyPrefixOrId.substring(0, 3);

        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        for (Schema.SObjectType item : gd.values()) {
            Schema.DescribeSObjectResult detail = item.getDescribe();
            if (detail.getKeyPrefix() == keyPrefix) {
                result = detail;
            }
        }

        return result;
    }

    private String getIoradPlayerLink(String text) {
        String result = null;
        List<String> playerLinks = new List<String>();
        playerLinks.add('http://dev.iorad.local/player');
        playerLinks.add('https://dev.iorad.local/player');
        playerLinks.add('http://test.iorad.com/player');
        playerLinks.add('https://test.iorad.com/player');
        playerLinks.add('http://www.iorad.com/player');
        playerLinks.add('https://www.iorad.com/player');
        playerLinks.add('http://iorad.com/player');
        playerLinks.add('https://iorad.com/player');

        List<String> tags = new List<String>();
        Pattern pattern = Pattern.compile('<a[\\s\\t]+([^>]+)>');
        Matcher matcher = pattern.matcher(text);
        while (matcher.find()) {
            tags.add(matcher.group() + 'link</a>');
        }
        if (tags.size() == 0) {
            return null;
        }

        XmlStreamReader reader = new XmlStreamReader('<div>' + String.join(tags, '') + '</div>');
        while(reader.hasNext()) {
            reader.next();

            if (reader.getEventType() == XmlTag.START_ELEMENT) {
                if (reader.getLocalName() == 'A' || reader.getLocalName() == 'a') {
                    String link = reader.getAttributeValue(null, 'href');
                    if (link != null && link != '') {
                        for (String player : playerLinks) {
                           if (link.startsWith(player)) {
                               result = link;
                           }
                        }
                    }
                }
            }
        }

        return result;
    }
}
