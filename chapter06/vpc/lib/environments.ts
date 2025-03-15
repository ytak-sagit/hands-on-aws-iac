export type Stages = 'dev'; // | 'stg' | 'prod';

export interface Environment {
  awsAccountId: string;
  cidr: string;
  enableNatGateway: boolean;
  oneNatGatewayPerAz: boolean;
}

export const environmentProps: Record<Stages, Environment> = {
  dev: {
    awsAccountId: '123456789012',
    cidr: '10.0.0.0/16',
    enableNatGateway: false,
    oneNatGatewayPerAz: false, // enableNatGateway が true の場合のみ意味を持つ
  },
}