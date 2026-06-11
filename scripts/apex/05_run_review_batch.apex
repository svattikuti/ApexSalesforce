Id jobId = PersonnelReviewBatch.runNow(50);
System.debug('Personnel review batch job queued: ' + jobId);

System.debug('After the async job completes, run:');
System.debug('SELECT Employee_Id__c, Review_Status__c FROM Personnel__c WHERE Employee_Id__c LIKE \'SAMPLE-%\'');
