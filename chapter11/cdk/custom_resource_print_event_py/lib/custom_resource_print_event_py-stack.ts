import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import { readFileSync } from 'node:fs';

export class CustomResourcePrintEventPyStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const code = readFileSync('lambda/print_event/main.py', 'utf-8');

    const func = new lambda.Function(this, 'PrintEventLambda', {
      functionName: 'PrintEventLambda',
      runtime: lambda.Runtime.PYTHON_3_12,
      handler: 'index.handler',
      code: lambda.Code.fromInline(code),
      architecture: lambda.Architecture.ARM_64,
      timeout: cdk.Duration.seconds(10),
      // NOTE: role を指定しない場合は、必要なロールを自動的に補完
    });

    new cdk.CustomResource(this, 'PrintEventCustomResource', {
      serviceToken: func.functionArn,
      serviceTimeout: cdk.Duration.seconds(15),
      properties: {
        Greeting: 'Hello',
      },
    });
  }
}
