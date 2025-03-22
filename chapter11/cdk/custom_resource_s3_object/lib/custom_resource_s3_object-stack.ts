import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import * as s3 from 'aws-cdk-lib/aws-s3';
import { readFileSync } from 'node:fs';

export class CustomResourceS3ObjectStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const code = readFileSync('lambda/put_s3_object/main.py', 'utf-8');

    const func = new lambda.Function(this, 'Function', {
      functionName: 'CRPutS3Object',
      runtime: lambda.Runtime.PYTHON_3_12,
      handler: 'index.lambda_handler',
      code: lambda.Code.fromInline(code),
      architecture: lambda.Architecture.ARM_64,
      timeout: cdk.Duration.seconds(15),
      // NOTE: role を指定しない場合は、必要なロールを自動的に補完
    });

    const bucketName = `${cdk.Stack.of(this).account}-test-bucket`;
    const bucket = s3.Bucket.fromBucketName(this, 'Bucket', bucketName);
    bucket.grantRead(func);
    bucket.grantPut(func);
    bucket.grantDelete(func);

    new cdk.CustomResource(this, 'CustomResource', {
      serviceToken: func.functionArn,
      serviceTimeout: cdk.Duration.seconds(30),
      properties: {
        Bucket: bucket.bucketName,
        Key: 'test-key-cdk',
        Body: 'Hello, World!',
      },
    });
  }
}
