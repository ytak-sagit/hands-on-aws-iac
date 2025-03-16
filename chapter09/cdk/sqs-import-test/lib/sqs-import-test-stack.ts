import * as cdk from 'aws-cdk-lib';
import * as sqs from 'aws-cdk-lib/aws-sqs';

export interface SqsImportTestStackProps extends cdk.StackProps {
}

export class SqsImportTestStack extends cdk.Stack {
  public constructor(scope: cdk.App, id: string, props: SqsImportTestStackProps = {}) {
    super(scope, id, props);

    // Resources
    const sqsQueue00importtest00Qt3Xt = new sqs.CfnQueue(this, 'SQSQueue00importtest00Qt3XT', {
      sqsManagedSseEnabled: true,
      receiveMessageWaitTimeSeconds: 0,
      delaySeconds: 0,
      messageRetentionPeriod: 345600,
      maximumMessageSize: 262144,
      visibilityTimeout: 10,
      queueName: 'import-test',
    });
    sqsQueue00importtest00Qt3Xt.cfnOptions.deletionPolicy = cdk.CfnDeletionPolicy.RETAIN;
  }
}
