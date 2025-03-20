import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import * as s3 from 'aws-cdk-lib/aws-s3';

interface LambdaPrintEventPyStackProps extends cdk.StackProps {
  stage: string;
  lambdaZipFileName: string;
}

const lambdaName = "print_event_py";

const getLambdaBucket = (stage: string) => `${stage}-ytak-lambda-deploy-ap-northeast-1`;

export const getSSMParameterName = (stage: string) => `/lambda_zip/${stage}/${lambdaName}`;

export class LambdaPrintEventPyStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props: LambdaPrintEventPyStackProps) {
    super(scope, id, props);

    // アセットが配置された S3 バケットのインスタンスを、静的メソッドで作成
    const bucket = s3.Bucket.fromBucketName(
      this,
      "LambdaPrintEventPyBucket",
      getLambdaBucket(props.stage),
    );

    // Lambda 関数本体
    new lambda.Function(this, "LambdaPrintEventPy", {
      functionName: `${props.stage}-${lambdaName}-cdk`,
      code: lambda.Code.fromBucket(bucket, `${lambdaName}/${props.lambdaZipFileName}.zip`),
      handler: "main.handler",
      runtime: lambda.Runtime.PYTHON_3_12,
      architecture: lambda.Architecture.ARM_64,
      // NOTE: role を指定しない場合は、必要なロールを自動的に補完
    });
  }
}
