export type Stages = 'dev'; // | 'stg' | 'prod';

interface EnvironmentProps {
  account: string;
}

export const environmentProps: Record<Stages, EnvironmentProps> = {
  dev: {
    account: '123456789012',
  },
}