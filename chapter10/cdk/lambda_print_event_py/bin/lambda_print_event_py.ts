#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib';
import { getSSMParameterName, LambdaPrintEventPyStack } from '../lib/lambda_print_event_py-stack';
import { environmentProps, Stages } from '../lib/environments';
import { getParameterFromSSM } from '../lib/utils';

const stage = process.env.STAGE as Stages;
if (!stage) {
  throw new Error('STAGE is not defined');
}

const environment = environmentProps[stage];
if (!environment) {
  throw new Error(`Invalid stage: ${stage}`);
}

(async () => {
  const app = new cdk.App();
  const _stage = new cdk.Stage(app, stage, {
    env: {
      account: environment.account,
      region: 'ap-northeast-1',
    },
  });

  const lambdaZipFileName = await getParameterFromSSM(
    getSSMParameterName(stage)
  );

  new LambdaPrintEventPyStack(_stage, 'LambdaPrintEventPyStack', {
    stage,
    lambdaZipFileName,
  });
})();
