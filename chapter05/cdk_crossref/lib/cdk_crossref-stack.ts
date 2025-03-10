/* スタック間の参照 - CDK におけるエクスポート */

import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as ec2 from 'aws-cdk-lib/aws-ec2';

// 2. スタックのクラスのインスタンス変数を用いる方法

export class VpcStack extends cdk.Stack {
  // NOTE: インスタンス変数が CloudFormation の Outputs となる
  readonly vpcId: string;

  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);
    const vpc = new ec2.Vpc(this, 'VPC');
    this.vpcId = vpc.vpcId;
  }
}

interface SecurityGroupStackProps extends cdk.StackProps {
  vpcId: string;
}

export class SecurityGroupStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props: SecurityGroupStackProps) {
    super(scope, id, props);
    new ec2.CfnSecurityGroup(this, 'SecurityGroup', {
      groupDescription: 'test security group',
      vpcId: props.vpcId,
    });
  }
}
