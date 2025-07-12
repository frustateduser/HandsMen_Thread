// Anonymous Apex script to schedule the Loyalty Points Batch Job
// This script schedules the job to run every Sunday at 12:00 AM

// First, abort any existing scheduled jobs with the same name
List<CronTrigger> existingJobs = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'Weekly Loyalty Points Calculation'];
for (CronTrigger job : existingJobs) {
    System.abortJob(job.Id);
}

// Schedule the new job
// Cron expression: 0 0 0 ? * SUN (Every Sunday at 12:00 AM)
LoyaltyPointsBatchJob loyaltyJob = new LoyaltyPointsBatchJob();
String jobId = System.schedule('Weekly Loyalty Points Calculation', '0 0 0 ? * SUN', loyaltyJob);

System.debug('Loyalty Points Batch Job scheduled with ID: ' + jobId);
System.debug('Job will run every Sunday at 12:00 AM');

// Alternative: If you want to test the job immediately, uncomment the following line:
// Database.executeBatch(new LoyaltyPointsBatchJob(), 200);
