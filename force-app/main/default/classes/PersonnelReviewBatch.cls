public with sharing class PersonnelReviewBatch implements Database.Batchable<SObject>, Schedulable {
    public Database.QueryLocator start(Database.BatchableContext context) {
        // start defines the full record set. Salesforce splits it into chunks
        // before calling execute.
        return Database.getQueryLocator([
            SELECT Id, Last_Review_Date__c, Review_Status__c
            FROM Personnel__c
            WHERE Status__c != 'Terminated'
        ]);
    }

    public void execute(Database.BatchableContext context, List<SObject> scope) {
        // execute handles one chunk. Keep it bulk-safe for the same reason
        // triggers must be bulk-safe.
        List<Personnel__c> updates = new List<Personnel__c>();
        Date today = Date.today();

        for (SObject row : scope) {
            Personnel__c person = (Personnel__c) row;
            String nextStatus = calculateReviewStatus(person.Last_Review_Date__c, today);
            if (person.Review_Status__c != nextStatus) {
                updates.add(new Personnel__c(Id = person.Id, Review_Status__c = nextStatus));
            }
        }

        if (!updates.isEmpty()) {
            update updates;
        }
    }

    public void finish(Database.BatchableContext context) {
        // Empty for now. In a real org this might publish a platform event,
        // write an audit record, or notify an admin.
    }

    public void execute(SchedulableContext context) {
        // The same class can be scheduled. The scheduled execution simply starts
        // the batch job with a conservative scope size.
        Database.executeBatch(new PersonnelReviewBatch(), 100);
    }

    public static Id runNow(Integer batchSize) {
        Integer safeBatchSize = batchSize == null || batchSize <= 0 ? 100 : batchSize;
        if (safeBatchSize > 2000) {
            safeBatchSize = 2000;
        }
        return Database.executeBatch(new PersonnelReviewBatch(), safeBatchSize);
    }

    public static String scheduleMonthly() {
        return System.schedule(
            'Monthly Personnel Review Refresh',
            '0 0 3 1 * ?',
            new PersonnelReviewBatch()
        );
    }

    public static String calculateReviewStatus(Date lastReviewDate, Date asOfDate) {
        Date effectiveDate = asOfDate == null ? Date.today() : asOfDate;
        if (lastReviewDate == null) {
            return 'Overdue';
        }

        Integer daysSinceReview = lastReviewDate.daysBetween(effectiveDate);
        if (daysSinceReview >= 365) {
            return 'Overdue';
        }
        if (daysSinceReview >= 300) {
            return 'Due Soon';
        }
        return 'Current';
    }
}
