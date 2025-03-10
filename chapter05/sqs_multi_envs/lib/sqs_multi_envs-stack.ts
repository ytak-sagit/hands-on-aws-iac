import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as sqs from 'aws-cdk-lib/aws-sqs';

// NOTE: スタックの props を増やしたいときは StackProps を継承したインターフェースを作成する
export interface SqsMultiEnvsStackProps extends cdk.StackProps {
  queueName: string;
}

export class SqsMultiEnvsStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props: SqsMultiEnvsStackProps) {
    super(scope, id, props);

    new sqs.Queue(this, 'SqsMultiEnvsQueue', {
      queueName: props.queueName,
    });
  }
}
