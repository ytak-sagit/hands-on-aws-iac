/* スタック間の参照 - CDK におけるエクスポート */

import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as ec2 from 'aws-cdk-lib/aws-ec2';

// 1. CfnOutput のコンストラクタを使う方法
// -> CloudFormation の Outputs セクションを明示的に CDK のコードに書く

export class VpcStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const vpc = new ec2.Vpc(this, 'VPC');

    // NOTE: ココで Outputs を明示
    new cdk.CfnOutput(this, 'VpcId', {
      value: vpc.vpcId,
      exportName: `${this.stackName}-VPCID`,
    });
  }
}

interface SecurityGroupStackProps extends cdk.StackProps {
  vpcStackName: string;
}

export class SecurityGroupStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props: SecurityGroupStackProps) {
    super(scope, id, props);

    // NOTE: Outputs でエクスポートされた値を他のスタックで参照（インポート）
    const vpcId = cdk.Fn.importValue(`${props.vpcStackName}-VPCID`);
    new ec2.CfnSecurityGroup(this, 'SecurityGroup', {
      groupDescription: 'test security group',
      vpcId,
    });
  }
}
