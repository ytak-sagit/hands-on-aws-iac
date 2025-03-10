#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib';
import { SqsMultiEnvsStack } from '../lib/sqs_multi_envs-stack';
import { environmentProps, Stages } from '../lib/environments';

const app = new cdk.App();

//----------------------------------------------------------------
// 1. 静的に環境ごとのスタックを定義する場合
for (const stage of Object.keys(environmentProps) as Stages[]) {
  const environment = environmentProps[stage];
  const env: cdk.Environment = {
    account: environment.account,
    region: environment.region,
  };

  new SqsMultiEnvsStack(app, `${stage}-SqsMultiEnvsStack1`, {
    queueName: `${stage}-MyQueue1`,
    env,
  });
  new SqsMultiEnvsStack(app, `${stage}-SqsMultiEnvsStack2`, {
    queueName: `${stage}-MyQueue2`,
    env,
  });
}

//----------------------------------------------------------------
// 2. 動的に環境ごとのスタックを定義する場合
const stage = process.env.STAGE as Stages;
if (!stage) {
  throw new Error('STAGE is not defined');
}

const environment = environmentProps[stage];
if (!environment) {
  throw new Error(`Invalid stage: ${stage}`);
}

const env: cdk.Environment = {
  account: environment.account,
  region: environment.region,
};

new SqsMultiEnvsStack(app, `${stage}-SqsMultiEnvsStackA`, {
  queueName: `${stage}-MyQueueA`,
  env,
});
new SqsMultiEnvsStack(app, `${stage}-SqsMultiEnvsStackB`, {
  queueName: `${stage}-MyQueueB`,
  env,
});

//----------------------------------------------------------------
// 3. Stage コンストラクタを使う場合
// env の定義までは 2. と同じ
const _stage = new cdk.Stage(app, stage, { env });
new SqsMultiEnvsStack(_stage, `SqsMultiEnvsStackX`, {
  queueName: `${stage}-MyQueueX`,
});
new SqsMultiEnvsStack(_stage, `SqsMultiEnvsStackY`, {
  queueName: `${stage}-MyQueueY`,
});
