// Walkthrough 7: Start Batch Apex from anonymous Apex.
// The job runs asynchronously, so this script queues it and prints the job Id.
Id jobId = PersonnelReviewBatch.runNow(50);
System.debug('Personnel review batch job queued: ' + jobId);

// After the batch finishes, query the sample records to see recalculated review
// statuses based on Last_Review_Date__c.
System.debug('After the async job completes, run:');
System.debug('SELECT Employee_Id__c, Review_Status__c FROM Personnel__c WHERE Employee_Id__c LIKE \'SAMPLE-%\'');
