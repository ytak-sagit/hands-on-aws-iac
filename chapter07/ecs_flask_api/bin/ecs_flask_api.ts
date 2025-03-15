#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib';
import { EcsFlaskApiStack } from '../lib/ecs_flask_api-stack';
import { environmentProps, Stages } from '../lib/environments';
import { EcsFlaskApiInfraStack } from '../lib/ecs_flask_api_infra-stack';

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
    account: environment.account,
    region: 'ap-northeast-1',
  },
});
const infraStack = new EcsFlaskApiInfraStack(
  _stage,
  'EcsFlaskApiInfraStack',
  {
    stage,
  },
);
new EcsFlaskApiStack(_stage, 'EcsFlaskApiStack', {
  stage,
  repositoryName: infraStack.repositoryName,
  secretsName: infraStack.secretsName,
});
