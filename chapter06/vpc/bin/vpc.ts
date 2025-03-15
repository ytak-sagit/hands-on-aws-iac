#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib';
import { VpcStack } from '../lib/vpc-stack';
import { Stages, environmentProps } from '../lib/environments';

const stage = process.env.STAGE as Stages;
if (!stage) {
  throw new Error('STAGE is not defined');
}

const environment = environmentProps[stage];
if (!environment) {
  throw new Error(`Invalid stage: ${stage}`);
}

const app = new cdk.App();
const _stage = new cdk.Stage(app, stage, {
  env: {
    account: environment.awsAccountId,
    region: 'ap-northeast-1'
  }
});
new VpcStack(_stage, 'VpcStack', {
  stage,
  cidr: environment.cidr,
  enableNatGateway: environment.enableNatGateway,
  oneNatGatewayPerAz: environment.oneNatGatewayPerAz,
});
