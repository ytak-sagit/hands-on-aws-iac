import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as ecs from 'aws-cdk-lib/aws-ecs';
import * as ecr from 'aws-cdk-lib/aws-ecr';
import * as ec2 from 'aws-cdk-lib/aws-ec2';
// import * as iam from 'aws-cdk-lib/aws-iam';
import * as logs from 'aws-cdk-lib/aws-logs';
import * as elbv2 from 'aws-cdk-lib/aws-elasticloadbalancingv2';
import * as sm from 'aws-cdk-lib/aws-secretsmanager';

interface EcsFlaskApiStackProps extends cdk.StackProps {
  stage: string;
  repositoryName: string;
  secretsName: string;
}

export class EcsFlaskApiStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props: EcsFlaskApiStackProps) {
    super(scope, id, props);

    /* リソース作成 */

    // 1. 既存のリソースのインスタンス
    const { vpc, secrets, repository } = this.#constructInstancesOfExistingResources(props);

    // 2. ECS クラスタ
    const { cluster } = this.#constructEcsCluster(vpc, props);

    // 3. ECS タスク実行ロール
    // ->
    // ECS サービスのコンストラクタの props に ECS タスク実行ロールを指定しない場合、
    // 自動的に必要なアクションを付与した ECS タスク実行ロールを作成してくれる

    // 4. ECS タスクロール
    // -> ECS タスク実行ロールと同様、自動作成可能
    // NOTE: 必要に応じて、アクションへロールの許可を追加する必要がある
    // （アクションはデプロイするアプリケーションに依存し、CDK の記述から特定できないため）

    // 5. セキュリティグループ
    // -> コンストラクタの props でセキュリティグループを指定しない場合、自動作成してくれる

    // 6. ALB
    const { defaultTargetGroup } = this.#constructAlb(vpc, props);

    // 7. ECS タスク定義
    const { taskDefinition } = this.#constructEcsTaskDefinition(secrets, repository, props);

    // 8. ECS サービス
    this.#constructEcsService(cluster, taskDefinition, defaultTargetGroup);
  }

  #constructInstancesOfExistingResources = (props: EcsFlaskApiStackProps) => {
    // 既存の VPC を参照
    const vpc = ec2.Vpc.fromLookup(this, 'EcsFlaskApiVpc', {
      vpcName: `${props.stage}-vpc-cdk`,
    });

    // 既存のシークレットを参照
    const secrets = sm.Secret.fromSecretNameV2(
      this,
      'EcsFlaskApiSecrets',
      props.secretsName,
    );

    // 既存のリポジトリを参照
    const repository = ecr.Repository.fromRepositoryName(
      this,
      'EcsFlaskApiRepository',
      props.repositoryName,
    );

    return {
      vpc,
      secrets,
      repository,
    };
  };

  #constructEcsCluster = (vpc: cdk.aws_ec2.IVpc, props: EcsFlaskApiStackProps) => {
    const cluster = new ecs.Cluster(this, 'EcsFlaskApiCluster', {
      clusterName: `${props.stage}-flask-api-cdk`,
      enableFargateCapacityProviders: true,
      vpc,
    });
    return {
      cluster,
    };
  };

  #constructAlb = (vpc: cdk.aws_ec2.IVpc, props: EcsFlaskApiStackProps) => {
    // ALB 本体
    const alb = new elbv2.ApplicationLoadBalancer(this, 'EcsFlaskApiAlb', {
      loadBalancerName: `${props.stage}-flask-api-alb-cdk`,
      vpc,
      internetFacing: true,
      // セキュリティグループを自動作成しない場合は、以下をコメントインする
      // securityGroup: albSecurityGroup,
    });

    // ALB のターゲットグループ
    const defaultTargetGroup = new elbv2.ApplicationTargetGroup(
      this,
      'EcsFlaskApiAlbTargetGloup',
      {
        targetGroupName: `${props.stage}-flask-api-cdk`,
        vpc,
        port: 5000,
        // ECS で ALB を使用する場合にはターゲットタイプを IP にする
        targetType: elbv2.TargetType.IP,
        protocol: elbv2.ApplicationProtocol.HTTP,
        healthCheck: {
          enabled: true,
          path: '/health',
          protocol: elbv2.Protocol.HTTP,
          interval: cdk.Duration.seconds(10),
          healthyHttpCodes: "200",
        },
      }
    );

    // ALB に 80 番ポートへの通信を受け付けるリスナーを追加
    alb.addListener('EcsFlaskApiAlbListener', {
      port: 80,
      open: true,
      protocol: elbv2.ApplicationProtocol.HTTP,
      defaultAction: elbv2.ListenerAction.forward([defaultTargetGroup]),
    });

    return {
      defaultTargetGroup,
    };
  };

  #constructEcsTaskDefinition = (
    secrets: cdk.aws_secretsmanager.ISecret,
    repository: cdk.aws_ecr.IRepository,
    props: EcsFlaskApiStackProps,
  ) => {
    // ECS タスク定義（Fargate 向け）
    const taskDefinition = new ecs.FargateTaskDefinition(
      this,
      'EcsFlaskApiTaskDefinition',
      {
        cpu: 256,
        memoryLimitMiB: 512,
        // ECS タスク実行ロールを自動作成しない場合は、以下をコメントインする
        // executionRole,
        // ECS タスクロールを自動作成しない場合は、以下をコメントインする
        // family: `${props.stage}-flask-api-cdk`,
      },
    );

    // ECS タスクのロググループ
    const logGroup = new logs.LogGroup(this, 'EcsFlaskApiLogGroup', {
      logGroupName: `/ecs/${props.stage}-flask-api-cdk`,
      retention: logs.RetentionDays.THREE_DAYS,
      removalPolicy: cdk.RemovalPolicy.DESTROY,
    });

    // タスク定義にコンテナを追加
    taskDefinition.addContainer('EcsFlaskApi', {
      image: ecs.ContainerImage.fromEcrRepository(repository, 'latest'),
      secrets: {
        CORRECT_ANSWER: ecs.Secret.fromSecretsManager(secrets),
      },
      portMappings: [
        {
          containerPort: 5000,
          hostPort: 5000,
        },
      ],
      logging: ecs.LogDrivers.awsLogs({
        streamPrefix: 'flask-api',
        logGroup,
      }),
    });

    return {
      taskDefinition,
    };
  };

  #constructEcsService = (
    cluster: cdk.aws_ecs.ICluster,
    taskDefinition: cdk.aws_ecs.TaskDefinition,
    defaultTargetGroup: cdk.aws_elasticloadbalancingv2.ApplicationTargetGroup,
  ) => {
    const service = new ecs.FargateService(
      this,
      'EcsFlaskApiService',
      {
        serviceName: 'flask-api-cdk',
        cluster,
        taskDefinition,
        // リソースの作成時にタスクが起動しないようにしておく。あとで手動で起動する
        desiredCount: 0,
        // セキュリティグループを自動作成しない場合は、以下をコメントインする
        // securityGroups: [ecsSecurityGroup],
        assignPublicIp: true,
        healthCheckGracePeriod: cdk.Duration.seconds(60),
        // サーキットブレーカーを有効化
        circuitBreaker: {
          enable: true,
          rollback: false,
        },
        // ECS Exec でコンテナに接続できるようにする
        enableExecuteCommand: true,
      },
    );

    // ECS サービスを ALB のターゲットグループに登録する
    service.attachToApplicationTargetGroup(defaultTargetGroup);
  };
}